import 'dart:isolate';
import 'dart:typed_data';

import '../../core/audio_object_descriptor.dart';
import '../../core/audio_extraction_fetch_plan.dart';
import '../../core/byte_range.dart';
import '../../core/byte_range_reader.dart';
import '../../core/byte_segment.dart';
import '../../core/extracted_metadata.dart';
import '../../core/extraction_failure.dart';
import '../model/mp3_metadata_plan_result.dart';
import '../model/mp3_metadata_probe_result.dart';
import '../parse/mp3_sparse_tag_reader.dart';
import '../parse/mp3_tag_parser.dart';

class Mp3MetadataService {
  const Mp3MetadataService();

  Future<ExtractedMetadata> extract({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required List<ByteSegment> initialSegments,
  }) async {
    final sparseReader = Mp3SparseTagReader(
      descriptor: descriptor,
      reader: reader,
      initialSegments: initialSegments,
    );
    final headSegment = initialSegments.isEmpty ? null : initialSegments.first;
    final probeResult = headSegment == null
        ? await probe(
            descriptor: descriptor,
            reader: reader,
            initialSegments: initialSegments,
          )
        : await analyzeHead(
            descriptor: descriptor,
            headBytes: headSegment.bytes,
          );
    if (probeResult == null) {
      throw ExtractionFailure(
        'mp3_metadata_unavailable',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }
    final planResult = await plan(
      descriptor: descriptor,
      reader: reader,
      probe: probeResult,
      initialSegments: sparseReader.segments,
    );
    var segments = await fetch(
      reader: reader,
      plan: planResult.primaryPlan,
      initialSegments: sparseReader.segments,
    );
    var parsed = parse(plan: planResult, segments: segments);

    if (_needsId3v1Fallback(parsed) && planResult.optionalId3v1Range != null) {
      final fallbackPlan = AudioExtractionFetchPlan(
        ranges: <ByteRange>[planResult.optionalId3v1Range!],
      );
      segments = await fetch(
        reader: reader,
        plan: fallbackPlan,
        initialSegments: segments,
      );
      final footerSegment = segments.firstWhere(
        (segment) => segment.covers(planResult.optionalId3v1Range!),
      );
      final tailBytes = footerSegment.slice(planResult.optionalId3v1Range!);
      final fallback = Mp3TagParser.parseId3v1(tailBytes);
      if (fallback != null) {
        parsed = parsed == null ? fallback : parsed.merge(fallback);
      }
    }

    if (parsed == null || !parsed.hasAnyMetadata) {
      throw ExtractionFailure(
        'mp3_metadata_unavailable',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }

    return ExtractedMetadata(
      title: parsed.title,
      artist: parsed.artist,
      album: parsed.album,
      albumArtist: parsed.albumArtist,
      genre: parsed.genre,
      year: parsed.year,
      trackNumber: parsed.trackNumber,
      discNumber: parsed.discNumber,
    );
  }

  Future<Mp3MetadataProbeResult?> probe({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required List<ByteSegment> initialSegments,
  }) async {
    final sparseReader = Mp3SparseTagReader(
      descriptor: descriptor,
      reader: reader,
      initialSegments: initialSegments,
    );
    return sparseReader.probeMetadata();
  }

  Future<Mp3MetadataProbeResult?> analyzeHead({
    required AudioObjectDescriptor descriptor,
    required Uint8List headBytes,
  }) async {
    final raw = await Isolate.run<Map<String, Object?>?>(() {
      return _analyzeMp3HeadBytes(headBytes, descriptor.sizeBytes);
    });
    if (raw == null) {
      return null;
    }
    return Mp3MetadataProbeResult(
      header: Mp3Id3Header(
        versionMajor: raw['versionMajor']! as int,
        versionRevision: raw['versionRevision']! as int,
        flags: raw['flags']! as int,
        tagSize: raw['tagSize']! as int,
      ),
      tagEnd: raw['tagEnd']! as int,
      optionalId3v1Range: raw['id3v1Start'] == null
          ? null
          : ByteRange(raw['id3v1Start']! as int, raw['id3v1End']! as int),
    );
  }

  Future<Mp3MetadataPlanResult> plan({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required Mp3MetadataProbeResult probe,
    required List<ByteSegment> initialSegments,
  }) async {
    final sparseReader = Mp3SparseTagReader(
      descriptor: descriptor,
      reader: reader,
      initialSegments: initialSegments,
    );
    return sparseReader.planMetadataWithParser(
      probe,
      parseWindow:
          ({
            required Uint8List bytes,
            required int windowStart,
            required int versionMajor,
            required int tagEnd,
          }) async {
            final raw = await Isolate.run<Map<String, Object?>>(() {
              return _planMp3Window(
                bytes: bytes,
                windowStart: windowStart,
                versionMajor: versionMajor,
                tagEnd: tagEnd,
              );
            });
            return Mp3WindowPlanScanResult(
              frames: ((raw['frames'] as List<Object?>?) ?? const <Object?>[])
                  .cast<Map<Object?, Object?>>()
                  .map(
                    (frame) => Mp3Id3FrameHeader(
                      id: frame['id']! as String,
                      size: frame['size']! as int,
                      flags: frame['flags']! as int,
                      offset: frame['offset']! as int,
                    ),
                  )
                  .toList(growable: false),
              nextOffset: raw['nextOffset']! as int,
              completed: raw['completed']! as bool,
              apicFrameHeader: raw['apicFrame'] == null
                  ? null
                  : Mp3Id3FrameHeader(
                      id:
                          (raw['apicFrame']! as Map<Object?, Object?>)['id']!
                              as String,
                      size:
                          (raw['apicFrame']! as Map<Object?, Object?>)['size']!
                              as int,
                      flags:
                          (raw['apicFrame']! as Map<Object?, Object?>)['flags']!
                              as int,
                      offset:
                          (raw['apicFrame']!
                                  as Map<Object?, Object?>)['offset']!
                              as int,
                    ),
            );
          },
    );
  }

  Future<List<ByteSegment>> fetch({
    required ByteRangeReader reader,
    required AudioExtractionFetchPlan plan,
    required List<ByteSegment> initialSegments,
  }) async {
    final segments = <ByteSegment>[...initialSegments];
    for (final range in plan.ranges) {
      if (segments.any((segment) => segment.covers(range))) {
        continue;
      }
      final bytes = await reader.read(range);
      segments.add(ByteSegment(start: range.start, bytes: bytes));
    }
    return segments;
  }

  Mp3ParsedTagData? parse({
    required Mp3MetadataPlanResult plan,
    required List<ByteSegment> segments,
  }) {
    Mp3ParsedTagData parsed = const Mp3ParsedTagData();
    for (final frame in plan.metadataFrames) {
      final range = ByteRange(frame.dataOffset, frame.endExclusive);
      final segment = segments.firstWhere(
        (candidate) => candidate.covers(range),
        orElse: () => throw StateError('Missing metadata segment for $range'),
      );
      parsed = parsed.merge(
        Mp3TagParser.parseId3Frame(
          frame.id,
          segment.slice(range),
          includeArtwork: false,
        ),
      );
    }
    return parsed.hasAnyMetadata ? parsed : null;
  }

  bool _needsId3v1Fallback(Mp3ParsedTagData? parsed) {
    return parsed == null ||
        parsed.title == null ||
        parsed.artist == null ||
        parsed.album == null ||
        parsed.year == null ||
        parsed.trackNumber == null;
  }
}

Map<String, Object?>? _analyzeMp3HeadBytes(Uint8List headBytes, int? fileSize) {
  final header = Mp3TagParser.parseId3Header(headBytes);
  if (header == null) {
    return null;
  }
  final tagEnd = fileSize == null
      ? header.totalSize
      : (fileSize < header.totalSize ? fileSize : header.totalSize);
  final id3v1Start =
      fileSize == null || fileSize < Mp3TagParser.id3v1FooterLength
      ? null
      : fileSize - Mp3TagParser.id3v1FooterLength;
  return <String, Object?>{
    'versionMajor': header.versionMajor,
    'versionRevision': header.versionRevision,
    'flags': header.flags,
    'tagSize': header.tagSize,
    'tagEnd': tagEnd,
    'id3v1Start': id3v1Start,
    'id3v1End': id3v1Start == null ? null : fileSize,
  };
}

Map<String, Object?> _planMp3Window({
  required Uint8List bytes,
  required int windowStart,
  required int versionMajor,
  required int tagEnd,
}) {
  final frames = <Map<String, Object?>>[];
  Map<String, Object?>? apicFrame;
  var localOffset = 0;
  var nextOffset = windowStart;
  var completed = false;

  while (localOffset + Mp3TagParser.id3FrameHeaderLength <= bytes.length) {
    final absoluteOffset = windowStart + localOffset;
    final frameHeader = Mp3TagParser.parseId3FrameHeader(
      bytes.sublist(
        localOffset,
        localOffset + Mp3TagParser.id3FrameHeaderLength,
      ),
      versionMajor: versionMajor,
      offset: absoluteOffset,
    );
    if (frameHeader == null || frameHeader.isPadding) {
      completed = true;
      nextOffset = absoluteOffset;
      break;
    }
    if (frameHeader.endExclusive > tagEnd) {
      completed = true;
      nextOffset = absoluteOffset;
      break;
    }
    if (Mp3TagParser.metadataFrameIds.contains(frameHeader.id)) {
      frames.add(<String, Object?>{
        'id': frameHeader.id,
        'size': frameHeader.size,
        'flags': frameHeader.flags,
        'offset': frameHeader.offset,
      });
    } else if (frameHeader.id == 'APIC' && apicFrame == null) {
      apicFrame = <String, Object?>{
        'id': frameHeader.id,
        'size': frameHeader.size,
        'flags': frameHeader.flags,
        'offset': frameHeader.offset,
      };
    }
    nextOffset = frameHeader.endExclusive;
    if (nextOffset >= windowStart + bytes.length) {
      break;
    }
    localOffset = nextOffset - windowStart;
  }

  return <String, Object?>{
    'frames': frames,
    'nextOffset': nextOffset,
    'completed': completed,
    'apicFrame': apicFrame,
  };
}

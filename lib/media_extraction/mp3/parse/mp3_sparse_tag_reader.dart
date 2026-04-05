import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import '../../core/audio_object_descriptor.dart';
import '../../core/byte_range.dart';
import '../../core/byte_range_reader.dart';
import '../../core/byte_segment.dart';
import '../../core/extraction_failure.dart';
import '../model/mp3_artwork_probe_result.dart';
import '../model/mp3_metadata_plan_result.dart';
import '../model/mp3_metadata_probe_result.dart';
import 'mp3_tag_parser.dart';

class Mp3SparseTagReader {
  static const int metadataInitialScanWindowBytes = 512;
  static const int maxMetadataScanBytes = 128 * 1024;
  static const int maxMetadataScanSteps = 7;
  static const int maxApicHeaderProbeBytes = 4 * 1024;

  Mp3SparseTagReader({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    Iterable<ByteSegment> initialSegments = const <ByteSegment>[],
  }) : _descriptor = descriptor,
       _reader = reader,
       _segments = <ByteSegment>[...initialSegments];

  final AudioObjectDescriptor _descriptor;
  final ByteRangeReader _reader;
  final List<ByteSegment> _segments;

  List<ByteSegment> get segments => List<ByteSegment>.unmodifiable(_segments);

  Future<Mp3MetadataProbeResult?> probeMetadata() async {
    final header = await _readId3Header();
    if (header == null) {
      return null;
    }

    return Mp3MetadataProbeResult(
      header: header,
      tagEnd: _resolveTagEnd(header),
      optionalId3v1Range: _id3v1FooterRange(),
    );
  }

  Future<Mp3MetadataPlanResult> planMetadata(
    Mp3MetadataProbeResult probe, {
    int scanWindowBytes = metadataInitialScanWindowBytes,
  }) async {
    return planMetadataWithParser(
      probe,
      scanWindowBytes: scanWindowBytes,
      parseWindow:
          ({
            required Uint8List bytes,
            required int windowStart,
            required int versionMajor,
            required int tagEnd,
          }) async {
            return _scanMetadataWindow(
              bytes: bytes,
              windowStart: windowStart,
              versionMajor: versionMajor,
              tagEnd: tagEnd,
            );
          },
    );
  }

  Future<Mp3MetadataPlanResult> planMetadataWithParser(
    Mp3MetadataProbeResult probe, {
    int scanWindowBytes = metadataInitialScanWindowBytes,
    required Future<Mp3WindowPlanScanResult> Function({
      required Uint8List bytes,
      required int windowStart,
      required int versionMajor,
      required int tagEnd,
    })
    parseWindow,
  }) async {
    var offset = probe.header.frameDataOffset;
    var currentWindowBytes = scanWindowBytes;
    var scannedBytes = 0;
    var scanSteps = 0;
    final frames = <Mp3Id3FrameHeader>[];
    Mp3ArtworkLocator? artworkLocator;
    final tagEnd = probe.tagEnd;

    while (offset + Mp3TagParser.id3FrameHeaderLength <= tagEnd) {
      if (scanSteps >= maxMetadataScanSteps ||
          scannedBytes >= maxMetadataScanBytes) {
        throw ExtractionFailure(
          'mp3_metadata_unavailable',
          fileName: _descriptor.fileName,
          mimeType: _descriptor.mimeType,
          details: <String, Object?>{
            'scanSteps': scanSteps,
            'scannedBytes': scannedBytes,
            'maxScanSteps': maxMetadataScanSteps,
            'maxScanBytes': maxMetadataScanBytes,
          },
        );
      }
      final stepWindow = math.min(
        math.max(1, currentWindowBytes),
        maxMetadataScanBytes - scannedBytes,
      );
      final windowEnd = math.min(tagEnd, offset + stepWindow);
      final windowRange = ByteRange(offset, windowEnd);
      final windowBytes = await _readRequiredRange(windowRange);
      final result = await parseWindow(
        bytes: windowBytes,
        windowStart: offset,
        versionMajor: probe.header.versionMajor,
        tagEnd: tagEnd,
      );
      scannedBytes += windowRange.length;
      scanSteps += 1;
      frames.addAll(result.frames);
      if (artworkLocator == null && result.apicFrameHeader != null) {
        artworkLocator = await _probeApicLocator(
          frame: result.apicFrameHeader!,
          maxProbeBytes: maxApicHeaderProbeBytes,
        );
      }
      if (_hasMinimumMetadataFrames(frames)) {
        return Mp3MetadataPlanResult(
          metadataFrames: frames,
          optionalId3v1Range: probe.optionalId3v1Range,
          artworkLocator: artworkLocator,
        );
      }
      offset = result.nextOffset;
      if (result.completed || offset <= windowRange.start) {
        return Mp3MetadataPlanResult(
          metadataFrames: frames,
          optionalId3v1Range: probe.optionalId3v1Range,
          artworkLocator: artworkLocator,
        );
      }
      currentWindowBytes = math.min(
        currentWindowBytes * 2,
        maxMetadataScanBytes,
      );
    }

    return Mp3MetadataPlanResult(
      metadataFrames: frames,
      optionalId3v1Range: probe.optionalId3v1Range,
      artworkLocator: artworkLocator,
    );
  }

  static Mp3WindowPlanScanResult _scanMetadataWindow({
    required Uint8List bytes,
    required int windowStart,
    required int versionMajor,
    required int tagEnd,
  }) {
    final frames = <Mp3Id3FrameHeader>[];
    var localOffset = 0;
    var nextOffset = windowStart;
    var completed = false;
    Mp3Id3FrameHeader? apicFrameHeader;

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
        frames.add(frameHeader);
      } else if (frameHeader.id == 'APIC' && apicFrameHeader == null) {
        apicFrameHeader = frameHeader;
      }
      nextOffset = frameHeader.endExclusive;
      if (nextOffset >= windowStart + bytes.length) {
        break;
      }
      localOffset = nextOffset - windowStart;
    }

    return Mp3WindowPlanScanResult(
      frames: frames,
      nextOffset: nextOffset,
      completed: completed,
      apicFrameHeader: apicFrameHeader,
    );
  }

  Future<Mp3ArtworkProbeResult?> probeArtwork() async {
    final header = await _readId3Header();
    if (header == null) {
      return null;
    }

    final tagEnd = _resolveTagEnd(header);
    var offset = header.frameDataOffset;

    while (offset + Mp3TagParser.id3FrameHeaderLength <= tagEnd) {
      final headerBytes = await _readRequiredRange(
        ByteRange(offset, offset + Mp3TagParser.id3FrameHeaderLength),
      );
      final frameHeader = Mp3TagParser.parseId3FrameHeader(
        headerBytes,
        versionMajor: header.versionMajor,
        offset: offset,
      );
      if (frameHeader == null || frameHeader.isPadding) {
        break;
      }
      if (frameHeader.endExclusive > tagEnd) {
        break;
      }

      if (frameHeader.id == 'APIC') {
        final locator = await _probeApicLocator(
          frame: frameHeader,
          maxProbeBytes: maxApicHeaderProbeBytes,
        );
        return Mp3ArtworkProbeResult(apicFrame: frameHeader, locator: locator);
      }
      offset = frameHeader.endExclusive;
    }

    return null;
  }

  Future<Mp3ParsedTagData?> readMetadata() async {
    final header = await _readId3Header();
    if (header == null) {
      return null;
    }

    final tagEnd = _resolveTagEnd(header);
    var offset = header.frameDataOffset;
    Mp3ParsedTagData parsed = const Mp3ParsedTagData();

    while (offset + Mp3TagParser.id3FrameHeaderLength <= tagEnd) {
      final headerBytes = await _readRequiredRange(
        ByteRange(offset, offset + Mp3TagParser.id3FrameHeaderLength),
      );
      final frameHeader = Mp3TagParser.parseId3FrameHeader(
        headerBytes,
        versionMajor: header.versionMajor,
        offset: offset,
      );
      if (frameHeader == null || frameHeader.isPadding) {
        break;
      }
      if (frameHeader.endExclusive > tagEnd) {
        break;
      }

      if (Mp3TagParser.metadataFrameIds.contains(frameHeader.id)) {
        final frameData = await _readRequiredRange(
          ByteRange(frameHeader.dataOffset, frameHeader.endExclusive),
        );
        parsed = parsed.merge(
          Mp3TagParser.parseId3Frame(
            frameHeader.id,
            frameData,
            includeArtwork: false,
          ),
        );
        if (_hasAllDesiredMetadata(parsed)) {
          break;
        }
      }
      offset = frameHeader.endExclusive;
    }

    return parsed.hasAnyMetadata ? parsed : null;
  }

  Future<Mp3ParsedTagData?> readArtwork() async {
    final header = await _readId3Header();
    if (header == null) {
      return null;
    }

    final tagEnd = _resolveTagEnd(header);
    var offset = header.frameDataOffset;

    while (offset + Mp3TagParser.id3FrameHeaderLength <= tagEnd) {
      final headerBytes = await _readRequiredRange(
        ByteRange(offset, offset + Mp3TagParser.id3FrameHeaderLength),
      );
      final frameHeader = Mp3TagParser.parseId3FrameHeader(
        headerBytes,
        versionMajor: header.versionMajor,
        offset: offset,
      );
      if (frameHeader == null || frameHeader.isPadding) {
        break;
      }
      if (frameHeader.endExclusive > tagEnd) {
        break;
      }

      if (frameHeader.id == 'APIC') {
        final frameData = await _readRequiredRange(
          ByteRange(frameHeader.dataOffset, frameHeader.endExclusive),
        );
        final parsed = Mp3TagParser.parseApicFrame(frameData);
        return parsed.artworkBytes == null || parsed.artworkBytes!.isEmpty
            ? null
            : parsed;
      }
      offset = frameHeader.endExclusive;
    }

    return null;
  }

  Future<Uint8List?> readId3v1Footer() async {
    final range = _id3v1FooterRange();
    if (range == null) {
      return null;
    }
    return _readRequiredRange(range);
  }

  Future<Mp3Id3Header?> _readId3Header() async {
    final headerRange = _boundedRange(0, Mp3TagParser.id3HeaderLength);
    if (headerRange == null) {
      throw ExtractionFailure(
        'mp3_head_segment_missing',
        fileName: _descriptor.fileName,
        mimeType: _descriptor.mimeType,
      );
    }
    final headerBytes = await _readRequiredRange(headerRange);
    if (headerBytes.isEmpty) {
      throw ExtractionFailure(
        'mp3_head_segment_missing',
        fileName: _descriptor.fileName,
        mimeType: _descriptor.mimeType,
      );
    }
    if (headerBytes.length < Mp3TagParser.id3HeaderLength) {
      return null;
    }
    return Mp3TagParser.parseId3Header(headerBytes);
  }

  Future<Uint8List> _readRequiredRange(ByteRange range) async {
    for (final segment in _segments) {
      if (segment.covers(range)) {
        return segment.slice(range);
      }
    }

    final bytes = await _reader.read(range);
    _segments.add(ByteSegment(start: range.start, bytes: bytes));
    return bytes;
  }

  ByteRange? _boundedRange(int start, int endExclusive) {
    final sizeBytes = _descriptor.sizeBytes;
    if (sizeBytes != null) {
      if (start >= sizeBytes) {
        return null;
      }
      return ByteRange(start, math.min(sizeBytes, endExclusive));
    }
    return ByteRange(start, endExclusive);
  }

  int _resolveTagEnd(Mp3Id3Header header) {
    final sizeBytes = _descriptor.sizeBytes;
    if (sizeBytes == null) {
      return header.totalSize;
    }
    return math.min(sizeBytes, header.totalSize);
  }

  ByteRange? _id3v1FooterRange() {
    final sizeBytes = _descriptor.sizeBytes;
    if (sizeBytes == null || sizeBytes < Mp3TagParser.id3v1FooterLength) {
      return null;
    }
    return ByteRange(sizeBytes - Mp3TagParser.id3v1FooterLength, sizeBytes);
  }

  bool _hasAllDesiredMetadata(Mp3ParsedTagData parsed) {
    return parsed.title != null &&
        parsed.artist != null &&
        parsed.album != null &&
        parsed.albumArtist != null &&
        parsed.genre != null &&
        parsed.year != null &&
        parsed.trackNumber != null &&
        parsed.discNumber != null;
  }

  bool _hasMinimumMetadataFrames(List<Mp3Id3FrameHeader> frames) {
    final ids = frames.map((frame) => frame.id).toSet();
    return ids.contains('TIT2') && ids.contains('TPE1') && ids.contains('TALB');
  }

  Future<Mp3ArtworkLocator> _probeApicLocator({
    required Mp3Id3FrameHeader frame,
    required int maxProbeBytes,
  }) async {
    final probeEnd = math.min(
      frame.endExclusive,
      frame.dataOffset + maxProbeBytes,
    );
    final probeBytes = await _readRequiredRange(
      ByteRange(frame.dataOffset, probeEnd),
    );
    if (probeBytes.isEmpty) {
      throw ExtractionFailure(
        'mp3_apic_locator_unavailable',
        fileName: _descriptor.fileName,
        mimeType: _descriptor.mimeType,
      );
    }
    final encoding = probeBytes[0];
    var cursor = 1;
    while (cursor < probeBytes.length && probeBytes[cursor] != 0) {
      cursor += 1;
    }
    if (cursor >= probeBytes.length) {
      throw ExtractionFailure(
        'mp3_apic_locator_unavailable',
        fileName: _descriptor.fileName,
        mimeType: _descriptor.mimeType,
      );
    }
    final mime = ascii.decode(
      probeBytes.sublist(1, cursor),
      allowInvalid: true,
    );
    cursor += 1;
    if (cursor >= probeBytes.length) {
      throw ExtractionFailure(
        'mp3_apic_locator_unavailable',
        fileName: _descriptor.fileName,
        mimeType: _descriptor.mimeType,
      );
    }
    final pictureType = probeBytes[cursor];
    cursor += 1;
    cursor = _skipDescription(probeBytes, cursor, encoding);
    final absoluteDataOffset = frame.dataOffset + cursor;
    final dataLength = frame.endExclusive - absoluteDataOffset;
    if (dataLength <= 0) {
      throw ExtractionFailure(
        'mp3_apic_locator_unavailable',
        fileName: _descriptor.fileName,
        mimeType: _descriptor.mimeType,
      );
    }
    return Mp3ArtworkLocator(
      mimeType: mime.isEmpty ? 'image/jpeg' : mime,
      pictureType: pictureType,
      dataOffset: absoluteDataOffset,
      dataLength: dataLength,
    );
  }

  int _skipDescription(Uint8List bytes, int cursor, int encoding) {
    if (encoding == 0 || encoding == 3) {
      while (cursor < bytes.length && bytes[cursor] != 0) {
        cursor += 1;
      }
      return cursor < bytes.length ? cursor + 1 : bytes.length;
    }
    while (cursor + 1 < bytes.length) {
      if (bytes[cursor] == 0 && bytes[cursor + 1] == 0) {
        return cursor + 2;
      }
      cursor += 2;
    }
    return bytes.length;
  }
}

class Mp3WindowPlanScanResult {
  const Mp3WindowPlanScanResult({
    required this.frames,
    required this.nextOffset,
    required this.completed,
    this.apicFrameHeader,
  });

  final List<Mp3Id3FrameHeader> frames;
  final int nextOffset;
  final bool completed;
  final Mp3Id3FrameHeader? apicFrameHeader;
}

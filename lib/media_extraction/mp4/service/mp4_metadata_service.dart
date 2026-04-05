import 'dart:typed_data';

import '../../core/audio_object_descriptor.dart';
import '../../core/audio_extraction_fetch_plan.dart';
import '../../core/byte_range_reader.dart';
import '../../core/byte_segment.dart';
import '../../core/extraction_failure.dart';
import '../../core/extracted_metadata.dart';
import '../layout/mp4_inner_layout_resolver.dart';
import '../model/mp4_box_header.dart';
import '../model/mp4_metadata_plan_result.dart';
import '../model/mp4_metadata_probe_result.dart';
import '../model/mp4_probe_goal.dart';
import '../parse/mp4_sparse_metadata_parser.dart';
import '../plan/mp4_metadata_fetch_plan.dart';
import '../top_level/mp4_top_level_scanner.dart';

class Mp4MetadataService {
  const Mp4MetadataService();

  static const int fixedHeaderWindowBytes = 8 * 1024;

  Future<ExtractedMetadata> extract({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required List<ByteSegment> initialSegments,
  }) async {
    final probe = await this.probe(
      descriptor: descriptor,
      reader: reader,
      initialSegments: initialSegments,
    );
    final planResult = await plan(
      descriptor: descriptor,
      reader: reader,
      probe: probe,
      initialSegments: probe.probeSegments,
    );
    final segments = await fetch(
      reader: reader,
      plan: planResult.plan,
      initialSegments: planResult.probeSegments,
    );
    final parsed = parse(plan: planResult, segments: segments);
    if (parsed == null || !parsed.hasAnyData) {
      throw ExtractionFailure(
        'mp4_sparse_parse_failed',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }
    return parsed;
  }

  Future<Mp4MetadataProbeResult> probe({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required List<ByteSegment> initialSegments,
  }) async {
    if (initialSegments.isEmpty) {
      throw ExtractionFailure(
        'mp4_head_segment_missing',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }
    final headSegment = initialSegments.firstWhere(
      (segment) => segment.start == 0,
      orElse: () => initialSegments.first,
    );
    final moovBox = await Mp4TopLevelScanner.findMoovBox(
      descriptor: descriptor,
      headBytes: headSegment.bytes,
      reader: reader,
    );
    return Mp4MetadataProbeResult(
      moovBox: moovBox,
      probeSegments: <ByteSegment>[...initialSegments],
    );
  }

  Future<Mp4MetadataProbeResult?> analyzeHead({
    required AudioObjectDescriptor descriptor,
    required List<ByteSegment> initialSegments,
  }) async {
    if (initialSegments.isEmpty) {
      throw ExtractionFailure(
        'mp4_head_segment_missing',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }
    final headBytes = _buildContiguousHeadBytes(initialSegments);
    if (headBytes.length < 8) {
      return null;
    }
    final fileSize = descriptor.sizeBytes!;
    var offset = 0;
    while (offset + 8 <= headBytes.length) {
      final headerBytes = headBytes.sublist(
        offset,
        offset + Mp4TopLevelScanner.topLevelHeaderBytesLength <=
                headBytes.length
            ? offset + Mp4TopLevelScanner.topLevelHeaderBytesLength
            : headBytes.length,
      );
      final header = _readHeader(
        headerBytes: headerBytes,
        fileOffset: offset,
        fileSize: fileSize,
      );
      if (header == null) {
        return null;
      }
      if (header.type == 'moov') {
        return Mp4MetadataProbeResult(
          moovBox: header.toBox(fileOffset: offset),
          probeSegments: initialSegments,
        );
      }
      final boxEnd = header.endFrom(offset);
      if (boxEnd <= offset) {
        throw ExtractionFailure(
          'mp4_invalid_top_level_box',
          fileName: descriptor.fileName,
          mimeType: descriptor.mimeType,
          details: <String, Object?>{
            'scanOffset': offset,
            'boxType': header.type,
            'boxSize': header.size,
          },
        );
      }
      if (boxEnd > headBytes.length) {
        return null;
      }
      offset = boxEnd;
    }
    return null;
  }

  Future<Mp4MetadataPlanResult> plan({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required Mp4MetadataProbeResult probe,
    required List<ByteSegment> initialSegments,
  }) async {
    final layout = await Mp4InnerLayoutResolver.resolve(
      descriptor: descriptor,
      moovBox: probe.moovBox,
      reader: reader,
      goal: Mp4ProbeGoal.metadata,
      moovScanWindowBytes: null,
    );
    return Mp4MetadataPlanResult(
      layout: layout,
      fetchPlan: Mp4MetadataFetchPlan.fromLayout(layout),
      probeSegments: <ByteSegment>[...initialSegments],
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

  ExtractedMetadata? parse({
    required Mp4MetadataPlanResult plan,
    required List<ByteSegment> segments,
  }) {
    return Mp4SparseMetadataParser.parse(
      layout: plan.layout,
      segments: segments,
    );
  }

  static Uint8List _buildContiguousHeadBytes(List<ByteSegment> segments) {
    final sorted = [...segments]
      ..sort((left, right) => left.start - right.start);
    final builder = BytesBuilder(copy: false);
    var expectedStart = 0;
    for (final segment in sorted) {
      if (segment.start != expectedStart) {
        break;
      }
      builder.add(segment.bytes);
      expectedStart = segment.endExclusive;
      if (expectedStart >= fixedHeaderWindowBytes) {
        break;
      }
    }
    final bytes = builder.takeBytes();
    if (bytes.isEmpty) {
      final first = sorted.isEmpty ? null : sorted.first;
      return first?.bytes ?? Uint8List(0);
    }
    return bytes;
  }

  static _TopLevelHeader? _readHeader({
    required Uint8List headerBytes,
    required int fileOffset,
    required int fileSize,
  }) {
    if (headerBytes.length < 8) {
      return null;
    }
    final data = ByteData.sublistView(headerBytes);
    final size32 = data.getUint32(0, Endian.big);
    final type = String.fromCharCodes(headerBytes.sublist(4, 8));
    if (size32 == 0) {
      if (fileOffset >= fileSize) {
        return null;
      }
      return _TopLevelHeader(
        type: type,
        size: fileSize - fileOffset,
        headerSize: 8,
        extendsToEof: true,
      );
    }
    if (size32 == 1) {
      if (headerBytes.length < 16) {
        return null;
      }
      final ext = ByteData.sublistView(
        headerBytes,
        8,
        16,
      ).getUint64(0, Endian.big);
      if (ext < 16 || fileOffset + ext > fileSize) {
        return null;
      }
      return _TopLevelHeader(type: type, size: ext, headerSize: 16);
    }
    if (size32 < 8 || fileOffset + size32 > fileSize) {
      return null;
    }
    return _TopLevelHeader(type: type, size: size32, headerSize: 8);
  }
}

class _TopLevelHeader {
  const _TopLevelHeader({
    required this.type,
    required this.size,
    this.headerSize = 8,
    this.extendsToEof = false,
  });

  final String type;
  final int size;
  final int headerSize;
  final bool extendsToEof;

  int endFrom(int offset) => offset + size;

  Mp4BoxHeader toBox({required int fileOffset}) => Mp4BoxHeader(
    offset: fileOffset,
    size: size,
    headerSize: headerSize,
    type: type,
    usesExtendedSize: headerSize == 16,
    extendsToEof: extendsToEof,
  );
}

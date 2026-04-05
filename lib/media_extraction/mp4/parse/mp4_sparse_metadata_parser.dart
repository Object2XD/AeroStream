import 'dart:typed_data';

import '../../core/byte_range.dart';
import '../../core/byte_segment.dart';
import '../../core/extracted_metadata.dart';
import '../model/mp4_box_header.dart';
import '../model/mp4_layout.dart';
import 'mp4_sparse_item_parser.dart';

class Mp4SparseMetadataParser {
  const Mp4SparseMetadataParser._();

  static ExtractedMetadata? parse({
    required Mp4Layout layout,
    required List<ByteSegment> segments,
  }) {
    var result = const ExtractedMetadata();

    final mvhdBox = layout.mvhdBox;
    if (mvhdBox != null) {
      final mvhdBytes = _sliceBox(segments, mvhdBox);
      if (mvhdBytes != null) {
        final durationMs = _parseMvhdDuration(mvhdBytes);
        if (durationMs != null) {
          result = result.merge(ExtractedMetadata(durationMs: durationMs));
        }
      }
    }

    for (final itemBox in layout.metadataItemBoxes) {
      final itemBytes = _sliceBox(segments, itemBox);
      if (itemBytes == null) {
        continue;
      }
      result = result.merge(
        Mp4SparseItemParser.parseItem(
          itemBytes,
          includeArtwork: false,
        ).metadata,
      );
    }

    return result.hasAnyData ? result : null;
  }

  static Uint8List? _sliceBox(List<ByteSegment> segments, Mp4BoxHeader box) {
    final range = ByteRange(box.offset, box.end);
    for (final segment in segments) {
      if (segment.covers(range)) {
        return segment.slice(range);
      }
    }
    return null;
  }

  static int? _parseMvhdDuration(Uint8List mvhdBytes) {
    if (mvhdBytes.length < 8) {
      return null;
    }
    final version = mvhdBytes[8];
    if (version == 1) {
      if (mvhdBytes.length < 40) {
        return null;
      }
      final timescale = ByteData.sublistView(
        mvhdBytes,
        28,
        32,
      ).getUint32(0, Endian.big);
      final high = ByteData.sublistView(
        mvhdBytes,
        32,
        36,
      ).getUint32(0, Endian.big);
      final low = ByteData.sublistView(
        mvhdBytes,
        36,
        40,
      ).getUint32(0, Endian.big);
      final duration = (high << 32) | low;
      if (timescale == 0) {
        return null;
      }
      return (duration * 1000 / timescale).round();
    }
    if (mvhdBytes.length < 28) {
      return null;
    }
    final timescale = ByteData.sublistView(
      mvhdBytes,
      20,
      24,
    ).getUint32(0, Endian.big);
    final duration = ByteData.sublistView(
      mvhdBytes,
      24,
      28,
    ).getUint32(0, Endian.big);
    if (timescale == 0) {
      return null;
    }
    return (duration * 1000 / timescale).round();
  }
}

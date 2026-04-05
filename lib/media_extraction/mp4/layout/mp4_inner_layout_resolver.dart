import 'dart:math' as math;

import '../../core/audio_object_descriptor.dart';
import '../../core/byte_range.dart';
import '../../core/byte_range_reader.dart';
import '../../core/extraction_failure.dart';
import '../box_header/mp4_box_header_reader.dart';
import '../model/mp4_box_header.dart';
import '../model/mp4_layout.dart';
import '../model/mp4_probe_goal.dart';

class Mp4InnerLayoutResolver {
  const Mp4InnerLayoutResolver._();

  static const innerHeaderBytesLength = 16;
  static const moovChildScanMaxBoxes = 1024;
  static const metaChildScanMaxBoxes = 512;
  static const ilstItemScanMaxBoxes = 4096;

  static Future<Mp4Layout> resolve({
    required AudioObjectDescriptor descriptor,
    required Mp4BoxHeader moovBox,
    required ByteRangeReader reader,
    required Mp4ProbeGoal goal,
    int? moovScanWindowBytes,
  }) async {
    final moovScanEnd = _resolveMoovScanEnd(
      moovBox: moovBox,
      fileSize: descriptor.sizeBytes!,
      moovScanWindowBytes: moovScanWindowBytes,
    );
    Mp4BoxHeader? mvhdBox;
    Mp4BoxHeader? metaBox;

    var scanOffset = moovBox.dataOffset;
    var stepCount = 0;
    while (scanOffset + 8 <= moovScanEnd) {
      if (stepCount >= moovChildScanMaxBoxes) {
        throw ExtractionFailure(
          'mp4_moov_child_scan_limit_exceeded',
          fileName: descriptor.fileName,
          mimeType: descriptor.mimeType,
          details: <String, Object?>{'scanOffset': scanOffset},
        );
      }
      final child = await _readInnerHeaderAt(
        descriptor: descriptor,
        reader: reader,
        offset: scanOffset,
        fileSize: descriptor.sizeBytes!,
        containerEnd: moovBox.end,
      );
      if (child == null) {
        break;
      }
      stepCount += 1;

      if (child.type == 'mvhd' && mvhdBox == null) {
        mvhdBox = child;
      }
      if (child.type == 'meta' && metaBox == null) {
        metaBox = child;
      } else if (child.type == 'udta' && metaBox == null) {
        metaBox = await _findChildType(
          descriptor: descriptor,
          reader: reader,
          start: child.dataOffset,
          end: math.min(child.end, moovScanEnd),
          containerEnd: child.end,
          childType: 'meta',
          fileSize: descriptor.sizeBytes!,
          maxBoxes: metaChildScanMaxBoxes,
        );
      }

      scanOffset = child.end;
      if (metaBox != null && mvhdBox != null && goal == Mp4ProbeGoal.artwork) {
        break;
      }
    }

    if (metaBox == null) {
      throw ExtractionFailure(
        'mp4_meta_not_found',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }

    final ilstBox = await _findChildType(
      descriptor: descriptor,
      reader: reader,
      start: metaBox.dataOffset + 4,
      end: math.min(metaBox.end, moovScanEnd),
      containerEnd: metaBox.end,
      childType: 'ilst',
      fileSize: descriptor.sizeBytes!,
      maxBoxes: metaChildScanMaxBoxes,
    );
    if (ilstBox == null) {
      throw ExtractionFailure(
        'mp4_ilst_not_found',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }

    final metadataItems = <Mp4BoxHeader>[];
    Mp4BoxHeader? covrBox;
    scanOffset = ilstBox.dataOffset;
    stepCount = 0;
    final ilstScanEnd = math.min(ilstBox.end, moovScanEnd);
    while (scanOffset + 8 <= ilstScanEnd) {
      if (stepCount >= ilstItemScanMaxBoxes) {
        throw ExtractionFailure(
          'mp4_ilst_item_scan_limit_exceeded',
          fileName: descriptor.fileName,
          mimeType: descriptor.mimeType,
          details: <String, Object?>{'scanOffset': scanOffset},
        );
      }
      final item = await _readInnerHeaderAt(
        descriptor: descriptor,
        reader: reader,
        offset: scanOffset,
        fileSize: descriptor.sizeBytes!,
        containerEnd: ilstBox.end,
      );
      if (item == null) {
        break;
      }
      stepCount += 1;

      if (desiredMp4MetadataItemTypes.contains(item.type)) {
        metadataItems.add(item);
      } else if (item.type == 'covr') {
        covrBox = item;
        if (goal == Mp4ProbeGoal.artwork) {
          break;
        }
      }

      scanOffset = item.end;
    }

    final layout = Mp4Layout(
      moovBox: moovBox,
      mvhdBox: mvhdBox,
      metaBox: metaBox,
      ilstBox: ilstBox,
      metadataItemBoxes: metadataItems,
      covrBox: covrBox,
    );
    if (goal == Mp4ProbeGoal.metadata && !layout.hasUsefulMetadata) {
      throw ExtractionFailure(
        'mp4_metadata_items_unresolved',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }
    return layout;
  }

  static int _resolveMoovScanEnd({
    required Mp4BoxHeader moovBox,
    required int fileSize,
    required int? moovScanWindowBytes,
  }) {
    if (moovScanWindowBytes == null || moovScanWindowBytes <= 0) {
      return moovBox.end;
    }
    final cappedEnd = moovBox.offset + moovScanWindowBytes;
    return math.min(math.min(fileSize, moovBox.end), cappedEnd);
  }

  static Future<Mp4BoxHeader?> _findChildType({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required int start,
    required int end,
    required int containerEnd,
    required String childType,
    required int fileSize,
    required int maxBoxes,
  }) async {
    var offset = start;
    var stepCount = 0;
    while (offset + 8 <= end) {
      if (stepCount >= maxBoxes) {
        throw ExtractionFailure(
          'mp4_moov_child_scan_limit_exceeded',
          fileName: descriptor.fileName,
          mimeType: descriptor.mimeType,
          details: <String, Object?>{
            'scanOffset': offset,
            'childType': childType,
          },
        );
      }
      final box = await _readInnerHeaderAt(
        descriptor: descriptor,
        reader: reader,
        offset: offset,
        fileSize: fileSize,
        containerEnd: containerEnd,
      );
      if (box == null) {
        return null;
      }
      stepCount += 1;
      if (box.type == childType) {
        return box;
      }
      offset = box.end;
    }
    return null;
  }

  static Future<Mp4BoxHeader?> _readInnerHeaderAt({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required int offset,
    required int fileSize,
    required int containerEnd,
  }) async {
    if (offset < 0 || offset >= fileSize || offset >= containerEnd) {
      return null;
    }
    final headerEnd = math.min(fileSize, offset + innerHeaderBytesLength);
    final headerBytes = await reader.read(ByteRange(offset, headerEnd));
    final box = Mp4BoxHeaderReader.readHeader(
      headerBytes,
      fileOffset: offset,
      fileSize: fileSize,
    );
    if (box == null || box.end > containerEnd) {
      return null;
    }
    return box;
  }
}

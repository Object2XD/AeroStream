import 'dart:math' as math;
import 'dart:typed_data';

import '../../core/audio_object_descriptor.dart';
import '../../core/byte_range.dart';
import '../../core/byte_range_reader.dart';
import '../../core/extraction_failure.dart';
import '../box_header/mp4_box_header_reader.dart';
import '../model/mp4_box_header.dart';

class Mp4TopLevelScanner {
  const Mp4TopLevelScanner._();

  static const topLevelHeaderBytesLength = 16;
  static const topLevelScanMaxBoxes = 128;
  static const topLevelScanMaxGapBytes = 1024 * 1024 * 1024;

  static Future<Mp4BoxHeader> findMoovBox({
    required AudioObjectDescriptor descriptor,
    required Uint8List headBytes,
    required ByteRangeReader reader,
  }) async {
    final fileSize = descriptor.sizeBytes;
    if (fileSize == null || fileSize <= 0) {
      throw ExtractionFailure(
        'mp4_size_unknown',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }

    final headHeaders = Mp4BoxHeaderReader.readTopLevelHeaders(
      headBytes,
      fileSize: fileSize,
    );
    if (headHeaders.isEmpty) {
      throw ExtractionFailure(
        'mp4_top_level_headers_missing',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }

    final moovBox = _firstBoxOfType(headHeaders, 'moov');
    if (moovBox != null) {
      return moovBox;
    }

    final mdatBox = _firstBoxOfType(headHeaders, 'mdat');
    if (mdatBox == null) {
      throw ExtractionFailure(
        'mp4_mdat_not_found',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }
    if (mdatBox.end >= fileSize) {
      throw ExtractionFailure(
        'mp4_moov_not_found',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
        details: <String, Object?>{'scanOffset': mdatBox.end},
      );
    }

    final scanStart = mdatBox.end;
    var scanOffset = scanStart;
    var stepCount = 0;
    while (scanOffset < fileSize) {
      final scannedGapBytes = scanOffset - scanStart;
      if (stepCount >= topLevelScanMaxBoxes ||
          scannedGapBytes > topLevelScanMaxGapBytes) {
        throw ExtractionFailure(
          'mp4_top_level_scan_limit_exceeded',
          fileName: descriptor.fileName,
          mimeType: descriptor.mimeType,
          details: <String, Object?>{
            'scanOffset': scanOffset,
            'stepCount': stepCount,
            'scannedGapBytes': scannedGapBytes,
          },
        );
      }

      final headerEnd = math.min(fileSize, scanOffset + topLevelHeaderBytesLength);
      final headerBytes = await reader.read(ByteRange(scanOffset, headerEnd));
      final box = Mp4BoxHeaderReader.readHeader(
        headerBytes,
        fileOffset: scanOffset,
        fileSize: fileSize,
      );
      if (box == null) {
        throw ExtractionFailure(
          'mp4_invalid_top_level_box',
          fileName: descriptor.fileName,
          mimeType: descriptor.mimeType,
          details: <String, Object?>{
            'scanOffset': scanOffset,
            'stepCount': stepCount,
            'scannedGapBytes': scannedGapBytes,
          },
        );
      }

      stepCount += 1;
      if (box.extendsToEof && box.type != 'moov') {
        throw ExtractionFailure(
          'mp4_invalid_top_level_box',
          fileName: descriptor.fileName,
          mimeType: descriptor.mimeType,
          details: <String, Object?>{
            'scanOffset': scanOffset,
            'boxType': box.type,
            'boxSize': box.size,
            'stepCount': stepCount,
            'scannedGapBytes': scannedGapBytes,
          },
        );
      }
      if (box.type == 'moov') {
        return box;
      }
      if (box.end <= scanOffset) {
        throw ExtractionFailure(
          'mp4_invalid_top_level_box',
          fileName: descriptor.fileName,
          mimeType: descriptor.mimeType,
          details: <String, Object?>{
            'scanOffset': scanOffset,
            'boxType': box.type,
            'boxSize': box.size,
            'stepCount': stepCount,
            'scannedGapBytes': scannedGapBytes,
          },
        );
      }
      scanOffset = box.end;
    }

    throw ExtractionFailure(
      'mp4_moov_not_found',
      fileName: descriptor.fileName,
      mimeType: descriptor.mimeType,
      details: <String, Object?>{
        'scanOffset': scanOffset,
        'stepCount': stepCount,
        'scannedGapBytes': scanOffset - scanStart,
      },
    );
  }

  static Mp4BoxHeader? _firstBoxOfType(
    Iterable<Mp4BoxHeader> headers,
    String type,
  ) {
    for (final header in headers) {
      if (header.type == type) {
        return header;
      }
    }
    return null;
  }
}

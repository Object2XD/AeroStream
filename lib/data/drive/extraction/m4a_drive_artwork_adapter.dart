import 'dart:math' as math;

import '../../../media_extraction/core/byte_range.dart';
import '../../../media_extraction/core/byte_segment.dart';
import '../../../media_extraction/core/audio_extraction_capabilities.dart';
import '../../../media_extraction/core/audio_extraction_cost_class.dart';
import '../../../media_extraction/core/extracted_artwork.dart';
import '../../../media_extraction/core/extraction_failure.dart';
import '../../../media_extraction/mp4/service/mp4_artwork_service.dart';
import '../audio_extraction_exception.dart';
import 'drive_artwork_adapter.dart';
import 'drive_byte_range_reader.dart';

class M4aDriveArtworkAdapter implements DriveArtworkAdapter {
  const M4aDriveArtworkAdapter({Mp4ArtworkService? service})
    : _service = service ?? const Mp4ArtworkService();

  static const _headBytesLength = 8 * 1024;

  final Mp4ArtworkService _service;

  @override
  bool supports(track) {
    final lowerName = track.fileName.toLowerCase();
    return track.mimeType == 'audio/mp4' ||
        track.mimeType == 'audio/x-m4a' ||
        lowerName.endsWith('.m4a') ||
        lowerName.endsWith('.mp4');
  }

  @override
  AudioExtractionCapabilities get capabilities =>
      const AudioExtractionCapabilities(
        supportsMetadata: false,
        supportsArtwork: true,
        costClass: AudioExtractionCostClass.exploratory,
        maxProbeBytes: 8 * 1024,
        maxPlannedRanges: 1,
      );

  @override
  DriveByteRangeFetchPolicy get fetchPolicy => DriveByteRangeFetchPolicy.exact;

  @override
  Future<ExtractedArtwork?> extract(DriveArtworkAdapterContext context) async {
    final descriptor = context.descriptor;
    final headLength = _resolveHeadLength(descriptor.sizeBytes);
    final headBytes = await context.reader.read(ByteRange(0, headLength));
    final initialSegments = <ByteSegment>[
      ByteSegment(start: 0, bytes: headBytes),
    ];

    try {
      return await _service.extract(
        descriptor: descriptor,
        reader: context.reader,
        initialSegments: initialSegments,
      );
    } on ExtractionFailure catch (error) {
      throw DriveRangedExtractionException(
        error.reason,
        fileName: context.track.fileName,
        mimeType: context.track.mimeType,
        cause: error,
      );
    }
  }

  int _resolveHeadLength(int? sizeBytes) {
    final safeSize = sizeBytes ?? _headBytesLength;
    return math.max(1, math.min(_headBytesLength, safeSize));
  }
}

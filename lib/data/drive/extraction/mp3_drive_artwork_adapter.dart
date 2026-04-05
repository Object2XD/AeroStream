import '../../../media_extraction/core/extracted_artwork.dart';
import '../../../media_extraction/core/audio_extraction_capabilities.dart';
import '../../../media_extraction/core/audio_extraction_cost_class.dart';
import '../../../media_extraction/core/extraction_failure.dart';
import '../../../media_extraction/mp3/service/mp3_artwork_service.dart';
import '../audio_extraction_exception.dart';
import 'drive_artwork_adapter.dart';
import 'drive_byte_range_reader.dart';

class Mp3DriveArtworkAdapter implements DriveArtworkAdapter {
  const Mp3DriveArtworkAdapter({Mp3ArtworkService? service})
    : _service = service ?? const Mp3ArtworkService();

  final Mp3ArtworkService _service;

  @override
  bool supports(track) {
    final lowerName = track.fileName.toLowerCase();
    return track.mimeType == 'audio/mpeg' || lowerName.endsWith('.mp3');
  }

  @override
  AudioExtractionCapabilities get capabilities =>
      const AudioExtractionCapabilities(
        supportsMetadata: false,
        supportsArtwork: true,
        costClass: AudioExtractionCostClass.light,
        maxProbeBytes: 4 * 1024,
        maxPlannedRanges: 1,
      );

  @override
  DriveByteRangeFetchPolicy get fetchPolicy => DriveByteRangeFetchPolicy.exact;

  @override
  Future<ExtractedArtwork?> extract(DriveArtworkAdapterContext context) async {
    try {
      return await _service.extract(
        descriptor: context.descriptor,
        reader: context.reader,
        initialSegments: const [],
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
}

import '../../../media_extraction/core/audio_object_descriptor.dart';
import '../../../media_extraction/core/audio_extraction_capabilities.dart';
import '../../../media_extraction/core/audio_extraction_cost_class.dart';
import '../../../media_extraction/core/byte_range_reader.dart';
import '../../../media_extraction/core/extracted_artwork.dart';
import '../../database/app_database.dart';
import 'drive_byte_range_reader.dart';

class DriveArtworkAdapterContext {
  const DriveArtworkAdapterContext({
    required this.track,
    required this.descriptor,
    required this.reader,
  });

  final Track track;
  final AudioObjectDescriptor descriptor;
  final ByteRangeReader reader;
}

abstract interface class DriveArtworkAdapter {
  bool supports(Track track);

  AudioExtractionCapabilities get capabilities =>
      const AudioExtractionCapabilities(
        supportsMetadata: false,
        supportsArtwork: true,
        costClass: AudioExtractionCostClass.exploratory,
        maxProbeBytes: 512 * 1024,
        maxPlannedRanges: 1,
      );

  DriveByteRangeFetchPolicy get fetchPolicy =>
      DriveByteRangeFetchPolicy.minimumWindow;

  Future<ExtractedArtwork?> extract(DriveArtworkAdapterContext context);
}

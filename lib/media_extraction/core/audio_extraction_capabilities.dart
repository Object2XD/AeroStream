import 'audio_extraction_cost_class.dart';

class AudioExtractionCapabilities {
  const AudioExtractionCapabilities({
    required this.supportsMetadata,
    required this.supportsArtwork,
    required this.costClass,
    required this.maxProbeBytes,
    required this.maxPlannedRanges,
  });

  final bool supportsMetadata;
  final bool supportsArtwork;
  final AudioExtractionCostClass costClass;
  final int maxProbeBytes;
  final int maxPlannedRanges;
}

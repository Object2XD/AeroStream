import '../../core/audio_extraction_cost_class.dart';
import '../../core/byte_segment.dart';
import 'mp4_box_header.dart';

class Mp4MetadataProbeResult {
  const Mp4MetadataProbeResult({
    required this.moovBox,
    required this.probeSegments,
  });

  final Mp4BoxHeader moovBox;
  final List<ByteSegment> probeSegments;

  AudioExtractionCostClass get costClass =>
      AudioExtractionCostClass.exploratory;

  int get maxProbeBytes =>
      probeSegments.fold<int>(0, (sum, segment) => sum + segment.bytes.length);
}

import '../../core/audio_extraction_cost_class.dart';
import '../../core/audio_extraction_fetch_plan.dart';
import '../../core/byte_range.dart';
import '../../core/byte_segment.dart';
import '../plan/mp4_artwork_fetch_plan.dart';
import 'mp4_layout.dart';

class Mp4ArtworkProbeResult {
  const Mp4ArtworkProbeResult({
    required this.layout,
    required this.fetchPlan,
    required this.probeSegments,
  });

  final Mp4Layout layout;
  final Mp4ArtworkFetchPlan? fetchPlan;
  final List<ByteSegment> probeSegments;

  AudioExtractionCostClass get costClass =>
      AudioExtractionCostClass.exploratory;

  int get maxProbeBytes =>
      probeSegments.fold<int>(0, (sum, segment) => sum + segment.bytes.length);

  int get maxPlannedRanges => fetchPlan == null ? 0 : 1;

  AudioExtractionFetchPlan? get plan => fetchPlan == null
      ? null
      : AudioExtractionFetchPlan(ranges: <ByteRange>[fetchPlan!.range]);
}

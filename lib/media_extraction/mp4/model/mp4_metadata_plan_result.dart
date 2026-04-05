import '../../core/audio_extraction_fetch_plan.dart';
import '../../core/byte_segment.dart';
import '../plan/mp4_metadata_fetch_plan.dart';
import 'mp4_layout.dart';

class Mp4MetadataPlanResult {
  const Mp4MetadataPlanResult({
    required this.layout,
    required this.fetchPlan,
    required this.probeSegments,
  });

  final Mp4Layout layout;
  final Mp4MetadataFetchPlan fetchPlan;
  final List<ByteSegment> probeSegments;

  int get maxPlannedRanges => fetchPlan.ranges.length;

  AudioExtractionFetchPlan get plan =>
      AudioExtractionFetchPlan(ranges: fetchPlan.ranges);
}

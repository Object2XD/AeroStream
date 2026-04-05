import '../../core/audio_object_descriptor.dart';
import '../../core/audio_extraction_fetch_plan.dart';
import '../../core/byte_range_reader.dart';
import '../../core/byte_segment.dart';
import '../../core/extraction_failure.dart';
import '../../core/extracted_artwork.dart';
import '../layout/mp4_inner_layout_resolver.dart';
import '../model/mp4_artwork_probe_result.dart';
import '../model/mp4_probe_goal.dart';
import '../parse/mp4_sparse_artwork_parser.dart';
import '../plan/mp4_artwork_fetch_plan.dart';
import '../top_level/mp4_top_level_scanner.dart';

class Mp4ArtworkService {
  const Mp4ArtworkService();

  static const int fixedHeaderWindowBytes = 8 * 1024;

  Future<ExtractedArtwork?> extract({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required List<ByteSegment> initialSegments,
  }) async {
    final probe = await this.probe(
      descriptor: descriptor,
      reader: reader,
      initialSegments: initialSegments,
    );
    final plan = probe.plan;
    if (plan == null) {
      return null;
    }
    final segments = await fetch(
      reader: reader,
      plan: plan,
      initialSegments: probe.probeSegments,
    );
    final artwork = parse(probe: probe, segments: segments);
    if (artwork == null || artwork.bytes.isEmpty) {
      throw ExtractionFailure(
        'artwork_sparse_unavailable',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }
    return artwork;
  }

  Future<Mp4ArtworkProbeResult> probe({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required List<ByteSegment> initialSegments,
  }) async {
    if (initialSegments.isEmpty) {
      throw ExtractionFailure(
        'mp4_head_segment_missing',
        fileName: descriptor.fileName,
        mimeType: descriptor.mimeType,
      );
    }
    final headSegment = initialSegments.firstWhere(
      (segment) => segment.start == 0,
      orElse: () => initialSegments.first,
    );
    final moovBox = await Mp4TopLevelScanner.findMoovBox(
      descriptor: descriptor,
      headBytes: headSegment.bytes,
      reader: reader,
    );
    final layout = await Mp4InnerLayoutResolver.resolve(
      descriptor: descriptor,
      moovBox: moovBox,
      reader: reader,
      goal: Mp4ProbeGoal.artwork,
      moovScanWindowBytes: null,
    );
    final plan = Mp4ArtworkFetchPlan.fromLayout(layout);
    return Mp4ArtworkProbeResult(
      layout: layout,
      fetchPlan: plan,
      probeSegments: <ByteSegment>[...initialSegments],
    );
  }

  Future<List<ByteSegment>> fetch({
    required ByteRangeReader reader,
    required AudioExtractionFetchPlan plan,
    required List<ByteSegment> initialSegments,
  }) async {
    final segments = <ByteSegment>[...initialSegments];
    for (final range in plan.ranges) {
      if (segments.any((segment) => segment.covers(range))) {
        continue;
      }
      final bytes = await reader.read(range);
      segments.add(ByteSegment(start: range.start, bytes: bytes));
    }
    return segments;
  }

  ExtractedArtwork? parse({
    required Mp4ArtworkProbeResult probe,
    required List<ByteSegment> segments,
  }) {
    final artworkBox = probe.layout.covrBox;
    if (artworkBox == null) {
      return null;
    }
    return Mp4SparseArtworkParser.parse(
      artworkBox: artworkBox,
      segments: segments,
    );
  }
}

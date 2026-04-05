import '../../core/audio_object_descriptor.dart';
import '../../core/audio_extraction_fetch_plan.dart';
import '../../core/byte_range_reader.dart';
import '../../core/byte_segment.dart';
import '../../core/extracted_artwork.dart';
import '../model/mp3_artwork_probe_result.dart';
import '../parse/mp3_sparse_tag_reader.dart';

class Mp3ArtworkService {
  const Mp3ArtworkService();

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
    if (probe == null) {
      return null;
    }
    final segments = await fetch(
      reader: reader,
      plan: probe.fetchPlan,
      initialSegments: initialSegments,
    );
    final extracted = parse(probe: probe, segments: segments);
    if (extracted == null) {
      return null;
    }
    return extracted;
  }

  Future<Mp3ArtworkProbeResult?> probe({
    required AudioObjectDescriptor descriptor,
    required ByteRangeReader reader,
    required List<ByteSegment> initialSegments,
  }) async {
    final sparseReader = Mp3SparseTagReader(
      descriptor: descriptor,
      reader: reader,
      initialSegments: initialSegments,
    );
    return sparseReader.probeArtwork();
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
    required Mp3ArtworkProbeResult probe,
    required List<ByteSegment> segments,
  }) {
    final range = probe.locator.dataRange;
    final segment = segments.firstWhere(
      (candidate) => candidate.covers(range),
      orElse: () => throw StateError('Missing APIC segment for $range'),
    );
    final artworkBytes = segment.slice(range);
    if (artworkBytes.isEmpty) {
      return null;
    }
    return ExtractedArtwork(
      bytes: artworkBytes,
      mimeType: probe.locator.mimeType,
    );
  }
}

import '../../core/audio_extraction_fetch_plan.dart';
import '../../core/byte_range.dart';
import 'mp3_artwork_probe_result.dart';
import '../parse/mp3_tag_parser.dart';

class Mp3MetadataPlanResult {
  const Mp3MetadataPlanResult({
    required this.metadataFrames,
    required this.optionalId3v1Range,
    this.artworkLocator,
  });

  final List<Mp3Id3FrameHeader> metadataFrames;
  final ByteRange? optionalId3v1Range;
  final Mp3ArtworkLocator? artworkLocator;

  int get maxPlannedRanges =>
      metadataFrames.length + (optionalId3v1Range == null ? 0 : 1);

  AudioExtractionFetchPlan get primaryPlan => AudioExtractionFetchPlan(
    ranges: metadataFrames
        .map((frame) => ByteRange(frame.dataOffset, frame.endExclusive))
        .toList(growable: false),
  );
}

import '../../core/audio_extraction_cost_class.dart';
import '../../core/byte_range.dart';
import '../parse/mp3_tag_parser.dart';

class Mp3MetadataProbeResult {
  const Mp3MetadataProbeResult({
    required this.header,
    required this.tagEnd,
    required this.optionalId3v1Range,
  });

  final Mp3Id3Header header;
  final int tagEnd;
  final ByteRange? optionalId3v1Range;

  AudioExtractionCostClass get costClass => AudioExtractionCostClass.light;

  int get maxProbeBytes => Mp3TagParser.id3HeaderLength;

  int get scanLength => tagEnd - header.frameDataOffset;
}

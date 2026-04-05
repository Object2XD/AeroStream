import '../../core/audio_extraction_cost_class.dart';
import '../../core/audio_extraction_fetch_plan.dart';
import '../../core/byte_range.dart';
import '../parse/mp3_tag_parser.dart';

class Mp3ArtworkLocator {
  const Mp3ArtworkLocator({
    required this.mimeType,
    required this.pictureType,
    required this.dataOffset,
    required this.dataLength,
  });

  final String mimeType;
  final int pictureType;
  final int dataOffset;
  final int dataLength;

  ByteRange get dataRange => ByteRange(dataOffset, dataOffset + dataLength);
}

class Mp3ArtworkProbeResult {
  const Mp3ArtworkProbeResult({required this.apicFrame, required this.locator});

  final Mp3Id3FrameHeader apicFrame;
  final Mp3ArtworkLocator locator;

  AudioExtractionCostClass get costClass => AudioExtractionCostClass.light;

  int get maxProbeBytes =>
      Mp3TagParser.id3HeaderLength + Mp3TagParser.id3FrameHeaderLength;

  int get maxPlannedRanges => 1;

  AudioExtractionFetchPlan get fetchPlan =>
      AudioExtractionFetchPlan(ranges: <ByteRange>[locator.dataRange]);

  bool get hasArtwork => true;
  String get artworkMime => locator.mimeType;
  int get artworkPictureType => locator.pictureType;
  int get artworkDataOffset => locator.dataOffset;
  int get artworkDataLength => locator.dataLength;
}

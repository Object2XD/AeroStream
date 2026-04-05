import '../../core/byte_range.dart';
import '../../core/byte_segment.dart';
import '../../core/extracted_artwork.dart';
import '../model/mp4_box_header.dart';
import 'mp4_sparse_item_parser.dart';

class Mp4SparseArtworkParser {
  const Mp4SparseArtworkParser._();

  static ExtractedArtwork? parse({
    required Mp4BoxHeader artworkBox,
    required List<ByteSegment> segments,
  }) {
    final range = ByteRange(artworkBox.offset, artworkBox.end);
    for (final segment in segments) {
      if (!segment.covers(range)) {
        continue;
      }
      final itemBytes = segment.slice(range);
      return Mp4SparseItemParser.parseItem(
        itemBytes,
        includeArtwork: true,
      ).artwork;
    }
    return null;
  }
}

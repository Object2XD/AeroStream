import '../../core/byte_range.dart';
import '../model/mp4_layout.dart';

class Mp4ArtworkFetchPlan {
  const Mp4ArtworkFetchPlan({required this.range});

  final ByteRange range;

  static Mp4ArtworkFetchPlan? fromLayout(Mp4Layout layout) {
    final artworkBox = layout.covrBox;
    if (artworkBox == null) {
      return null;
    }
    return Mp4ArtworkFetchPlan(
      range: ByteRange(artworkBox.offset, artworkBox.end),
    );
  }
}

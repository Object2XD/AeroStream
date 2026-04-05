import '../../core/byte_range.dart';
import '../model/mp4_layout.dart';

class Mp4MetadataFetchPlan {
  const Mp4MetadataFetchPlan({required this.ranges});

  final List<ByteRange> ranges;

  static const mergeGapBytes = 1024;

  factory Mp4MetadataFetchPlan.fromLayout(Mp4Layout layout) {
    final rawRanges = <ByteRange>[
      if (layout.mvhdBox != null)
        ByteRange(layout.mvhdBox!.offset, layout.mvhdBox!.end),
      for (final itemBox in layout.metadataItemBoxes)
        ByteRange(itemBox.offset, itemBox.end),
    ]..sort((left, right) => left.start.compareTo(right.start));

    if (rawRanges.isEmpty) {
      return const Mp4MetadataFetchPlan(ranges: <ByteRange>[]);
    }

    final merged = <ByteRange>[];
    var current = rawRanges.first;
    for (final next in rawRanges.skip(1)) {
      if (next.start - current.endExclusive <= mergeGapBytes) {
        current = current.merge(next);
      } else {
        merged.add(current);
        current = next;
      }
    }
    merged.add(current);
    return Mp4MetadataFetchPlan(ranges: merged);
  }
}

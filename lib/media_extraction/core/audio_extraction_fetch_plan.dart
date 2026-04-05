import 'byte_range.dart';

class AudioExtractionFetchPlan {
  const AudioExtractionFetchPlan({required this.ranges});

  final List<ByteRange> ranges;

  int get rangeCount => ranges.length;
}

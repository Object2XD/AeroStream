class ByteRange {
  const ByteRange(this.start, this.endExclusive)
    : assert(start >= 0),
      assert(endExclusive >= start);

  final int start;
  final int endExclusive;

  int get length => endExclusive - start;

  bool covers(ByteRange other) {
    return start <= other.start && endExclusive >= other.endExclusive;
  }

  String toHttpRangeHeader() {
    return 'bytes=$start-${endExclusive - 1}';
  }

  ByteRange merge(ByteRange other) {
    final mergedStart = start < other.start ? start : other.start;
    final mergedEnd = endExclusive > other.endExclusive
        ? endExclusive
        : other.endExclusive;
    return ByteRange(mergedStart, mergedEnd);
  }

  @override
  bool operator ==(Object other) {
    return other is ByteRange &&
        other.start == start &&
        other.endExclusive == endExclusive;
  }

  @override
  int get hashCode => Object.hash(start, endExclusive);

  @override
  String toString() => 'ByteRange($start,$endExclusive)';
}

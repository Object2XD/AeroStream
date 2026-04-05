import 'dart:typed_data';

import 'byte_range.dart';

class ByteSegment {
  const ByteSegment({required this.start, required this.bytes})
    : assert(start >= 0);

  final int start;
  final Uint8List bytes;

  int get endExclusive => start + bytes.length;

  bool covers(ByteRange range) {
    return start <= range.start && endExclusive >= range.endExclusive;
  }

  Uint8List slice(ByteRange range) {
    final relativeStart = range.start - start;
    final relativeEnd = range.endExclusive - start;
    return Uint8List.fromList(bytes.sublist(relativeStart, relativeEnd));
  }
}

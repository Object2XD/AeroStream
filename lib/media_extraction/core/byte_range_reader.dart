import 'dart:typed_data';

import 'byte_range.dart';

abstract interface class ByteRangeReader {
  Future<Uint8List> read(ByteRange range);
}

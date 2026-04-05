import 'dart:convert';
import 'dart:typed_data';

import '../model/mp4_box_header.dart';

class Mp4BoxHeaderReader {
  const Mp4BoxHeaderReader._();

  static Mp4BoxHeader? readHeader(
    Uint8List bytes, {
    int offset = 0,
    int fileOffset = 0,
    required int fileSize,
  }) {
    final absoluteOffset = fileOffset + offset;
    if (offset < 0 || absoluteOffset < 0 || offset + 8 > bytes.length) {
      return null;
    }
    if (absoluteOffset >= fileSize) {
      return null;
    }
    final size32 = ByteData.sublistView(
      bytes,
      offset,
      offset + 4,
    ).getUint32(0, Endian.big);
    final type = latin1.decode(bytes.sublist(offset + 4, offset + 8));
    var headerSize = 8;
    int size;
    var usesExtendedSize = false;
    var extendsToEof = false;
    if (size32 == 1) {
      if (offset + 16 > bytes.length) {
        return null;
      }
      size = _readUint64(bytes, offset + 8);
      headerSize = 16;
      usesExtendedSize = true;
    } else if (size32 == 0) {
      size = fileSize - absoluteOffset;
      extendsToEof = true;
    } else {
      size = size32;
    }
    if (size < headerSize || absoluteOffset + size > fileSize) {
      return null;
    }
    return Mp4BoxHeader(
      offset: absoluteOffset,
      size: size,
      headerSize: headerSize,
      type: type,
      usesExtendedSize: usesExtendedSize,
      extendsToEof: extendsToEof,
    );
  }

  static List<Mp4BoxHeader> readTopLevelHeaders(
    Uint8List bytes, {
    int fileOffset = 0,
    required int fileSize,
  }) {
    final headers = <Mp4BoxHeader>[];
    var offset = 0;
    while (offset + 8 <= bytes.length) {
      final header = readHeader(
        bytes,
        offset: offset,
        fileOffset: fileOffset,
        fileSize: fileSize,
      );
      if (header == null) {
        break;
      }
      headers.add(header);
      final nextOffset = header.end - fileOffset;
      if (nextOffset <= offset || nextOffset >= bytes.length) {
        break;
      }
      offset = nextOffset;
    }
    return headers;
  }

  static int _readUint64(Uint8List bytes, int offset) {
    final high = ByteData.sublistView(
      bytes,
      offset,
      offset + 4,
    ).getUint32(0, Endian.big);
    final low = ByteData.sublistView(
      bytes,
      offset + 4,
      offset + 8,
    ).getUint32(0, Endian.big);
    return (high << 32) | low;
  }
}

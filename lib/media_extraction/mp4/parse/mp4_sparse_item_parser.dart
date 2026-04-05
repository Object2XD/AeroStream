import 'dart:convert';
import 'dart:typed_data';

import '../../core/extracted_artwork.dart';
import '../../core/extracted_metadata.dart';

class ParsedMp4ItemPayload {
  const ParsedMp4ItemPayload({
    this.metadata = const ExtractedMetadata(),
    this.artwork,
  });

  final ExtractedMetadata metadata;
  final ExtractedArtwork? artwork;
}

class Mp4SparseItemParser {
  const Mp4SparseItemParser._();

  static ParsedMp4ItemPayload parseItem(
    Uint8List itemBytes, {
    required bool includeArtwork,
  }) {
    final item = _readMp4Box(itemBytes, 0, itemBytes.length);
    if (item == null) {
      return const ParsedMp4ItemPayload();
    }
    final dataBox = _findChildBox(itemBytes, item.dataOffset, item.end, 'data');
    if (dataBox == null || dataBox.payloadLength < 8) {
      return const ParsedMp4ItemPayload();
    }
    final data = ByteData.sublistView(
      itemBytes,
      dataBox.dataOffset,
      dataBox.dataOffset + 8,
    );
    final dataType = data.getUint32(0, Endian.big);
    final payload = itemBytes.sublist(dataBox.dataOffset + 8, dataBox.end);
    switch (item.type) {
      case '\u00a9nam':
        return ParsedMp4ItemPayload(
          metadata: ExtractedMetadata(title: _decodeMp4Text(payload)),
        );
      case '\u00a9ART':
        return ParsedMp4ItemPayload(
          metadata: ExtractedMetadata(artist: _decodeMp4Text(payload)),
        );
      case '\u00a9alb':
        return ParsedMp4ItemPayload(
          metadata: ExtractedMetadata(album: _decodeMp4Text(payload)),
        );
      case 'aART':
        return ParsedMp4ItemPayload(
          metadata: ExtractedMetadata(albumArtist: _decodeMp4Text(payload)),
        );
      case '\u00a9gen':
        return ParsedMp4ItemPayload(
          metadata: ExtractedMetadata(genre: _decodeMp4Text(payload)),
        );
      case '\u00a9day':
        return ParsedMp4ItemPayload(
          metadata: ExtractedMetadata(year: _parseLeadingInt(_decodeMp4Text(payload))),
        );
      case 'trkn':
        return ParsedMp4ItemPayload(
          metadata: ExtractedMetadata(trackNumber: _parseMp4Ordinal(payload)),
        );
      case 'disk':
        return ParsedMp4ItemPayload(
          metadata: ExtractedMetadata(discNumber: _parseMp4Ordinal(payload)),
        );
      case 'covr':
        if (!includeArtwork || payload.isEmpty) {
          return const ParsedMp4ItemPayload();
        }
        final mimeType = switch (dataType) {
          13 => 'image/jpeg',
          14 => 'image/png',
          27 => 'image/webp',
          _ => 'image/jpeg',
        };
        return ParsedMp4ItemPayload(
          artwork: ExtractedArtwork(
            bytes: Uint8List.fromList(payload),
            mimeType: mimeType,
          ),
        );
      default:
        return const ParsedMp4ItemPayload();
    }
  }

  static String? _decodeMp4Text(Uint8List payload) {
    if (payload.isEmpty) {
      return null;
    }
    return utf8.decode(payload, allowMalformed: true).trim();
  }

  static int? _parseMp4Ordinal(Uint8List payload) {
    if (payload.length >= 4) {
      final value = (payload[2] << 8) | payload[3];
      if (value > 0) {
        return value;
      }
    }
    if (payload.length >= 6) {
      final value = (payload[4] << 8) | payload[5];
      if (value > 0) {
        return value;
      }
    }
    return null;
  }

  static int? _parseLeadingInt(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final match = RegExp(r'\d{1,4}').firstMatch(value);
    return match == null ? null : int.tryParse(match.group(0)!);
  }
}

class _Mp4Box {
  const _Mp4Box({
    required this.offset,
    required this.size,
    required this.headerSize,
    required this.type,
  });

  final int offset;
  final int size;
  final int headerSize;
  final String type;

  int get dataOffset => offset + headerSize;
  int get end => offset + size;
  int get payloadLength => size - headerSize;
}

_Mp4Box? _readMp4Box(Uint8List bytes, int offset, int end) {
  if (offset + 8 > end) {
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
  if (size32 == 1) {
    if (offset + 16 > end) {
      return null;
    }
    final data = ByteData.sublistView(bytes, offset + 8, offset + 16);
    final high = data.getUint32(0, Endian.big);
    final low = data.getUint32(4, Endian.big);
    size = (high << 32) | low;
    headerSize = 16;
  } else if (size32 == 0) {
    size = end - offset;
  } else {
    size = size32;
  }
  if (size < headerSize || offset + size > end) {
    return null;
  }
  return _Mp4Box(
    offset: offset,
    size: size,
    headerSize: headerSize,
    type: type,
  );
}

_Mp4Box? _findChildBox(Uint8List bytes, int start, int end, String type) {
  var offset = start;
  while (offset < end) {
    final box = _readMp4Box(bytes, offset, end);
    if (box == null) {
      return null;
    }
    if (box.type == type) {
      return box;
    }
    offset = box.end;
  }
  return null;
}

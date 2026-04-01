import 'dart:convert';
import 'dart:typed_data';

import 'legacy_text_decoder.dart';

class ParsedTagData {
  const ParsedTagData({
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.trackNumber,
    this.discNumber,
    this.durationMs,
    this.artworkBytes,
    this.artworkMimeType,
  });

  final String? title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final int? discNumber;
  final int? durationMs;
  final Uint8List? artworkBytes;
  final String? artworkMimeType;

  bool get hasAnyTag =>
      title != null ||
      artist != null ||
      album != null ||
      albumArtist != null ||
      genre != null ||
      year != null ||
      trackNumber != null ||
      discNumber != null ||
      artworkBytes != null;

  ParsedTagData merge(ParsedTagData other) {
    return ParsedTagData(
      title: title ?? other.title,
      artist: artist ?? other.artist,
      album: album ?? other.album,
      albumArtist: albumArtist ?? other.albumArtist,
      genre: genre ?? other.genre,
      year: year ?? other.year,
      trackNumber: trackNumber ?? other.trackNumber,
      discNumber: discNumber ?? other.discNumber,
      durationMs: durationMs ?? other.durationMs,
      artworkBytes: artworkBytes ?? other.artworkBytes,
      artworkMimeType: artworkMimeType ?? other.artworkMimeType,
    );
  }
}

class DriveEmbeddedTagParser {
  const DriveEmbeddedTagParser._();

  static ParsedTagData? parse({
    required Uint8List headBytes,
    required Uint8List tailBytes,
    required String mimeType,
    required String fileName,
  }) {
    final lowerName = fileName.toLowerCase();
    if (mimeType == 'audio/mpeg' || lowerName.endsWith('.mp3')) {
      return _parseMp3(headBytes, tailBytes);
    }
    if (mimeType == 'audio/flac' || lowerName.endsWith('.flac')) {
      return _parseFlac(headBytes);
    }
    if (mimeType == 'audio/wav' ||
        mimeType == 'audio/x-wav' ||
        lowerName.endsWith('.wav')) {
      return _parseWav(headBytes);
    }
    return null;
  }

  static ParsedTagData? _parseMp3(Uint8List headBytes, Uint8List tailBytes) {
    ParsedTagData? result;
    if (headBytes.length >= 10 &&
        ascii.decode(headBytes.sublist(0, 3), allowInvalid: true) == 'ID3') {
      final tagSize = _readSynchsafeInt(headBytes, 6);
      final available = headBytes.length >= tagSize + 10
          ? tagSize + 10
          : headBytes.length;
      var offset = 10;
      ParsedTagData parsed = const ParsedTagData();

      while (offset + 10 <= available) {
        final frameId = ascii.decode(
          headBytes.sublist(offset, offset + 4),
          allowInvalid: true,
        );
        if (frameId.trim().isEmpty || frameId == '\u0000\u0000\u0000\u0000') {
          break;
        }

        final frameSize = _readUint32(headBytes, offset + 4);
        if (frameSize <= 0 || offset + 10 + frameSize > available) {
          break;
        }

        final frameData = headBytes.sublist(
          offset + 10,
          offset + 10 + frameSize,
        );
        parsed = parsed.merge(_parseId3Frame(frameId, frameData));
        offset += 10 + frameSize;
      }

      if (parsed.hasAnyTag) {
        result = parsed;
      }
    }

    if (tailBytes.length >= 128) {
      final last128 = tailBytes.sublist(tailBytes.length - 128);
      if (ascii.decode(last128.sublist(0, 3), allowInvalid: true) == 'TAG') {
        final fallback = ParsedTagData(
          title: _trimLegacyText(last128.sublist(3, 33)),
          artist: _trimLegacyText(last128.sublist(33, 63)),
          album: _trimLegacyText(last128.sublist(63, 93)),
          year: int.tryParse(_trimLegacyText(last128.sublist(93, 97)) ?? ''),
          genre: null,
          trackNumber: last128[125] == 0 ? last128[126] : null,
        );
        result = (result ?? const ParsedTagData()).merge(fallback);
      }
    }

    return result;
  }

  static ParsedTagData _parseId3Frame(String frameId, Uint8List frameData) {
    if (frameData.isEmpty) {
      return const ParsedTagData();
    }

    switch (frameId) {
      case 'TIT2':
        return ParsedTagData(title: _decodeId3Text(frameData));
      case 'TPE1':
        return ParsedTagData(artist: _decodeId3Text(frameData));
      case 'TALB':
        return ParsedTagData(album: _decodeId3Text(frameData));
      case 'TPE2':
        return ParsedTagData(albumArtist: _decodeId3Text(frameData));
      case 'TCON':
        return ParsedTagData(genre: _decodeId3Text(frameData));
      case 'TRCK':
        return ParsedTagData(
          trackNumber: _parseLeadingInt(_decodeId3Text(frameData)),
        );
      case 'TPOS':
        return ParsedTagData(
          discNumber: _parseLeadingInt(_decodeId3Text(frameData)),
        );
      case 'TDRC':
      case 'TYER':
        return ParsedTagData(year: _parseLeadingInt(_decodeId3Text(frameData)));
      case 'APIC':
        return _parseApic(frameData);
      default:
        return const ParsedTagData();
    }
  }

  static ParsedTagData _parseApic(Uint8List frameData) {
    final encoding = frameData[0];
    var offset = 1;
    while (offset < frameData.length && frameData[offset] != 0) {
      offset++;
    }
    final mimeType = ascii.decode(
      frameData.sublist(1, offset),
      allowInvalid: true,
    );
    offset++;
    if (offset >= frameData.length) {
      return const ParsedTagData();
    }
    offset++;
    final descriptionEnd = _findTerminator(frameData, offset, encoding);
    offset = descriptionEnd;
    final artwork = frameData.sublist(offset);
    if (artwork.isEmpty) {
      return const ParsedTagData();
    }
    return ParsedTagData(
      artworkBytes: Uint8List.fromList(artwork),
      artworkMimeType: mimeType.isEmpty ? 'image/jpeg' : mimeType,
    );
  }

  static ParsedTagData? _parseFlac(Uint8List headBytes) {
    if (headBytes.length < 4 ||
        ascii.decode(headBytes.sublist(0, 4), allowInvalid: true) != 'fLaC') {
      return null;
    }

    var offset = 4;
    ParsedTagData result = const ParsedTagData();
    var isLast = false;

    while (!isLast && offset + 4 <= headBytes.length) {
      final header = headBytes[offset];
      isLast = (header & 0x80) != 0;
      final blockType = header & 0x7f;
      final blockLength =
          (headBytes[offset + 1] << 16) |
          (headBytes[offset + 2] << 8) |
          headBytes[offset + 3];
      offset += 4;
      if (offset + blockLength > headBytes.length) {
        break;
      }
      final block = headBytes.sublist(offset, offset + blockLength);
      switch (blockType) {
        case 4:
          result = result.merge(_parseVorbisComment(block));
          break;
        case 6:
          result = result.merge(_parseFlacPicture(block));
          break;
        default:
          break;
      }
      offset += blockLength;
    }

    return result.hasAnyTag ? result : null;
  }

  static ParsedTagData _parseVorbisComment(Uint8List block) {
    final data = ByteData.sublistView(block);
    if (block.length < 8) {
      return const ParsedTagData();
    }
    var offset = 0;
    final vendorLength = data.getUint32(offset, Endian.little);
    offset += 4 + vendorLength;
    if (offset + 4 > block.length) {
      return const ParsedTagData();
    }
    final commentCount = data.getUint32(offset, Endian.little);
    offset += 4;

    ParsedTagData result = const ParsedTagData();
    for (var i = 0; i < commentCount; i++) {
      if (offset + 4 > block.length) {
        break;
      }
      final commentLength = data.getUint32(offset, Endian.little);
      offset += 4;
      if (offset + commentLength > block.length) {
        break;
      }
      final raw = utf8.decode(block.sublist(offset, offset + commentLength));
      offset += commentLength;
      final separator = raw.indexOf('=');
      if (separator <= 0) {
        continue;
      }
      final key = raw.substring(0, separator).toUpperCase();
      final value = raw.substring(separator + 1).trim();
      switch (key) {
        case 'TITLE':
          result = result.merge(ParsedTagData(title: value));
          break;
        case 'ARTIST':
          result = result.merge(ParsedTagData(artist: value));
          break;
        case 'ALBUM':
          result = result.merge(ParsedTagData(album: value));
          break;
        case 'ALBUMARTIST':
          result = result.merge(ParsedTagData(albumArtist: value));
          break;
        case 'GENRE':
          result = result.merge(ParsedTagData(genre: value));
          break;
        case 'DATE':
        case 'YEAR':
          result = result.merge(ParsedTagData(year: _parseLeadingInt(value)));
          break;
        case 'TRACKNUMBER':
          result = result.merge(
            ParsedTagData(trackNumber: _parseLeadingInt(value)),
          );
          break;
        case 'DISCNUMBER':
          result = result.merge(
            ParsedTagData(discNumber: _parseLeadingInt(value)),
          );
          break;
        default:
          break;
      }
    }
    return result;
  }

  static ParsedTagData _parseFlacPicture(Uint8List block) {
    final data = ByteData.sublistView(block);
    if (block.length < 32) {
      return const ParsedTagData();
    }
    var offset = 4;
    final mimeLength = data.getUint32(offset, Endian.big);
    offset += 4;
    if (offset + mimeLength > block.length) {
      return const ParsedTagData();
    }
    final mimeType = utf8.decode(block.sublist(offset, offset + mimeLength));
    offset += mimeLength;
    if (offset + 4 > block.length) {
      return const ParsedTagData();
    }
    final descriptionLength = data.getUint32(offset, Endian.big);
    offset += 4 + descriptionLength;
    offset += 16;
    if (offset + 4 > block.length) {
      return const ParsedTagData();
    }
    final pictureLength = data.getUint32(offset, Endian.big);
    offset += 4;
    if (offset + pictureLength > block.length) {
      return const ParsedTagData();
    }
    return ParsedTagData(
      artworkBytes: Uint8List.fromList(
        block.sublist(offset, offset + pictureLength),
      ),
      artworkMimeType: mimeType,
    );
  }

  static ParsedTagData? _parseWav(Uint8List headBytes) {
    if (headBytes.length < 12 ||
        ascii.decode(headBytes.sublist(0, 4), allowInvalid: true) != 'RIFF' ||
        ascii.decode(headBytes.sublist(8, 12), allowInvalid: true) != 'WAVE') {
      return null;
    }

    var offset = 12;
    ParsedTagData result = const ParsedTagData();
    while (offset + 8 <= headBytes.length) {
      final chunkId = ascii.decode(
        headBytes.sublist(offset, offset + 4),
        allowInvalid: true,
      );
      final chunkSize = ByteData.sublistView(
        headBytes,
        offset + 4,
        offset + 8,
      ).getUint32(0, Endian.little);
      offset += 8;
      if (offset + chunkSize > headBytes.length) {
        break;
      }
      final chunkData = headBytes.sublist(offset, offset + chunkSize);
      if (chunkId == 'LIST' &&
          chunkData.length >= 4 &&
          ascii.decode(chunkData.sublist(0, 4), allowInvalid: true) == 'INFO') {
        result = result.merge(_parseWavInfo(chunkData.sublist(4)));
      }
      offset += chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    return result.hasAnyTag ? result : null;
  }

  static ParsedTagData _parseWavInfo(Uint8List infoBytes) {
    var offset = 0;
    ParsedTagData result = const ParsedTagData();
    while (offset + 8 <= infoBytes.length) {
      final id = ascii.decode(
        infoBytes.sublist(offset, offset + 4),
        allowInvalid: true,
      );
      final size = ByteData.sublistView(
        infoBytes,
        offset + 4,
        offset + 8,
      ).getUint32(0, Endian.little);
      offset += 8;
      if (offset + size > infoBytes.length) {
        break;
      }
      final value = _trimLegacyText(infoBytes.sublist(offset, offset + size));
      switch (id) {
        case 'INAM':
          result = result.merge(ParsedTagData(title: value));
          break;
        case 'IART':
          result = result.merge(ParsedTagData(artist: value));
          break;
        case 'IPRD':
          result = result.merge(ParsedTagData(album: value));
          break;
        case 'IGNR':
          result = result.merge(ParsedTagData(genre: value));
          break;
        case 'ICRD':
          result = result.merge(ParsedTagData(year: _parseLeadingInt(value)));
          break;
        default:
          break;
      }
      offset += size + (size.isOdd ? 1 : 0);
    }
    return result;
  }

  static int _readSynchsafeInt(Uint8List bytes, int offset) {
    return ((bytes[offset] & 0x7f) << 21) |
        ((bytes[offset + 1] & 0x7f) << 14) |
        ((bytes[offset + 2] & 0x7f) << 7) |
        (bytes[offset + 3] & 0x7f);
  }

  static int _readUint32(Uint8List bytes, int offset) {
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  static String? _decodeId3Text(Uint8List frameData) {
    if (frameData.length <= 1) {
      return null;
    }
    final encoding = frameData[0];
    final textBytes = frameData.sublist(1);
    return switch (encoding) {
      0 => decodeLegacySingleByteText(textBytes),
      1 => _trimString(_decodeUtf16(textBytes, expectBom: true)),
      2 => _trimString(
        _decodeUtf16(textBytes, expectBom: false, bigEndian: true),
      ),
      _ => _trimString(utf8.decode(textBytes, allowMalformed: true)),
    };
  }

  static String _decodeUtf16(
    Uint8List bytes, {
    required bool expectBom,
    bool bigEndian = false,
  }) {
    var offset = 0;
    var endian = bigEndian ? Endian.big : Endian.little;
    if (expectBom && bytes.length >= 2) {
      final bom = (bytes[0] << 8) | bytes[1];
      if (bom == 0xfeff) {
        endian = Endian.big;
        offset = 2;
      } else if (bom == 0xfffe) {
        endian = Endian.little;
        offset = 2;
      }
    }
    final codeUnits = <int>[];
    for (var i = offset; i + 1 < bytes.length; i += 2) {
      final value = ByteData.sublistView(bytes, i, i + 2).getUint16(0, endian);
      if (value == 0) {
        break;
      }
      codeUnits.add(value);
    }
    return String.fromCharCodes(codeUnits);
  }

  static int _findTerminator(Uint8List bytes, int offset, int encoding) {
    if (encoding == 0 || encoding == 3) {
      while (offset < bytes.length && bytes[offset] != 0) {
        offset++;
      }
      return offset + 1;
    }

    while (offset + 1 < bytes.length) {
      if (bytes[offset] == 0 && bytes[offset + 1] == 0) {
        return offset + 2;
      }
      offset += 2;
    }
    return bytes.length;
  }

  static String? _trimLegacyText(Uint8List bytes) {
    return decodeLegacySingleByteText(bytes);
  }

  static String? _trimString(String? value) {
    final trimmed = value?.replaceAll('\u0000', '').trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static int? _parseLeadingInt(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final match = RegExp(r'\d{1,4}').firstMatch(value);
    return match == null ? null : int.tryParse(match.group(0)!);
  }
}

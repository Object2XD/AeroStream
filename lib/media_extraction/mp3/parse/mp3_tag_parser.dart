import 'dart:convert';
import 'dart:typed_data';

import '../../core/legacy_text_decoder.dart';

class Mp3ParsedTagData {
  const Mp3ParsedTagData({
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.trackNumber,
    this.discNumber,
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
  final Uint8List? artworkBytes;
  final String? artworkMimeType;

  bool get hasAnyData =>
      title != null ||
      artist != null ||
      album != null ||
      albumArtist != null ||
      genre != null ||
      year != null ||
      trackNumber != null ||
      discNumber != null ||
      artworkBytes != null;

  bool get hasAnyMetadata =>
      title != null ||
      artist != null ||
      album != null ||
      albumArtist != null ||
      genre != null ||
      year != null ||
      trackNumber != null ||
      discNumber != null;

  Mp3ParsedTagData merge(Mp3ParsedTagData other) {
    return Mp3ParsedTagData(
      title: title ?? other.title,
      artist: artist ?? other.artist,
      album: album ?? other.album,
      albumArtist: albumArtist ?? other.albumArtist,
      genre: genre ?? other.genre,
      year: year ?? other.year,
      trackNumber: trackNumber ?? other.trackNumber,
      discNumber: discNumber ?? other.discNumber,
      artworkBytes: artworkBytes ?? other.artworkBytes,
      artworkMimeType: artworkMimeType ?? other.artworkMimeType,
    );
  }
}

class Mp3Id3Header {
  const Mp3Id3Header({
    required this.versionMajor,
    required this.versionRevision,
    required this.flags,
    required this.tagSize,
  });

  final int versionMajor;
  final int versionRevision;
  final int flags;
  final int tagSize;

  bool get hasFooter => versionMajor == 4 && (flags & 0x10) != 0;

  int get headerLength => 10;

  int get totalSize => headerLength + tagSize + (hasFooter ? 10 : 0);

  int get frameDataOffset => headerLength;
}

class Mp3Id3FrameHeader {
  const Mp3Id3FrameHeader({
    required this.id,
    required this.size,
    required this.flags,
    required this.offset,
  });

  final String id;
  final int size;
  final int flags;
  final int offset;

  int get headerLength => 10;

  int get dataOffset => offset + headerLength;

  int get endExclusive => dataOffset + size;

  bool get isPadding =>
      id.trim().isEmpty || id == '\u0000\u0000\u0000\u0000' || size <= 0;
}

class Mp3TagParser {
  const Mp3TagParser._();

  static const id3v1FooterLength = 128;
  static const id3HeaderLength = 10;
  static const id3FrameHeaderLength = 10;

  static const Set<String> metadataFrameIds = <String>{
    'TIT2',
    'TPE1',
    'TALB',
    'TPE2',
    'TCON',
    'TRCK',
    'TPOS',
    'TDRC',
    'TYER',
  };

  static Mp3ParsedTagData? parse({
    required Uint8List headBytes,
    Uint8List? tailBytes,
    bool includeArtwork = true,
  }) {
    final headParsed = parseId3v2(headBytes, includeArtwork: includeArtwork);
    final tailParsed = tailBytes == null ? null : parseId3v1(tailBytes);
    final merged = switch ((headParsed, tailParsed)) {
      (null, null) => null,
      (final head?, null) => head,
      (null, final tail?) => tail,
      (final head?, final tail?) => head.merge(tail),
    };
    if (merged == null || !merged.hasAnyData) {
      return null;
    }
    return merged;
  }

  static Mp3Id3Header? parseId3Header(Uint8List bytes) {
    if (bytes.length < id3HeaderLength ||
        ascii.decode(bytes.sublist(0, 3), allowInvalid: true) != 'ID3') {
      return null;
    }
    return Mp3Id3Header(
      versionMajor: bytes[3],
      versionRevision: bytes[4],
      flags: bytes[5],
      tagSize: _readSynchsafeInt(bytes, 6),
    );
  }

  static Mp3Id3FrameHeader? parseId3FrameHeader(
    Uint8List bytes, {
    required int versionMajor,
    required int offset,
  }) {
    if (bytes.length < id3FrameHeaderLength) {
      return null;
    }
    final id = ascii.decode(bytes.sublist(0, 4), allowInvalid: true);
    if (id.trim().isEmpty || id == '\u0000\u0000\u0000\u0000') {
      return Mp3Id3FrameHeader(id: id, size: 0, flags: 0, offset: offset);
    }
    final size = switch (versionMajor) {
      4 => _readSynchsafeInt(bytes, 4),
      _ => _readUint32(bytes, 4),
    };
    final flags = (bytes[8] << 8) | bytes[9];
    return Mp3Id3FrameHeader(id: id, size: size, flags: flags, offset: offset);
  }

  static Mp3ParsedTagData? parseId3v2(
    Uint8List headBytes, {
    required bool includeArtwork,
  }) {
    final header = parseId3Header(headBytes);
    if (header == null) {
      return null;
    }

    final available = headBytes.length >= header.totalSize
        ? header.totalSize
        : headBytes.length;
    var offset = header.frameDataOffset;
    Mp3ParsedTagData parsed = const Mp3ParsedTagData();

    while (offset + id3FrameHeaderLength <= available) {
      final frameHeader = parseId3FrameHeader(
        headBytes.sublist(offset, offset + id3FrameHeaderLength),
        versionMajor: header.versionMajor,
        offset: offset,
      );
      if (frameHeader == null || frameHeader.isPadding) {
        break;
      }
      if (frameHeader.endExclusive > available) {
        break;
      }

      final frameData = headBytes.sublist(
        frameHeader.dataOffset,
        frameHeader.endExclusive,
      );
      parsed = parsed.merge(
        parseId3Frame(
          frameHeader.id,
          frameData,
          includeArtwork: includeArtwork,
        ),
      );
      offset = frameHeader.endExclusive;
    }

    if (!parsed.hasAnyData) {
      return null;
    }
    return parsed;
  }

  static Mp3ParsedTagData? parseId3v1(Uint8List tailBytes) {
    if (tailBytes.length < id3v1FooterLength) {
      return null;
    }

    final last128 = tailBytes.sublist(tailBytes.length - id3v1FooterLength);
    if (ascii.decode(last128.sublist(0, 3), allowInvalid: true) != 'TAG') {
      return null;
    }

    final parsed = Mp3ParsedTagData(
      title: decodeLegacySingleByteText(last128.sublist(3, 33)),
      artist: decodeLegacySingleByteText(last128.sublist(33, 63)),
      album: decodeLegacySingleByteText(last128.sublist(63, 93)),
      year: int.tryParse(
        decodeLegacySingleByteText(last128.sublist(93, 97)) ?? '',
      ),
      trackNumber: last128[125] == 0 ? last128[126] : null,
    );
    if (!parsed.hasAnyData) {
      return null;
    }
    return parsed;
  }

  static Mp3ParsedTagData parseId3Frame(
    String frameId,
    Uint8List frameData, {
    required bool includeArtwork,
  }) {
    if (frameData.isEmpty) {
      return const Mp3ParsedTagData();
    }

    switch (frameId) {
      case 'TIT2':
        return Mp3ParsedTagData(title: _decodeId3Text(frameData));
      case 'TPE1':
        return Mp3ParsedTagData(artist: _decodeId3Text(frameData));
      case 'TALB':
        return Mp3ParsedTagData(album: _decodeId3Text(frameData));
      case 'TPE2':
        return Mp3ParsedTagData(albumArtist: _decodeId3Text(frameData));
      case 'TCON':
        return Mp3ParsedTagData(genre: _decodeId3Text(frameData));
      case 'TRCK':
        return Mp3ParsedTagData(
          trackNumber: _parseLeadingInt(_decodeId3Text(frameData)),
        );
      case 'TPOS':
        return Mp3ParsedTagData(
          discNumber: _parseLeadingInt(_decodeId3Text(frameData)),
        );
      case 'TDRC':
      case 'TYER':
        return Mp3ParsedTagData(
          year: _parseLeadingInt(_decodeId3Text(frameData)),
        );
      case 'APIC':
        return includeArtwork
            ? parseApicFrame(frameData)
            : const Mp3ParsedTagData();
      default:
        return const Mp3ParsedTagData();
    }
  }

  static Mp3ParsedTagData parseApicFrame(Uint8List frameData) {
    if (frameData.isEmpty) {
      return const Mp3ParsedTagData();
    }
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
      return const Mp3ParsedTagData();
    }

    offset++;
    final descriptionEnd = _findTerminator(frameData, offset, encoding);
    offset = descriptionEnd;
    final artwork = frameData.sublist(offset);
    if (artwork.isEmpty) {
      return const Mp3ParsedTagData();
    }

    return Mp3ParsedTagData(
      artworkBytes: Uint8List.fromList(artwork),
      artworkMimeType: mimeType.isEmpty ? 'image/jpeg' : mimeType,
    );
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
    for (var index = offset; index + 1 < bytes.length; index += 2) {
      final value = ByteData.sublistView(
        bytes,
        index,
        index + 2,
      ).getUint16(0, endian);
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
}

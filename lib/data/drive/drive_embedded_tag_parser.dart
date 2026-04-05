import 'dart:convert';
import 'dart:typed_data';

import '../../media_extraction/mp3/parse/mp3_tag_parser.dart';
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
      durationMs != null ||
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
    int? fileSize,
    bool includeArtwork = true,
  }) {
    final lowerName = fileName.toLowerCase();
    if (mimeType == 'audio/mpeg' || lowerName.endsWith('.mp3')) {
      return _parseMp3WithSharedParser(
        headBytes,
        tailBytes,
        includeArtwork: includeArtwork,
      );
    }
    if (mimeType == 'audio/flac' || lowerName.endsWith('.flac')) {
      return _parseFlac(headBytes, includeArtwork: includeArtwork);
    }
    if (mimeType == 'audio/wav' ||
        mimeType == 'audio/x-wav' ||
        lowerName.endsWith('.wav')) {
      return _parseWav(headBytes);
    }
    if (mimeType == 'audio/mp4' ||
        mimeType == 'audio/x-m4a' ||
        lowerName.endsWith('.m4a') ||
        lowerName.endsWith('.mp4')) {
      return _parseMp4(
        headBytes,
        tailBytes,
        fileSize: fileSize,
        includeArtwork: includeArtwork,
      );
    }
    return null;
  }

  static ParsedTagData? _parseMp3WithSharedParser(
    Uint8List headBytes,
    Uint8List tailBytes, {
    required bool includeArtwork,
  }) {
    final parsed = Mp3TagParser.parse(
      headBytes: headBytes,
      tailBytes: tailBytes,
      includeArtwork: includeArtwork,
    );
    if (parsed == null || !parsed.hasAnyData) {
      return null;
    }
    return ParsedTagData(
      title: parsed.title,
      artist: parsed.artist,
      album: parsed.album,
      albumArtist: parsed.albumArtist,
      genre: parsed.genre,
      year: parsed.year,
      trackNumber: parsed.trackNumber,
      discNumber: parsed.discNumber,
      artworkBytes: parsed.artworkBytes,
      artworkMimeType: parsed.artworkMimeType,
    );
  }

  static ParsedTagData? _parseFlac(
    Uint8List headBytes, {
    required bool includeArtwork,
  }) {
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
          if (includeArtwork) {
            result = result.merge(_parseFlacPicture(block));
          }
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

  static ParsedTagData? _parseMp4(
    Uint8List headBytes,
    Uint8List tailBytes, {
    required int? fileSize,
    required bool includeArtwork,
  }) {
    final resolvedFileSize = fileSize ?? headBytes.length;
    if (resolvedFileSize <= 0) {
      return null;
    }

    final tailStart = tailBytes.isEmpty
        ? resolvedFileSize
        : resolvedFileSize - tailBytes.length;
    final view = _SegmentedFileView(
      fileSize: resolvedFileSize,
      segments: <_ByteSegment>[
        _ByteSegment(fileOffset: 0, bytes: headBytes),
        if (tailBytes.isNotEmpty && tailStart >= headBytes.length)
          _ByteSegment(fileOffset: tailStart, bytes: tailBytes),
      ],
    );
    final moovBox = view.findTopLevelBox('moov');
    if (moovBox == null) {
      return null;
    }
    final moovBytes = view.read(moovBox.offset, moovBox.size);
    if (moovBytes == null) {
      return null;
    }
    return _parseMp4Moov(moovBytes, includeArtwork: includeArtwork);
  }

  static ParsedTagData? _parseMp4Moov(
    Uint8List moovBytes, {
    required bool includeArtwork,
  }) {
    ParsedTagData result = const ParsedTagData();
    var durationMs = _findMp4Duration(
      moovBytes,
      start: 8,
      end: moovBytes.length,
    );

    void walk(int start, int end) {
      var offset = start;
      while (offset < end) {
        final box = _readMp4Box(moovBytes, offset, end);
        if (box == null) {
          break;
        }
        switch (box.type) {
          case 'mvhd':
            durationMs ??= _parseMvhdDuration(moovBytes, box);
            break;
          case 'trak':
          case 'mdia':
          case 'udta':
          case 'moov':
            walk(box.dataOffset, box.end);
            break;
          case 'meta':
            walk(box.dataOffset + 4, box.end);
            break;
          case 'ilst':
            result = result.merge(
              _parseMp4Ilst(
                moovBytes,
                start: box.dataOffset,
                end: box.end,
                includeArtwork: includeArtwork,
              ),
            );
            break;
          default:
            break;
        }
        offset = box.end;
      }
    }

    walk(8, moovBytes.length);
    if (durationMs != null) {
      result = result.merge(ParsedTagData(durationMs: durationMs));
    }
    return result.hasAnyTag ? result : null;
  }

  static ParsedTagData _parseMp4Ilst(
    Uint8List bytes, {
    required int start,
    required int end,
    required bool includeArtwork,
  }) {
    ParsedTagData result = const ParsedTagData();
    var offset = start;
    while (offset < end) {
      final item = _readMp4Box(bytes, offset, end);
      if (item == null) {
        break;
      }
      result = result.merge(
        _parseMp4MetadataItem(bytes, item, includeArtwork: includeArtwork),
      );
      offset = item.end;
    }
    return result;
  }

  static ParsedTagData _parseMp4MetadataItem(
    Uint8List bytes,
    _Mp4Box item, {
    required bool includeArtwork,
  }) {
    final dataBox = _findChildBox(bytes, item.dataOffset, item.end, 'data');
    if (dataBox == null || dataBox.payloadLength < 8) {
      return const ParsedTagData();
    }
    final data = ByteData.sublistView(
      bytes,
      dataBox.dataOffset,
      dataBox.dataOffset + 8,
    );
    final dataType = data.getUint32(0, Endian.big);
    final payload = bytes.sublist(dataBox.dataOffset + 8, dataBox.end);
    switch (item.type) {
      case '\u00a9nam':
        return ParsedTagData(title: _decodeMp4Text(payload));
      case '\u00a9ART':
        return ParsedTagData(artist: _decodeMp4Text(payload));
      case '\u00a9alb':
        return ParsedTagData(album: _decodeMp4Text(payload));
      case 'aART':
        return ParsedTagData(albumArtist: _decodeMp4Text(payload));
      case '\u00a9gen':
        return ParsedTagData(genre: _decodeMp4Text(payload));
      case '\u00a9day':
        return ParsedTagData(year: _parseLeadingInt(_decodeMp4Text(payload)));
      case 'trkn':
        return ParsedTagData(trackNumber: _parseMp4Ordinal(payload));
      case 'disk':
        return ParsedTagData(discNumber: _parseMp4Ordinal(payload));
      case 'covr':
        if (!includeArtwork || payload.isEmpty) {
          return const ParsedTagData();
        }
        final mimeType = switch (dataType) {
          14 => 'image/png',
          27 => 'image/bmp',
          _ => 'image/jpeg',
        };
        return ParsedTagData(
          artworkBytes: Uint8List.fromList(payload),
          artworkMimeType: mimeType,
        );
      default:
        return const ParsedTagData();
    }
  }

  static int? _findMp4Duration(
    Uint8List bytes, {
    required int start,
    required int end,
  }) {
    var durationMs = _findDurationInBoxes(bytes, start: start, end: end);
    if (durationMs != null) {
      return durationMs;
    }
    return null;
  }

  static int? _findDurationInBoxes(
    Uint8List bytes, {
    required int start,
    required int end,
  }) {
    var offset = start;
    while (offset < end) {
      final box = _readMp4Box(bytes, offset, end);
      if (box == null) {
        break;
      }
      switch (box.type) {
        case 'mvhd':
          return _parseMvhdDuration(bytes, box);
        case 'mdhd':
          return _parseMdhdDuration(bytes, box);
        case 'meta':
          final nested = _findDurationInBoxes(
            bytes,
            start: box.dataOffset + 4,
            end: box.end,
          );
          if (nested != null) {
            return nested;
          }
          break;
        case 'trak':
        case 'mdia':
        case 'moov':
        case 'udta':
          final nested = _findDurationInBoxes(
            bytes,
            start: box.dataOffset,
            end: box.end,
          );
          if (nested != null) {
            return nested;
          }
          break;
        default:
          break;
      }
      offset = box.end;
    }
    return null;
  }

  static int? _parseMvhdDuration(Uint8List bytes, _Mp4Box box) {
    if (box.payloadLength < 20) {
      return null;
    }
    final version = bytes[box.dataOffset];
    final timescaleOffset = box.dataOffset + (version == 1 ? 20 : 12);
    final durationOffset = box.dataOffset + (version == 1 ? 24 : 16);
    if (durationOffset + (version == 1 ? 8 : 4) > box.end) {
      return null;
    }
    final timescale = ByteData.sublistView(
      bytes,
      timescaleOffset,
      timescaleOffset + 4,
    ).getUint32(0, Endian.big);
    if (timescale == 0) {
      return null;
    }
    final duration = version == 1
        ? _readUint64(bytes, durationOffset)
        : ByteData.sublistView(
            bytes,
            durationOffset,
            durationOffset + 4,
          ).getUint32(0, Endian.big);
    if (duration <= 0) {
      return null;
    }
    return ((duration * 1000) ~/ timescale).toInt();
  }

  static int? _parseMdhdDuration(Uint8List bytes, _Mp4Box box) {
    if (box.payloadLength < 20) {
      return null;
    }
    final version = bytes[box.dataOffset];
    final timescaleOffset = box.dataOffset + (version == 1 ? 16 : 12);
    final durationOffset = box.dataOffset + (version == 1 ? 20 : 16);
    if (durationOffset + (version == 1 ? 8 : 4) > box.end) {
      return null;
    }
    final timescale = ByteData.sublistView(
      bytes,
      timescaleOffset,
      timescaleOffset + 4,
    ).getUint32(0, Endian.big);
    if (timescale == 0) {
      return null;
    }
    final duration = version == 1
        ? _readUint64(bytes, durationOffset)
        : ByteData.sublistView(
            bytes,
            durationOffset,
            durationOffset + 4,
          ).getUint32(0, Endian.big);
    if (duration <= 0) {
      return null;
    }
    return ((duration * 1000) ~/ timescale).toInt();
  }

  static _Mp4Box? _findChildBox(
    Uint8List bytes,
    int start,
    int end,
    String type,
  ) {
    var offset = start;
    while (offset < end) {
      final box = _readMp4Box(bytes, offset, end);
      if (box == null) {
        break;
      }
      if (box.type == type) {
        return box;
      }
      offset = box.end;
    }
    return null;
  }

  static _Mp4Box? _readMp4Box(Uint8List bytes, int offset, int end) {
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
      size = _readUint64(bytes, offset + 8);
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

  static int _readUint64(Uint8List bytes, int offset) {
    final data = ByteData.sublistView(bytes, offset, offset + 8);
    final high = data.getUint32(0, Endian.big);
    final low = data.getUint32(4, Endian.big);
    return (high << 32) | low;
  }

  static String? _decodeMp4Text(Uint8List payload) {
    if (payload.isEmpty) {
      return null;
    }
    final decoded = utf8.decode(payload, allowMalformed: true).trim();
    if (decoded.isNotEmpty) {
      return decoded;
    }
    final fallback = latin1.decode(payload, allowInvalid: true).trim();
    return fallback.isEmpty ? null : fallback;
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

  static String? _trimLegacyText(Uint8List bytes) {
    return decodeLegacySingleByteText(bytes);
  }

  static int? _parseLeadingInt(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final match = RegExp(r'\d{1,4}').firstMatch(value);
    return match == null ? null : int.tryParse(match.group(0)!);
  }
}

class _ByteSegment {
  const _ByteSegment({required this.fileOffset, required this.bytes});

  final int fileOffset;
  final Uint8List bytes;

  int get endOffset => fileOffset + bytes.length;

  bool contains(int offset, int length) {
    return offset >= fileOffset && offset + length <= endOffset;
  }
}

class _SegmentedFileView {
  const _SegmentedFileView({required this.fileSize, required this.segments});

  final int fileSize;
  final List<_ByteSegment> segments;

  Uint8List? read(int offset, int length) {
    if (offset < 0 || length < 0 || offset + length > fileSize) {
      return null;
    }
    for (final segment in segments) {
      if (segment.contains(offset, length)) {
        final start = offset - segment.fileOffset;
        return Uint8List.fromList(segment.bytes.sublist(start, start + length));
      }
    }
    return null;
  }

  _Mp4Box? findTopLevelBox(String type) {
    final sorted = [...segments]
      ..sort((left, right) => left.fileOffset.compareTo(right.fileOffset));
    var offset = 0;
    for (final segment in sorted) {
      if (offset < segment.fileOffset || offset >= segment.endOffset) {
        continue;
      }
      while (offset + 8 <= fileSize) {
        final header = read(offset, 16) ?? read(offset, 8);
        if (header == null) {
          break;
        }
        final size32 = ByteData.sublistView(
          header,
          0,
          4,
        ).getUint32(0, Endian.big);
        final resolvedType = latin1.decode(header.sublist(4, 8));
        var headerSize = 8;
        int size;
        if (size32 == 1) {
          if (header.length < 16) {
            break;
          }
          size = DriveEmbeddedTagParser._readUint64(header, 8);
          headerSize = 16;
        } else if (size32 == 0) {
          size = fileSize - offset;
        } else {
          size = size32;
        }
        if (size < headerSize || offset + size > fileSize) {
          break;
        }
        final resolved = _Mp4Box(
          offset: offset,
          size: size,
          headerSize: headerSize,
          type: resolvedType,
        );
        if (resolved.type == type) {
          return resolved;
        }
        offset = resolved.end;
        if (offset < segment.fileOffset || offset >= segment.endOffset) {
          break;
        }
      }
    }
    return null;
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

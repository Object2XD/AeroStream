import 'dart:convert';
import 'dart:typed_data';

import 'package:aero_stream/media_extraction/core/byte_range.dart';
import 'package:aero_stream/media_extraction/core/byte_range_reader.dart';

class Mp3TestFrame {
  const Mp3TestFrame({
    required this.id,
    required this.headerRange,
    required this.payloadRange,
  });

  final String id;
  final ByteRange headerRange;
  final ByteRange payloadRange;
}

class Mp3TestFile {
  const Mp3TestFile({
    required this.bytes,
    required this.frames,
    required this.id3HeaderRange,
    required this.id3v1Range,
  });

  final Uint8List bytes;
  final Map<String, Mp3TestFrame> frames;
  final ByteRange? id3HeaderRange;
  final ByteRange? id3v1Range;

  Mp3TestFrame frame(String id) {
    final frame = frames[id];
    if (frame == null) {
      throw StateError('Missing frame: $id');
    }
    return frame;
  }
}

Uint8List buildMp3Bytes({
  String? title,
  String? artist,
  String? album,
  String? albumArtist,
  String? genre,
  int? year,
  int? trackNumber,
  int? discNumber,
  Uint8List? artworkBytes,
  String artworkMimeType = 'image/jpeg',
  List<int> Function(String text)? titleEncoder,
  List<int> Function(String text)? artistEncoder,
  List<int> Function(String text)? albumEncoder,
  List<int> Function(String text)? albumArtistEncoder,
  List<int> Function(String text)? genreEncoder,
  bool includeId3v2 = true,
  int audioPaddingBytes = 32,
  String? id3v1Title,
  String? id3v1Artist,
  String? id3v1Album,
  int? id3v1Year,
  int? id3v1TrackNumber,
}) {
  return buildMp3Fixture(
    title: title,
    artist: artist,
    album: album,
    albumArtist: albumArtist,
    genre: genre,
    year: year,
    trackNumber: trackNumber,
    discNumber: discNumber,
    artworkBytes: artworkBytes,
    artworkMimeType: artworkMimeType,
    titleEncoder: titleEncoder,
    artistEncoder: artistEncoder,
    albumEncoder: albumEncoder,
    albumArtistEncoder: albumArtistEncoder,
    genreEncoder: genreEncoder,
    includeId3v2: includeId3v2,
    audioPaddingBytes: audioPaddingBytes,
    id3v1Title: id3v1Title,
    id3v1Artist: id3v1Artist,
    id3v1Album: id3v1Album,
    id3v1Year: id3v1Year,
    id3v1TrackNumber: id3v1TrackNumber,
  ).bytes;
}

Mp3TestFile buildMp3Fixture({
  String? title,
  String? artist,
  String? album,
  String? albumArtist,
  String? genre,
  int? year,
  int? trackNumber,
  int? discNumber,
  Uint8List? artworkBytes,
  String artworkMimeType = 'image/jpeg',
  List<int> Function(String text)? titleEncoder,
  List<int> Function(String text)? artistEncoder,
  List<int> Function(String text)? albumEncoder,
  List<int> Function(String text)? albumArtistEncoder,
  List<int> Function(String text)? genreEncoder,
  bool includeId3v2 = true,
  int audioPaddingBytes = 32,
  String? id3v1Title,
  String? id3v1Artist,
  String? id3v1Album,
  int? id3v1Year,
  int? id3v1TrackNumber,
}) {
  final builtFrames = <_BuiltFrame>[
    if (title != null)
      _BuiltFrame(
        id: 'TIT2',
        bytes: _textFrame('TIT2', title, encoder: titleEncoder),
      ),
    if (artist != null)
      _BuiltFrame(
        id: 'TPE1',
        bytes: _textFrame('TPE1', artist, encoder: artistEncoder),
      ),
    if (album != null)
      _BuiltFrame(
        id: 'TALB',
        bytes: _textFrame('TALB', album, encoder: albumEncoder),
      ),
    if (albumArtist != null)
      _BuiltFrame(
        id: 'TPE2',
        bytes: _textFrame('TPE2', albumArtist, encoder: albumArtistEncoder),
      ),
    if (genre != null)
      _BuiltFrame(
        id: 'TCON',
        bytes: _textFrame('TCON', genre, encoder: genreEncoder),
      ),
    if (year != null)
      _BuiltFrame(id: 'TYER', bytes: _textFrame('TYER', '$year')),
    if (trackNumber != null)
      _BuiltFrame(id: 'TRCK', bytes: _textFrame('TRCK', '$trackNumber')),
    if (discNumber != null)
      _BuiltFrame(id: 'TPOS', bytes: _textFrame('TPOS', '$discNumber')),
    if (artworkBytes != null)
      _BuiltFrame(
        id: 'APIC',
        bytes: _apicFrame(artworkBytes, mimeType: artworkMimeType),
      ),
  ];
  final frames = <String, Mp3TestFrame>{};
  var frameOffset = includeId3v2 ? 10 : 0;
  for (final builtFrame in builtFrames) {
    frames[builtFrame.id] = Mp3TestFrame(
      id: builtFrame.id,
      headerRange: ByteRange(frameOffset, frameOffset + 10),
      payloadRange: ByteRange(
        frameOffset + 10,
        frameOffset + builtFrame.bytes.length,
      ),
    );
    frameOffset += builtFrame.bytes.length;
  }

  final frameBytes = <int>[
    for (final builtFrame in builtFrames) ...builtFrame.bytes,
  ];
  final hasId3v1 =
      id3v1Title != null ||
      id3v1Artist != null ||
      id3v1Album != null ||
      id3v1Year != null ||
      id3v1TrackNumber != null;
  final id3v1Range = hasId3v1
      ? ByteRange(
          (includeId3v2 ? 10 + frameBytes.length : 0) + audioPaddingBytes,
          (includeId3v2 ? 10 + frameBytes.length : 0) + audioPaddingBytes + 128,
        )
      : null;

  return Mp3TestFile(
    bytes: Uint8List.fromList([
      if (includeId3v2) ...<int>[
        ...ascii.encode('ID3'),
        3,
        0,
        0,
        ..._synchsafe(frameBytes.length),
        ...frameBytes,
      ],
      ...List<int>.filled(audioPaddingBytes, 0),
      if (hasId3v1)
        ..._id3v1Tag(
          title: id3v1Title,
          artist: id3v1Artist,
          album: id3v1Album,
          year: id3v1Year,
          trackNumber: id3v1TrackNumber,
        ),
    ]),
    frames: frames,
    id3HeaderRange: includeId3v2 ? const ByteRange(0, 10) : null,
    id3v1Range: id3v1Range,
  );
}

class _BuiltFrame {
  const _BuiltFrame({required this.id, required this.bytes});

  final String id;
  final List<int> bytes;
}

List<int> _textFrame(
  String id,
  String text, {
  List<int> Function(String text)? encoder,
}) {
  final payload = <int>[0, ...(encoder ?? latin1.encode)(text)];
  return <int>[
    ...ascii.encode(id),
    ..._uint32(payload.length),
    0,
    0,
    ...payload,
  ];
}

List<int> _apicFrame(Uint8List artworkBytes, {required String mimeType}) {
  final payload = <int>[0, ...ascii.encode(mimeType), 0, 3, 0, ...artworkBytes];
  return <int>[
    ...ascii.encode('APIC'),
    ..._uint32(payload.length),
    0,
    0,
    ...payload,
  ];
}

List<int> _id3v1Tag({
  String? title,
  String? artist,
  String? album,
  int? year,
  int? trackNumber,
}) {
  return <int>[
    ...ascii.encode('TAG'),
    ..._fixedLatin1(title, 30),
    ..._fixedLatin1(artist, 30),
    ..._fixedLatin1(album, 30),
    ..._fixedLatin1(year == null ? null : '$year', 4),
    ...List<int>.filled(28, 0),
    0,
    trackNumber ?? 0,
    0,
  ];
}

List<int> _fixedLatin1(String? value, int length) {
  final encoded = value == null ? const <int>[] : latin1.encode(value);
  final truncated = encoded.length > length
      ? encoded.sublist(0, length)
      : encoded;
  return <int>[...truncated, ...List<int>.filled(length - truncated.length, 0)];
}

List<int> _synchsafe(int value) {
  return <int>[
    (value >> 21) & 0x7f,
    (value >> 14) & 0x7f,
    (value >> 7) & 0x7f,
    value & 0x7f,
  ];
}

List<int> _uint32(int value) {
  return <int>[
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];
}

class MemoryByteRangeReader implements ByteRangeReader {
  MemoryByteRangeReader(this.bytes);

  final Uint8List bytes;
  final List<ByteRange> reads = <ByteRange>[];

  @override
  Future<Uint8List> read(ByteRange range) async {
    reads.add(range);
    return Uint8List.fromList(bytes.sublist(range.start, range.endExclusive));
  }
}

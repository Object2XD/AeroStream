import 'dart:convert';
import 'dart:typed_data';

import 'package:aero_stream/media_extraction/core/byte_range.dart';
import 'package:aero_stream/media_extraction/core/byte_range_reader.dart';

Uint8List buildM4aBytes({
  required String title,
  required String artist,
  String album = 'Range Album',
  String albumArtist = 'Range Album Artist',
  String genre = 'Pop',
  int year = 2024,
  int trackNumber = 1,
  int discNumber = 1,
  int durationMs = 180000,
  int mdatPaddingBytes = 32,
  int trackPaddingBytes = 0,
  int moovMetadataPaddingBytes = 0,
  int metaPaddingBytes = 0,
  int moovPaddingBytes = 0,
  bool metaAtMoovRoot = false,
  Uint8List? artworkBytes,
  List<List<int>> topLevelBoxesAfterMdat = const <List<int>>[],
  List<List<int>> extraIlstItemsBeforeArtwork = const <List<int>>[],
  List<List<int>> extraIlstItemsAfterArtwork = const <List<int>>[],
}) {
  final ftyp = mp4Box('ftyp', <int>[
    ...latin1.encode('M4A '),
    ...uint32(0),
    ...latin1.encode('M4A '),
    ...latin1.encode('isom'),
  ]);
  final mvhd = mp4Box('mvhd', <int>[
    0,
    0,
    0,
    0,
    ...uint32(0),
    ...uint32(0),
    ...uint32(1000),
    ...uint32(durationMs),
    ...List<int>.filled(80, 0),
  ]);
  final ilst = mp4Box('ilst', <int>[
    ...mp4TextItem('\u00a9nam', title),
    ...mp4TextItem('\u00a9ART', artist),
    ...mp4TextItem('\u00a9alb', album),
    ...mp4TextItem('aART', albumArtist),
    ...mp4TextItem('\u00a9gen', genre),
    ...mp4TextItem('\u00a9day', '$year'),
    ...mp4OrdinalItem('trkn', trackNumber),
    ...mp4OrdinalItem('disk', discNumber),
    for (final item in extraIlstItemsBeforeArtwork) ...item,
    if (artworkBytes != null) ...mp4CoverItem(artworkBytes),
    for (final item in extraIlstItemsAfterArtwork) ...item,
  ]);
  final meta = mp4Box('meta', <int>[
    0,
    0,
    0,
    0,
    if (metaPaddingBytes > 0) ...List<int>.filled(metaPaddingBytes, 0),
    ...ilst,
  ]);
  final metaContainer = metaAtMoovRoot ? meta : mp4Box('udta', meta);
  final moov = mp4Box('moov', <int>[
    ...mvhd,
    if (trackPaddingBytes > 0)
      ...mp4Box('trak', List<int>.filled(trackPaddingBytes, 0)),
    if (moovMetadataPaddingBytes > 0)
      ...mp4Box('free', List<int>.filled(moovMetadataPaddingBytes, 0)),
    ...metaContainer,
    if (moovPaddingBytes > 0)
      ...mp4Box('free', List<int>.filled(moovPaddingBytes, 0)),
  ]);
  final mdat = mp4Box('mdat', List<int>.filled(mdatPaddingBytes, 0));
  return Uint8List.fromList(<int>[
    ...ftyp,
    ...mdat,
    for (final box in topLevelBoxesAfterMdat) ...box,
    ...moov,
  ]);
}

List<int> mp4TextItem(String type, String text) {
  return mp4Box(type, mp4DataBox(1, utf8.encode(text)));
}

List<int> mp4OrdinalItem(String type, int value) {
  return mp4Box(
    type,
    mp4DataBox(0, <int>[0, 0, (value >> 8) & 0xff, value & 0xff, 0, 0, 0, 0]),
  );
}

List<int> mp4CoverItem(Uint8List artworkBytes) {
  return mp4Box('covr', mp4DataBox(13, artworkBytes));
}

List<int> mp4DataBox(int dataType, List<int> payload) {
  return mp4Box('data', <int>[...uint32(dataType), 0, 0, 0, 0, ...payload]);
}

List<int> mp4Box(String type, List<int> payload) {
  final size = payload.length + 8;
  return <int>[...uint32(size), ...latin1.encode(type), ...payload];
}

List<int> mp4RawBox(
  String type, {
  required int size32,
  List<int> payload = const <int>[],
}) {
  return <int>[...uint32(size32), ...latin1.encode(type), ...payload];
}

List<int> uint32(int value) {
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

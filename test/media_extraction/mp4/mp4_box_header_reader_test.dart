import 'dart:convert';
import 'dart:typed_data';

import 'package:aero_stream/media_extraction/mp4/box_header/mp4_box_header_reader.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mp4_test_fixture.dart';

void main() {
  test('Mp4BoxHeaderReader parses extended-size boxes', () {
    final bytes = Uint8List.fromList(<int>[
      0,
      0,
      0,
      1,
      ...latin1.encode('wide'),
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      24,
      ...List<int>.filled(8, 0),
    ]);

    final header = Mp4BoxHeaderReader.readHeader(bytes, fileSize: bytes.length);

    expect(header, isNotNull);
    expect(header!.type, 'wide');
    expect(header.size, 24);
    expect(header.headerSize, 16);
    expect(header.usesExtendedSize, isTrue);
  });

  test('Mp4BoxHeaderReader parses EOF-sized top-level boxes', () {
    final bytes = Uint8List.fromList(<int>[
      ...uint32(0),
      ...latin1.encode('moov'),
      ...List<int>.filled(20, 0),
    ]);

    final header = Mp4BoxHeaderReader.readHeader(bytes, fileSize: bytes.length);

    expect(header, isNotNull);
    expect(header!.type, 'moov');
    expect(header.size, bytes.length);
    expect(header.extendsToEof, isTrue);
  });
}

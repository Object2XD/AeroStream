import 'dart:typed_data';

import 'package:aero_stream/media_extraction/core/audio_object_descriptor.dart';
import 'package:aero_stream/media_extraction/mp4/top_level/mp4_top_level_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mp4_test_fixture.dart';

void main() {
  test('Mp4TopLevelScanner walks boxes after mdat until moov', () async {
    final bytes = buildM4aBytes(
      title: 'Scanner Title',
      artist: 'Scanner Artist',
      mdatPaddingBytes: 1280000,
      topLevelBoxesAfterMdat: <List<int>>[
        mp4Box('wide', const <int>[]),
        mp4Box('free', List<int>.filled(96 * 1024, 0)),
        mp4Box('zzzz', List<int>.filled(24, 7)),
      ],
    );
    final reader = MemoryByteRangeReader(bytes);
    final descriptor = AudioObjectDescriptor(
      objectId: 'scan-1',
      fileName: 'scan.m4a',
      mimeType: 'audio/mp4',
      sizeBytes: bytes.length,
    );

    final moovBox = await Mp4TopLevelScanner.findMoovBox(
      descriptor: descriptor,
      headBytes: Uint8List.fromList(bytes.sublist(0, 512 * 1024)),
      reader: reader,
    );

    expect(moovBox.type, 'moov');
    expect(reader.reads, isNotEmpty);
  });

  test('Mp4TopLevelScanner fast-fails on invalid top-level headers', () async {
    final bytes = buildM4aBytes(
      title: 'Broken',
      artist: 'Broken',
      mdatPaddingBytes: 1280000,
      topLevelBoxesAfterMdat: <List<int>>[
        mp4RawBox('free', size32: 4),
      ],
    );
    final reader = MemoryByteRangeReader(bytes);
    final descriptor = AudioObjectDescriptor(
      objectId: 'scan-2',
      fileName: 'broken.m4a',
      mimeType: 'audio/mp4',
      sizeBytes: bytes.length,
    );

    await expectLater(
      () => Mp4TopLevelScanner.findMoovBox(
        descriptor: descriptor,
        headBytes: Uint8List.fromList(bytes.sublist(0, 512 * 1024)),
        reader: reader,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'reason',
          contains('mp4_invalid_top_level_box'),
        ),
      ),
    );
  });
}

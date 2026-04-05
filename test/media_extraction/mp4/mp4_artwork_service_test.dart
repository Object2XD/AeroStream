import 'dart:typed_data';

import 'package:aero_stream/media_extraction/core/audio_object_descriptor.dart';
import 'package:aero_stream/media_extraction/core/byte_segment.dart';
import 'package:aero_stream/media_extraction/core/extraction_failure.dart';
import 'package:aero_stream/media_extraction/mp4/service/mp4_artwork_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mp4_test_fixture.dart';

void main() {
  test('Mp4ArtworkService extracts covr artwork by exact range', () async {
    final artworkBytes = Uint8List.fromList(List<int>.filled(64000, 4));
    final bytes = buildM4aBytes(
      title: 'Artwork Title',
      artist: 'Artwork Artist',
      artworkBytes: artworkBytes,
      mdatPaddingBytes: 1280000,
      topLevelBoxesAfterMdat: <List<int>>[
        mp4Box('wide', const <int>[]),
        mp4Box('free', List<int>.filled(96 * 1024, 0)),
      ],
    );
    final headBytes = Uint8List.fromList(
      bytes.sublist(0, Mp4ArtworkService.fixedHeaderWindowBytes),
    );
    final reader = MemoryByteRangeReader(bytes);
    final descriptor = AudioObjectDescriptor(
      objectId: 'artwork-1',
      fileName: 'artwork.m4a',
      mimeType: 'audio/mp4',
      sizeBytes: bytes.length,
    );

    final extracted = await const Mp4ArtworkService().extract(
      descriptor: descriptor,
      reader: reader,
      initialSegments: <ByteSegment>[ByteSegment(start: 0, bytes: headBytes)],
    );

    expect(extracted, isNotNull);
    expect(extracted!.bytes, orderedEquals(artworkBytes));
    expect(extracted.mimeType, 'image/jpeg');
    expect(
      reader.reads.where(
        (range) => range.start >= 28 && range.endExclusive <= 28 + 1280000,
      ),
      isEmpty,
    );
  });

  test('Mp4ArtworkService exposes covr probe and single-range plan', () async {
    final artworkBytes = Uint8List.fromList(List<int>.filled(64000, 4));
    final bytes = buildM4aBytes(
      title: 'Artwork Title',
      artist: 'Artwork Artist',
      artworkBytes: artworkBytes,
      mdatPaddingBytes: 1280000,
      topLevelBoxesAfterMdat: <List<int>>[
        mp4Box('wide', const <int>[]),
        mp4Box('free', List<int>.filled(96 * 1024, 0)),
      ],
    );
    final headBytes = Uint8List.fromList(
      bytes.sublist(0, Mp4ArtworkService.fixedHeaderWindowBytes),
    );
    final reader = MemoryByteRangeReader(bytes);
    final service = const Mp4ArtworkService();

    final probe = await service.probe(
      descriptor: AudioObjectDescriptor(
        objectId: 'artwork-probe',
        fileName: 'artwork.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: bytes.length,
      ),
      reader: reader,
      initialSegments: <ByteSegment>[ByteSegment(start: 0, bytes: headBytes)],
    );

    expect(probe.plan, isNotNull);
    expect(probe.plan!.rangeCount, 1);
    expect(probe.maxPlannedRanges, 1);
  });

  test(
    'Mp4ArtworkService fails when ilst is outside fixed moov scan window',
    () async {
      final artworkBytes = Uint8List.fromList(List<int>.filled(64000, 4));
      final bytes = buildM4aBytes(
        title: 'Artwork Title',
        artist: 'Artwork Artist',
        artworkBytes: artworkBytes,
        metaPaddingBytes: 12 * 1024,
      );
      final headBytes = Uint8List.fromList(
        bytes.sublist(0, Mp4ArtworkService.fixedHeaderWindowBytes),
      );
      final reader = MemoryByteRangeReader(bytes);
      final descriptor = AudioObjectDescriptor(
        objectId: 'artwork-2',
        fileName: 'artwork-window.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: bytes.length,
      );

      await expectLater(
        () => const Mp4ArtworkService().extract(
          descriptor: descriptor,
          reader: reader,
          initialSegments: <ByteSegment>[
            ByteSegment(start: 0, bytes: headBytes),
          ],
        ),
        throwsA(
          isA<ExtractionFailure>().having(
            (failure) => failure.reason,
            'reason',
            'mp4_ilst_not_found',
          ),
        ),
      );
    },
  );
}

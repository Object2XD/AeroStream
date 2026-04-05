import 'dart:typed_data';

import 'package:aero_stream/media_extraction/core/audio_object_descriptor.dart';
import 'package:aero_stream/media_extraction/core/byte_range.dart';
import 'package:aero_stream/media_extraction/mp3/service/mp3_artwork_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mp3_test_fixture.dart';

void main() {
  test(
    'Mp3ArtworkService extracts APIC artwork with exact payload reads',
    () async {
      final artworkBytes = Uint8List.fromList(List<int>.filled(4096, 5));
      final fixture = buildMp3Fixture(
        title: 'Artwork Title',
        artist: 'Artwork Artist',
        artworkBytes: artworkBytes,
        audioPaddingBytes: 700000,
      );
      final reader = MemoryByteRangeReader(fixture.bytes);
      final descriptor = AudioObjectDescriptor(
        objectId: 'artwork-head',
        fileName: 'artwork.mp3',
        mimeType: 'audio/mpeg',
        sizeBytes: fixture.bytes.length,
      );

      final extracted = await const Mp3ArtworkService().extract(
        descriptor: descriptor,
        reader: reader,
        initialSegments: const [],
      );

      expect(extracted, isNotNull);
      expect(extracted!.bytes, orderedEquals(artworkBytes));
      expect(extracted.mimeType, 'image/jpeg');
      expect(
        reader.reads,
        equals([
          fixture.id3HeaderRange!,
          fixture.frame('TIT2').headerRange,
          fixture.frame('TPE1').headerRange,
          fixture.frame('APIC').headerRange,
          ByteRange(
            fixture.frame('APIC').payloadRange.start,
            fixture.frame('APIC').payloadRange.start + 4096,
          ),
          ByteRange(
            fixture.frame('APIC').payloadRange.start + 14,
            fixture.frame('APIC').payloadRange.endExclusive,
          ),
        ]),
      );
    },
  );

  test('Mp3ArtworkService returns null when APIC is absent', () async {
    final fixture = buildMp3Fixture(
      title: 'No Artwork',
      artist: 'No Artwork Artist',
      audioPaddingBytes: 700000,
    );
    final reader = MemoryByteRangeReader(fixture.bytes);
    final descriptor = AudioObjectDescriptor(
      objectId: 'artwork-none',
      fileName: 'no-artwork.mp3',
      mimeType: 'audio/mpeg',
      sizeBytes: fixture.bytes.length,
    );

    final extracted = await const Mp3ArtworkService().extract(
      descriptor: descriptor,
      reader: reader,
      initialSegments: const [],
    );

    expect(extracted, isNull);
    expect(
      reader.reads,
      equals([
        fixture.id3HeaderRange!,
        fixture.frame('TIT2').headerRange,
        fixture.frame('TPE1').headerRange,
      ]),
    );
  });

  test('Mp3ArtworkService exposes APIC probe and bounded fetch plan', () async {
    final artworkBytes = Uint8List.fromList(List<int>.filled(4096, 5));
    final fixture = buildMp3Fixture(
      title: 'Artwork Title',
      artist: 'Artwork Artist',
      artworkBytes: artworkBytes,
      audioPaddingBytes: 700000,
    );
    final reader = MemoryByteRangeReader(fixture.bytes);
    final service = const Mp3ArtworkService();

    final probe = await service.probe(
      descriptor: AudioObjectDescriptor(
        objectId: 'artwork-probe',
        fileName: 'artwork.mp3',
        mimeType: 'audio/mpeg',
        sizeBytes: fixture.bytes.length,
      ),
      reader: reader,
      initialSegments: const [],
    );

    expect(probe, isNotNull);
    expect(
      probe!.fetchPlan.ranges,
      equals([
        ByteRange(
          fixture.frame('APIC').payloadRange.start + 14,
          fixture.frame('APIC').payloadRange.endExclusive,
        ),
      ]),
    );
    expect(probe.artworkMime, 'image/jpeg');
    expect(probe.maxPlannedRanges, 1);
  });
}

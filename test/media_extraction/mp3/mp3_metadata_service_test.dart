import 'dart:typed_data';

import 'package:aero_stream/media_extraction/core/audio_object_descriptor.dart';
import 'package:aero_stream/media_extraction/core/byte_range.dart';
import 'package:aero_stream/media_extraction/mp3/service/mp3_metadata_service.dart';
import 'package:charset/charset.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mp3_test_fixture.dart';

void main() {
  test(
    'Mp3MetadataService extracts sparse ID3v2 metadata with exact reads',
    () async {
      final fixture = buildMp3Fixture(
        title: 'Head Title',
        artist: 'Head Artist',
        album: 'Head Album',
        albumArtist: 'Head Album Artist',
        genre: 'J-Pop',
        year: 2024,
        trackNumber: 3,
        discNumber: 1,
        audioPaddingBytes: 700000,
      );
      final reader = MemoryByteRangeReader(fixture.bytes);
      final descriptor = AudioObjectDescriptor(
        objectId: 'metadata-head',
        fileName: 'head.mp3',
        mimeType: 'audio/mpeg',
        sizeBytes: fixture.bytes.length,
      );

      final extracted = await const Mp3MetadataService().extract(
        descriptor: descriptor,
        reader: reader,
        initialSegments: const [],
      );

      expect(extracted.title, 'Head Title');
      expect(extracted.artist, 'Head Artist');
      expect(extracted.album, 'Head Album');
      expect(extracted.albumArtist, 'Head Album Artist');
      expect(extracted.genre, 'J-Pop');
      expect(extracted.year, 2024);
      expect(extracted.trackNumber, 3);
      expect(extracted.discNumber, 1);
      expect(reader.reads, contains(fixture.id3HeaderRange!));
      expect(
        reader.reads,
        contains(
          ByteRange(10, fixture.frame('TPOS').payloadRange.endExclusive),
        ),
      );
      expect(reader.reads, contains(fixture.frame('TIT2').payloadRange));
      expect(reader.reads, contains(fixture.frame('TPE1').payloadRange));
      expect(reader.reads, contains(fixture.frame('TALB').payloadRange));
      expect(reader.reads, contains(fixture.frame('TPE2').payloadRange));
      expect(reader.reads, contains(fixture.frame('TCON').payloadRange));
      expect(reader.reads, contains(fixture.frame('TYER').payloadRange));
      expect(reader.reads, contains(fixture.frame('TRCK').payloadRange));
      expect(reader.reads, contains(fixture.frame('TPOS').payloadRange));
    },
  );

  test('Mp3MetadataService preserves Shift_JIS and Latin-1 decoding', () async {
    final shiftJisBytes = buildMp3Bytes(
      title: '宇多田ヒカル',
      artist: '椎名林檎',
      albumArtist: '宇多田ヒカル',
      titleEncoder: shiftJis.encode,
      artistEncoder: shiftJis.encode,
      albumArtistEncoder: shiftJis.encode,
    );
    final latin1Bytes = buildMp3Bytes(
      title: 'Beyoncé',
      artist: 'Sigur Rós',
      albumArtist: 'Zoë',
    );
    final shiftJisReader = MemoryByteRangeReader(shiftJisBytes);
    final latin1Reader = MemoryByteRangeReader(latin1Bytes);

    final shiftJisExtracted = await const Mp3MetadataService().extract(
      descriptor: AudioObjectDescriptor(
        objectId: 'metadata-shift-jis',
        fileName: 'shift-jis.mp3',
        mimeType: 'audio/mpeg',
        sizeBytes: shiftJisBytes.length,
      ),
      reader: shiftJisReader,
      initialSegments: const [],
    );
    final latin1Extracted = await const Mp3MetadataService().extract(
      descriptor: AudioObjectDescriptor(
        objectId: 'metadata-latin1',
        fileName: 'latin1.mp3',
        mimeType: 'audio/mpeg',
        sizeBytes: latin1Bytes.length,
      ),
      reader: latin1Reader,
      initialSegments: const [],
    );

    expect(shiftJisExtracted.title, '宇多田ヒカル');
    expect(shiftJisExtracted.artist, '椎名林檎');
    expect(shiftJisExtracted.albumArtist, '宇多田ヒカル');
    expect(latin1Extracted.title, 'Beyoncé');
    expect(latin1Extracted.artist, 'Sigur Rós');
    expect(latin1Extracted.albumArtist, 'Zoë');
  });

  test(
    'Mp3MetadataService skips APIC payloads during metadata parsing',
    () async {
      final fixture = buildMp3Fixture(
        title: 'Head Title',
        artist: 'Head Artist',
        album: 'Head Album',
        year: 2024,
        trackNumber: 3,
        discNumber: 1,
        artworkBytes: Uint8List.fromList(List<int>.filled(64000, 7)),
        audioPaddingBytes: 700000,
      );
      final reader = MemoryByteRangeReader(fixture.bytes);

      final extracted = await const Mp3MetadataService().extract(
        descriptor: AudioObjectDescriptor(
          objectId: 'metadata-skip-apic',
          fileName: 'skip-apic.mp3',
          mimeType: 'audio/mpeg',
          sizeBytes: fixture.bytes.length,
        ),
        reader: reader,
        initialSegments: const [],
      );

      expect(extracted.title, 'Head Title');
      expect(
        reader.reads,
        isNot(
          contains(
            ByteRange(10, fixture.frame('APIC').payloadRange.endExclusive),
          ),
        ),
      );
      final apicHeader = fixture.frame('APIC').headerRange;
      final apicHeaderCovered = reader.reads.any(
        (range) =>
            range.start <= apicHeader.start &&
            range.endExclusive >= apicHeader.endExclusive,
      );
      expect(apicHeaderCovered, isTrue);
    },
  );

  test('Mp3MetadataService falls back to ID3v1 only when needed', () async {
    final fixture = buildMp3Fixture(
      artist: 'Head Artist',
      includeId3v2: true,
      audioPaddingBytes: 700000,
      id3v1Title: 'Tail Title',
      id3v1Artist: 'Tail Artist',
      id3v1Album: 'Tail Album',
      id3v1Year: 1998,
      id3v1TrackNumber: 7,
    );
    final reader = MemoryByteRangeReader(fixture.bytes);
    final descriptor = AudioObjectDescriptor(
      objectId: 'metadata-tail',
      fileName: 'tail.mp3',
      mimeType: 'audio/mpeg',
      sizeBytes: fixture.bytes.length,
    );

    final extracted = await const Mp3MetadataService().extract(
      descriptor: descriptor,
      reader: reader,
      initialSegments: const [],
    );

    expect(extracted.title, 'Tail Title');
    expect(extracted.artist, 'Head Artist');
    expect(extracted.album, 'Tail Album');
    expect(extracted.year, 1998);
    expect(extracted.trackNumber, 7);
    expect(reader.reads, contains(fixture.id3HeaderRange!));
    expect(
      reader.reads,
      contains(ByteRange(10, fixture.frame('TPE1').payloadRange.endExclusive)),
    );
    expect(reader.reads, contains(fixture.frame('TPE1').payloadRange));
    expect(reader.reads, contains(fixture.id3v1Range!));
  });

  test(
    'Mp3MetadataService probe stays bounded to ID3 header and tag bounds',
    () async {
      final fixture = buildMp3Fixture(
        artist: 'Head Artist',
        includeId3v2: true,
        audioPaddingBytes: 700000,
        id3v1Title: 'Tail Title',
        id3v1Artist: 'Tail Artist',
        id3v1Album: 'Tail Album',
        id3v1Year: 1998,
        id3v1TrackNumber: 7,
      );
      final reader = MemoryByteRangeReader(fixture.bytes);
      final service = const Mp3MetadataService();

      final probe = await service.probe(
        descriptor: AudioObjectDescriptor(
          objectId: 'metadata-probe',
          fileName: 'probe.mp3',
          mimeType: 'audio/mpeg',
          sizeBytes: fixture.bytes.length,
        ),
        reader: reader,
        initialSegments: const [],
      );

      expect(probe, isNotNull);
      expect(probe!.header.frameDataOffset, 10);
      expect(probe.tagEnd, fixture.frame('TPE1').payloadRange.endExclusive);
      expect(probe.optionalId3v1Range, fixture.id3v1Range);
      expect(probe.maxProbeBytes, 10);
      expect(reader.reads, equals(<ByteRange>[fixture.id3HeaderRange!]));
    },
  );

  test(
    'Mp3MetadataService plan builds bounded fetch plan after probe',
    () async {
      final fixture = buildMp3Fixture(
        artist: 'Head Artist',
        includeId3v2: true,
        audioPaddingBytes: 700000,
        id3v1Title: 'Tail Title',
        id3v1Artist: 'Tail Artist',
        id3v1Album: 'Tail Album',
        id3v1Year: 1998,
        id3v1TrackNumber: 7,
      );
      final reader = MemoryByteRangeReader(fixture.bytes);
      final service = const Mp3MetadataService();
      final descriptor = AudioObjectDescriptor(
        objectId: 'metadata-plan',
        fileName: 'plan.mp3',
        mimeType: 'audio/mpeg',
        sizeBytes: fixture.bytes.length,
      );

      final probe = await service.probe(
        descriptor: descriptor,
        reader: reader,
        initialSegments: const [],
      );
      final plan = await service.plan(
        descriptor: descriptor,
        reader: reader,
        probe: probe!,
        initialSegments: const [],
      );

      expect(plan.metadataFrames, hasLength(1));
      expect(plan.metadataFrames.single.id, 'TPE1');
      expect(
        plan.primaryPlan.ranges,
        equals(<ByteRange>[fixture.frame('TPE1').payloadRange]),
      );
      expect(plan.optionalId3v1Range, fixture.id3v1Range);
      expect(plan.maxPlannedRanges, 2);
      expect(
        reader.reads,
        contains(
          ByteRange(10, fixture.frame('TPE1').payloadRange.endExclusive),
        ),
      );
    },
  );
}

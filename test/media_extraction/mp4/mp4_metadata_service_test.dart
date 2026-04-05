import 'dart:typed_data';

import 'package:aero_stream/media_extraction/core/audio_object_descriptor.dart';
import 'package:aero_stream/media_extraction/core/byte_segment.dart';
import 'package:aero_stream/media_extraction/mp4/service/mp4_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mp4_test_fixture.dart';

void main() {
  test(
    'Mp4MetadataService extracts metadata without fetching covr payload',
    () async {
      final bytes = buildM4aBytes(
        title: 'Sparse Title',
        artist: 'Sparse Artist',
        albumArtist: 'Sparse Album Artist',
        artworkBytes: Uint8List.fromList(List<int>.filled(1600000, 7)),
        mdatPaddingBytes: 1280000,
        trackPaddingBytes: 1024,
      );
      final headBytes = Uint8List.fromList(
        bytes.sublist(0, Mp4MetadataService.fixedHeaderWindowBytes),
      );
      final reader = MemoryByteRangeReader(bytes);
      final descriptor = AudioObjectDescriptor(
        objectId: 'metadata-1',
        fileName: 'sparse.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: bytes.length,
      );

      final extracted = await const Mp4MetadataService().extract(
        descriptor: descriptor,
        reader: reader,
        initialSegments: <ByteSegment>[ByteSegment(start: 0, bytes: headBytes)],
      );

      expect(extracted.title, 'Sparse Title');
      expect(extracted.artist, 'Sparse Artist');
      expect(extracted.albumArtist, 'Sparse Album Artist');
      expect(extracted.durationMs, 180000);
      expect(reader.reads, isNotEmpty);
      expect(
        reader.reads.where(
          (range) => range.start >= 28 && range.endExclusive <= 28 + 1280000,
        ),
        isEmpty,
      );
    },
  );

  test(
    'Mp4MetadataService exposes probe result with bounded fetch plan',
    () async {
      final bytes = buildM4aBytes(
        title: 'Sparse Title',
        artist: 'Sparse Artist',
        albumArtist: 'Sparse Album Artist',
        artworkBytes: Uint8List.fromList(List<int>.filled(1600000, 7)),
        mdatPaddingBytes: 1280000,
        trackPaddingBytes: 1024,
      );
      final headBytes = Uint8List.fromList(
        bytes.sublist(0, Mp4MetadataService.fixedHeaderWindowBytes),
      );
      final reader = MemoryByteRangeReader(bytes);
      final service = const Mp4MetadataService();

      final probe = await service.probe(
        descriptor: AudioObjectDescriptor(
          objectId: 'metadata-probe',
          fileName: 'sparse.m4a',
          mimeType: 'audio/mp4',
          sizeBytes: bytes.length,
        ),
        reader: reader,
        initialSegments: <ByteSegment>[ByteSegment(start: 0, bytes: headBytes)],
      );
      final plan = await service.plan(
        descriptor: AudioObjectDescriptor(
          objectId: 'metadata-plan',
          fileName: 'sparse.m4a',
          mimeType: 'audio/mp4',
          sizeBytes: bytes.length,
        ),
        reader: reader,
        probe: probe,
        initialSegments: probe.probeSegments,
      );

      expect(probe.moovBox.type, 'moov');
      expect(probe.maxProbeBytes, lessThanOrEqualTo(8 * 1024));
      expect(plan.plan.rangeCount, greaterThan(0));
      expect(plan.maxPlannedRanges, plan.plan.rangeCount);
    },
  );

  test(
    'Mp4MetadataService resolves metadata even when meta is deep in moov',
    () async {
      final bytes = buildM4aBytes(
        title: 'Sparse Title',
        artist: 'Sparse Artist',
        mdatPaddingBytes: 256,
        moovMetadataPaddingBytes: 12 * 1024,
      );
      final headBytes = Uint8List.fromList(
        bytes.sublist(0, Mp4MetadataService.fixedHeaderWindowBytes),
      );
      final reader = MemoryByteRangeReader(bytes);
      final descriptor = AudioObjectDescriptor(
        objectId: 'metadata-2',
        fileName: 'sparse-window.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: bytes.length,
      );

      final extracted = await const Mp4MetadataService().extract(
        descriptor: descriptor,
        reader: reader,
        initialSegments: <ByteSegment>[ByteSegment(start: 0, bytes: headBytes)],
      );
      expect(extracted.title, 'Sparse Title');
      expect(extracted.artist, 'Sparse Artist');
      expect(
        reader.reads.any(
          (range) => range.start > Mp4MetadataService.fixedHeaderWindowBytes,
        ),
        isTrue,
      );
    },
  );
}

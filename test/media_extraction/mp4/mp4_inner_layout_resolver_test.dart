import 'dart:typed_data';

import 'package:aero_stream/media_extraction/core/audio_object_descriptor.dart';
import 'package:aero_stream/media_extraction/mp4/layout/mp4_inner_layout_resolver.dart';
import 'package:aero_stream/media_extraction/mp4/model/mp4_probe_goal.dart';
import 'package:aero_stream/media_extraction/mp4/top_level/mp4_top_level_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mp4_test_fixture.dart';

void main() {
  test('Mp4InnerLayoutResolver resolves metadata after large trak', () async {
    final bytes = buildM4aBytes(
      title: 'Resolver Title',
      artist: 'Resolver Artist',
      artworkBytes: Uint8List.fromList(List<int>.filled(1200000, 9)),
      mdatPaddingBytes: 1280000,
      trackPaddingBytes: 800000,
    );
    final reader = MemoryByteRangeReader(bytes);
    final descriptor = AudioObjectDescriptor(
      objectId: 'layout-1',
      fileName: 'layout.m4a',
      mimeType: 'audio/mp4',
      sizeBytes: bytes.length,
    );
    final moovBox = await Mp4TopLevelScanner.findMoovBox(
      descriptor: descriptor,
      headBytes: Uint8List.fromList(bytes.sublist(0, 512 * 1024)),
      reader: reader,
    );

    final layout = await Mp4InnerLayoutResolver.resolve(
      descriptor: descriptor,
      moovBox: moovBox,
      reader: reader,
      goal: Mp4ProbeGoal.metadata,
    );

    expect(layout.mvhdBox, isNotNull);
    expect(layout.metaBox, isNotNull);
    expect(layout.ilstBox, isNotNull);
    expect(layout.metadataItemBoxes, isNotEmpty);
  });

  test('Mp4InnerLayoutResolver resolves meta directly under moov', () async {
    final bytes = buildM4aBytes(
      title: 'Root Meta Title',
      artist: 'Root Meta Artist',
      metaAtMoovRoot: true,
    );
    final reader = MemoryByteRangeReader(bytes);
    final descriptor = AudioObjectDescriptor(
      objectId: 'layout-2',
      fileName: 'root-meta.m4a',
      mimeType: 'audio/mp4',
      sizeBytes: bytes.length,
    );
    final moovBox = await Mp4TopLevelScanner.findMoovBox(
      descriptor: descriptor,
      headBytes: bytes,
      reader: reader,
    );

    final layout = await Mp4InnerLayoutResolver.resolve(
      descriptor: descriptor,
      moovBox: moovBox,
      reader: reader,
      goal: Mp4ProbeGoal.metadata,
    );

    expect(layout.metaBox, isNotNull);
    expect(layout.ilstBox, isNotNull);
  });
}

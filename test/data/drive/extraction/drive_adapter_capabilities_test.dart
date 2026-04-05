import 'package:aero_stream/data/drive/extraction/m4a_drive_artwork_adapter.dart';
import 'package:aero_stream/data/drive/extraction/m4a_drive_metadata_adapter.dart';
import 'package:aero_stream/data/drive/extraction/mp3_drive_artwork_adapter.dart';
import 'package:aero_stream/data/drive/extraction/mp3_drive_metadata_adapter.dart';
import 'package:aero_stream/media_extraction/core/audio_extraction_cost_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MP3 adapters expose light bounded capabilities', () {
    const metadataAdapter = Mp3DriveMetadataAdapter();
    const artworkAdapter = Mp3DriveArtworkAdapter();

    expect(metadataAdapter.capabilities.supportsMetadata, isTrue);
    expect(metadataAdapter.capabilities.supportsArtwork, isFalse);
    expect(
      metadataAdapter.capabilities.costClass,
      AudioExtractionCostClass.light,
    );
    expect(metadataAdapter.capabilities.maxPlannedRanges, 12);

    expect(artworkAdapter.capabilities.supportsMetadata, isFalse);
    expect(artworkAdapter.capabilities.supportsArtwork, isTrue);
    expect(
      artworkAdapter.capabilities.costClass,
      AudioExtractionCostClass.light,
    );
    expect(artworkAdapter.capabilities.maxPlannedRanges, 1);
  });

  test('M4A adapters expose exploratory bounded capabilities', () {
    const metadataAdapter = M4aDriveMetadataAdapter();
    const artworkAdapter = M4aDriveArtworkAdapter();

    expect(metadataAdapter.capabilities.supportsMetadata, isTrue);
    expect(metadataAdapter.capabilities.supportsArtwork, isFalse);
    expect(
      metadataAdapter.capabilities.costClass,
      AudioExtractionCostClass.exploratory,
    );
    expect(metadataAdapter.capabilities.maxProbeBytes, 768 * 1024);

    expect(artworkAdapter.capabilities.supportsMetadata, isFalse);
    expect(artworkAdapter.capabilities.supportsArtwork, isTrue);
    expect(
      artworkAdapter.capabilities.costClass,
      AudioExtractionCostClass.exploratory,
    );
    expect(artworkAdapter.capabilities.maxPlannedRanges, 1);
  });
}

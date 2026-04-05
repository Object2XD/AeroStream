import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:charset/charset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:aero_stream/media_extraction/mp4/box_header/mp4_box_header_reader.dart';
import 'package:aero_stream/media_extraction/mp4/top_level/mp4_top_level_scanner.dart';

import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/audio_extraction_exception.dart';
import 'package:aero_stream/data/drive/drive_download_debug_meter.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_embedded_tag_parser.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/extraction/drive_artwork_extractor.dart';
import 'package:aero_stream/data/drive/extraction/drive_metadata_extractor.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';

import 'test_drive_scan_logger.dart';
import '../../media_extraction/mp3/mp3_test_fixture.dart' as mp3_fixture;

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'DriveMetadataExtractor parses MP3 metadata through the ranged adapter',
    () async {
      final bytes = _buildMp3Bytes(
        title: 'Range Title',
        artist: 'Range Artist',
        albumArtist: 'Range Album Artist',
      );
      final httpClient = _ByteDriveHttpClient({'track-1': bytes});
      final extractor = DriveMetadataExtractor(driveHttpClient: httpClient);
      final track = await _seedTrack(
        database,
        driveFileId: 'track-1',
        fileName: 'range-title.mp3',
        sizeBytes: bytes.length,
      );

      final metadata = await extractor.extract(track);

      expect(metadata.title, 'Range Title');
      expect(metadata.artist, 'Range Artist');
      expect(metadata.albumArtist, 'Range Album Artist');
      expect(
        httpClient.requestedRanges,
        unorderedEquals(<String?>['bytes=0-9', 'bytes=10-83']),
      );
      expect(httpClient.requestedRanges, isNot(contains('bytes=0-524287')));
      expect(httpClient.downloadFileCount, 0);
    },
  );

  test(
    'DriveMetadataExtractor emits metadata download summary in debug mode',
    () async {
      final bytes = _buildMp3Bytes(
        title: 'Debug Title',
        artist: 'Debug Artist',
        albumArtist: 'Debug Album Artist',
      );
      final httpClient = _ByteDriveHttpClient({'track-debug-meta': bytes});
      final logger = RecordingDriveScanLogger();
      final extractor = DriveMetadataExtractor(
        driveHttpClient: httpClient,
        logger: logger,
      );
      final track = await _seedTrack(
        database,
        driveFileId: 'track-debug-meta',
        fileName: 'debug-meta.mp3',
        sizeBytes: bytes.length,
      );
      final meter = DriveDownloadDebugMeter();

      await extractor.extract(
        track,
        debugContext: DriveDownloadDebugContext(
          meter: meter,
          component: DriveDownloadDebugComponent.metadata,
          driveFileId: track.driveFileId,
          jobId: 99,
          taskId: 1001,
        ),
      );

      final summaryEntry = logger
          .byOperation('metadata_download_summary')
          .single;
      expect(summaryEntry.details['downloadedBytes'], isA<int>());
      expect(summaryEntry.details['downloadedBytes'] as int, greaterThan(0));
      expect(summaryEntry.details['requestCount'], greaterThan(0));
      expect(logger.containsOperation('range_fetch_plan_summary'), isTrue);
      expect(logger.containsOperation('full_fetch_requested_bytes'), isFalse);
    },
  );

  test(
    'DriveArtworkExtractor emits artwork download summary in debug mode',
    () async {
      final fixture = mp3_fixture.buildMp3Fixture(
        title: 'Artwork Debug',
        artist: 'Artwork Debug Artist',
        artworkBytes: Uint8List.fromList(List<int>.filled(2048, 7)),
        audioPaddingBytes: 1000,
      );
      final httpClient = _ByteDriveHttpClient({
        'track-debug-art': fixture.bytes,
      });
      final logger = RecordingDriveScanLogger();
      final extractor = DriveArtworkExtractor(
        driveHttpClient: httpClient,
        logger: logger,
      );
      final track = await _seedTrack(
        database,
        driveFileId: 'track-debug-art',
        fileName: 'debug-art.mp3',
        sizeBytes: fixture.bytes.length,
      );
      final meter = DriveDownloadDebugMeter();

      final artwork = await extractor.extract(
        track,
        debugContext: DriveDownloadDebugContext(
          meter: meter,
          component: DriveDownloadDebugComponent.artwork,
          driveFileId: track.driveFileId,
          jobId: 99,
          taskId: 1002,
        ),
      );

      expect(artwork, isNotNull);
      final summaryEntry = logger
          .byOperation('artwork_download_summary')
          .single;
      expect(summaryEntry.details['downloadedBytes'], isA<int>());
      expect(summaryEntry.details['downloadedBytes'] as int, greaterThan(0));
      expect(summaryEntry.details['requestCount'], greaterThan(0));
    },
  );

  test('DriveMetadataExtractor decodes Shift_JIS ranged MP3 tags', () async {
    final bytes = _buildMp3Bytes(
      title: '宇多田ヒカル',
      artist: '椎名林檎',
      albumArtist: '宇多田ヒカル',
      titleEncoder: shiftJis.encode,
      artistEncoder: shiftJis.encode,
      albumArtistEncoder: shiftJis.encode,
    );
    final httpClient = _ByteDriveHttpClient({'track-shift-jis': bytes});
    final extractor = DriveMetadataExtractor(driveHttpClient: httpClient);
    final track = await _seedTrack(
      database,
      driveFileId: 'track-shift-jis',
      fileName: 'shift-jis.mp3',
      sizeBytes: bytes.length,
    );

    final metadata = await extractor.extract(track);

    expect(metadata.title, '宇多田ヒカル');
    expect(metadata.artist, '椎名林檎');
    expect(metadata.albumArtist, '宇多田ヒカル');
  });

  test(
    'DriveMetadataExtractor preserves western Latin-1 ranged MP3 tags',
    () async {
      final bytes = _buildMp3Bytes(
        title: 'Beyoncé',
        artist: 'Sigur Rós',
        albumArtist: 'Zoë',
      );
      final httpClient = _ByteDriveHttpClient({'track-latin1': bytes});
      final extractor = DriveMetadataExtractor(driveHttpClient: httpClient);
      final track = await _seedTrack(
        database,
        driveFileId: 'track-latin1',
        fileName: 'latin1.mp3',
        sizeBytes: bytes.length,
      );

      final metadata = await extractor.extract(track);

      expect(metadata.title, 'Beyoncé');
      expect(metadata.artist, 'Sigur Rós');
      expect(metadata.albumArtist, 'Zoë');
    },
  );

  test(
    'DriveMetadataExtractor keeps albumArtist empty when ranged tag is missing',
    () async {
      final bytes = _buildMp3Bytes(
        title: 'Range Title',
        artist: 'Range Artist',
      );
      final httpClient = _ByteDriveHttpClient({'track-1b': bytes});
      final extractor = DriveMetadataExtractor(driveHttpClient: httpClient);
      final track = await _seedTrack(
        database,
        driveFileId: 'track-1b',
        fileName: 'range-missing-album-artist.mp3',
        sizeBytes: bytes.length,
      );

      final metadata = await extractor.extract(track);

      expect(metadata.artist, 'Range Artist');
      expect(metadata.albumArtist, isEmpty);
      expect(
        httpClient.requestedRanges,
        unorderedEquals(<String?>['bytes=0-9', 'bytes=10-54']),
      );
    },
  );

  test(
    'DriveMetadataExtractor keeps MP3 albumArtist distinct during full metadata conversion',
    () async {
      final track = await _seedTrack(
        database,
        driveFileId: 'track-1c',
        fileName: 'fallback-title.bin',
        mimeType: 'application/octet-stream',
        sizeBytes: 1024,
      );
      final metadata = Mp3Metadata()
        ..songName = 'Fallback Title'
        ..leadPerformer = 'Fallback Artist'
        ..bandOrOrchestra = 'Fallback Album Artist';

      final extracted = DriveMetadataExtractor.extractFromFullMetadata(
        track: track,
        metadata: metadata,
      );

      expect(extracted.title, 'Fallback Title');
      expect(extracted.artist, 'Fallback Artist');
      expect(extracted.albumArtist, 'Fallback Album Artist');
    },
  );

  test(
    'DriveMetadataExtractor clears MP3 albumArtist during full metadata conversion when tag is missing',
    () async {
      final track = await _seedTrack(
        database,
        driveFileId: 'track-1d',
        fileName: 'fallback-missing-album-artist.bin',
        mimeType: 'application/octet-stream',
        sizeBytes: 1024,
      );
      final metadata = Mp3Metadata()
        ..songName = 'Fallback Title'
        ..leadPerformer = 'Fallback Artist';

      final extracted = DriveMetadataExtractor.extractFromFullMetadata(
        track: track,
        metadata: metadata,
      );

      expect(extracted.artist, 'Fallback Artist');
      expect(extracted.albumArtist, isEmpty);
    },
  );

  test(
    'DriveMetadataExtractor repairs mojibake during full metadata conversion',
    () async {
      final track = await _seedTrack(
        database,
        driveFileId: 'track-1e',
        fileName: 'fallback-shift-jis.bin',
        mimeType: 'application/octet-stream',
        sizeBytes: 1024,
      );
      final metadata = Mp3Metadata()
        ..songName = latin1.decode(
          shiftJis.encode('宇多田ヒカル'),
          allowInvalid: true,
        )
        ..leadPerformer = latin1.decode(
          shiftJis.encode('椎名林檎'),
          allowInvalid: true,
        )
        ..bandOrOrchestra = latin1.decode(
          shiftJis.encode('宇多田ヒカル'),
          allowInvalid: true,
        );

      final extracted = DriveMetadataExtractor.extractFromFullMetadata(
        track: track,
        metadata: metadata,
      );

      expect(extracted.title, '宇多田ヒカル');
      expect(extracted.artist, '椎名林檎');
      expect(extracted.albumArtist, '宇多田ヒカル');
    },
  );

  test(
    'DriveMetadataExtractor fetches the MP3 tail only when ID3v1 fallback is needed',
    () async {
      final bytes = _buildMp3Bytes(
        artist: 'Head Artist',
        audioPaddingBytes: 700000,
        id3v1Title: 'Tail Title',
        id3v1Artist: 'Tail Artist',
        id3v1Album: 'Tail Album',
        id3v1Year: 1998,
        id3v1TrackNumber: 7,
      );
      final httpClient = _ByteDriveHttpClient({'track-concurrent': bytes});
      final extractor = DriveMetadataExtractor(driveHttpClient: httpClient);
      final track = await _seedTrack(
        database,
        driveFileId: 'track-concurrent',
        fileName: 'concurrent.mp3',
        sizeBytes: bytes.length,
      );

      final metadata = await extractor.extract(track);

      expect(metadata.title, 'Tail Title');
      expect(metadata.artist, 'Head Artist');
      expect(metadata.album, 'Tail Album');
      expect(metadata.year, 1998);
      expect(metadata.trackNumber, 7);
      expect(
        httpClient.requestedRanges,
        equals(<String?>[
          'bytes=0-9',
          'bytes=10-31',
          'bytes=${bytes.length - 128}-${bytes.length - 1}',
        ]),
      );
      expect(
        httpClient.requestedRanges.last,
        'bytes=${bytes.length - 128}-${bytes.length - 1}',
      );
    },
  );

  test(
    'DriveMetadataExtractor skips MP3 APIC payload bytes during metadata parsing',
    () async {
      final fixture = mp3_fixture.buildMp3Fixture(
        title: 'Head Title',
        artist: 'Head Artist',
        album: 'Head Album',
        year: 2024,
        trackNumber: 3,
        discNumber: 1,
        artworkBytes: Uint8List.fromList(List<int>.filled(64000, 7)),
        audioPaddingBytes: 700000,
      );
      final httpClient = _ByteDriveHttpClient({
        'track-mp3-no-apic': fixture.bytes,
      });
      final extractor = DriveMetadataExtractor(driveHttpClient: httpClient);
      final track = await _seedTrack(
        database,
        driveFileId: 'track-mp3-no-apic',
        fileName: 'no-apic-payload.mp3',
        sizeBytes: fixture.bytes.length,
      );

      final metadata = await extractor.extract(track);

      expect(metadata.title, 'Head Title');
      expect(httpClient.requestedRanges, contains('bytes=0-9'));
      expect(
        httpClient.requestedRanges,
        isNot(
          contains(
            'bytes=10-${fixture.frame('APIC').payloadRange.endExclusive - 1}',
          ),
        ),
      );
      expect(httpClient.requestedRanges, isNot(contains('bytes=0-524287')));
      expect(httpClient.downloadFileCount, 0);
    },
  );

  test(
    'DriveMetadataExtractor parses ranged metadata from M4A ilst boxes',
    () async {
      final bytes = _buildM4aBytes(
        title: 'M4A Title',
        artist: 'M4A Artist',
        album: 'M4A Album',
        albumArtist: 'M4A Album Artist',
        genre: 'J-Pop',
        year: 1999,
        trackNumber: 2,
        discNumber: 1,
        durationMs: 210000,
      );
      final httpClient = _ByteDriveHttpClient({'track-m4a': bytes});
      final extractor = DriveMetadataExtractor(driveHttpClient: httpClient);
      final track = await _seedTrack(
        database,
        driveFileId: 'track-m4a',
        fileName: 'song.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: bytes.length,
      );

      final metadata = await extractor.extract(track);

      expect(metadata.title, 'M4A Title');
      expect(metadata.artist, 'M4A Artist');
      expect(metadata.album, 'M4A Album');
      expect(metadata.albumArtist, 'M4A Album Artist');
      expect(metadata.genre, 'J-Pop');
      expect(metadata.year, 1999);
      expect(metadata.trackNumber, 2);
      expect(metadata.discNumber, 1);
      expect(metadata.durationMs, 210000);
      expect(httpClient.requestedRanges, hasLength(1));
      expect(httpClient.requestedRanges.single, 'bytes=0-${bytes.length - 1}');
      expect(httpClient.downloadFileCount, 0);
    },
  );

  test(
    'DriveMetadataExtractor skips large covr payloads for probed M4A metadata',
    () async {
      final bytes = _buildM4aBytes(
        title: 'Sparse Title',
        artist: 'Sparse Artist',
        albumArtist: 'Sparse Album Artist',
        durationMs: 180000,
        mdatPaddingBytes: 1280000,
        artworkBytes: Uint8List.fromList(List<int>.filled(1600000, 7)),
      );
      final topLevelHeaders = Mp4BoxHeaderReader.readTopLevelHeaders(
        bytes,
        fileSize: bytes.length,
      );
      final moovBox = topLevelHeaders.firstWhere(
        (header) => header.type == 'moov',
      );
      final httpClient = _ByteDriveHttpClient({'track-m4a-sparse': bytes});
      final logger = RecordingDriveScanLogger();
      final extractor = DriveMetadataExtractor(
        driveHttpClient: httpClient,
        logger: logger,
      );
      final track = await _seedTrack(
        database,
        driveFileId: 'track-m4a-sparse',
        fileName: 'sparse.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: bytes.length,
      );

      final metadata = await extractor.extract(track);

      expect(moovBox.size, greaterThan(1024 * 1024));
      expect(metadata.title, 'Sparse Title');
      expect(metadata.artist, 'Sparse Artist');
      expect(metadata.albumArtist, 'Sparse Album Artist');
      expect(httpClient.requestedRanges.length, greaterThan(3));
      expect(httpClient.requestedRanges.first, 'bytes=0-8191');
      expect(httpClient.requestedRanges, isNot(contains('bytes=65536-131071')));
      final finalRange = httpClient.requestedRanges.last!;
      final finalMatch = RegExp(r'^bytes=(\d+)-(\d+)$').firstMatch(finalRange);
      expect(finalMatch, isNotNull);
      expect(int.parse(finalMatch!.group(1)!), greaterThan(moovBox.offset));
      expect(int.parse(finalMatch.group(1)!), lessThan(moovBox.end));
      expect(
        int.parse(finalMatch.group(2)!),
        lessThanOrEqualTo(moovBox.end - 1),
      );
      expect(
        httpClient.requestedRanges.take(httpClient.requestedRanges.length - 1),
        isNot(contains('bytes=${moovBox.offset}-${moovBox.end - 1}')),
      );
      expect(logger.containsOperation('ranged_parse_success'), isTrue);
      expect(httpClient.downloadFileCount, 0);
    },
  );

  test(
    'DriveEmbeddedTagParser skips M4A artwork bytes during metadata-only parsing',
    () {
      final artworkBytes = Uint8List.fromList([1, 2, 3, 4]);
      final bytes = _buildM4aBytes(
        title: 'Artwork Title',
        artist: 'Artwork Artist',
        artworkBytes: artworkBytes,
      );

      final metadataOnly = DriveEmbeddedTagParser.parse(
        headBytes: bytes,
        tailBytes: bytes,
        mimeType: 'audio/mp4',
        fileName: 'artwork.m4a',
        fileSize: bytes.length,
        includeArtwork: false,
      );
      final withArtwork = DriveEmbeddedTagParser.parse(
        headBytes: bytes,
        tailBytes: bytes,
        mimeType: 'audio/mp4',
        fileName: 'artwork.m4a',
        fileSize: bytes.length,
      );

      expect(metadataOnly, isNotNull);
      expect(metadataOnly!.title, 'Artwork Title');
      expect(metadataOnly.artworkBytes, isNull);
      expect(withArtwork, isNotNull);
      expect(withArtwork!.artworkBytes, orderedEquals(artworkBytes));
    },
  );

  test(
    'DriveMetadataExtractor walks top-level boxes after mdat before parsing M4A metadata',
    () async {
      final bytes = _buildM4aBytes(
        title: 'Scanned Title',
        artist: 'Scanned Artist',
        albumArtist: 'Scanned Album Artist',
        durationMs: 180000,
        mdatPaddingBytes: 1280000,
        topLevelBoxesAfterMdat: <List<int>>[
          _mp4Box('wide', const <int>[]),
          _mp4Box('free', List<int>.filled(96 * 1024, 0)),
          _mp4Box('zzzz', List<int>.filled(24, 7)),
        ],
        artworkBytes: Uint8List.fromList(List<int>.filled(256000, 8)),
      );
      final httpClient = _ByteDriveHttpClient({'track-m4a-scanned': bytes});
      final logger = RecordingDriveScanLogger();
      final extractor = DriveMetadataExtractor(
        driveHttpClient: httpClient,
        logger: logger,
      );
      final track = await _seedTrack(
        database,
        driveFileId: 'track-m4a-scanned',
        fileName: 'scanned-gap.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: bytes.length,
      );

      final metadata = await extractor.extract(track);

      expect(metadata.title, 'Scanned Title');
      expect(metadata.artist, 'Scanned Artist');
      expect(metadata.albumArtist, 'Scanned Album Artist');
      expect(httpClient.downloadFileCount, 0);
      expect(logger.containsOperation('ranged_parse_success'), isTrue);
    },
  );

  test(
    'DriveMetadataExtractor keeps M4A head probe fixed and follows box headers',
    () async {
      final bytes = _buildM4aBytes(
        title: 'Looped Title',
        artist: 'Looped Artist',
        albumArtist: 'Looped Album Artist',
        durationMs: 180000,
        mdatPaddingBytes: 96 * 1024,
      );
      final httpClient = _ByteDriveHttpClient({'track-m4a-loop': bytes});
      final extractor = DriveMetadataExtractor(driveHttpClient: httpClient);
      final track = await _seedTrack(
        database,
        driveFileId: 'track-m4a-loop',
        fileName: 'looped.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: bytes.length,
      );

      final metadata = await extractor.extract(track);

      expect(metadata.title, 'Looped Title');
      expect(metadata.artist, 'Looped Artist');
      expect(httpClient.downloadFileCount, 0);
      expect(httpClient.requestedRanges, hasLength(greaterThanOrEqualTo(2)));
      expect(httpClient.requestedRanges.first, 'bytes=0-8191');
      expect(httpClient.requestedRanges[1], isNot(startsWith('bytes=65536-')));
      expect(httpClient.requestedRanges, isNot(contains('bytes=0-524287')));
    },
  );

  test(
    'DriveMetadataExtractor scans deep moov layout via range header walks',
    () async {
      final bytes = _buildM4aBytes(
        title: 'Expanded Title',
        artist: 'Expanded Artist',
        albumArtist: 'Expanded Album Artist',
        durationMs: 180000,
        mdatPaddingBytes: 1280000,
        moovMetadataPaddingBytes: 96 * 1024,
        artworkBytes: Uint8List.fromList(List<int>.filled(1200000, 9)),
      );
      final topLevelHeaders = Mp4BoxHeaderReader.readTopLevelHeaders(
        bytes,
        fileSize: bytes.length,
      );
      final moovBox = topLevelHeaders.firstWhere(
        (header) => header.type == 'moov',
      );
      final httpClient = _ByteDriveHttpClient({'track-m4a-expanded': bytes});
      final logger = RecordingDriveScanLogger();
      final extractor = DriveMetadataExtractor(
        driveHttpClient: httpClient,
        logger: logger,
      );
      final track = await _seedTrack(
        database,
        driveFileId: 'track-m4a-expanded',
        fileName: 'expanded.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: bytes.length,
      );

      final metadata = await extractor.extract(track);

      expect(moovBox.size, greaterThan(1024 * 1024));
      expect(metadata.title, 'Expanded Title');
      expect(metadata.artist, 'Expanded Artist');
      expect(metadata.albumArtist, 'Expanded Album Artist');
      expect(httpClient.downloadFileCount, 0);
      expect(httpClient.requestedRanges.length, greaterThan(3));
      expect(httpClient.requestedRanges.first, 'bytes=0-8191');
      expect(httpClient.requestedRanges, isNot(contains('bytes=65536-131071')));
      final finalRange = httpClient.requestedRanges.last!;
      final finalMatch = RegExp(r'^bytes=(\d+)-(\d+)$').firstMatch(finalRange);
      expect(finalMatch, isNotNull);
      expect(int.parse(finalMatch!.group(1)!), greaterThan(moovBox.offset));
      expect(int.parse(finalMatch.group(1)!), lessThan(moovBox.end));
      expect(
        int.parse(finalMatch.group(2)!),
        lessThanOrEqualTo(moovBox.end - 1),
      );
      expect(
        httpClient.requestedRanges.take(httpClient.requestedRanges.length - 1),
        isNot(contains('bytes=${moovBox.offset}-${moovBox.end - 1}')),
      );
      expect(logger.containsOperation('ranged_parse_success'), isTrue);
    },
  );

  test(
    'DriveMetadataExtractor fast-fails when the top-level box scan sees an invalid header',
    () async {
      final invalidBytes = _buildM4aBytes(
        title: 'Fallback Title',
        artist: 'Fallback Artist',
        durationMs: 180000,
        mdatPaddingBytes: 1280000,
        moovPaddingBytes: 1600000,
        topLevelBoxesAfterMdat: <List<int>>[_mp4RawBox('free', size32: 4)],
      );
      final httpClient = _ByteDriveHttpClient({
        'track-m4a-fallback': invalidBytes,
      });
      final logger = RecordingDriveScanLogger();
      final extractor = DriveMetadataExtractor(
        driveHttpClient: httpClient,
        logger: logger,
      );
      final track = await _seedTrack(
        database,
        driveFileId: 'track-m4a-fallback',
        fileName: 'fallback.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: invalidBytes.length,
      );

      await expectLater(
        () => extractor.extract(track),
        throwsA(
          isA<DriveRangedExtractionException>().having(
            (error) => error.reason,
            'reason',
            'mp4_invalid_top_level_box',
          ),
        ),
      );

      expect(httpClient.downloadFileCount, 0);
      expect(logger.containsOperation('ranged_fast_fail'), isTrue);
      expect(logger.containsOperation('full_download_fallback'), isFalse);
    },
  );

  test(
    'DriveMetadataExtractor fast-fails when a non-moov top-level box extends to EOF',
    () async {
      final rangedBytes = _buildM4aBytes(
        title: 'EOF Title',
        artist: 'EOF Artist',
        durationMs: 180000,
        mdatPaddingBytes: 1280000,
        topLevelBoxesAfterMdat: <List<int>>[_mp4RawBox('free', size32: 0)],
      );
      final httpClient = _ByteDriveHttpClient({'track-m4a-size0': rangedBytes});
      final logger = RecordingDriveScanLogger();
      final extractor = DriveMetadataExtractor(
        driveHttpClient: httpClient,
        logger: logger,
      );
      final track = await _seedTrack(
        database,
        driveFileId: 'track-m4a-size0',
        fileName: 'size0-invalid.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: rangedBytes.length,
      );

      await expectLater(
        () => extractor.extract(track),
        throwsA(
          isA<DriveRangedExtractionException>().having(
            (error) => error.reason,
            'reason',
            'mp4_invalid_top_level_box',
          ),
        ),
      );

      expect(httpClient.downloadFileCount, 0);
      expect(logger.containsOperation('ranged_fast_fail'), isTrue);
    },
  );

  test(
    'DriveMetadataExtractor fast-fails when the top-level box scan exceeds its limit',
    () async {
      final fillerBoxes = List<List<int>>.generate(
        Mp4TopLevelScanner.topLevelScanMaxBoxes + 1,
        (_) => _mp4Box('wide', const <int>[]),
      );
      final rangedBytes = _buildM4aBytes(
        title: 'Limited Title',
        artist: 'Limited Artist',
        durationMs: 180000,
        mdatPaddingBytes: 1280000,
        topLevelBoxesAfterMdat: fillerBoxes,
      );
      final httpClient = _ByteDriveHttpClient({'track-m4a-limit': rangedBytes});
      final logger = RecordingDriveScanLogger();
      final extractor = DriveMetadataExtractor(
        driveHttpClient: httpClient,
        logger: logger,
      );
      final track = await _seedTrack(
        database,
        driveFileId: 'track-m4a-limit',
        fileName: 'limit-gap.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: rangedBytes.length,
      );

      await expectLater(
        () => extractor.extract(track),
        throwsA(
          isA<DriveRangedExtractionException>().having(
            (error) => error.reason,
            'reason',
            'mp4_top_level_scan_limit_exceeded',
          ),
        ),
      );

      expect(httpClient.downloadFileCount, 0);
      expect(logger.containsOperation('ranged_fast_fail'), isTrue);
    },
  );

  test(
    'DriveArtworkExtractor parses MP3 artwork through the ranged adapter',
    () async {
      final artworkBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final bytes = _buildMp3Bytes(
        title: 'Range Title',
        artist: 'Range Artist',
        artworkBytes: artworkBytes,
      );
      final httpClient = _ByteDriveHttpClient({'track-2': bytes});
      final extractor = DriveArtworkExtractor(driveHttpClient: httpClient);
      final track = await _seedTrack(
        database,
        driveFileId: 'track-2',
        fileName: 'range-artwork.mp3',
        sizeBytes: bytes.length,
      );

      final artwork = await extractor.extract(track);

      expect(artwork, isNotNull);
      expect(artwork!.bytes, orderedEquals(artworkBytes));
      expect(artwork.mimeType, 'image/jpeg');
      expect(artwork.contentHash, sha1.convert(artworkBytes).toString());
      expect(
        httpClient.requestedRanges,
        equals(<String?>[
          'bytes=0-9',
          'bytes=10-19',
          'bytes=32-41',
          'bytes=55-64',
          'bytes=65-83',
        ]),
      );
    },
  );

  test(
    'DriveArtworkExtractor parses M4A artwork without full-download fallback',
    () async {
      final artworkBytes = Uint8List.fromList(List<int>.filled(64000, 4));
      final bytes = _buildM4aBytes(
        title: 'Artwork Title',
        artist: 'Artwork Artist',
        durationMs: 180000,
        mdatPaddingBytes: 1280000,
        topLevelBoxesAfterMdat: <List<int>>[
          _mp4Box('wide', const <int>[]),
          _mp4Box('free', List<int>.filled(96 * 1024, 0)),
          _mp4Box('zzzz', List<int>.filled(24, 4)),
        ],
        artworkBytes: artworkBytes,
      );
      final httpClient = _ByteDriveHttpClient({'track-m4a-art': bytes});
      final logger = RecordingDriveScanLogger();
      final extractor = DriveArtworkExtractor(
        driveHttpClient: httpClient,
        logger: logger,
      );
      final track = await _seedTrack(
        database,
        driveFileId: 'track-m4a-art',
        fileName: 'artwork-range.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: bytes.length,
      );

      final artwork = await extractor.extract(track);

      expect(artwork, isNotNull);
      expect(artwork!.bytes, orderedEquals(artworkBytes));
      expect(artwork.mimeType, 'image/jpeg');
      expect(httpClient.downloadFileCount, 0);
      expect(logger.containsOperation('ranged_parse_success'), isTrue);
    },
  );

  test(
    'DriveArtworkExtractor fast-fails when the top-level box scan sees an invalid header',
    () async {
      final rangedBytes = _buildM4aBytes(
        title: 'Fallback Title',
        artist: 'Fallback Artist',
        durationMs: 180000,
        mdatPaddingBytes: 1280000,
        artworkBytes: Uint8List.fromList(List<int>.filled(128, 5)),
      );
      final topLevelHeaders = Mp4BoxHeaderReader.readTopLevelHeaders(
        rangedBytes,
        fileSize: rangedBytes.length,
      );
      final mdatBox = topLevelHeaders.firstWhere(
        (header) => header.type == 'mdat',
      );
      final httpClient = _MoovProbeFailingByteDriveHttpClient(
        rangedBytesByFileId: {'track-m4a-art-fail': rangedBytes},
        poisonedRangeStarts: {mdatBox.end},
      );
      final logger = RecordingDriveScanLogger();
      final extractor = DriveArtworkExtractor(
        driveHttpClient: httpClient,
        logger: logger,
      );
      final track = await _seedTrack(
        database,
        driveFileId: 'track-m4a-art-fail',
        fileName: 'artwork-fail.m4a',
        mimeType: 'audio/mp4',
        sizeBytes: rangedBytes.length,
      );

      await expectLater(
        () => extractor.extract(track),
        throwsA(
          isA<DriveRangedExtractionException>().having(
            (error) => error.reason,
            'reason',
            'mp4_invalid_top_level_box',
          ),
        ),
      );

      expect(httpClient.downloadFileCount, 0);
      expect(logger.containsOperation('ranged_fast_fail'), isTrue);
      expect(logger.containsOperation('ranged_fast_fail'), isTrue);
      expect(logger.containsOperation('full_download_fallback'), isFalse);
    },
  );

  test('DriveMetadataExtractor logs ranged failure and fast-fail', () async {
    final bytes = _buildMp3Bytes(
      title: 'Fallback Title',
      artist: 'Fallback Artist',
    );
    final httpClient = _RangeFailingDriveHttpClient({'track-logger': bytes});
    final logger = RecordingDriveScanLogger();
    final extractor = DriveMetadataExtractor(
      driveHttpClient: httpClient,
      logger: logger,
    );
    final track = await _seedTrack(
      database,
      driveFileId: 'track-logger',
      fileName: 'fallback-logger.mp3',
      sizeBytes: 700000,
    );

    await expectLater(
      () => extractor.extract(track),
      throwsA(
        isA<DriveRangedExtractionException>().having(
          (error) => error.reason,
          'reason',
          'ranged_parse_failed',
        ),
      ),
    );
    expect(logger.containsOperation('ranged_parse_fail'), isTrue);
    expect(logger.containsOperation('ranged_fast_fail'), isTrue);
    expect(logger.containsOperation('full_download_fallback'), isFalse);
    expect(logger.containsOperation('extract_fail'), isTrue);
  });
}

Future<Track> _seedTrack(
  AppDatabase database, {
  required String driveFileId,
  required String fileName,
  String mimeType = 'audio/mpeg',
  required int sizeBytes,
}) async {
  await database.setActiveAccount(
    SyncAccountsCompanion.insert(
      providerAccountId: 'account-1',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: 'test',
      connectedAt: DateTime(2026, 3, 30),
      isActive: const Value(true),
    ),
  );
  final account = await database.getActiveAccount();
  final rootId = await database.upsertRoot(
    SyncRootsCompanion.insert(
      accountId: account!.id,
      folderId: 'root-folder',
      folderName: 'Library',
      syncState: Value(DriveScanJobState.completed.value),
    ),
  );
  await database.upsertTrack(
    TracksCompanion.insert(
      rootId: rootId,
      driveFileId: driveFileId,
      fileName: fileName,
      title: 'Projected Title',
      artist: '',
      album: '',
      albumArtist: '',
      genre: '',
      mimeType: mimeType,
      sizeBytes: Value(sizeBytes),
      md5Checksum: const Value('md5'),
      modifiedTime: Value(DateTime(2026, 3, 30)),
      metadataStatus: Value(TrackMetadataStatus.pending.value),
      artworkStatus: Value(TrackArtworkStatus.pending.value),
      indexStatus: Value(TrackIndexStatus.active.value),
      contentFingerprint: Value(
        buildContentFingerprint(
          md5Checksum: 'md5',
          sizeBytes: sizeBytes,
          modifiedTime: DateTime(2026, 3, 30),
        ),
      ),
    ),
  );
  return (await database.getTrackByDriveFileId(driveFileId))!;
}

Uint8List _buildMp3Bytes({
  String? title,
  String? artist,
  String? album,
  String? albumArtist,
  Uint8List? artworkBytes,
  List<int> Function(String text)? titleEncoder,
  List<int> Function(String text)? artistEncoder,
  List<int> Function(String text)? albumEncoder,
  List<int> Function(String text)? albumArtistEncoder,
  bool includeId3v2 = true,
  int audioPaddingBytes = 32,
  String? id3v1Title,
  String? id3v1Artist,
  String? id3v1Album,
  int? id3v1Year,
  int? id3v1TrackNumber,
}) {
  final frames = <int>[
    if (title != null) ..._textFrame('TIT2', title, encoder: titleEncoder),
    if (artist != null) ..._textFrame('TPE1', artist, encoder: artistEncoder),
    if (album != null) ..._textFrame('TALB', album, encoder: albumEncoder),
    if (albumArtist != null)
      ..._textFrame('TPE2', albumArtist, encoder: albumArtistEncoder),
    if (artworkBytes != null) ..._apicFrame(artworkBytes),
  ];

  return Uint8List.fromList([
    if (includeId3v2) ...<int>[
      ...ascii.encode('ID3'),
      3,
      0,
      0,
      ..._synchsafe(frames.length),
      ...frames,
    ],
    ...List<int>.filled(audioPaddingBytes, 0),
    if (id3v1Title != null ||
        id3v1Artist != null ||
        id3v1Album != null ||
        id3v1Year != null ||
        id3v1TrackNumber != null)
      ..._id3v1Tag(
        title: id3v1Title,
        artist: id3v1Artist,
        album: id3v1Album,
        year: id3v1Year,
        trackNumber: id3v1TrackNumber,
      ),
  ]);
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

List<int> _apicFrame(Uint8List artworkBytes) {
  final payload = <int>[
    0,
    ...ascii.encode('image/jpeg'),
    0,
    3,
    0,
    ...artworkBytes,
  ];
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

List<int> _uint64(int value) {
  return <int>[
    (value >> 56) & 0xff,
    (value >> 48) & 0xff,
    (value >> 40) & 0xff,
    (value >> 32) & 0xff,
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];
}

Uint8List _buildM4aBytes({
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
  int moovMetadataPaddingBytes = 0,
  int moovPaddingBytes = 0,
  Uint8List? artworkBytes,
  List<List<int>> topLevelBoxesAfterMdat = const <List<int>>[],
}) {
  final ftyp = _mp4Box('ftyp', <int>[
    ...latin1.encode('M4A '),
    ..._uint32(0),
    ...latin1.encode('M4A '),
    ...latin1.encode('isom'),
  ]);
  final mvhd = _mp4Box('mvhd', <int>[
    0,
    0,
    0,
    0,
    ..._uint32(0),
    ..._uint32(0),
    ..._uint32(1000),
    ..._uint32(durationMs),
    ...List<int>.filled(80, 0),
  ]);
  final ilst = _mp4Box('ilst', <int>[
    ..._mp4TextItem('\u00a9nam', title),
    ..._mp4TextItem('\u00a9ART', artist),
    ..._mp4TextItem('\u00a9alb', album),
    ..._mp4TextItem('aART', albumArtist),
    ..._mp4TextItem('\u00a9gen', genre),
    ..._mp4TextItem('\u00a9day', '$year'),
    ..._mp4OrdinalItem('trkn', trackNumber),
    ..._mp4OrdinalItem('disk', discNumber),
    if (artworkBytes != null) ..._mp4CoverItem(artworkBytes),
  ]);
  final meta = _mp4Box('meta', <int>[0, 0, 0, 0, ...ilst]);
  final udta = _mp4Box('udta', meta);
  final moov = _mp4Box('moov', <int>[
    ...mvhd,
    if (moovMetadataPaddingBytes > 0)
      ..._mp4Box('free', List<int>.filled(moovMetadataPaddingBytes, 0)),
    ...udta,
    if (moovPaddingBytes > 0)
      ..._mp4Box('free', List<int>.filled(moovPaddingBytes, 0)),
  ]);
  final mdat = _mp4Box('mdat', List<int>.filled(mdatPaddingBytes, 0));
  return Uint8List.fromList(<int>[
    ...ftyp,
    ...mdat,
    for (final box in topLevelBoxesAfterMdat) ...box,
    ...moov,
  ]);
}

List<int> _mp4TextItem(String type, String text) {
  return _mp4Box(type, _mp4DataBox(1, utf8.encode(text)));
}

List<int> _mp4OrdinalItem(String type, int value) {
  return _mp4Box(
    type,
    _mp4DataBox(0, <int>[0, 0, (value >> 8) & 0xff, value & 0xff, 0, 0, 0, 0]),
  );
}

List<int> _mp4CoverItem(Uint8List artworkBytes) {
  return _mp4Box('covr', _mp4DataBox(13, artworkBytes));
}

List<int> _mp4DataBox(int dataType, List<int> payload) {
  return _mp4Box('data', <int>[..._uint32(dataType), 0, 0, 0, 0, ...payload]);
}

List<int> _mp4Box(String type, List<int> payload) {
  return <int>[
    ..._uint32(payload.length + 8),
    ...latin1.encode(type),
    ...payload,
  ];
}

List<int> _mp4RawBox(
  String type, {
  required int size32,
  List<int> payload = const <int>[],
  int? extendedSize,
}) {
  return <int>[
    ..._uint32(size32),
    ...latin1.encode(type),
    if (size32 == 1) ..._uint64(extendedSize ?? (payload.length + 16)),
    ...payload,
  ];
}

class _ByteDriveHttpClient extends DriveHttpClient {
  _ByteDriveHttpClient(this.bytesByFileId)
    : super(authRepository: _FakeAuthRepository());

  final Map<String, Uint8List> bytesByFileId;
  final List<String?> requestedRanges = <String?>[];
  int downloadFileCount = 0;

  @override
  Future<Uint8List> downloadBytes({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    requestedRanges.add(rangeHeader);
    final bytes = bytesByFileId[fileId];
    if (bytes == null) {
      throw StateError('Missing bytes for $fileId');
    }
    if (rangeHeader == null || rangeHeader.isEmpty) {
      return bytes;
    }
    final match = RegExp(r'^bytes=(\d+)-(\d+)$').firstMatch(rangeHeader);
    if (match == null) {
      throw StateError('Unsupported range header: $rangeHeader');
    }
    final start = int.parse(match.group(1)!);
    final inclusiveEnd = int.parse(match.group(2)!);
    final end = inclusiveEnd >= bytes.length ? bytes.length : inclusiveEnd + 1;
    if (start >= end) {
      return Uint8List(0);
    }
    return Uint8List.fromList(bytes.sublist(start, end));
  }

  @override
  Future<http.StreamedResponse> downloadFile({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    final bytes = bytesByFileId[fileId];
    if (bytes == null) {
      throw StateError('Missing bytes for $fileId');
    }
    downloadFileCount += 1;
    return http.StreamedResponse(Stream<List<int>>.value(bytes), 200);
  }
}

class _RangeFailingDriveHttpClient extends _ByteDriveHttpClient {
  _RangeFailingDriveHttpClient(super.bytesByFileId);

  @override
  Future<Uint8List> downloadBytes({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    throw StateError('ranged bytes unavailable');
  }
}

class _MoovProbeFailingByteDriveHttpClient extends _ByteDriveHttpClient {
  _MoovProbeFailingByteDriveHttpClient({
    required Map<String, Uint8List> rangedBytesByFileId,
    required this.poisonedRangeStarts,
  }) : super(rangedBytesByFileId);

  final Set<int> poisonedRangeStarts;

  @override
  Future<Uint8List> downloadBytes({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    final start = _rangeStart(rangeHeader);
    if (start != null && poisonedRangeStarts.contains(start)) {
      requestedRanges.add(rangeHeader);
      final match = RegExp(r'^bytes=(\d+)-(\d+)$').firstMatch(rangeHeader!);
      final end = int.parse(match!.group(2)!);
      return Uint8List(end - start + 1);
    }
    return super.downloadBytes(
      fileId: fileId,
      resourceKey: resourceKey,
      rangeHeader: rangeHeader,
    );
  }
}

int? _rangeStart(String? rangeHeader) {
  if (rangeHeader == null || rangeHeader.isEmpty) {
    return null;
  }
  final match = RegExp(r'^bytes=(\d+)-(\d+)$').firstMatch(rangeHeader);
  if (match == null) {
    return null;
  }
  return int.parse(match.group(1)!);
}

class _FakeAuthRepository implements DriveAuthRepository {
  @override
  String? get configurationMessage => null;

  @override
  bool get isConfigured => true;

  @override
  Future<DriveAccountProfile> connect() {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<DriveAccountProfile?> restoreSession() async => null;

  @override
  Future<T> withClient<T>(Future<T> Function(http.Client client) action) {
    throw UnimplementedError();
  }
}

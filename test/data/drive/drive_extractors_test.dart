import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:charset/charset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_artwork_extractor.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/drive_metadata_extractor.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';

import 'test_drive_scan_logger.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'DriveMetadataExtractor parses ranged metadata inside an isolate',
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
    },
  );

  test(
    'DriveMetadataExtractor keeps MP3 albumArtist distinct on full-download fallback',
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
    'DriveMetadataExtractor clears MP3 albumArtist on fallback when tag is missing',
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
    'DriveMetadataExtractor repairs mojibake on full-download MP3 metadata',
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
    'DriveMetadataExtractor fetches head and tail ranges concurrently',
    () async {
      final bytes = _buildMp3Bytes(
        title: 'Concurrent Title',
        artist: 'Concurrent Artist',
      );
      final httpClient = _ConcurrentByteDriveHttpClient({
        'track-concurrent': bytes,
      });
      final extractor = DriveMetadataExtractor(driveHttpClient: httpClient);
      final track = await _seedTrack(
        database,
        driveFileId: 'track-concurrent',
        fileName: 'concurrent.mp3',
        sizeBytes: 700000,
      );

      final metadata = await extractor.extract(track);

      expect(metadata.title, 'Concurrent Title');
      expect(httpClient.maxConcurrentDownloads, greaterThan(1));
    },
  );

  test(
    'DriveArtworkExtractor parses ranged artwork and hash inside an isolate',
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
    },
  );

  test(
    'DriveMetadataExtractor logs ranged failure and full-download fallback',
    () async {
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
        throwsA(isA<MetadataParserException>()),
      );
      expect(logger.containsOperation('ranged_parse_fail'), isTrue);
      expect(logger.containsOperation('full_download_fallback'), isTrue);
      expect(logger.containsOperation('extract_fail'), isTrue);
    },
  );
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
  required String title,
  required String artist,
  String? albumArtist,
  Uint8List? artworkBytes,
  List<int> Function(String text)? titleEncoder,
  List<int> Function(String text)? artistEncoder,
  List<int> Function(String text)? albumArtistEncoder,
}) {
  final frames = <int>[
    ..._textFrame('TIT2', title, encoder: titleEncoder),
    ..._textFrame('TPE1', artist, encoder: artistEncoder),
    if (albumArtist != null)
      ..._textFrame('TPE2', albumArtist, encoder: albumArtistEncoder),
    if (artworkBytes != null) ..._apicFrame(artworkBytes),
  ];

  return Uint8List.fromList([
    ...ascii.encode('ID3'),
    3,
    0,
    0,
    ..._synchsafe(frames.length),
    ...frames,
    ...List<int>.filled(32, 0),
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

class _ByteDriveHttpClient extends DriveHttpClient {
  _ByteDriveHttpClient(this.bytesByFileId)
    : super(authRepository: _FakeAuthRepository());

  final Map<String, Uint8List> bytesByFileId;

  @override
  Future<Uint8List> downloadBytes({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    final bytes = bytesByFileId[fileId];
    if (bytes == null) {
      throw StateError('Missing bytes for $fileId');
    }
    return bytes;
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
    return http.StreamedResponse(Stream<List<int>>.value(bytes), 200);
  }
}

class _ConcurrentByteDriveHttpClient extends _ByteDriveHttpClient {
  _ConcurrentByteDriveHttpClient(super.bytesByFileId);

  int inFlightDownloads = 0;
  int maxConcurrentDownloads = 0;

  @override
  Future<Uint8List> downloadBytes({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    inFlightDownloads += 1;
    if (inFlightDownloads > maxConcurrentDownloads) {
      maxConcurrentDownloads = inFlightDownloads;
    }

    try {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      return await super.downloadBytes(
        fileId: fileId,
        resourceKey: resourceKey,
        rangeHeader: rangeHeader,
      );
    } finally {
      inFlightDownloads -= 1;
    }
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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'package:aero_stream/data/drive/benchmark/drive_benchmark_read_model.dart';
import 'package:aero_stream/data/drive/drive_scan_backlog.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';

void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('drive-benchmark-read-');
    dbFile = File('${tempDir.path}\\aero_stream.sqlite');
    final database = sqlite.sqlite3.open(dbFile.path);
    try {
      _createSchema(database);
      _seedBaseData(database);
    } finally {
      database.close();
    }
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'largest-pending selects biggest matching pending tracks read-only',
    () async {
      final readModel = await SqliteDriveBenchmarkReadModel.open(
        databasePath: dbFile.path,
      );
      addTearDown(readModel.close);

      final tracks = await readModel.selectTracks(
        source: DriveBenchmarkTrackSource.largestPending,
        filter: DriveBenchmarkTrackFilter(
          metadataStatuses: <String>{TrackMetadataStatus.pending.value},
          artworkStatuses: const <String>{},
          mimeType: 'audio/mp4',
          limit: 2,
        ),
      );

      expect(tracks, hasLength(2));
      expect(tracks.first.track.driveFileId, 'track-large');
      expect(tracks.last.track.driveFileId, 'track-small');
    },
  );

  test('running-task-targets resolves active scan task targets', () async {
    final readModel = await SqliteDriveBenchmarkReadModel.open(
      databasePath: dbFile.path,
    );
    addTearDown(readModel.close);

    final tracks = await readModel.selectTracks(
      source: DriveBenchmarkTrackSource.runningTaskTargets,
      filter: DriveBenchmarkTrackFilter(
        metadataStatuses: <String>{TrackMetadataStatus.pending.value},
        artworkStatuses: const <String>{},
        limit: 5,
      ),
    );

    expect(tracks.map((track) => track.track.driveFileId), ['track-small']);
  });

  test('job sample returns state, last error, and running tasks', () async {
    final readModel = await SqliteDriveBenchmarkReadModel.open(
      databasePath: dbFile.path,
    );
    addTearDown(readModel.close);

    final sample = await readModel.getJobSample(22);

    expect(sample, isNotNull);
    expect(sample!.state, 'failed');
    expect(sample.phase, 'metadata_enrichment');
    expect(sample.lastError, 'Reconnect Google Drive to continue syncing.');
    expect(sample.runningTasks, hasLength(1));
    expect(sample.runningTasks.first.targetDriveId, 'track-small');
    expect(sample.runningTasks.first.fileName, 'small.m4a');
    expect(
      sample.pipelineBacklog,
      const ScanPipelineBacklog(
        metadata: ScanTaskBacklogEntry(runningCount: 1),
      ),
    );
  });
}

void _createSchema(sqlite.Database database) {
  database.execute('''
    CREATE TABLE sync_accounts (
      id INTEGER PRIMARY KEY,
      provider_account_id TEXT NOT NULL,
      email TEXT NOT NULL,
      display_name TEXT NOT NULL,
      auth_kind TEXT NOT NULL,
      is_active INTEGER NOT NULL,
      connected_at INTEGER NOT NULL,
      auth_session_state TEXT NOT NULL,
      auth_session_error TEXT
    )
  ''');

  database.execute('''
    CREATE TABLE tracks (
      id INTEGER PRIMARY KEY,
      root_id INTEGER NOT NULL,
      drive_file_id TEXT NOT NULL,
      resource_key TEXT,
      file_name TEXT NOT NULL,
      title TEXT NOT NULL,
      title_sort TEXT NOT NULL,
      artist TEXT NOT NULL,
      artist_sort TEXT NOT NULL,
      album TEXT NOT NULL,
      album_artist TEXT NOT NULL,
      genre TEXT NOT NULL,
      year INTEGER,
      track_number INTEGER NOT NULL,
      disc_number INTEGER NOT NULL,
      duration_ms INTEGER NOT NULL,
      mime_type TEXT NOT NULL,
      size_bytes INTEGER,
      md5_checksum TEXT,
      modified_time INTEGER,
      artwork_uri TEXT,
      artwork_blob_id INTEGER,
      artwork_status TEXT NOT NULL,
      cache_path TEXT,
      cache_status TEXT NOT NULL,
      metadata_status TEXT NOT NULL,
      index_status TEXT NOT NULL,
      metadata_schema_version INTEGER NOT NULL,
      content_fingerprint TEXT,
      play_count INTEGER NOT NULL,
      last_played_at INTEGER,
      is_favorite INTEGER NOT NULL,
      inserted_at INTEGER NOT NULL,
      discovered_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      removed_at INTEGER
    )
  ''');

  database.execute('''
    CREATE TABLE scan_jobs (
      id INTEGER PRIMARY KEY,
      account_id INTEGER NOT NULL,
      root_id INTEGER,
      kind TEXT NOT NULL,
      state TEXT NOT NULL,
      phase TEXT NOT NULL,
      metadata_ready_count INTEGER NOT NULL,
      artwork_ready_count INTEGER NOT NULL,
      failed_count INTEGER NOT NULL,
      last_error TEXT
    )
  ''');

  database.execute('''
    CREATE TABLE scan_tasks (
      id INTEGER PRIMARY KEY,
      job_id INTEGER NOT NULL,
      kind TEXT NOT NULL,
      state TEXT NOT NULL,
      root_id INTEGER,
      target_drive_id TEXT,
      attempts INTEGER NOT NULL,
      priority INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      last_error TEXT
    )
  ''');
}

void _seedBaseData(sqlite.Database database) {
  database.execute('''
    INSERT INTO sync_accounts (
      id,
      provider_account_id,
      email,
      display_name,
      auth_kind,
      is_active,
      connected_at,
      auth_session_state,
      auth_session_error
    ) VALUES (
      1,
      'account-1',
      'listener@example.com',
      'Listener',
      'oauth_desktop',
      1,
      1712188800,
      'ready',
      NULL
    )
  ''');

  _insertTrack(
    database,
    id: 1,
    driveFileId: 'track-large',
    fileName: 'large.m4a',
    mimeType: 'audio/mp4',
    sizeBytes: 9000000,
    metadataStatus: TrackMetadataStatus.pending.value,
    artworkStatus: TrackArtworkStatus.pending.value,
  );
  _insertTrack(
    database,
    id: 2,
    driveFileId: 'track-small',
    fileName: 'small.m4a',
    mimeType: 'audio/mp4',
    sizeBytes: 1000000,
    metadataStatus: TrackMetadataStatus.pending.value,
    artworkStatus: TrackArtworkStatus.pending.value,
  );
  _insertTrack(
    database,
    id: 3,
    driveFileId: 'track-removed',
    fileName: 'removed.m4a',
    mimeType: 'audio/mp4',
    sizeBytes: 8000000,
    metadataStatus: TrackMetadataStatus.pending.value,
    artworkStatus: TrackArtworkStatus.pending.value,
    indexStatus: TrackIndexStatus.removed.value,
  );

  database.execute('''
    INSERT INTO scan_jobs (
      id,
      account_id,
      root_id,
      kind,
      state,
      phase,
      metadata_ready_count,
      artwork_ready_count,
      failed_count,
      last_error
    ) VALUES (
      22,
      1,
      1,
      'baseline',
      'failed',
      'metadata_enrichment',
      9550,
      120,
      47,
      'Reconnect Google Drive to continue syncing.'
    )
  ''');

  database.execute('''
    INSERT INTO scan_tasks (
      id,
      job_id,
      kind,
      state,
      root_id,
      target_drive_id,
      attempts,
      priority,
      updated_at,
      last_error
    ) VALUES (
      501,
      22,
      'extract_tags',
      'running',
      1,
      'track-small',
      2,
      10,
      1712188800,
      NULL
    )
  ''');
}

void _insertTrack(
  sqlite.Database database, {
  required int id,
  required String driveFileId,
  required String fileName,
  required String mimeType,
  required int sizeBytes,
  required String metadataStatus,
  required String artworkStatus,
  String indexStatus = 'active',
}) {
  database.execute(
    '''
    INSERT INTO tracks (
      id,
      root_id,
      drive_file_id,
      resource_key,
      file_name,
      title,
      title_sort,
      artist,
      artist_sort,
      album,
      album_artist,
      genre,
      year,
      track_number,
      disc_number,
      duration_ms,
      mime_type,
      size_bytes,
      md5_checksum,
      modified_time,
      artwork_uri,
      artwork_blob_id,
      artwork_status,
      cache_path,
      cache_status,
      metadata_status,
      index_status,
      metadata_schema_version,
      content_fingerprint,
      play_count,
      last_played_at,
      is_favorite,
      inserted_at,
      discovered_at,
      updated_at,
      removed_at
    ) VALUES (?, 1, ?, NULL, ?, 'Title', 'title', 'Artist', 'artist', 'Album', 'Album Artist', '', NULL, 1, 1, 180000, ?, ?, 'md5', 1712188800, NULL, NULL, ?, NULL, 'none', ?, ?, 3, 'fingerprint', 0, NULL, 0, 1712188800, 1712188800, 1712188800, NULL)
    ''',
    <Object?>[
      id,
      driveFileId,
      fileName,
      mimeType,
      sizeBytes,
      artworkStatus,
      metadataStatus,
      indexStatus,
    ],
  );
}

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../../database/app_database.dart';
import '../drive_scan_backlog.dart';
import '../metadata_pipeline_backlog.dart';
import '../drive_scan_models.dart';

enum DriveBenchmarkTrackSource {
  largestPending('largest-pending'),
  failed('failed'),
  runningTaskTargets('running-task-targets'),
  driveFileId('drive-file-id');

  const DriveBenchmarkTrackSource(this.cliValue);

  final String cliValue;

  static DriveBenchmarkTrackSource? fromCli(String? value) {
    for (final candidate in values) {
      if (candidate.cliValue == value) {
        return candidate;
      }
    }
    return null;
  }
}

class DriveBenchmarkTrackFilter {
  const DriveBenchmarkTrackFilter({
    required this.metadataStatuses,
    required this.artworkStatuses,
    this.mimeType,
    this.limit = 10,
    this.driveFileIds = const <String>[],
  });

  final Set<String> metadataStatuses;
  final Set<String> artworkStatuses;
  final String? mimeType;
  final int limit;
  final List<String> driveFileIds;
}

class BenchmarkActiveAccount {
  const BenchmarkActiveAccount({
    required this.id,
    required this.providerAccountId,
    required this.email,
    required this.displayName,
    required this.authKind,
    required this.authSessionState,
    required this.authSessionError,
  });

  final int id;
  final String providerAccountId;
  final String email;
  final String displayName;
  final String authKind;
  final String authSessionState;
  final String? authSessionError;
}

class BenchmarkTrackCandidate {
  const BenchmarkTrackCandidate({required this.track, required this.source});

  final Track track;
  final DriveBenchmarkTrackSource source;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'trackId': track.id,
      'driveFileId': track.driveFileId,
      'fileName': track.fileName,
      'mimeType': track.mimeType,
      'sizeBytes': track.sizeBytes,
      'metadataStatus': track.metadataStatus,
      'artworkStatus': track.artworkStatus,
      'source': source.cliValue,
    };
  }
}

class BenchmarkRunningTask {
  const BenchmarkRunningTask({
    required this.id,
    required this.kind,
    required this.state,
    required this.targetDriveId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.attempts,
    required this.lastError,
    this.runtimeStage,
    this.updatedAt,
  });

  final int id;
  final String kind;
  final String state;
  final String? targetDriveId;
  final String? fileName;
  final String? mimeType;
  final int? sizeBytes;
  final int attempts;
  final String? lastError;
  final String? runtimeStage;
  final DateTime? updatedAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'kind': kind,
      'state': state,
      'targetDriveId': targetDriveId,
      'fileName': fileName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'attempts': attempts,
      'lastError': lastError,
      'runtimeStage': runtimeStage,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class BenchmarkJobSample {
  const BenchmarkJobSample({
    required this.jobId,
    required this.state,
    required this.phase,
    required this.metadataReadyCount,
    required this.artworkReadyCount,
    required this.failedCount,
    required this.lastError,
    required this.runningTasks,
    this.pipelineBacklog = const ScanPipelineBacklog(),
    this.metadataPipelineBacklog = const MetadataPipelineBacklog(),
  });

  final int jobId;
  final String state;
  final String phase;
  final int metadataReadyCount;
  final int artworkReadyCount;
  final int failedCount;
  final String? lastError;
  final List<BenchmarkRunningTask> runningTasks;
  final ScanPipelineBacklog pipelineBacklog;
  final MetadataPipelineBacklog metadataPipelineBacklog;
}

abstract interface class DriveBenchmarkReadModel {
  String get databasePath;

  Future<BenchmarkActiveAccount?> getActiveAccount();

  Future<List<BenchmarkTrackCandidate>> selectTracks({
    required DriveBenchmarkTrackSource source,
    required DriveBenchmarkTrackFilter filter,
  });

  Future<BenchmarkJobSample?> getJobSample(int jobId);

  void close();
}

class SqliteDriveBenchmarkReadModel implements DriveBenchmarkReadModel {
  SqliteDriveBenchmarkReadModel._({
    required String databasePath,
    required sqlite.Database database,
  }) : _databasePath = databasePath,
       _database = database;

  final String _databasePath;
  final sqlite.Database _database;

  static Future<SqliteDriveBenchmarkReadModel> open({
    String? databasePath,
  }) async {
    final resolvedPath = databasePath ?? await defaultDatabasePath();
    final database = sqlite.sqlite3.open(
      resolvedPath,
      mode: sqlite.OpenMode.readOnly,
    );
    return SqliteDriveBenchmarkReadModel._(
      databasePath: resolvedPath,
      database: database,
    );
  }

  static Future<String> defaultDatabasePath() async {
    final directory = await getApplicationSupportDirectory();
    return p.join(directory.path, 'aero_stream.sqlite');
  }

  @override
  String get databasePath => _databasePath;

  @override
  Future<BenchmarkActiveAccount?> getActiveAccount() async {
    final rows = _database.select('''
      SELECT
        id,
        provider_account_id,
        email,
        display_name,
        auth_kind,
        auth_session_state,
        auth_session_error
      FROM sync_accounts
      WHERE is_active = 1
      ORDER BY connected_at DESC, id DESC
      LIMIT 1
      ''');
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return BenchmarkActiveAccount(
      id: _readInt(row, 'id'),
      providerAccountId: _readString(row, 'provider_account_id'),
      email: _readString(row, 'email'),
      displayName: _readString(row, 'display_name'),
      authKind: _readString(row, 'auth_kind'),
      authSessionState: _readString(row, 'auth_session_state'),
      authSessionError: _readNullableString(row, 'auth_session_error'),
    );
  }

  @override
  Future<List<BenchmarkTrackCandidate>> selectTracks({
    required DriveBenchmarkTrackSource source,
    required DriveBenchmarkTrackFilter filter,
  }) async {
    final sql = StringBuffer('''
      SELECT tracks.*
      FROM tracks
    ''');
    final parameters = <Object?>[];

    if (source == DriveBenchmarkTrackSource.runningTaskTargets) {
      sql.write('''
        INNER JOIN scan_tasks
          ON scan_tasks.target_drive_id = tracks.drive_file_id
      ''');
    }

    final whereClauses = <String>['tracks.index_status != ?'];
    parameters.add(TrackIndexStatus.removed.value);

    if (filter.mimeType != null && filter.mimeType!.trim().isNotEmpty) {
      whereClauses.add('tracks.mime_type = ?');
      parameters.add(filter.mimeType!.trim());
    }

    switch (source) {
      case DriveBenchmarkTrackSource.largestPending:
      case DriveBenchmarkTrackSource.failed:
        final statusClause = _buildTrackStatusClause(
          metadataStatuses: filter.metadataStatuses,
          artworkStatuses: filter.artworkStatuses,
          parameters: parameters,
        );
        if (statusClause != null) {
          whereClauses.add(statusClause);
        }
      case DriveBenchmarkTrackSource.runningTaskTargets:
        whereClauses.add('scan_tasks.state = ?');
        parameters.add(DriveScanTaskState.running.value);
        final kinds = <String>{
          if (filter.metadataStatuses.isNotEmpty)
            DriveScanTaskKind.extractTags.value,
          if (filter.artworkStatuses.isNotEmpty)
            DriveScanTaskKind.extractArtwork.value,
        };
        if (kinds.isNotEmpty) {
          whereClauses.add(
            'scan_tasks.kind IN (${_placeholders(kinds.length)})',
          );
          parameters.addAll(kinds);
        }
      case DriveBenchmarkTrackSource.driveFileId:
        if (filter.driveFileIds.isEmpty) {
          return const <BenchmarkTrackCandidate>[];
        }
        whereClauses.add(
          'tracks.drive_file_id IN (${_placeholders(filter.driveFileIds.length)})',
        );
        parameters.addAll(filter.driveFileIds);
    }

    if (whereClauses.isNotEmpty) {
      sql.write(' WHERE ');
      sql.write(whereClauses.join(' AND '));
    }

    switch (source) {
      case DriveBenchmarkTrackSource.largestPending:
      case DriveBenchmarkTrackSource.failed:
        sql.write(
          ' ORDER BY COALESCE(tracks.size_bytes, 0) DESC, tracks.id ASC',
        );
      case DriveBenchmarkTrackSource.runningTaskTargets:
        sql.write(
          ' ORDER BY scan_tasks.priority DESC, scan_tasks.updated_at ASC, tracks.id ASC',
        );
      case DriveBenchmarkTrackSource.driveFileId:
        sql.write(' ORDER BY tracks.id ASC');
    }

    sql.write(' LIMIT ?');
    parameters.add(filter.limit);

    final rows = _database.select(sql.toString(), parameters);
    return rows
        .map(
          (row) =>
              BenchmarkTrackCandidate(track: _mapTrack(row), source: source),
        )
        .toList(growable: false);
  }

  @override
  Future<BenchmarkJobSample?> getJobSample(int jobId) async {
    final jobRows = _database.select(
      '''
      SELECT
        id,
        state,
        phase,
        metadata_ready_count,
        artwork_ready_count,
        failed_count,
        last_error
      FROM scan_jobs
      WHERE id = ?
      LIMIT 1
      ''',
      <Object?>[jobId],
    );
    if (jobRows.isEmpty) {
      return null;
    }

    final taskRows = _database.select(
      '''
      SELECT
        scan_tasks.id,
        scan_tasks.kind,
        scan_tasks.state,
        scan_tasks.target_drive_id,
        scan_tasks.attempts,
        scan_tasks.last_error,
        scan_tasks.runtime_stage,
        scan_tasks.updated_at,
        tracks.file_name,
        tracks.mime_type,
        tracks.size_bytes
      FROM scan_tasks
      LEFT JOIN tracks
        ON tracks.drive_file_id = scan_tasks.target_drive_id
      WHERE scan_tasks.job_id = ?
        AND scan_tasks.state = ?
      ORDER BY scan_tasks.kind ASC, scan_tasks.id ASC
      ''',
      <Object?>[jobId, DriveScanTaskState.running.value],
    );
    final backlogRows = _database.select(
      '''
      SELECT kind, state, COUNT(*) AS count
      FROM scan_tasks
      WHERE job_id = ?
      GROUP BY kind, state
      ''',
      <Object?>[jobId],
    );

    final row = jobRows.first;
    return BenchmarkJobSample(
      jobId: _readInt(row, 'id'),
      state: _readString(row, 'state'),
      phase: _readString(row, 'phase'),
      metadataReadyCount: _readInt(row, 'metadata_ready_count'),
      artworkReadyCount: _readInt(row, 'artwork_ready_count'),
      failedCount: _readInt(row, 'failed_count'),
      lastError: _readNullableString(row, 'last_error'),
      pipelineBacklog: _readPipelineBacklog(backlogRows),
      runningTasks: taskRows
          .map(
            (taskRow) => BenchmarkRunningTask(
              id: _readInt(taskRow, 'id'),
              kind: _readString(taskRow, 'kind'),
              state: _readString(taskRow, 'state'),
              targetDriveId: _readNullableString(taskRow, 'target_drive_id'),
              fileName: _readNullableString(taskRow, 'file_name'),
              mimeType: _readNullableString(taskRow, 'mime_type'),
              sizeBytes: _readNullableInt(taskRow, 'size_bytes'),
              attempts: _readInt(taskRow, 'attempts'),
              lastError: _readNullableString(taskRow, 'last_error'),
              runtimeStage: _readNullableString(taskRow, 'runtime_stage'),
              updatedAt: _readDateTime(taskRow['updated_at']),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  void close() {
    _database.close();
  }

  String? _buildTrackStatusClause({
    required Set<String> metadataStatuses,
    required Set<String> artworkStatuses,
    required List<Object?> parameters,
  }) {
    final clauses = <String>[];
    if (metadataStatuses.isNotEmpty) {
      clauses.add(
        'tracks.metadata_status IN (${_placeholders(metadataStatuses.length)})',
      );
      parameters.addAll(metadataStatuses);
    }
    if (artworkStatuses.isNotEmpty) {
      clauses.add(
        'tracks.artwork_status IN (${_placeholders(artworkStatuses.length)})',
      );
      parameters.addAll(artworkStatuses);
    }
    if (clauses.isEmpty) {
      return null;
    }
    if (clauses.length == 1) {
      return clauses.single;
    }
    return '(${clauses.join(' OR ')})';
  }

  Track _mapTrack(sqlite.Row row) {
    final md5Checksum = _readNullableString(row, 'md5_checksum');
    final sizeBytes = _readNullableInt(row, 'size_bytes');
    final modifiedTime = _readDateTime(row['modified_time']);
    return Track(
      id: _readInt(row, 'id'),
      rootId: _readInt(row, 'root_id'),
      driveFileId: _readString(row, 'drive_file_id'),
      resourceKey: _readNullableString(row, 'resource_key'),
      fileName: _readString(row, 'file_name'),
      title: _readString(row, 'title'),
      titleSort: _readString(row, 'title_sort'),
      artist: _readString(row, 'artist'),
      artistSort: _readString(row, 'artist_sort'),
      album: _readString(row, 'album'),
      albumArtist: _readString(row, 'album_artist'),
      genre: _readString(row, 'genre'),
      year: _readNullableInt(row, 'year'),
      trackNumber: _readInt(row, 'track_number'),
      discNumber: _readInt(row, 'disc_number'),
      durationMs: _readInt(row, 'duration_ms'),
      mimeType: _readString(row, 'mime_type'),
      sizeBytes: sizeBytes,
      md5Checksum: md5Checksum,
      modifiedTime: modifiedTime,
      artworkUri: _readNullableString(row, 'artwork_uri'),
      artworkBlobId: _readNullableInt(row, 'artwork_blob_id'),
      artworkStatus: _readString(row, 'artwork_status'),
      cachePath: _readNullableString(row, 'cache_path'),
      cacheStatus: _readString(row, 'cache_status'),
      metadataStatus: _readString(row, 'metadata_status'),
      indexStatus: _readString(row, 'index_status'),
      metadataSchemaVersion: _readInt(row, 'metadata_schema_version'),
      contentFingerprint:
          _readNullableString(row, 'content_fingerprint') ??
          buildContentFingerprint(
            md5Checksum: md5Checksum,
            sizeBytes: sizeBytes,
            modifiedTime: modifiedTime,
          ),
      playCount: _readInt(row, 'play_count'),
      lastPlayedAt: _readDateTime(row['last_played_at']),
      isFavorite: _readBool(row, 'is_favorite'),
      insertedAt:
          _readDateTime(row['inserted_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      discoveredAt:
          _readDateTime(row['discovered_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          _readDateTime(row['updated_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      removedAt: _readDateTime(row['removed_at']),
    );
  }

  static int _readInt(sqlite.Row row, String key) {
    final value = row[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.parse(value.toString());
  }

  static int? _readNullableInt(sqlite.Row row, String key) {
    final value = row[key];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  static bool _readBool(sqlite.Row row, String key) {
    final value = row[key];
    if (value is bool) {
      return value;
    }
    if (value is int) {
      return value != 0;
    }
    final normalized = value.toString().trim().toLowerCase();
    return normalized == '1' || normalized == 'true';
  }

  static String _readString(sqlite.Row row, String key) {
    return row[key]?.toString() ?? '';
  }

  static String? _readNullableString(sqlite.Row row, String key) {
    final value = row[key];
    if (value == null) {
      return null;
    }
    final normalized = value.toString();
    return normalized.isEmpty ? null : normalized;
  }

  static DateTime? _readDateTime(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      if (value == 0) {
        return null;
      }
      final isMilliseconds = value.abs() > 100000000000;
      return DateTime.fromMillisecondsSinceEpoch(
        isMilliseconds ? value : value * 1000,
      );
    }
    if (value is num) {
      return _readDateTime(value.toInt());
    }
    return DateTime.tryParse(value.toString());
  }

  static String _placeholders(int count) {
    return List<String>.filled(count, '?').join(', ');
  }

  static ScanPipelineBacklog _readPipelineBacklog(List<sqlite.Row> rows) {
    var discoveryQueued = 0;
    var discoveryRunning = 0;
    var discoveryFailed = 0;
    var changesQueued = 0;
    var changesRunning = 0;
    var changesFailed = 0;
    var metadataQueued = 0;
    var metadataRunning = 0;
    var metadataFailed = 0;
    var artworkQueued = 0;
    var artworkRunning = 0;
    var artworkFailed = 0;
    var deleteQueued = 0;
    var deleteRunning = 0;
    var deleteFailed = 0;

    for (final row in rows) {
      final kind = _readString(row, 'kind');
      final state = _readString(row, 'state');
      final count = _readInt(row, 'count');
      switch (kind) {
        case 'discover_folder':
          switch (state) {
            case 'queued':
              discoveryQueued += count;
            case 'running':
              discoveryRunning += count;
            case 'failed':
              discoveryFailed += count;
          }
        case 'reconcile_change':
          switch (state) {
            case 'queued':
              changesQueued += count;
            case 'running':
              changesRunning += count;
            case 'failed':
              changesFailed += count;
          }
        case 'extract_tags':
          switch (state) {
            case 'queued':
              metadataQueued += count;
            case 'running':
              metadataRunning += count;
            case 'failed':
              metadataFailed += count;
          }
        case 'extract_artwork':
          switch (state) {
            case 'queued':
              artworkQueued += count;
            case 'running':
              artworkRunning += count;
            case 'failed':
              artworkFailed += count;
          }
        case 'delete_projection':
          switch (state) {
            case 'queued':
              deleteQueued += count;
            case 'running':
              deleteRunning += count;
            case 'failed':
              deleteFailed += count;
          }
      }
    }

    return ScanPipelineBacklog(
      discovery: ScanTaskBacklogEntry(
        queuedCount: discoveryQueued,
        runningCount: discoveryRunning,
        failedCount: discoveryFailed,
      ),
      changes: ScanTaskBacklogEntry(
        queuedCount: changesQueued,
        runningCount: changesRunning,
        failedCount: changesFailed,
      ),
      metadata: ScanTaskBacklogEntry(
        queuedCount: metadataQueued,
        runningCount: metadataRunning,
        failedCount: metadataFailed,
      ),
      artwork: ScanTaskBacklogEntry(
        queuedCount: artworkQueued,
        runningCount: artworkRunning,
        failedCount: artworkFailed,
      ),
      deleteProjection: ScanTaskBacklogEntry(
        queuedCount: deleteQueued,
        runningCount: deleteRunning,
        failedCount: deleteFailed,
      ),
    );
  }
}

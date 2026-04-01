import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../drive/drive_entities.dart';
import '../drive/drive_scan_models.dart';
import '../../models/library_models.dart';

part 'app_database.g.dart';

const currentTrackMetadataSchemaVersion = 3;
const repairableTrackMetadataSchemaVersion = 1;
const currentUnixTimestampSql = "CAST(strftime('%s', 'now') AS INTEGER)";

class TrackMetadataBatchUpdate {
  const TrackMetadataBatchUpdate({
    required this.trackId,
    required this.titleValue,
    required this.artistValue,
    required this.albumValue,
    required this.albumArtistValue,
    required this.genreValue,
    required this.yearValue,
    required this.trackNumberValue,
    required this.discNumberValue,
    required this.durationMsValue,
    required this.artworkUriValue,
    required this.metadataStatusValue,
    required this.metadataSchemaVersionValue,
    this.artworkStatusValue,
    this.artworkBlobIdValue,
  });

  final int trackId;
  final String titleValue;
  final String artistValue;
  final String albumValue;
  final String albumArtistValue;
  final String genreValue;
  final int? yearValue;
  final int trackNumberValue;
  final int discNumberValue;
  final int durationMsValue;
  final String? artworkUriValue;
  final String metadataStatusValue;
  final int metadataSchemaVersionValue;
  final String? artworkStatusValue;
  final int? artworkBlobIdValue;
}

class TrackProjectionBatchUpdate {
  const TrackProjectionBatchUpdate({
    required this.trackId,
    required this.fileNameValue,
    required this.mimeTypeValue,
    required this.sizeBytesValue,
    required this.md5ChecksumValue,
    required this.modifiedTimeValue,
    required this.resourceKeyValue,
    required this.contentFingerprintValue,
    required this.indexStatusValue,
    required this.updatedAtValue,
    this.removedAtValue,
    this.cachePathValue,
    this.cacheStatusValue,
    this.metadataStatusValue,
    this.artworkStatusValue,
    this.artworkUriValue,
    this.artworkBlobIdValue,
  });

  final int trackId;
  final String fileNameValue;
  final String mimeTypeValue;
  final int? sizeBytesValue;
  final String? md5ChecksumValue;
  final DateTime? modifiedTimeValue;
  final String? resourceKeyValue;
  final String contentFingerprintValue;
  final String indexStatusValue;
  final DateTime updatedAtValue;
  final DateTime? removedAtValue;
  final String? cachePathValue;
  final String? cacheStatusValue;
  final String? metadataStatusValue;
  final String? artworkStatusValue;
  final String? artworkUriValue;
  final int? artworkBlobIdValue;
}

class SyncAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get providerAccountId => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text()();
  TextColumn get authKind => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get connectedAt => dateTime()();
  TextColumn get authSessionState =>
      text().withDefault(Constant(DriveAuthSessionState.ready.value))();
  TextColumn get authSessionError => text().nullable()();
  TextColumn get driveStartPageToken => text().nullable()();
  TextColumn get driveChangePageToken => text().nullable()();
  DateTimeColumn get lastSuccessfulSyncAt => dateTime().nullable()();
}

class SyncRoots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(SyncAccounts, #id)();
  TextColumn get folderId => text()();
  TextColumn get folderName => text()();
  TextColumn get parentFolderId => text().nullable()();
  TextColumn get syncState =>
      text().withDefault(Constant(DriveScanJobState.completed.value))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  IntColumn get activeJobId => integer().nullable()();
  IntColumn get indexedCount => integer().withDefault(const Constant(0))();
  IntColumn get metadataReadyCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get artworkReadyCount => integer().withDefault(const Constant(0))();
  IntColumn get failedCount => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {accountId, folderId},
  ];
}

class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rootId => integer().references(SyncRoots, #id)();
  TextColumn get driveFileId => text()();
  TextColumn get resourceKey => text().nullable()();
  TextColumn get fileName => text()();
  TextColumn get title => text()();
  TextColumn get titleSort => text().withDefault(const Constant(''))();
  TextColumn get artist => text()();
  TextColumn get artistSort => text().withDefault(const Constant(''))();
  TextColumn get album => text()();
  TextColumn get albumArtist => text()();
  TextColumn get genre => text()();
  IntColumn get year => integer().nullable()();
  IntColumn get trackNumber => integer().withDefault(const Constant(0))();
  IntColumn get discNumber => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get md5Checksum => text().nullable()();
  DateTimeColumn get modifiedTime => dateTime().nullable()();
  TextColumn get artworkUri => text().nullable()();
  IntColumn get artworkBlobId => integer().nullable()();
  TextColumn get artworkStatus =>
      text().withDefault(Constant(TrackArtworkStatus.pending.value))();
  TextColumn get cachePath => text().nullable()();
  TextColumn get cacheStatus => text().withDefault(const Constant('none'))();
  TextColumn get metadataStatus =>
      text().withDefault(Constant(TrackMetadataStatus.pending.value))();
  TextColumn get indexStatus =>
      text().withDefault(Constant(TrackIndexStatus.active.value))();
  IntColumn get metadataSchemaVersion => integer().withDefault(
    const Constant(currentTrackMetadataSchemaVersion),
  )();
  TextColumn get contentFingerprint => text().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get insertedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get discoveredAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get removedAt => dateTime().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {driveFileId},
  ];
}

class LibraryProjectionMetas extends Table {
  @override
  String get tableName => 'library_projection_meta';

  IntColumn get id => integer()();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  TextColumn get backfillState =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastBackfillAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class LibraryAlbumProjections extends Table {
  @override
  String get tableName => 'library_albums';

  TextColumn get stableId => text()();
  TextColumn get album => text()();
  TextColumn get albumArtist => text()();
  TextColumn get titleSort => text()();
  TextColumn get artistSort => text()();
  IntColumn get year => integer().withDefault(const Constant(0))();
  TextColumn get artworkUri => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {stableId};
}

class LibraryArtistProjections extends Table {
  @override
  String get tableName => 'library_artists';

  TextColumn get stableId => text()();
  TextColumn get name => text()();
  TextColumn get nameSort => text()();
  IntColumn get songCount => integer().withDefault(const Constant(0))();
  TextColumn get artworkUri => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {stableId};
}

class LibraryAlbumArtistProjections extends Table {
  @override
  String get tableName => 'library_album_artists';

  TextColumn get stableId => text()();
  TextColumn get name => text()();
  TextColumn get nameSort => text()();
  IntColumn get albumCount => integer().withDefault(const Constant(0))();
  TextColumn get artworkUri => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {stableId};
}

class LibraryGenreProjections extends Table {
  @override
  String get tableName => 'library_genres';

  TextColumn get stableId => text()();
  TextColumn get name => text()();
  TextColumn get nameSort => text()();
  IntColumn get songCount => integer().withDefault(const Constant(0))();
  TextColumn get artworkUri => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {stableId};
}

class DriveObjects extends Table {
  TextColumn get driveId => text()();
  TextColumn get parentDriveId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get mimeType => text()();
  TextColumn get objectKind => text()();
  TextColumn get resourceKey => text().nullable()();
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get md5Checksum => text().nullable()();
  DateTimeColumn get modifiedTime => dateTime().nullable()();
  TextColumn get rootIdsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isTombstoned => boolean().withDefault(const Constant(false))();
  IntColumn get lastSeenJobId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {driveId};
}

class ScanJobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(SyncAccounts, #id)();
  IntColumn get rootId => integer().nullable()();
  TextColumn get kind => text()();
  TextColumn get state => text()();
  TextColumn get phase => text()();
  TextColumn get checkpointToken => text().nullable()();
  TextColumn get startPageToken => text().nullable()();
  IntColumn get indexedCount => integer().withDefault(const Constant(0))();
  IntColumn get metadataReadyCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get artworkReadyCount => integer().withDefault(const Constant(0))();
  IntColumn get failedCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
}

class ScanTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jobId => integer().references(ScanJobs, #id)();
  TextColumn get kind => text()();
  TextColumn get state =>
      text().withDefault(Constant(DriveScanTaskState.queued.value))();
  IntColumn get rootId => integer().nullable()();
  TextColumn get targetDriveId => text().nullable()();
  TextColumn get dedupeKey => text().nullable()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {jobId, dedupeKey},
  ];
}

class ArtworkBlobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contentHash => text()();
  TextColumn get mimeType => text()();
  TextColumn get fileExtension => text()();
  TextColumn get filePath => text()();
  IntColumn get byteSize => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {contentHash},
  ];
}

class PlaybackStates extends Table {
  IntColumn get id => integer()();
  TextColumn get queueTrackIdsJson =>
      text().withDefault(const Constant('[]'))();
  IntColumn get currentTrackId => integer().nullable()();
  IntColumn get currentIndex => integer().withDefault(const Constant(-1))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  BoolColumn get isPlaying => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class RootScanCounts {
  const RootScanCounts({
    required this.indexedCount,
    required this.metadataReadyCount,
    required this.artworkReadyCount,
    required this.failedCount,
  });

  final int indexedCount;
  final int metadataReadyCount;
  final int artworkReadyCount;
  final int failedCount;
}

class _LibraryAlbumProjectionKey {
  const _LibraryAlbumProjectionKey(this.albumArtist, this.album);

  final String albumArtist;
  final String album;

  String get stableId => '$albumArtist\x1F$album';

  @override
  bool operator ==(Object other) =>
      other is _LibraryAlbumProjectionKey &&
      other.albumArtist == albumArtist &&
      other.album == album;

  @override
  int get hashCode => Object.hash(albumArtist, album);
}

class _LibraryTrackProjectionDiff {
  const _LibraryTrackProjectionDiff({this.before, this.after});

  final Track? before;
  final Track? after;
}

@DriftDatabase(
  tables: [
    SyncAccounts,
    SyncRoots,
    Tracks,
    LibraryProjectionMetas,
    LibraryAlbumProjections,
    LibraryArtistProjections,
    LibraryAlbumArtistProjections,
    LibraryGenreProjections,
    DriveObjects,
    ScanJobs,
    ScanTasks,
    ArtworkBlobs,
    PlaybackStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(syncAccounts, syncAccounts.driveStartPageToken);
        await m.addColumn(syncAccounts, syncAccounts.driveChangePageToken);
        await m.addColumn(syncAccounts, syncAccounts.lastSuccessfulSyncAt);

        await m.addColumn(syncRoots, syncRoots.activeJobId);
        await m.addColumn(syncRoots, syncRoots.indexedCount);
        await m.addColumn(syncRoots, syncRoots.metadataReadyCount);
        await m.addColumn(syncRoots, syncRoots.artworkReadyCount);
        await m.addColumn(syncRoots, syncRoots.failedCount);

        await m.addColumn(tracks, tracks.artworkBlobId);
        await m.addColumn(tracks, tracks.artworkStatus);
        await m.addColumn(tracks, tracks.indexStatus);
        await m.addColumn(tracks, tracks.contentFingerprint);
        await m.addColumn(tracks, tracks.discoveredAt);
        await m.addColumn(tracks, tracks.updatedAt);
        await m.addColumn(tracks, tracks.removedAt);

        await m.createTable(driveObjects);
        await m.createTable(scanJobs);
        await m.createTable(scanTasks);
        await m.createTable(artworkBlobs);

        await customStatement('''
          UPDATE tracks
          SET
            index_status = '${TrackIndexStatus.active.value}',
            artwork_status = CASE
              WHEN artwork_uri IS NULL OR artwork_uri = '' THEN '${TrackArtworkStatus.pending.value}'
              ELSE '${TrackArtworkStatus.ready.value}'
            END,
            discovered_at = COALESCE(discovered_at, inserted_at, $currentUnixTimestampSql),
            updated_at = COALESCE(updated_at, inserted_at, $currentUnixTimestampSql)
        ''');
      }
      if (from < 3) {
        await m.addColumn(syncAccounts, syncAccounts.authSessionState);
        await m.addColumn(syncAccounts, syncAccounts.authSessionError);
        await customStatement('''
          UPDATE sync_accounts
          SET auth_session_state = '${DriveAuthSessionState.ready.value}'
          WHERE auth_session_state IS NULL OR auth_session_state = ''
        ''');
      }
      if (from < 4) {
        await m.addColumn(tracks, tracks.metadataSchemaVersion);
        await customStatement('''
          UPDATE tracks
          SET metadata_schema_version = $repairableTrackMetadataSchemaVersion
          WHERE metadata_schema_version IS NULL
        ''');
      }
      if (from < 5) {
        await m.addColumn(tracks, tracks.titleSort);
        await m.addColumn(tracks, tracks.artistSort);
        await m.createTable(libraryProjectionMetas);
        await m.createTable(libraryAlbumProjections);
        await m.createTable(libraryArtistProjections);
        await m.createTable(libraryAlbumArtistProjections);
        await m.createTable(libraryGenreProjections);
        await customStatement('''
          UPDATE tracks
          SET
            title_sort = LOWER(TRIM(COALESCE(title, ''))),
            artist_sort = LOWER(TRIM(COALESCE(artist, '')))
          WHERE title_sort IS NULL OR title_sort = '' OR artist_sort IS NULL
        ''');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      await _repairLegacyDateTimeStorage();
      await _createIndexesIfNeeded();
      await ensureLibraryProjectionMetaRow();
    },
  );

  Future<void> ensurePlaybackStateRow() async {
    await into(
      playbackStates,
    ).insertOnConflictUpdate(const PlaybackStatesCompanion(id: Value(1)));
  }

  Future<void> ensureLibraryProjectionMetaRow() async {
    await into(libraryProjectionMetas).insertOnConflictUpdate(
      const LibraryProjectionMetasCompanion(
        id: Value(1),
        revision: Value(0),
        backfillState: Value('pending'),
      ),
    );
  }

  Future<LibraryProjectionMeta?> getLibraryProjectionMeta() {
    return (select(
      libraryProjectionMetas,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
  }

  Future<int> getLibraryProjectionRevision() async {
    final row = await getLibraryProjectionMeta();
    return row?.revision ?? 0;
  }

  Future<void> _repairLegacyDateTimeStorage() async {
    await customStatement('''
      UPDATE tracks
      SET
        discovered_at = CASE
          WHEN typeof(discovered_at) = 'text'
            THEN CAST(strftime('%s', discovered_at) AS INTEGER)
          ELSE discovered_at
        END,
        updated_at = CASE
          WHEN typeof(updated_at) = 'text'
            THEN CAST(strftime('%s', updated_at) AS INTEGER)
          ELSE updated_at
        END
      WHERE typeof(discovered_at) = 'text' OR typeof(updated_at) = 'text'
    ''');
    await customStatement('''
      UPDATE library_projection_meta
      SET last_backfill_at = CAST(strftime('%s', last_backfill_at) AS INTEGER)
      WHERE typeof(last_backfill_at) = 'text'
    ''');
    await customStatement('''
      UPDATE library_albums
      SET updated_at = CAST(strftime('%s', updated_at) AS INTEGER)
      WHERE typeof(updated_at) = 'text'
    ''');
    await customStatement('''
      UPDATE library_artists
      SET updated_at = CAST(strftime('%s', updated_at) AS INTEGER)
      WHERE typeof(updated_at) = 'text'
    ''');
    await customStatement('''
      UPDATE library_album_artists
      SET updated_at = CAST(strftime('%s', updated_at) AS INTEGER)
      WHERE typeof(updated_at) = 'text'
    ''');
    await customStatement('''
      UPDATE library_genres
      SET updated_at = CAST(strftime('%s', updated_at) AS INTEGER)
      WHERE typeof(updated_at) = 'text'
    ''');
  }

  Future<void> _createIndexesIfNeeded() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_root_id ON tracks (root_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_index_status ON tracks (index_status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_metadata_status ON tracks (metadata_status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_artwork_status ON tracks (artwork_status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_content_fingerprint ON tracks (content_fingerprint)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_title_page ON tracks (index_status, title_sort, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_artist_page ON tracks (index_status, artist_sort, title_sort, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_duration_page ON tracks (index_status, duration_ms DESC, title_sort, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_album_detail ON tracks (index_status, metadata_status, album, album_artist, disc_number, track_number, title, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_library_albums_title ON library_albums (title_sort, stable_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_library_albums_artist ON library_albums (artist_sort, title_sort, stable_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_library_albums_year ON library_albums (year DESC, title_sort, stable_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_library_artists_name ON library_artists (name_sort, stable_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_library_artists_song_count ON library_artists (song_count DESC, name_sort, stable_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_library_album_artists_name ON library_album_artists (name_sort, stable_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_library_album_artists_album_count ON library_album_artists (album_count DESC, name_sort, stable_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_library_genres_name ON library_genres (name_sort, stable_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_library_genres_song_count ON library_genres (song_count DESC, name_sort, stable_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_drive_objects_parent_drive_id ON drive_objects (parent_drive_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_drive_objects_last_seen_job_id ON drive_objects (last_seen_job_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_scan_jobs_account_state_created ON scan_jobs (account_id, state, created_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_scan_tasks_job_kind_state_priority ON scan_tasks (job_id, kind, state, priority DESC, created_at ASC)',
    );
  }

  Stream<SyncAccount?> watchActiveAccount() {
    final query = select(syncAccounts)
      ..where((table) => table.isActive.equals(true))
      ..limit(1);
    return query.watchSingleOrNull();
  }

  Future<SyncAccount?> getActiveAccount() {
    final query = select(syncAccounts)
      ..where((table) => table.isActive.equals(true))
      ..limit(1);
    return query.getSingleOrNull();
  }

  Stream<List<SyncRoot>> watchRoots() {
    final query = select(syncRoots)
      ..orderBy([(table) => OrderingTerm(expression: table.folderName)]);
    return query.watch();
  }

  Future<List<SyncRoot>> getRoots() {
    final query = select(syncRoots)
      ..orderBy([(table) => OrderingTerm(expression: table.folderName)]);
    return query.get();
  }

  Future<SyncRoot?> getRootById(int rootId) {
    return (select(
      syncRoots,
    )..where((table) => table.id.equals(rootId))).getSingleOrNull();
  }

  Future<SyncRoot?> getRootByFolderId(String folderId) {
    return (select(
      syncRoots,
    )..where((table) => table.folderId.equals(folderId))).getSingleOrNull();
  }

  Stream<List<Track>> watchAllTracks() {
    final query = select(tracks)
      ..where(
        (table) => table.indexStatus.isNotValue(TrackIndexStatus.removed.value),
      )
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.lastPlayedAt,
          mode: OrderingMode.desc,
        ),
        (table) => OrderingTerm(expression: table.title),
      ]);
    return query.watch();
  }

  Stream<List<Track>> watchRecentTracks({int limit = 5}) {
    final query = select(tracks)
      ..where(
        (table) => table.indexStatus.isNotValue(TrackIndexStatus.removed.value),
      )
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.lastPlayedAt,
          mode: OrderingMode.desc,
        ),
        (table) =>
            OrderingTerm(expression: table.insertedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.watch();
  }

  Stream<List<Track>> watchFavoriteTracks({int limit = 20}) {
    final query = select(tracks)
      ..where(
        (table) =>
            table.isFavorite.equals(true) &
            table.indexStatus.isNotValue(TrackIndexStatus.removed.value),
      )
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.lastPlayedAt,
          mode: OrderingMode.desc,
        ),
        (table) => OrderingTerm(expression: table.title),
      ])
      ..limit(limit);
    return query.watch();
  }

  Future<Track?> getTrackById(int trackId) {
    final query = select(tracks)..where((table) => table.id.equals(trackId));
    return query.getSingleOrNull();
  }

  Future<Track?> getTrackByDriveFileId(String driveFileId) {
    final query = select(tracks)
      ..where((table) => table.driveFileId.equals(driveFileId));
    return query.getSingleOrNull();
  }

  Future<List<Track>> getTracksByDriveFileIds(Iterable<String> driveFileIds) {
    final ids = driveFileIds.toSet().toList(growable: false);
    if (ids.isEmpty) {
      return Future.value(const <Track>[]);
    }
    final query = select(tracks)..where((table) => table.driveFileId.isIn(ids));
    return query.get();
  }

  Future<List<Track>> getTracksByIds(Iterable<int> trackIds) {
    final ids = trackIds.toSet().toList(growable: false);
    if (ids.isEmpty) {
      return Future.value(const <Track>[]);
    }
    final query = select(tracks)..where((table) => table.id.isIn(ids));
    return query.get();
  }

  Stream<PlaybackState?> watchPlaybackState() {
    final query = select(playbackStates)..where((table) => table.id.equals(1));
    return query.watchSingleOrNull();
  }

  Future<PlaybackState?> getPlaybackState() async {
    await ensurePlaybackStateRow();
    final query = select(playbackStates)..where((table) => table.id.equals(1));
    return query.getSingleOrNull();
  }

  Future<int> setActiveAccount(SyncAccountsCompanion account) async {
    return transaction(() async {
      final existingActiveAccount = await getActiveAccount();
      await update(
        syncAccounts,
      ).write(const SyncAccountsCompanion(isActive: Value(false)));

      if (existingActiveAccount != null) {
        await (update(
          syncAccounts,
        )..where((table) => table.id.equals(existingActiveAccount.id))).write(
          _mergeActiveAccountCompanion(existingActiveAccount, account),
        );
        return existingActiveAccount.id;
      }

      return into(
        syncAccounts,
      ).insert(_mergeActiveAccountCompanion(null, account));
    });
  }

  SyncAccountsCompanion _mergeActiveAccountCompanion(
    SyncAccount? existing,
    SyncAccountsCompanion incoming,
  ) {
    return SyncAccountsCompanion(
      providerAccountId: incoming.providerAccountId.present
          ? incoming.providerAccountId
          : Value(existing?.providerAccountId ?? ''),
      email: incoming.email.present
          ? incoming.email
          : Value(existing?.email ?? ''),
      displayName: incoming.displayName.present
          ? incoming.displayName
          : Value(existing?.displayName ?? ''),
      authKind: incoming.authKind.present
          ? incoming.authKind
          : Value(existing?.authKind ?? ''),
      isActive: incoming.isActive.present
          ? incoming.isActive
          : const Value(true),
      connectedAt: incoming.connectedAt.present
          ? incoming.connectedAt
          : Value(existing?.connectedAt ?? DateTime.now()),
      authSessionState: incoming.authSessionState.present
          ? incoming.authSessionState
          : Value(
              existing?.authSessionState ?? DriveAuthSessionState.ready.value,
            ),
      authSessionError: incoming.authSessionError.present
          ? incoming.authSessionError
          : Value(existing?.authSessionError),
      driveStartPageToken: incoming.driveStartPageToken.present
          ? incoming.driveStartPageToken
          : Value(existing?.driveStartPageToken),
      driveChangePageToken: incoming.driveChangePageToken.present
          ? incoming.driveChangePageToken
          : Value(existing?.driveChangePageToken),
      lastSuccessfulSyncAt: incoming.lastSuccessfulSyncAt.present
          ? incoming.lastSuccessfulSyncAt
          : Value(existing?.lastSuccessfulSyncAt),
    );
  }

  Future<void> updateAccountAuthSession(
    int accountId, {
    required String authSessionStateValue,
    String? authSessionErrorValue,
  }) {
    return (update(
      syncAccounts,
    )..where((table) => table.id.equals(accountId))).write(
      SyncAccountsCompanion(
        authSessionState: Value(authSessionStateValue),
        authSessionError: Value(authSessionErrorValue),
      ),
    );
  }

  Future<void> markAccountReauthRequired(
    int accountId, {
    String authSessionErrorValue = driveAuthReconnectRequiredMessage,
    String rootErrorValue = driveSyncReconnectRequiredMessage,
  }) async {
    await transaction(() async {
      await updateAccountAuthSession(
        accountId,
        authSessionStateValue: DriveAuthSessionState.reauthRequired.value,
        authSessionErrorValue: authSessionErrorValue,
      );

      final activeJobs =
          await (select(scanJobs)..where(
                (table) =>
                    table.accountId.equals(accountId) &
                    table.state.isIn([
                      DriveScanJobState.queued.value,
                      DriveScanJobState.running.value,
                      DriveScanJobState.paused.value,
                      DriveScanJobState.cancelRequested.value,
                    ]),
              ))
              .get();

      if (activeJobs.isNotEmpty) {
        final activeJobIds = activeJobs
            .map((job) => job.id)
            .toList(growable: false);
        final now = DateTime.now();

        await (update(
          scanJobs,
        )..where((table) => table.id.isIn(activeJobIds))).write(
          ScanJobsCompanion(
            state: Value(DriveScanJobState.failed.value),
            lastError: Value(rootErrorValue),
            finishedAt: Value(now),
          ),
        );

        await (update(scanTasks)..where(
              (table) =>
                  table.jobId.isIn(activeJobIds) &
                  table.state.isIn([
                    DriveScanTaskState.queued.value,
                    DriveScanTaskState.running.value,
                  ]),
            ))
            .write(
              ScanTasksCompanion(
                state: Value(DriveScanTaskState.canceled.value),
                lastError: Value(rootErrorValue),
                lockedAt: const Value(null),
                updatedAt: Value(now),
              ),
            );
      }

      await (update(
        syncRoots,
      )..where((table) => table.accountId.equals(accountId))).write(
        SyncRootsCompanion(
          syncState: Value(DriveScanJobState.failed.value),
          lastError: Value(rootErrorValue),
          activeJobId: const Value(null),
        ),
      );
    });
  }

  Future<void> updateAccountSyncCheckpoint(
    int accountId, {
    String? driveStartPageTokenValue,
    String? driveChangePageTokenValue,
    DateTime? lastSuccessfulSyncAtValue,
  }) {
    return (update(
      syncAccounts,
    )..where((table) => table.id.equals(accountId))).write(
      SyncAccountsCompanion(
        driveStartPageToken: Value(driveStartPageTokenValue),
        driveChangePageToken: Value(driveChangePageTokenValue),
        lastSuccessfulSyncAt: Value(lastSuccessfulSyncAtValue),
      ),
    );
  }

  Future<void> clearActiveAccount() async {
    await transaction(() async {
      await delete(syncAccounts).go();
      await delete(syncRoots).go();
      await delete(tracks).go();
      await delete(libraryAlbumProjections).go();
      await delete(libraryArtistProjections).go();
      await delete(libraryAlbumArtistProjections).go();
      await delete(libraryGenreProjections).go();
      await delete(libraryProjectionMetas).go();
      await delete(driveObjects).go();
      await delete(scanTasks).go();
      await delete(scanJobs).go();
    });
    await ensureLibraryProjectionMetaRow();
  }

  Future<int> upsertRoot(SyncRootsCompanion root) {
    return into(syncRoots).insertOnConflictUpdate(root);
  }

  Future<void> updateRootState(
    int rootId, {
    required String syncStateValue,
    DateTime? lastSyncedAtValue,
    String? lastErrorValue,
    int? activeJobIdValue,
  }) async {
    await (update(syncRoots)..where((table) => table.id.equals(rootId))).write(
      SyncRootsCompanion(
        syncState: Value(syncStateValue),
        lastSyncedAt: Value(lastSyncedAtValue),
        lastError: Value(lastErrorValue),
        activeJobId: Value(activeJobIdValue),
      ),
    );
  }

  Future<void> updateRootCounters(
    int rootId, {
    int? indexedCountValue,
    int? metadataReadyCountValue,
    int? artworkReadyCountValue,
    int? failedCountValue,
  }) async {
    await (update(syncRoots)..where((table) => table.id.equals(rootId))).write(
      SyncRootsCompanion(
        indexedCount: indexedCountValue == null
            ? const Value.absent()
            : Value(indexedCountValue),
        metadataReadyCount: metadataReadyCountValue == null
            ? const Value.absent()
            : Value(metadataReadyCountValue),
        artworkReadyCount: artworkReadyCountValue == null
            ? const Value.absent()
            : Value(artworkReadyCountValue),
        failedCount: failedCountValue == null
            ? const Value.absent()
            : Value(failedCountValue),
      ),
    );
  }

  Future<void> deleteRoot(int rootId) async {
    final removedTracks = await (select(
      tracks,
    )..where((table) => table.rootId.equals(rootId))).get();
    await transaction(() async {
      await (delete(
        tracks,
      )..where((table) => table.rootId.equals(rootId))).go();
      await (delete(syncRoots)..where((table) => table.id.equals(rootId))).go();
    });
    await _refreshLibraryProjectionsForDiffs(
      removedTracks.map((track) => _LibraryTrackProjectionDiff(before: track)),
    );
  }

  Future<void> purgeTracksMissingFromRoot(
    int rootId,
    Set<String> currentDriveIds,
  ) async {
    final deleteQuery = select(tracks)
      ..where((table) => table.rootId.equals(rootId));
    if (currentDriveIds.isNotEmpty) {
      deleteQuery.where((table) => table.driveFileId.isNotIn(currentDriveIds));
    }
    final removedTracks = await deleteQuery.get();

    final query = delete(tracks)..where((table) => table.rootId.equals(rootId));
    if (currentDriveIds.isNotEmpty) {
      query.where((table) => table.driveFileId.isNotIn(currentDriveIds));
    }
    await query.go();
    await _refreshLibraryProjectionsForDiffs(
      removedTracks.map((track) => _LibraryTrackProjectionDiff(before: track)),
    );
  }

  Future<int> upsertTrack(TracksCompanion track) async {
    await insertAllTracksOnConflictUpdate([track]);
    final driveFileId = track.driveFileId.value;
    final row = await getTrackByDriveFileId(driveFileId);
    return row?.id ?? 0;
  }

  Future<void> insertAllTracksOnConflictUpdate(
    List<TracksCompanion> rows,
  ) async {
    if (rows.isEmpty) {
      return;
    }
    final driveIds = rows
        .map((row) => row.driveFileId.value)
        .toList(growable: false);
    final beforeTracks = await getTracksByDriveFileIds(driveIds);
    await batch((batch) {
      batch.insertAllOnConflictUpdate(tracks, rows);
    });
    final afterTracks = await getTracksByDriveFileIds(driveIds);
    await _refreshLibraryProjectionsForDiffs(
      _buildTrackDiffsByDriveFileId(
        beforeTracks: beforeTracks,
        afterTracks: afterTracks,
      ),
    );
  }

  Future<List<Track>> tracksNeedingMetadata({int? limit}) {
    final query = select(tracks)
      ..where(
        (table) =>
            (table.metadataStatus.equals(TrackMetadataStatus.pending.value) |
                table.metadataStatus.equals(TrackMetadataStatus.stale.value)) &
            table.indexStatus.isNotValue(TrackIndexStatus.removed.value),
      )
      ..orderBy([(table) => OrderingTerm(expression: table.insertedAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<List<Track>> tracksNeedingArtwork({int? limit}) {
    final query = select(tracks)
      ..where(
        (table) =>
            table.artworkStatus.equals(TrackArtworkStatus.pending.value) &
            table.indexStatus.isNotValue(TrackIndexStatus.removed.value),
      )
      ..orderBy([(table) => OrderingTerm(expression: table.updatedAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<List<Track>> tracksPendingDeletion({int? limit}) {
    final query = select(tracks)
      ..where(
        (table) =>
            table.indexStatus.equals(TrackIndexStatus.pendingDelete.value),
      )
      ..orderBy([(table) => OrderingTerm(expression: table.updatedAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<List<Track>> getTracksNeedingMetadataCatchUp({
    required int accountId,
    required int metadataSchemaVersionBelow,
    int? rootId,
    int? limit,
  }) async {
    final roots = await getRoots();
    final rootIds = roots
        .where((root) => root.accountId == accountId)
        .where((root) => rootId == null || root.id == rootId)
        .map((root) => root.id)
        .toList(growable: false);
    if (rootIds.isEmpty) {
      return const <Track>[];
    }

    final query = select(tracks)
      ..where(
        (table) =>
            table.rootId.isIn(rootIds) &
            table.indexStatus.isNotValue(TrackIndexStatus.removed.value) &
            (table.metadataStatus.equals(TrackMetadataStatus.pending.value) |
                table.metadataStatus.equals(TrackMetadataStatus.stale.value) |
                (table.metadataStatus.equals(TrackMetadataStatus.ready.value) &
                    table.metadataSchemaVersion.isSmallerThanValue(
                      metadataSchemaVersionBelow,
                    ))),
      )
      ..orderBy([(table) => OrderingTerm(expression: table.updatedAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<void> updateTrackMetadata(
    int trackId, {
    required String titleValue,
    required String artistValue,
    required String albumValue,
    required String albumArtistValue,
    required String genreValue,
    required int? yearValue,
    required int trackNumberValue,
    required int discNumberValue,
    required int durationMsValue,
    required String? artworkUriValue,
    required String metadataStatusValue,
    required int metadataSchemaVersionValue,
    String? artworkStatusValue,
    int? artworkBlobIdValue,
  }) async {
    await applyTrackMetadataBatch([
      TrackMetadataBatchUpdate(
        trackId: trackId,
        titleValue: titleValue,
        artistValue: artistValue,
        albumValue: albumValue,
        albumArtistValue: albumArtistValue,
        genreValue: genreValue,
        yearValue: yearValue,
        trackNumberValue: trackNumberValue,
        discNumberValue: discNumberValue,
        durationMsValue: durationMsValue,
        artworkUriValue: artworkUriValue,
        metadataStatusValue: metadataStatusValue,
        metadataSchemaVersionValue: metadataSchemaVersionValue,
        artworkStatusValue: artworkStatusValue,
        artworkBlobIdValue: artworkBlobIdValue,
      ),
    ]);
  }

  Future<void> applyTrackMetadataBatch(
    List<TrackMetadataBatchUpdate> updates,
  ) async {
    if (updates.isEmpty) {
      return;
    }

    final trackIds = updates
        .map((update) => update.trackId)
        .toList(growable: false);
    final beforeTracks = await getTracksByIds(trackIds);
    final now = DateTime.now();
    await batch((batch) {
      for (final updateRow in updates) {
        batch.update(
          tracks,
          TracksCompanion(
            title: Value(updateRow.titleValue),
            titleSort: Value(_normalizeSortValue(updateRow.titleValue)),
            artist: Value(updateRow.artistValue),
            artistSort: Value(_normalizeSortValue(updateRow.artistValue)),
            album: Value(updateRow.albumValue),
            albumArtist: Value(updateRow.albumArtistValue),
            genre: Value(updateRow.genreValue),
            year: Value(updateRow.yearValue),
            trackNumber: Value(updateRow.trackNumberValue),
            discNumber: Value(updateRow.discNumberValue),
            durationMs: Value(updateRow.durationMsValue),
            artworkUri: Value(updateRow.artworkUriValue),
            artworkBlobId: updateRow.artworkBlobIdValue == null
                ? const Value.absent()
                : Value(updateRow.artworkBlobIdValue),
            metadataStatus: Value(updateRow.metadataStatusValue),
            metadataSchemaVersion: Value(updateRow.metadataSchemaVersionValue),
            artworkStatus: updateRow.artworkStatusValue == null
                ? const Value.absent()
                : Value(updateRow.artworkStatusValue!),
            updatedAt: Value(now),
          ),
          where: (table) => table.id.equals(updateRow.trackId),
        );
      }
    });
    final afterTracks = await getTracksByIds(trackIds);
    await _refreshLibraryProjectionsForDiffs(
      _buildTrackDiffsByTrackId(
        beforeTracks: beforeTracks,
        afterTracks: afterTracks,
      ),
    );
  }

  Future<void> updateTrackProjection(
    int trackId, {
    required String fileNameValue,
    required String mimeTypeValue,
    required int? sizeBytesValue,
    required String? md5ChecksumValue,
    required DateTime? modifiedTimeValue,
    required String? resourceKeyValue,
    required String contentFingerprintValue,
    required String indexStatusValue,
    required DateTime updatedAtValue,
    DateTime? removedAtValue,
    String? cachePathValue,
    String? cacheStatusValue,
    String? metadataStatusValue,
    String? artworkStatusValue,
    String? artworkUriValue,
    int? artworkBlobIdValue,
  }) async {
    await applyTrackProjectionBatch([
      TrackProjectionBatchUpdate(
        trackId: trackId,
        fileNameValue: fileNameValue,
        mimeTypeValue: mimeTypeValue,
        sizeBytesValue: sizeBytesValue,
        md5ChecksumValue: md5ChecksumValue,
        modifiedTimeValue: modifiedTimeValue,
        resourceKeyValue: resourceKeyValue,
        contentFingerprintValue: contentFingerprintValue,
        indexStatusValue: indexStatusValue,
        updatedAtValue: updatedAtValue,
        removedAtValue: removedAtValue,
        cachePathValue: cachePathValue,
        cacheStatusValue: cacheStatusValue,
        metadataStatusValue: metadataStatusValue,
        artworkStatusValue: artworkStatusValue,
        artworkUriValue: artworkUriValue,
        artworkBlobIdValue: artworkBlobIdValue,
      ),
    ]);
  }

  Future<void> applyTrackProjectionBatch(
    List<TrackProjectionBatchUpdate> updates,
  ) async {
    if (updates.isEmpty) {
      return;
    }

    final trackIds = updates
        .map((update) => update.trackId)
        .toList(growable: false);
    final beforeTracks = await getTracksByIds(trackIds);
    await batch((batch) {
      for (final updateRow in updates) {
        batch.update(
          tracks,
          TracksCompanion(
            fileName: Value(updateRow.fileNameValue),
            mimeType: Value(updateRow.mimeTypeValue),
            sizeBytes: Value(updateRow.sizeBytesValue),
            md5Checksum: Value(updateRow.md5ChecksumValue),
            modifiedTime: Value(updateRow.modifiedTimeValue),
            resourceKey: Value(updateRow.resourceKeyValue),
            contentFingerprint: Value(updateRow.contentFingerprintValue),
            indexStatus: Value(updateRow.indexStatusValue),
            cachePath: updateRow.cachePathValue == null
                ? const Value.absent()
                : Value(updateRow.cachePathValue!),
            cacheStatus: updateRow.cacheStatusValue == null
                ? const Value.absent()
                : Value(updateRow.cacheStatusValue!),
            metadataStatus: updateRow.metadataStatusValue == null
                ? const Value.absent()
                : Value(updateRow.metadataStatusValue!),
            artworkStatus: updateRow.artworkStatusValue == null
                ? const Value.absent()
                : Value(updateRow.artworkStatusValue!),
            artworkUri: updateRow.artworkUriValue == null
                ? const Value.absent()
                : Value(updateRow.artworkUriValue!),
            artworkBlobId: updateRow.artworkBlobIdValue == null
                ? const Value.absent()
                : Value(updateRow.artworkBlobIdValue),
            updatedAt: Value(updateRow.updatedAtValue),
            removedAt: Value(updateRow.removedAtValue),
          ),
          where: (table) => table.id.equals(updateRow.trackId),
        );
      }
    });
    final afterTracks = await getTracksByIds(trackIds);
    await _refreshLibraryProjectionsForDiffs(
      _buildTrackDiffsByTrackId(
        beforeTracks: beforeTracks,
        afterTracks: afterTracks,
      ),
    );
  }

  Future<void> markTrackPendingDeleteByDriveFileId(
    String driveFileId, {
    DateTime? removedAtValue,
  }) async {
    final beforeTrack = await getTrackByDriveFileId(driveFileId);
    await (update(
      tracks,
    )..where((table) => table.driveFileId.equals(driveFileId))).write(
      TracksCompanion(
        indexStatus: Value(TrackIndexStatus.pendingDelete.value),
        removedAt: Value(removedAtValue ?? DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final afterTrack = await getTrackByDriveFileId(driveFileId);
    await _refreshLibraryProjectionsForDiffs([
      _LibraryTrackProjectionDiff(before: beforeTrack, after: afterTrack),
    ]);
  }

  Future<void> markTrackRemovedById(int trackId) async {
    final beforeTrack = await getTrackById(trackId);
    await (update(tracks)..where((table) => table.id.equals(trackId))).write(
      TracksCompanion(
        indexStatus: Value(TrackIndexStatus.removed.value),
        updatedAt: Value(DateTime.now()),
        removedAt: Value(DateTime.now()),
      ),
    );
    final afterTrack = await getTrackById(trackId);
    await _refreshLibraryProjectionsForDiffs([
      _LibraryTrackProjectionDiff(before: beforeTrack, after: afterTrack),
    ]);
  }

  Future<void> updateTrackCache(
    int trackId, {
    required String? cachePathValue,
    required String cacheStatusValue,
  }) {
    return (update(tracks)..where((table) => table.id.equals(trackId))).write(
      TracksCompanion(
        cachePath: Value(cachePathValue),
        cacheStatus: Value(cacheStatusValue),
      ),
    );
  }

  Future<void> clearTrackCachesByIds(Iterable<int> trackIds) {
    final ids = trackIds.toSet().toList(growable: false);
    if (ids.isEmpty) {
      return Future.value();
    }
    return (update(tracks)..where((table) => table.id.isIn(ids))).write(
      const TracksCompanion(cachePath: Value(null), cacheStatus: Value('none')),
    );
  }

  Future<void> recordPlay({
    required int trackId,
    required bool incrementPlayCount,
  }) async {
    final track = await getTrackById(trackId);
    if (track == null) {
      return;
    }

    await (update(tracks)..where((table) => table.id.equals(trackId))).write(
      TracksCompanion(
        playCount: Value(track.playCount + (incrementPlayCount ? 1 : 0)),
        lastPlayedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setFavorite(int trackId, bool isFavoriteValue) {
    return (update(tracks)..where((table) => table.id.equals(trackId))).write(
      TracksCompanion(isFavorite: Value(isFavoriteValue)),
    );
  }

  Future<void> savePlaybackState({
    required List<int> queueTrackIds,
    required int? currentTrackIdValue,
    required int currentIndexValue,
    required int positionMsValue,
    required bool isPlayingValue,
  }) async {
    await ensurePlaybackStateRow();
    await into(playbackStates).insertOnConflictUpdate(
      PlaybackStatesCompanion(
        id: const Value(1),
        queueTrackIdsJson: Value(jsonEncode(queueTrackIds)),
        currentTrackId: Value(currentTrackIdValue),
        currentIndex: Value(currentIndexValue),
        positionMs: Value(positionMsValue),
        isPlaying: Value(isPlayingValue),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> countTracks() {
    return customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM tracks
      WHERE index_status != ?
      ''',
      variables: [Variable.withString(TrackIndexStatus.removed.value)],
      readsFrom: {tracks},
    ).getSingle().then((row) => row.read<int>('count'));
  }

  Stream<int> watchTrackCount() {
    return customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM tracks
      WHERE index_status != ?
      ''',
      variables: [Variable.withString(TrackIndexStatus.removed.value)],
      readsFrom: {tracks},
    ).watchSingle().map((row) => row.read<int>('count'));
  }

  Stream<int> watchFavoriteCount() {
    return customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM tracks
      WHERE is_favorite = 1 AND index_status != ?
      ''',
      variables: [Variable.withString(TrackIndexStatus.removed.value)],
      readsFrom: {tracks},
    ).watchSingle().map((row) => row.read<int>('count'));
  }

  Stream<int> watchCacheSizeBytes() {
    return customSelect(
      '''
      SELECT COALESCE(SUM(size_bytes), 0) AS size
      FROM tracks
      WHERE cache_status != ? AND index_status != ?
      ''',
      variables: [
        Variable.withString('none'),
        Variable.withString(TrackIndexStatus.removed.value),
      ],
      readsFrom: {tracks},
    ).watchSingle().map((row) => row.read<int>('size'));
  }

  Future<int> upsertDriveObject(DriveObjectsCompanion row) {
    return into(driveObjects).insertOnConflictUpdate(row);
  }

  Future<void> insertAllDriveObjectsOnConflictUpdate(
    List<DriveObjectsCompanion> rows,
  ) async {
    if (rows.isEmpty) {
      return;
    }
    await batch((batch) {
      batch.insertAllOnConflictUpdate(driveObjects, rows);
    });
  }

  Future<DriveObject?> getDriveObjectById(String driveId) {
    return (select(
      driveObjects,
    )..where((table) => table.driveId.equals(driveId))).getSingleOrNull();
  }

  Future<List<DriveObject>> getDriveObjectsByIds(Iterable<String> driveIds) {
    final ids = driveIds.toSet().toList(growable: false);
    if (ids.isEmpty) {
      return Future.value(const <DriveObject>[]);
    }
    return (select(
      driveObjects,
    )..where((table) => table.driveId.isIn(ids))).get();
  }

  Future<List<DriveObject>> getChildDriveObjects(String parentDriveId) {
    return (select(
      driveObjects,
    )..where((table) => table.parentDriveId.equals(parentDriveId))).get();
  }

  Future<List<DriveObject>> getAllDescendants(String driveId) async {
    final descendants = <DriveObject>[];
    final queue = <String>[driveId];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      final children = await getChildDriveObjects(current);
      descendants.addAll(children);
      queue.addAll(children.map((child) => child.driveId));
    }
    return descendants;
  }

  Future<int> createScanJob(ScanJobsCompanion row) {
    return into(scanJobs).insert(row);
  }

  Future<ScanJob?> getScanJobById(int jobId) {
    return (select(
      scanJobs,
    )..where((table) => table.id.equals(jobId))).getSingleOrNull();
  }

  Future<ScanJob?> getLatestActiveScanJob({int? accountId}) {
    final query = select(scanJobs)
      ..where((table) {
        final stateFilter = table.state.isIn([
          DriveScanJobState.queued.value,
          DriveScanJobState.running.value,
          DriveScanJobState.paused.value,
          DriveScanJobState.cancelRequested.value,
        ]);
        if (accountId == null) {
          return stateFilter;
        }
        return stateFilter & table.accountId.equals(accountId);
      })
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Stream<ScanJob?> watchLatestActiveScanJob({int? accountId}) {
    final query = select(scanJobs)
      ..where((table) {
        final stateFilter = table.state.isIn([
          DriveScanJobState.queued.value,
          DriveScanJobState.running.value,
          DriveScanJobState.paused.value,
          DriveScanJobState.cancelRequested.value,
        ]);
        if (accountId == null) {
          return stateFilter;
        }
        return stateFilter & table.accountId.equals(accountId);
      })
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  Future<ScanJob?> getNextRunnableScanJob() {
    final query = select(scanJobs)
      ..where(
        (table) => table.state.isIn([
          DriveScanJobState.queued.value,
          DriveScanJobState.running.value,
          DriveScanJobState.cancelRequested.value,
        ]),
      )
      ..orderBy([(table) => OrderingTerm(expression: table.createdAt)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<void> updateScanJob(int jobId, ScanJobsCompanion row) {
    return (update(
      scanJobs,
    )..where((table) => table.id.equals(jobId))).write(row);
  }

  Future<void> cancelQueuedScanTasks(int jobId) {
    return (update(scanTasks)..where(
          (table) =>
              table.jobId.equals(jobId) &
              table.state.equals(DriveScanTaskState.queued.value),
        ))
        .write(
          ScanTasksCompanion(
            state: Value(DriveScanTaskState.canceled.value),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> requeueRunningScanTasks(int jobId) {
    return (update(scanTasks)..where(
          (table) =>
              table.jobId.equals(jobId) &
              table.state.equals(DriveScanTaskState.running.value),
        ))
        .write(
          ScanTasksCompanion(
            state: Value(DriveScanTaskState.queued.value),
            lockedAt: const Value(null),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> enqueueScanTasks(List<ScanTasksCompanion> rows) async {
    if (rows.isEmpty) {
      return;
    }
    await batch((batch) {
      batch.insertAll(
        scanTasks,
        rows,
        onConflict: DoNothing<ScanTasks, ScanTask>(
          target: [scanTasks.jobId, scanTasks.dedupeKey],
        ),
      );
    });
  }

  Future<List<ScanTask>> takeQueuedScanTasks(
    int jobId, {
    required String kind,
    required int limit,
  }) async {
    return transaction(() async {
      final rows =
          await (select(scanTasks)
                ..where(
                  (table) =>
                      table.jobId.equals(jobId) &
                      table.kind.equals(kind) &
                      table.state.equals(DriveScanTaskState.queued.value),
                )
                ..orderBy([
                  (table) => OrderingTerm(
                    expression: table.priority,
                    mode: OrderingMode.desc,
                  ),
                  (table) => OrderingTerm(expression: table.createdAt),
                ])
                ..limit(limit))
              .get();

      if (rows.isEmpty) {
        return rows;
      }

      final now = DateTime.now();
      await batch((batch) {
        for (final row in rows) {
          batch.update(
            scanTasks,
            ScanTasksCompanion(
              state: Value(DriveScanTaskState.running.value),
              lockedAt: Value(now),
              updatedAt: Value(now),
            ),
            where: (table) => table.id.equals(row.id),
          );
        }
      });

      return rows
          .map(
            (row) => row.copyWith(
              state: DriveScanTaskState.running.value,
              lockedAt: Value(now),
              updatedAt: now,
            ),
          )
          .toList(growable: false);
    });
  }

  Future<void> completeScanTasks(Iterable<int> taskIds) async {
    final ids = taskIds.toSet().toList(growable: false);
    if (ids.isEmpty) {
      return;
    }
    await (update(scanTasks)..where((table) => table.id.isIn(ids))).write(
      ScanTasksCompanion(
        state: Value(DriveScanTaskState.completed.value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> failScanTasks(
    Iterable<int> taskIds, {
    required String error,
  }) async {
    final ids = taskIds.toSet().toList(growable: false);
    if (ids.isEmpty) {
      return;
    }
    await (update(scanTasks)..where((table) => table.id.isIn(ids))).write(
      ScanTasksCompanion(
        state: Value(DriveScanTaskState.failed.value),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> countQueuedScanTasks(
    int jobId, {
    String? kind,
    bool includeRunning = false,
  }) async {
    final states = [
      DriveScanTaskState.queued.value,
      if (includeRunning) DriveScanTaskState.running.value,
    ];
    final query = customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM scan_tasks
      WHERE job_id = ?
        AND state IN (${states.map((_) => '?').join(', ')})
        ${kind == null ? '' : 'AND kind = ?'}
      ''',
      variables: [
        Variable.withInt(jobId),
        for (final state in states) Variable.withString(state),
        if (kind != null) Variable.withString(kind),
      ],
      readsFrom: {scanTasks},
    );
    final row = await query.getSingle();
    return row.read<int>('count');
  }

  Future<List<ScanTask>> getFailedScanTasks(int jobId) {
    return (select(scanTasks)..where(
          (table) =>
              table.jobId.equals(jobId) &
              table.state.equals(DriveScanTaskState.failed.value),
        ))
        .get();
  }

  Future<int> upsertArtworkBlob(ArtworkBlobsCompanion row) {
    return into(artworkBlobs).insertOnConflictUpdate(row);
  }

  Future<ArtworkBlob?> getArtworkBlobByHash(String contentHash) {
    return (select(artworkBlobs)
          ..where((table) => table.contentHash.equals(contentHash)))
        .getSingleOrNull();
  }

  Future<List<ArtworkBlob>> getArtworkBlobsByHashes(Iterable<String> hashes) {
    final uniqueHashes = hashes.toSet().toList(growable: false);
    if (uniqueHashes.isEmpty) {
      return Future.value(const <ArtworkBlob>[]);
    }
    return (select(
      artworkBlobs,
    )..where((table) => table.contentHash.isIn(uniqueHashes))).get();
  }

  Future<RootScanCounts> getRootScanCounts(int rootId) async {
    final row = await customSelect(
      '''
      SELECT
        SUM(CASE WHEN index_status != ? THEN 1 ELSE 0 END) AS indexed_count,
        SUM(CASE WHEN metadata_status = ? AND index_status != ? THEN 1 ELSE 0 END) AS metadata_ready_count,
        SUM(CASE WHEN artwork_status = ? AND index_status != ? THEN 1 ELSE 0 END) AS artwork_ready_count,
        SUM(CASE WHEN metadata_status = ? OR artwork_status = ? THEN 1 ELSE 0 END) AS failed_count
      FROM tracks
      WHERE root_id = ?
      ''',
      variables: [
        Variable.withString(TrackIndexStatus.removed.value),
        Variable.withString(TrackMetadataStatus.ready.value),
        Variable.withString(TrackIndexStatus.removed.value),
        Variable.withString(TrackArtworkStatus.ready.value),
        Variable.withString(TrackIndexStatus.removed.value),
        Variable.withString(TrackMetadataStatus.failed.value),
        Variable.withString(TrackArtworkStatus.failed.value),
        Variable.withInt(rootId),
      ],
      readsFrom: {tracks},
    ).getSingle();

    return RootScanCounts(
      indexedCount: row.read<int?>('indexed_count') ?? 0,
      metadataReadyCount: row.read<int?>('metadata_ready_count') ?? 0,
      artworkReadyCount: row.read<int?>('artwork_ready_count') ?? 0,
      failedCount: row.read<int?>('failed_count') ?? 0,
    );
  }

  Future<void> refreshRootProgress(int rootId) async {
    final counts = await getRootScanCounts(rootId);
    await updateRootCounters(
      rootId,
      indexedCountValue: counts.indexedCount,
      metadataReadyCountValue: counts.metadataReadyCount,
      artworkReadyCountValue: counts.artworkReadyCount,
      failedCountValue: counts.failedCount,
    );
  }

  Future<void> rebuildLibraryProjections() async {
    await ensureLibraryProjectionMetaRow();
    await _setLibraryProjectionBackfillState(
      state: LibraryProjectionBackfillState.running,
      clearError: true,
    );

    try {
      await transaction(() async {
        await delete(libraryAlbumProjections).go();
        await delete(libraryArtistProjections).go();
        await delete(libraryAlbumArtistProjections).go();
        await delete(libraryGenreProjections).go();

        await customStatement('''
          INSERT INTO library_albums (
            stable_id,
            album,
            album_artist,
            title_sort,
            artist_sort,
            year,
            artwork_uri,
            updated_at
          )
          SELECT
            album_artist || x'1F' || album AS stable_id,
            album,
            album_artist,
            LOWER(TRIM(album)) AS title_sort,
            LOWER(TRIM(album_artist)) AS artist_sort,
            COALESCE(MAX(year), 0) AS year,
            COALESCE(MAX(artwork_uri), '') AS artwork_uri,
            $currentUnixTimestampSql AS updated_at
          FROM tracks
          WHERE metadata_status = '${TrackMetadataStatus.ready.value}'
            AND index_status != '${TrackIndexStatus.removed.value}'
            AND album != ''
            AND album_artist != ''
          GROUP BY album, album_artist
        ''');

        await customStatement('''
          INSERT INTO library_artists (
            stable_id,
            name,
            name_sort,
            song_count,
            artwork_uri,
            updated_at
          )
          SELECT
            artist AS stable_id,
            artist AS name,
            LOWER(TRIM(artist)) AS name_sort,
            COUNT(*) AS song_count,
            COALESCE(MAX(artwork_uri), '') AS artwork_uri,
            $currentUnixTimestampSql AS updated_at
          FROM tracks
          WHERE metadata_status = '${TrackMetadataStatus.ready.value}'
            AND index_status != '${TrackIndexStatus.removed.value}'
            AND artist != ''
          GROUP BY artist
        ''');

        await customStatement('''
          INSERT INTO library_album_artists (
            stable_id,
            name,
            name_sort,
            album_count,
            artwork_uri,
            updated_at
          )
          SELECT
            album_artist AS stable_id,
            album_artist AS name,
            LOWER(TRIM(album_artist)) AS name_sort,
            COUNT(DISTINCT album) AS album_count,
            COALESCE(MAX(artwork_uri), '') AS artwork_uri,
            $currentUnixTimestampSql AS updated_at
          FROM tracks
          WHERE metadata_status = '${TrackMetadataStatus.ready.value}'
            AND index_status != '${TrackIndexStatus.removed.value}'
            AND album_artist != ''
            AND album != ''
          GROUP BY album_artist
        ''');

        await customStatement('''
          INSERT INTO library_genres (
            stable_id,
            name,
            name_sort,
            song_count,
            artwork_uri,
            updated_at
          )
          SELECT
            genre AS stable_id,
            genre AS name,
            LOWER(TRIM(genre)) AS name_sort,
            COUNT(*) AS song_count,
            COALESCE(MAX(artwork_uri), '') AS artwork_uri,
            $currentUnixTimestampSql AS updated_at
          FROM tracks
          WHERE metadata_status = '${TrackMetadataStatus.ready.value}'
            AND index_status != '${TrackIndexStatus.removed.value}'
            AND genre != ''
          GROUP BY genre
        ''');

        await customStatement('''
          UPDATE library_projection_meta
          SET
            revision = revision + 1,
            backfill_state = '${LibraryProjectionBackfillState.ready.name}',
            last_backfill_at = $currentUnixTimestampSql,
            last_error = NULL
          WHERE id = 1
        ''');
      });
    } catch (error) {
      await _setLibraryProjectionBackfillState(
        state: LibraryProjectionBackfillState.failed,
        lastError: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> _refreshLibraryProjectionsForDiffs(
    Iterable<_LibraryTrackProjectionDiff> diffs,
  ) async {
    final diffList = diffs.toList(growable: false);
    if (diffList.isEmpty) {
      return;
    }

    await ensureLibraryProjectionMetaRow();

    final albumKeys = <_LibraryAlbumProjectionKey>{};
    final artistKeys = <String>{};
    final albumArtistKeys = <String>{};
    final genreKeys = <String>{};

    for (final diff in diffList) {
      for (final track in [diff.before, diff.after].whereType<Track>()) {
        final albumKey = _albumProjectionKeyForTrack(track);
        if (albumKey != null) {
          albumKeys.add(albumKey);
        }
        final artistKey = _artistProjectionKeyForTrack(track);
        if (artistKey != null) {
          artistKeys.add(artistKey);
        }
        final albumArtistKey = _albumArtistProjectionKeyForTrack(track);
        if (albumArtistKey != null) {
          albumArtistKeys.add(albumArtistKey);
        }
        final genreKey = _genreProjectionKeyForTrack(track);
        if (genreKey != null) {
          genreKeys.add(genreKey);
        }
      }
    }

    await transaction(() async {
      for (final key in albumKeys) {
        await _refreshAlbumProjection(key);
      }
      for (final key in artistKeys) {
        await _refreshArtistProjection(key);
      }
      for (final key in albumArtistKeys) {
        await _refreshAlbumArtistProjection(key);
      }
      for (final key in genreKeys) {
        await _refreshGenreProjection(key);
      }
      await customStatement(
        'UPDATE library_projection_meta SET revision = revision + 1 WHERE id = 1',
      );
    });
  }

  Future<void> _refreshAlbumProjection(_LibraryAlbumProjectionKey key) async {
    final row = await customSelect(
      '''
      SELECT
        COALESCE(MAX(year), 0) AS year,
        COALESCE(MAX(artwork_uri), '') AS artwork_uri
      FROM tracks
      WHERE metadata_status = ?
        AND index_status != ?
        AND album = ?
        AND album_artist = ?
      ''',
      variables: [
        Variable.withString(TrackMetadataStatus.ready.value),
        Variable.withString(TrackIndexStatus.removed.value),
        Variable.withString(key.album),
        Variable.withString(key.albumArtist),
      ],
      readsFrom: {tracks},
    ).getSingle();

    final hasRows = (await customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM tracks
      WHERE metadata_status = ?
        AND index_status != ?
        AND album = ?
        AND album_artist = ?
      ''',
      variables: [
        Variable.withString(TrackMetadataStatus.ready.value),
        Variable.withString(TrackIndexStatus.removed.value),
        Variable.withString(key.album),
        Variable.withString(key.albumArtist),
      ],
      readsFrom: {tracks},
    ).getSingle()).read<int>('count');

    if (hasRows == 0) {
      await (delete(
        libraryAlbumProjections,
      )..where((table) => table.stableId.equals(key.stableId))).go();
      return;
    }

    await into(libraryAlbumProjections).insertOnConflictUpdate(
      LibraryAlbumProjectionsCompanion(
        stableId: Value(key.stableId),
        album: Value(key.album),
        albumArtist: Value(key.albumArtist),
        titleSort: Value(_normalizeSortValue(key.album)),
        artistSort: Value(_normalizeSortValue(key.albumArtist)),
        year: Value(row.read<int?>('year') ?? 0),
        artworkUri: Value(row.read<String?>('artwork_uri') ?? ''),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _refreshArtistProjection(String artist) async {
    final row = await customSelect(
      '''
      SELECT
        COUNT(*) AS song_count,
        COALESCE(MAX(artwork_uri), '') AS artwork_uri
      FROM tracks
      WHERE metadata_status = ?
        AND index_status != ?
        AND artist = ?
      ''',
      variables: [
        Variable.withString(TrackMetadataStatus.ready.value),
        Variable.withString(TrackIndexStatus.removed.value),
        Variable.withString(artist),
      ],
      readsFrom: {tracks},
    ).getSingle();

    final count = row.read<int>('song_count');
    if (count == 0) {
      await (delete(
        libraryArtistProjections,
      )..where((table) => table.stableId.equals(artist))).go();
      return;
    }

    await into(libraryArtistProjections).insertOnConflictUpdate(
      LibraryArtistProjectionsCompanion(
        stableId: Value(artist),
        name: Value(artist),
        nameSort: Value(_normalizeSortValue(artist)),
        songCount: Value(count),
        artworkUri: Value(row.read<String?>('artwork_uri') ?? ''),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _refreshAlbumArtistProjection(String albumArtist) async {
    final row = await customSelect(
      '''
      SELECT
        COUNT(DISTINCT album) AS album_count,
        COALESCE(MAX(artwork_uri), '') AS artwork_uri
      FROM tracks
      WHERE metadata_status = ?
        AND index_status != ?
        AND album_artist = ?
        AND album != ''
      ''',
      variables: [
        Variable.withString(TrackMetadataStatus.ready.value),
        Variable.withString(TrackIndexStatus.removed.value),
        Variable.withString(albumArtist),
      ],
      readsFrom: {tracks},
    ).getSingle();

    final count = row.read<int>('album_count');
    if (count == 0) {
      await (delete(
        libraryAlbumArtistProjections,
      )..where((table) => table.stableId.equals(albumArtist))).go();
      return;
    }

    await into(libraryAlbumArtistProjections).insertOnConflictUpdate(
      LibraryAlbumArtistProjectionsCompanion(
        stableId: Value(albumArtist),
        name: Value(albumArtist),
        nameSort: Value(_normalizeSortValue(albumArtist)),
        albumCount: Value(count),
        artworkUri: Value(row.read<String?>('artwork_uri') ?? ''),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _refreshGenreProjection(String genre) async {
    final row = await customSelect(
      '''
      SELECT
        COUNT(*) AS song_count,
        COALESCE(MAX(artwork_uri), '') AS artwork_uri
      FROM tracks
      WHERE metadata_status = ?
        AND index_status != ?
        AND genre = ?
      ''',
      variables: [
        Variable.withString(TrackMetadataStatus.ready.value),
        Variable.withString(TrackIndexStatus.removed.value),
        Variable.withString(genre),
      ],
      readsFrom: {tracks},
    ).getSingle();

    final count = row.read<int>('song_count');
    if (count == 0) {
      await (delete(
        libraryGenreProjections,
      )..where((table) => table.stableId.equals(genre))).go();
      return;
    }

    await into(libraryGenreProjections).insertOnConflictUpdate(
      LibraryGenreProjectionsCompanion(
        stableId: Value(genre),
        name: Value(genre),
        nameSort: Value(_normalizeSortValue(genre)),
        songCount: Value(count),
        artworkUri: Value(row.read<String?>('artwork_uri') ?? ''),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _setLibraryProjectionBackfillState({
    required LibraryProjectionBackfillState state,
    String? lastError,
    bool clearError = false,
  }) async {
    await (update(
      libraryProjectionMetas,
    )..where((table) => table.id.equals(1))).write(
      LibraryProjectionMetasCompanion(
        backfillState: Value(state.name),
        lastBackfillAt: state == LibraryProjectionBackfillState.ready
            ? Value(DateTime.now())
            : const Value.absent(),
        lastError: clearError ? const Value(null) : Value(lastError),
      ),
    );
  }

  List<_LibraryTrackProjectionDiff> _buildTrackDiffsByDriveFileId({
    required List<Track> beforeTracks,
    required List<Track> afterTracks,
  }) {
    final beforeByDriveId = {
      for (final track in beforeTracks) track.driveFileId: track,
    };
    final afterByDriveId = {
      for (final track in afterTracks) track.driveFileId: track,
    };
    final driveIds = {...beforeByDriveId.keys, ...afterByDriveId.keys};
    return driveIds
        .map(
          (driveId) => _LibraryTrackProjectionDiff(
            before: beforeByDriveId[driveId],
            after: afterByDriveId[driveId],
          ),
        )
        .toList(growable: false);
  }

  List<_LibraryTrackProjectionDiff> _buildTrackDiffsByTrackId({
    required List<Track> beforeTracks,
    required List<Track> afterTracks,
  }) {
    final beforeById = {for (final track in beforeTracks) track.id: track};
    final afterById = {for (final track in afterTracks) track.id: track};
    final ids = {...beforeById.keys, ...afterById.keys};
    return ids
        .map(
          (id) => _LibraryTrackProjectionDiff(
            before: beforeById[id],
            after: afterById[id],
          ),
        )
        .toList(growable: false);
  }

  _LibraryAlbumProjectionKey? _albumProjectionKeyForTrack(Track track) {
    if (!_isTrackVisibleInAggregateLibrary(track) ||
        track.album.isEmpty ||
        track.albumArtist.isEmpty) {
      return null;
    }
    return _LibraryAlbumProjectionKey(track.albumArtist, track.album);
  }

  String? _artistProjectionKeyForTrack(Track track) {
    if (!_isTrackVisibleInAggregateLibrary(track) || track.artist.isEmpty) {
      return null;
    }
    return track.artist;
  }

  String? _albumArtistProjectionKeyForTrack(Track track) {
    if (!_isTrackVisibleInAggregateLibrary(track) ||
        track.albumArtist.isEmpty ||
        track.album.isEmpty) {
      return null;
    }
    return track.albumArtist;
  }

  String? _genreProjectionKeyForTrack(Track track) {
    if (!_isTrackVisibleInAggregateLibrary(track) || track.genre.isEmpty) {
      return null;
    }
    return track.genre;
  }

  bool _isTrackVisibleInAggregateLibrary(Track track) {
    return track.metadataStatus == TrackMetadataStatus.ready.value &&
        track.indexStatus != TrackIndexStatus.removed.value;
  }

  String _normalizeSortValue(String value) {
    return value.trim().toLowerCase();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'aero_stream.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

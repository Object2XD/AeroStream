import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';
import '../../data/mock_library.dart';
import '../../models/library_models.dart';
import '../../models/track_item.dart';
import 'drive_scan_models.dart';

abstract class LibraryCatalogRepository {
  Stream<int> watchLibraryRevision();

  Stream<LibraryCounts> watchLibraryCounts();

  Stream<LibraryProjectionStatusSnapshot> watchProjectionStatus();

  Future<void> ensureProjectionBackfillStarted();

  Future<LibraryPage<TrackItem>> fetchSongsPage({
    required LibrarySongSort sort,
    LibraryCursor? cursor,
    required int limit,
  });

  Future<LibraryPage<LibraryAlbum>> fetchAlbumsPage({
    required LibraryAlbumSort sort,
    LibraryCursor? cursor,
    required int limit,
  });

  Future<LibraryPage<LibraryArtist>> fetchArtistsPage({
    required LibraryArtistSort sort,
    LibraryCursor? cursor,
    required int limit,
  });

  Future<LibraryPage<LibraryAlbumArtist>> fetchAlbumArtistsPage({
    required LibraryAlbumArtistSort sort,
    LibraryCursor? cursor,
    required int limit,
  });

  Future<LibraryPage<LibraryGenre>> fetchGenresPage({
    required LibraryGenreSort sort,
    LibraryCursor? cursor,
    required int limit,
  });

  Future<List<TrackItem>> fetchAllSongs({required LibrarySongSort sort});
}

class DatabaseLibraryCatalogRepository implements LibraryCatalogRepository {
  DatabaseLibraryCatalogRepository(this._database);

  final AppDatabase _database;

  Future<void>? _backfillFuture;

  @override
  Stream<int> watchLibraryRevision() {
    return watchProjectionStatus().map((snapshot) => snapshot.revision);
  }

  @override
  Stream<LibraryCounts> watchLibraryCounts() {
    return _database
        .customSelect(
          '''
          SELECT
            (SELECT COUNT(*) FROM tracks WHERE index_status != ?) AS track_count,
            (SELECT COUNT(*) FROM library_albums) AS album_count,
            (SELECT COUNT(*) FROM library_artists) AS artist_count,
            (SELECT COUNT(*) FROM library_album_artists) AS album_artist_count,
            (SELECT COUNT(*) FROM library_genres) AS genre_count
          ''',
          variables: [
            Variable.withString(TrackIndexStatus.removed.value),
          ],
          readsFrom: {
            _database.tracks,
            _database.libraryAlbumProjections,
            _database.libraryArtistProjections,
            _database.libraryAlbumArtistProjections,
            _database.libraryGenreProjections,
          },
        )
        .watchSingle()
        .map(
          (row) => LibraryCounts(
            trackCount: row.read<int>('track_count'),
            albumCount: row.read<int>('album_count'),
            artistCount: row.read<int>('artist_count'),
            albumArtistCount: row.read<int>('album_artist_count'),
            genreCount: row.read<int>('genre_count'),
          ),
        );
  }

  @override
  Stream<LibraryProjectionStatusSnapshot> watchProjectionStatus() {
    return (_database.select(_database.libraryProjectionMetas)
          ..where((table) => table.id.equals(1)))
        .watchSingleOrNull()
        .map((row) {
          if (row == null) {
            return const LibraryProjectionStatusSnapshot(
              state: LibraryProjectionBackfillState.pending,
              revision: 0,
            );
          }
          return LibraryProjectionStatusSnapshot(
            state: LibraryProjectionBackfillState.values.byName(
              row.backfillState,
            ),
            revision: row.revision,
            errorMessage: row.lastError,
          );
        });
  }

  @override
  Future<void> ensureProjectionBackfillStarted() async {
    await _database.ensureLibraryProjectionMetaRow();
    final meta = await _database.getLibraryProjectionMeta();
    final state =
        meta == null
            ? LibraryProjectionBackfillState.pending
            : LibraryProjectionBackfillState.values.byName(meta.backfillState);

    if (state == LibraryProjectionBackfillState.ready ||
        state == LibraryProjectionBackfillState.running) {
      return;
    }

    _backfillFuture ??= _database
        .rebuildLibraryProjections()
        .whenComplete(() => _backfillFuture = null);
    await _backfillFuture;
  }

  @override
  Future<LibraryPage<TrackItem>> fetchSongsPage({
    required LibrarySongSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final revision = await _database.getLibraryProjectionRevision();
    final totalCount = await _countActiveTracks();
    final orderSql = _songOrderSql(sort);
    final cursorClause = _songCursorClause(sort, cursor);
    final rows = await _database.customSelect(
      '''
      SELECT
        id,
        file_name,
        title,
        artist,
        album,
        duration_ms,
        COALESCE(artwork_uri, '') AS artwork_uri,
        title_sort,
        artist_sort
      FROM tracks
      WHERE index_status != ?
      ${cursorClause.sql}
      ORDER BY $orderSql
      LIMIT ?
      ''',
      variables: [
        Variable.withString(TrackIndexStatus.removed.value),
        ...cursorClause.variables,
        Variable.withInt(limit + 1),
      ],
      readsFrom: {_database.tracks},
    ).get();

    return _buildPage(
      rows: rows,
      limit: limit,
      revision: revision,
      totalCount: totalCount,
      mapRow:
          (row) => TrackItem(
            id: row.read<int>('id'),
            title: row.read<String>('title'),
            artist: row.read<String>('artist').isEmpty
                ? 'Google Drive'
                : row.read<String>('artist'),
            album: row.read<String>('album').isEmpty
                ? row.read<String>('file_name')
                : row.read<String>('album'),
            durationSeconds: (row.read<int>('duration_ms') / 1000).round(),
            imageUrl: row.read<String>('artwork_uri'),
          ),
      nextCursorBuilder: (row) => _songNextCursor(sort, row),
    );
  }

  @override
  Future<LibraryPage<LibraryAlbum>> fetchAlbumsPage({
    required LibraryAlbumSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final revision = await _database.getLibraryProjectionRevision();
    final totalCount = await _countProjectionRows(
      tableName: 'library_albums',
      readsFrom: {_database.libraryAlbumProjections},
    );
    final orderSql = _albumOrderSql(sort);
    final cursorClause = _albumCursorClause(sort, cursor);
    final rows = await _database.customSelect(
      '''
      SELECT
        stable_id,
        album,
        album_artist,
        title_sort,
        artist_sort,
        year,
        COALESCE(artwork_uri, '') AS artwork_uri
      FROM library_albums
      WHERE 1 = 1
      ${cursorClause.sql}
      ORDER BY $orderSql
      LIMIT ?
      ''',
      variables: [
        ...cursorClause.variables,
        Variable.withInt(limit + 1),
      ],
      readsFrom: {_database.libraryAlbumProjections},
    ).get();

    return _buildPage(
      rows: rows,
      limit: limit,
      revision: revision,
      totalCount: totalCount,
      mapRow:
          (row) => LibraryAlbum(
            id: albumRouteKey(
              albumArtist: row.read<String>('album_artist'),
              album: row.read<String>('album'),
            ),
            title: row.read<String>('album'),
            artist: row.read<String>('album_artist'),
            year: row.read<int>('year'),
            imageUrl: row.read<String>('artwork_uri'),
          ),
      nextCursorBuilder: (row) => _albumNextCursor(sort, row),
    );
  }

  @override
  Future<LibraryPage<LibraryArtist>> fetchArtistsPage({
    required LibraryArtistSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final revision = await _database.getLibraryProjectionRevision();
    final totalCount = await _countProjectionRows(
      tableName: 'library_artists',
      readsFrom: {_database.libraryArtistProjections},
    );
    final orderSql = _artistOrderSql(sort);
    final cursorClause = _artistCursorClause(sort, cursor);
    final rows = await _database.customSelect(
      '''
      SELECT
        stable_id,
        name,
        name_sort,
        song_count,
        COALESCE(artwork_uri, '') AS artwork_uri
      FROM library_artists
      WHERE 1 = 1
      ${cursorClause.sql}
      ORDER BY $orderSql
      LIMIT ?
      ''',
      variables: [
        ...cursorClause.variables,
        Variable.withInt(limit + 1),
      ],
      readsFrom: {_database.libraryArtistProjections},
    ).get();

    return _buildPage(
      rows: rows,
      limit: limit,
      revision: revision,
      totalCount: totalCount,
      mapRow:
          (row) => LibraryArtist(
            id: row.read<String>('stable_id'),
            name: row.read<String>('name'),
            songCount: row.read<int>('song_count'),
            imageUrl: row.read<String>('artwork_uri'),
          ),
      nextCursorBuilder: (row) => _artistNextCursor(sort, row),
    );
  }

  @override
  Future<LibraryPage<LibraryAlbumArtist>> fetchAlbumArtistsPage({
    required LibraryAlbumArtistSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final revision = await _database.getLibraryProjectionRevision();
    final totalCount = await _countProjectionRows(
      tableName: 'library_album_artists',
      readsFrom: {_database.libraryAlbumArtistProjections},
    );
    final orderSql = _albumArtistOrderSql(sort);
    final cursorClause = _albumArtistCursorClause(sort, cursor);
    final rows = await _database.customSelect(
      '''
      SELECT
        stable_id,
        name,
        name_sort,
        album_count,
        COALESCE(artwork_uri, '') AS artwork_uri
      FROM library_album_artists
      WHERE 1 = 1
      ${cursorClause.sql}
      ORDER BY $orderSql
      LIMIT ?
      ''',
      variables: [
        ...cursorClause.variables,
        Variable.withInt(limit + 1),
      ],
      readsFrom: {_database.libraryAlbumArtistProjections},
    ).get();

    return _buildPage(
      rows: rows,
      limit: limit,
      revision: revision,
      totalCount: totalCount,
      mapRow:
          (row) => LibraryAlbumArtist(
            id: row.read<String>('stable_id'),
            name: row.read<String>('name'),
            albumCount: row.read<int>('album_count'),
            imageUrl: row.read<String>('artwork_uri'),
          ),
      nextCursorBuilder: (row) => _albumArtistNextCursor(sort, row),
    );
  }

  @override
  Future<LibraryPage<LibraryGenre>> fetchGenresPage({
    required LibraryGenreSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final revision = await _database.getLibraryProjectionRevision();
    final totalCount = await _countProjectionRows(
      tableName: 'library_genres',
      readsFrom: {_database.libraryGenreProjections},
    );
    final orderSql = _genreOrderSql(sort);
    final cursorClause = _genreCursorClause(sort, cursor);
    final rows = await _database.customSelect(
      '''
      SELECT
        stable_id,
        name,
        name_sort,
        song_count,
        COALESCE(artwork_uri, '') AS artwork_uri
      FROM library_genres
      WHERE 1 = 1
      ${cursorClause.sql}
      ORDER BY $orderSql
      LIMIT ?
      ''',
      variables: [
        ...cursorClause.variables,
        Variable.withInt(limit + 1),
      ],
      readsFrom: {_database.libraryGenreProjections},
    ).get();

    return _buildPage(
      rows: rows,
      limit: limit,
      revision: revision,
      totalCount: totalCount,
      mapRow:
          (row) => LibraryGenre(
            id: row.read<String>('stable_id'),
            name: row.read<String>('name'),
            songCount: row.read<int>('song_count'),
            imageUrl: row.read<String>('artwork_uri'),
          ),
      nextCursorBuilder: (row) => _genreNextCursor(sort, row),
    );
  }

  @override
  Future<List<TrackItem>> fetchAllSongs({required LibrarySongSort sort}) async {
    final items = <TrackItem>[];
    LibraryCursor? cursor;
    var hasMore = true;
    while (hasMore) {
      final page = await fetchSongsPage(sort: sort, cursor: cursor, limit: 250);
      items.addAll(page.items);
      cursor = page.nextCursor;
      hasMore = page.hasMore && cursor != null;
    }
    return items;
  }

  LibraryPage<T> _buildPage<T>({
    required List<QueryRow> rows,
    required int limit,
    required int revision,
    required int totalCount,
    required T Function(QueryRow row) mapRow,
    required LibraryCursor Function(QueryRow row) nextCursorBuilder,
  }) {
    final hasMore = rows.length > limit;
    final pageRows = hasMore ? rows.take(limit).toList(growable: false) : rows;
    return LibraryPage<T>(
      items: pageRows.map(mapRow).toList(growable: false),
      totalCount: totalCount,
      nextCursor:
          hasMore && pageRows.isNotEmpty
              ? nextCursorBuilder(pageRows.last)
              : null,
      hasMore: hasMore,
      revision: revision,
    );
  }

  Future<int> _countActiveTracks() => _database.countTracks();

  Future<int> _countProjectionRows({
    required String tableName,
    required Set<ResultSetImplementation> readsFrom,
  }) async {
    final row = await _database.customSelect(
      'SELECT COUNT(*) AS count FROM $tableName',
      readsFrom: readsFrom,
    ).getSingle();
    return row.read<int>('count');
  }

  String _songOrderSql(LibrarySongSort sort) {
    switch (sort) {
      case LibrarySongSort.artist:
        return 'artist_sort ASC, title_sort ASC, id ASC';
      case LibrarySongSort.duration:
        return 'duration_ms DESC, title_sort ASC, id ASC';
      case LibrarySongSort.title:
        return 'title_sort ASC, id ASC';
    }
  }

  String _albumOrderSql(LibraryAlbumSort sort) {
    switch (sort) {
      case LibraryAlbumSort.artist:
        return 'artist_sort ASC, title_sort ASC, stable_id ASC';
      case LibraryAlbumSort.year:
        return 'year DESC, title_sort ASC, stable_id ASC';
      case LibraryAlbumSort.title:
        return 'title_sort ASC, stable_id ASC';
    }
  }

  String _artistOrderSql(LibraryArtistSort sort) {
    switch (sort) {
      case LibraryArtistSort.songCount:
        return 'song_count DESC, name_sort ASC, stable_id ASC';
      case LibraryArtistSort.name:
        return 'name_sort ASC, stable_id ASC';
    }
  }

  String _albumArtistOrderSql(LibraryAlbumArtistSort sort) {
    switch (sort) {
      case LibraryAlbumArtistSort.albumCount:
        return 'album_count DESC, name_sort ASC, stable_id ASC';
      case LibraryAlbumArtistSort.name:
        return 'name_sort ASC, stable_id ASC';
    }
  }

  String _genreOrderSql(LibraryGenreSort sort) {
    switch (sort) {
      case LibraryGenreSort.songCount:
        return 'song_count DESC, name_sort ASC, stable_id ASC';
      case LibraryGenreSort.name:
        return 'name_sort ASC, stable_id ASC';
    }
  }

  _CursorSql _songCursorClause(LibrarySongSort sort, LibraryCursor? cursor) {
    if (cursor == null) {
      return const _CursorSql.empty();
    }

    final values = _decodeCursor(cursor);
    switch (sort) {
      case LibrarySongSort.artist:
        return _CursorSql(
          sql: '''
            AND (
              artist_sort > ?
              OR (artist_sort = ? AND title_sort > ?)
              OR (artist_sort = ? AND title_sort = ? AND id > ?)
            )
          ''',
          variables: [
            Variable.withString(values['artistSort'] as String),
            Variable.withString(values['artistSort'] as String),
            Variable.withString(values['titleSort'] as String),
            Variable.withString(values['artistSort'] as String),
            Variable.withString(values['titleSort'] as String),
            Variable.withInt(values['id'] as int),
          ],
        );
      case LibrarySongSort.duration:
        return _CursorSql(
          sql: '''
            AND (
              duration_ms < ?
              OR (duration_ms = ? AND title_sort > ?)
              OR (duration_ms = ? AND title_sort = ? AND id > ?)
            )
          ''',
          variables: [
            Variable.withInt(values['durationMs'] as int),
            Variable.withInt(values['durationMs'] as int),
            Variable.withString(values['titleSort'] as String),
            Variable.withInt(values['durationMs'] as int),
            Variable.withString(values['titleSort'] as String),
            Variable.withInt(values['id'] as int),
          ],
        );
      case LibrarySongSort.title:
        return _CursorSql(
          sql: 'AND (title_sort > ? OR (title_sort = ? AND id > ?))',
          variables: [
            Variable.withString(values['titleSort'] as String),
            Variable.withString(values['titleSort'] as String),
            Variable.withInt(values['id'] as int),
          ],
        );
    }
  }

  _CursorSql _albumCursorClause(LibraryAlbumSort sort, LibraryCursor? cursor) {
    if (cursor == null) {
      return const _CursorSql.empty();
    }

    final values = _decodeCursor(cursor);
    switch (sort) {
      case LibraryAlbumSort.artist:
        return _CursorSql(
          sql: '''
            AND (
              artist_sort > ?
              OR (artist_sort = ? AND title_sort > ?)
              OR (artist_sort = ? AND title_sort = ? AND stable_id > ?)
            )
          ''',
          variables: [
            Variable.withString(values['artistSort'] as String),
            Variable.withString(values['artistSort'] as String),
            Variable.withString(values['titleSort'] as String),
            Variable.withString(values['artistSort'] as String),
            Variable.withString(values['titleSort'] as String),
            Variable.withString(values['stableId'] as String),
          ],
        );
      case LibraryAlbumSort.year:
        return _CursorSql(
          sql: '''
            AND (
              year < ?
              OR (year = ? AND title_sort > ?)
              OR (year = ? AND title_sort = ? AND stable_id > ?)
            )
          ''',
          variables: [
            Variable.withInt(values['year'] as int),
            Variable.withInt(values['year'] as int),
            Variable.withString(values['titleSort'] as String),
            Variable.withInt(values['year'] as int),
            Variable.withString(values['titleSort'] as String),
            Variable.withString(values['stableId'] as String),
          ],
        );
      case LibraryAlbumSort.title:
        return _CursorSql(
          sql:
              'AND (title_sort > ? OR (title_sort = ? AND stable_id > ?))',
          variables: [
            Variable.withString(values['titleSort'] as String),
            Variable.withString(values['titleSort'] as String),
            Variable.withString(values['stableId'] as String),
          ],
        );
    }
  }

  _CursorSql _artistCursorClause(LibraryArtistSort sort, LibraryCursor? cursor) {
    if (cursor == null) {
      return const _CursorSql.empty();
    }

    final values = _decodeCursor(cursor);
    switch (sort) {
      case LibraryArtistSort.songCount:
        return _CursorSql(
          sql: '''
            AND (
              song_count < ?
              OR (song_count = ? AND name_sort > ?)
              OR (song_count = ? AND name_sort = ? AND stable_id > ?)
            )
          ''',
          variables: [
            Variable.withInt(values['metric'] as int),
            Variable.withInt(values['metric'] as int),
            Variable.withString(values['nameSort'] as String),
            Variable.withInt(values['metric'] as int),
            Variable.withString(values['nameSort'] as String),
            Variable.withString(values['stableId'] as String),
          ],
        );
      case LibraryArtistSort.name:
        return _CursorSql(
          sql: 'AND (name_sort > ? OR (name_sort = ? AND stable_id > ?))',
          variables: [
            Variable.withString(values['nameSort'] as String),
            Variable.withString(values['nameSort'] as String),
            Variable.withString(values['stableId'] as String),
          ],
        );
    }
  }

  _CursorSql _albumArtistCursorClause(
    LibraryAlbumArtistSort sort,
    LibraryCursor? cursor,
  ) {
    if (cursor == null) {
      return const _CursorSql.empty();
    }

    final values = _decodeCursor(cursor);
    switch (sort) {
      case LibraryAlbumArtistSort.albumCount:
        return _CursorSql(
          sql: '''
            AND (
              album_count < ?
              OR (album_count = ? AND name_sort > ?)
              OR (album_count = ? AND name_sort = ? AND stable_id > ?)
            )
          ''',
          variables: [
            Variable.withInt(values['metric'] as int),
            Variable.withInt(values['metric'] as int),
            Variable.withString(values['nameSort'] as String),
            Variable.withInt(values['metric'] as int),
            Variable.withString(values['nameSort'] as String),
            Variable.withString(values['stableId'] as String),
          ],
        );
      case LibraryAlbumArtistSort.name:
        return _CursorSql(
          sql: 'AND (name_sort > ? OR (name_sort = ? AND stable_id > ?))',
          variables: [
            Variable.withString(values['nameSort'] as String),
            Variable.withString(values['nameSort'] as String),
            Variable.withString(values['stableId'] as String),
          ],
        );
    }
  }

  _CursorSql _genreCursorClause(LibraryGenreSort sort, LibraryCursor? cursor) {
    if (cursor == null) {
      return const _CursorSql.empty();
    }

    final values = _decodeCursor(cursor);
    switch (sort) {
      case LibraryGenreSort.songCount:
        return _CursorSql(
          sql: '''
            AND (
              song_count < ?
              OR (song_count = ? AND name_sort > ?)
              OR (song_count = ? AND name_sort = ? AND stable_id > ?)
            )
          ''',
          variables: [
            Variable.withInt(values['metric'] as int),
            Variable.withInt(values['metric'] as int),
            Variable.withString(values['nameSort'] as String),
            Variable.withInt(values['metric'] as int),
            Variable.withString(values['nameSort'] as String),
            Variable.withString(values['stableId'] as String),
          ],
        );
      case LibraryGenreSort.name:
        return _CursorSql(
          sql: 'AND (name_sort > ? OR (name_sort = ? AND stable_id > ?))',
          variables: [
            Variable.withString(values['nameSort'] as String),
            Variable.withString(values['nameSort'] as String),
            Variable.withString(values['stableId'] as String),
          ],
        );
    }
  }

  LibraryCursor _songNextCursor(LibrarySongSort sort, QueryRow row) {
    switch (sort) {
      case LibrarySongSort.artist:
        return _encodeCursor(<String, Object?>{
          'artistSort': row.read<String>('artist_sort'),
          'titleSort': row.read<String>('title_sort'),
          'id': row.read<int>('id'),
        });
      case LibrarySongSort.duration:
        return _encodeCursor(<String, Object?>{
          'durationMs': row.read<int>('duration_ms'),
          'titleSort': row.read<String>('title_sort'),
          'id': row.read<int>('id'),
        });
      case LibrarySongSort.title:
        return _encodeCursor(<String, Object?>{
          'titleSort': row.read<String>('title_sort'),
          'id': row.read<int>('id'),
        });
    }
  }

  LibraryCursor _albumNextCursor(LibraryAlbumSort sort, QueryRow row) {
    switch (sort) {
      case LibraryAlbumSort.artist:
        return _encodeCursor(<String, Object?>{
          'artistSort': row.read<String>('artist_sort'),
          'titleSort': row.read<String>('title_sort'),
          'stableId': row.read<String>('stable_id'),
        });
      case LibraryAlbumSort.year:
        return _encodeCursor(<String, Object?>{
          'year': row.read<int>('year'),
          'titleSort': row.read<String>('title_sort'),
          'stableId': row.read<String>('stable_id'),
        });
      case LibraryAlbumSort.title:
        return _encodeCursor(<String, Object?>{
          'titleSort': row.read<String>('title_sort'),
          'stableId': row.read<String>('stable_id'),
        });
    }
  }

  LibraryCursor _artistNextCursor(LibraryArtistSort sort, QueryRow row) {
    return _encodeCursor(<String, Object?>{
      'metric':
          sort == LibraryArtistSort.songCount
              ? row.read<int>('song_count')
              : null,
      'nameSort': row.read<String>('name_sort'),
      'stableId': row.read<String>('stable_id'),
    });
  }

  LibraryCursor _albumArtistNextCursor(
    LibraryAlbumArtistSort sort,
    QueryRow row,
  ) {
    return _encodeCursor(<String, Object?>{
      'metric':
          sort == LibraryAlbumArtistSort.albumCount
              ? row.read<int>('album_count')
              : null,
      'nameSort': row.read<String>('name_sort'),
      'stableId': row.read<String>('stable_id'),
    });
  }

  LibraryCursor _genreNextCursor(LibraryGenreSort sort, QueryRow row) {
    return _encodeCursor(<String, Object?>{
      'metric':
          sort == LibraryGenreSort.songCount
              ? row.read<int>('song_count')
              : null,
      'nameSort': row.read<String>('name_sort'),
      'stableId': row.read<String>('stable_id'),
    });
  }

  LibraryCursor _encodeCursor(Map<String, Object?> values) {
    return LibraryCursor(jsonEncode(values));
  }

  Map<String, Object?> _decodeCursor(LibraryCursor cursor) {
    return jsonDecode(cursor.value) as Map<String, Object?>;
  }
}

class MockLibraryCatalogRepository implements LibraryCatalogRepository {
  const MockLibraryCatalogRepository();

  @override
  Stream<LibraryCounts> watchLibraryCounts() {
    return Stream.value(
      LibraryCounts(
        trackCount: librarySongs.length,
        albumCount: libraryAlbums.length,
        artistCount: libraryArtists.length,
        albumArtistCount: libraryAlbumArtists.length,
        genreCount: libraryGenres.length,
      ),
    );
  }

  @override
  Stream<LibraryProjectionStatusSnapshot> watchProjectionStatus() {
    return Stream.value(
      const LibraryProjectionStatusSnapshot(
        state: LibraryProjectionBackfillState.ready,
        revision: 1,
      ),
    );
  }

  @override
  Stream<int> watchLibraryRevision() => Stream.value(1);

  @override
  Future<void> ensureProjectionBackfillStarted() async {}

  @override
  Future<LibraryPage<LibraryAlbum>> fetchAlbumsPage({
    required LibraryAlbumSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final sorted = [...libraryAlbums];
    switch (sort) {
      case LibraryAlbumSort.artist:
        sorted.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case LibraryAlbumSort.year:
        sorted.sort((a, b) => b.year.compareTo(a.year));
        break;
      case LibraryAlbumSort.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return _sliceMockPage(sorted, cursor: cursor, limit: limit);
  }

  @override
  Future<LibraryPage<LibraryAlbumArtist>> fetchAlbumArtistsPage({
    required LibraryAlbumArtistSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final sorted = [...libraryAlbumArtists];
    switch (sort) {
      case LibraryAlbumArtistSort.albumCount:
        sorted.sort((a, b) => b.albumCount.compareTo(a.albumCount));
        break;
      case LibraryAlbumArtistSort.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return _sliceMockPage(sorted, cursor: cursor, limit: limit);
  }

  @override
  Future<LibraryPage<LibraryArtist>> fetchArtistsPage({
    required LibraryArtistSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final sorted = [...libraryArtists];
    switch (sort) {
      case LibraryArtistSort.songCount:
        sorted.sort((a, b) => b.songCount.compareTo(a.songCount));
        break;
      case LibraryArtistSort.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return _sliceMockPage(sorted, cursor: cursor, limit: limit);
  }

  @override
  Future<LibraryPage<LibraryGenre>> fetchGenresPage({
    required LibraryGenreSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final sorted = [...libraryGenres];
    switch (sort) {
      case LibraryGenreSort.songCount:
        sorted.sort((a, b) => b.songCount.compareTo(a.songCount));
        break;
      case LibraryGenreSort.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return _sliceMockPage(sorted, cursor: cursor, limit: limit);
  }

  @override
  Future<LibraryPage<TrackItem>> fetchSongsPage({
    required LibrarySongSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final sorted = [...librarySongs];
    switch (sort) {
      case LibrarySongSort.artist:
        sorted.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case LibrarySongSort.duration:
        sorted.sort((a, b) => b.durationSeconds.compareTo(a.durationSeconds));
        break;
      case LibrarySongSort.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return _sliceMockPage(sorted, cursor: cursor, limit: limit);
  }

  @override
  Future<List<TrackItem>> fetchAllSongs({required LibrarySongSort sort}) {
    return fetchSongsPage(sort: sort, limit: librarySongs.length).then(
      (page) => page.items,
    );
  }

  LibraryPage<T> _sliceMockPage<T>(
    List<T> items, {
    required LibraryCursor? cursor,
    required int limit,
  }) {
    final start = cursor == null ? 0 : int.parse(cursor.value);
    final end = start + limit > items.length ? items.length : start + limit;
    return LibraryPage<T>(
      items: items.sublist(start, end),
      totalCount: items.length,
      nextCursor: end < items.length ? LibraryCursor(end.toString()) : null,
      hasMore: end < items.length,
      revision: 1,
    );
  }
}

class _CursorSql {
  const _CursorSql({
    required this.sql,
    required this.variables,
  });

  const _CursorSql.empty() : sql = '', variables = const [];

  final String sql;
  final List<Variable<Object>> variables;
}

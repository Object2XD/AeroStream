import 'dart:async';
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

  Future<LibrarySlice<TrackItem>> fetchSongsSlice({
    required LibrarySongSort sort,
    required int offset,
    required int limit,
  });

  Future<LibrarySlice<LibraryAlbum>> fetchAlbumsSlice({
    required LibraryAlbumSort sort,
    required int offset,
    required int limit,
  });

  Future<LibrarySlice<LibraryArtist>> fetchArtistsSlice({
    required LibraryArtistSort sort,
    required int offset,
    required int limit,
  });

  Future<LibrarySlice<LibraryAlbumArtist>> fetchAlbumArtistsSlice({
    required LibraryAlbumArtistSort sort,
    required int offset,
    required int limit,
  });

  Future<LibrarySlice<LibraryGenre>> fetchGenresSlice({
    required LibraryGenreSort sort,
    required int offset,
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
          variables: [Variable.withString(TrackIndexStatus.removed.value)],
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
    return (_database.select(
      _database.libraryProjectionMetas,
    )..where((table) => table.id.equals(1))).watchSingleOrNull().map((row) {
      if (row == null) {
        return const LibraryProjectionStatusSnapshot(
          state: LibraryProjectionBackfillState.pending,
          revision: 0,
        );
      }
      return LibraryProjectionStatusSnapshot(
        state: LibraryProjectionBackfillState.values.byName(row.backfillState),
        revision: row.revision,
        errorMessage: row.lastError,
      );
    });
  }

  @override
  Future<void> ensureProjectionBackfillStarted() async {
    await _database.ensureLibraryProjectionMetaRow();
    final meta = await _database.getLibraryProjectionMeta();
    final state = meta == null
        ? LibraryProjectionBackfillState.pending
        : LibraryProjectionBackfillState.values.byName(meta.backfillState);

    if (state == LibraryProjectionBackfillState.ready ||
        state == LibraryProjectionBackfillState.running) {
      return;
    }

    _backfillFuture ??= _database.rebuildLibraryProjections().whenComplete(
      () => _backfillFuture = null,
    );
    await _backfillFuture;
  }

  @override
  Future<LibrarySlice<TrackItem>> fetchSongsSlice({
    required LibrarySongSort sort,
    required int offset,
    required int limit,
  }) async {
    final revision = await _database.getLibraryProjectionRevision();
    final totalCount = await _countVisibleSongs();
    final orderSql = _songOrderSql(sort);
    final rows = await _database
        .customSelect(
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
      WHERE index_status = ?
      ORDER BY $orderSql
      LIMIT ?
      OFFSET ?
      ''',
          variables: [
            Variable.withString(TrackIndexStatus.active.value),
            Variable.withInt(limit),
            Variable.withInt(offset),
          ],
          readsFrom: {_database.tracks},
        )
        .get();

    return _buildSlice(
      offset: offset,
      rows: rows,
      revision: revision,
      totalCount: totalCount,
      mapRow: (row) => TrackItem(
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
    );
  }

  @override
  Future<LibrarySlice<LibraryAlbum>> fetchAlbumsSlice({
    required LibraryAlbumSort sort,
    required int offset,
    required int limit,
  }) async {
    final revision = await _database.getLibraryProjectionRevision();
    final totalCount = await _countProjectionRows(
      tableName: 'library_albums',
      readsFrom: {_database.libraryAlbumProjections},
    );
    final orderSql = _albumOrderSql(sort);
    final rows = await _database
        .customSelect(
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
      ORDER BY $orderSql
      LIMIT ?
      OFFSET ?
      ''',
          variables: [Variable.withInt(limit), Variable.withInt(offset)],
          readsFrom: {_database.libraryAlbumProjections},
        )
        .get();

    return _buildSlice(
      offset: offset,
      rows: rows,
      revision: revision,
      totalCount: totalCount,
      mapRow: (row) => LibraryAlbum(
        id: albumRouteKey(
          albumArtist: row.read<String>('album_artist'),
          album: row.read<String>('album'),
        ),
        title: row.read<String>('album'),
        artist: row.read<String>('album_artist'),
        year: row.read<int>('year'),
        imageUrl: row.read<String>('artwork_uri'),
      ),
    );
  }

  @override
  Future<LibrarySlice<LibraryArtist>> fetchArtistsSlice({
    required LibraryArtistSort sort,
    required int offset,
    required int limit,
  }) async {
    final revision = await _database.getLibraryProjectionRevision();
    final totalCount = await _countProjectionRows(
      tableName: 'library_artists',
      readsFrom: {_database.libraryArtistProjections},
    );
    final orderSql = _artistOrderSql(sort);
    final rows = await _database
        .customSelect(
          '''
      SELECT
        stable_id,
        name,
        name_sort,
        song_count,
        COALESCE(artwork_uri, '') AS artwork_uri
      FROM library_artists
      WHERE 1 = 1
      ORDER BY $orderSql
      LIMIT ?
      OFFSET ?
      ''',
          variables: [Variable.withInt(limit), Variable.withInt(offset)],
          readsFrom: {_database.libraryArtistProjections},
        )
        .get();

    return _buildSlice(
      offset: offset,
      rows: rows,
      revision: revision,
      totalCount: totalCount,
      mapRow: (row) => LibraryArtist(
        id: row.read<String>('stable_id'),
        name: row.read<String>('name'),
        songCount: row.read<int>('song_count'),
        imageUrl: row.read<String>('artwork_uri'),
      ),
    );
  }

  @override
  Future<LibrarySlice<LibraryAlbumArtist>> fetchAlbumArtistsSlice({
    required LibraryAlbumArtistSort sort,
    required int offset,
    required int limit,
  }) async {
    final revision = await _database.getLibraryProjectionRevision();
    final totalCount = await _countProjectionRows(
      tableName: 'library_album_artists',
      readsFrom: {_database.libraryAlbumArtistProjections},
    );
    final orderSql = _albumArtistOrderSql(sort);
    final rows = await _database
        .customSelect(
          '''
      SELECT
        stable_id,
        name,
        name_sort,
        album_count,
        COALESCE(artwork_uri, '') AS artwork_uri
      FROM library_album_artists
      WHERE 1 = 1
      ORDER BY $orderSql
      LIMIT ?
      OFFSET ?
      ''',
          variables: [Variable.withInt(limit), Variable.withInt(offset)],
          readsFrom: {_database.libraryAlbumArtistProjections},
        )
        .get();

    return _buildSlice(
      offset: offset,
      rows: rows,
      revision: revision,
      totalCount: totalCount,
      mapRow: (row) => LibraryAlbumArtist(
        id: row.read<String>('stable_id'),
        name: row.read<String>('name'),
        albumCount: row.read<int>('album_count'),
        imageUrl: row.read<String>('artwork_uri'),
      ),
    );
  }

  @override
  Future<LibrarySlice<LibraryGenre>> fetchGenresSlice({
    required LibraryGenreSort sort,
    required int offset,
    required int limit,
  }) async {
    final revision = await _database.getLibraryProjectionRevision();
    final totalCount = await _countProjectionRows(
      tableName: 'library_genres',
      readsFrom: {_database.libraryGenreProjections},
    );
    final orderSql = _genreOrderSql(sort);
    final rows = await _database
        .customSelect(
          '''
      SELECT
        stable_id,
        name,
        name_sort,
        song_count,
        COALESCE(artwork_uri, '') AS artwork_uri
      FROM library_genres
      WHERE 1 = 1
      ORDER BY $orderSql
      LIMIT ?
      OFFSET ?
      ''',
          variables: [Variable.withInt(limit), Variable.withInt(offset)],
          readsFrom: {_database.libraryGenreProjections},
        )
        .get();

    return _buildSlice(
      offset: offset,
      rows: rows,
      revision: revision,
      totalCount: totalCount,
      mapRow: (row) => LibraryGenre(
        id: row.read<String>('stable_id'),
        name: row.read<String>('name'),
        songCount: row.read<int>('song_count'),
        imageUrl: row.read<String>('artwork_uri'),
      ),
    );
  }

  @override
  Future<List<TrackItem>> fetchAllSongs({required LibrarySongSort sort}) async {
    final items = <TrackItem>[];
    var offset = 0;
    while (true) {
      final slice = await fetchSongsSlice(
        sort: sort,
        offset: offset,
        limit: 250,
      );
      items.addAll(slice.items);
      offset += slice.items.length;
      if (slice.items.length < 250) {
        break;
      }
    }
    return items;
  }

  LibrarySlice<T> _buildSlice<T>({
    required int offset,
    required List<QueryRow> rows,
    required int revision,
    required int totalCount,
    required T Function(QueryRow row) mapRow,
  }) {
    return LibrarySlice<T>(
      offset: offset,
      items: rows.map(mapRow).toList(growable: false),
      totalCount: totalCount,
      revision: revision,
    );
  }

  Future<int> _countVisibleSongs() async {
    final row = await _database
        .customSelect(
          '''
      SELECT COUNT(*) AS count
      FROM tracks
      WHERE index_status = ?
      ''',
          variables: [Variable.withString(TrackIndexStatus.active.value)],
          readsFrom: {_database.tracks},
        )
        .getSingle();
    return row.read<int>('count');
  }

  Future<int> _countProjectionRows({
    required String tableName,
    required Set<ResultSetImplementation> readsFrom,
  }) async {
    final row = await _database
        .customSelect(
          'SELECT COUNT(*) AS count FROM $tableName',
          readsFrom: readsFrom,
        )
        .getSingle();
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
  Future<LibrarySlice<LibraryAlbum>> fetchAlbumsSlice({
    required LibraryAlbumSort sort,
    required int offset,
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
    return _sliceMockPage(sorted, offset: offset, limit: limit);
  }

  @override
  Future<LibrarySlice<LibraryAlbumArtist>> fetchAlbumArtistsSlice({
    required LibraryAlbumArtistSort sort,
    required int offset,
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
    return _sliceMockPage(sorted, offset: offset, limit: limit);
  }

  @override
  Future<LibrarySlice<LibraryArtist>> fetchArtistsSlice({
    required LibraryArtistSort sort,
    required int offset,
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
    return _sliceMockPage(sorted, offset: offset, limit: limit);
  }

  @override
  Future<LibrarySlice<LibraryGenre>> fetchGenresSlice({
    required LibraryGenreSort sort,
    required int offset,
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
    return _sliceMockPage(sorted, offset: offset, limit: limit);
  }

  @override
  Future<LibrarySlice<TrackItem>> fetchSongsSlice({
    required LibrarySongSort sort,
    required int offset,
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
    return _sliceMockPage(sorted, offset: offset, limit: limit);
  }

  @override
  Future<List<TrackItem>> fetchAllSongs({required LibrarySongSort sort}) {
    return fetchSongsSlice(
      sort: sort,
      offset: 0,
      limit: librarySongs.length,
    ).then((slice) => slice.items);
  }

  LibrarySlice<T> _sliceMockPage<T>(
    List<T> items, {
    required int offset,
    required int limit,
  }) {
    final end = offset + limit > items.length ? items.length : offset + limit;
    return LibrarySlice<T>(
      offset: offset,
      items: items.sublist(offset, end),
      totalCount: items.length,
      revision: 1,
    );
  }
}

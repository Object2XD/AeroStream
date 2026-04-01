import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';
import '../../models/library_models.dart';
import '../../models/track_item.dart';
import 'drive_scan_models.dart';

class LibraryInfoStats {
  const LibraryInfoStats({
    required this.trackCount,
    required this.favoriteCount,
    required this.totalListeningMinutes,
    required this.connectedRoots,
  });

  final int trackCount;
  final int favoriteCount;
  final int totalListeningMinutes;
  final int connectedRoots;
}

class LibraryAlbumDetail {
  const LibraryAlbumDetail({
    required this.album,
    required this.tracks,
  });

  final LibraryAlbum album;
  final List<TrackItem> tracks;
}

class DriveLibraryRepository {
  const DriveLibraryRepository(this._database);

  final AppDatabase _database;

  Stream<List<TrackItem>> watchRecentTracks({int limit = 5}) {
    return _database.watchRecentTracks(limit: limit).map(
          (rows) => rows.map(_trackItemFromRow).toList(growable: false),
        );
  }

  Stream<List<TrackItem>> watchSongs() {
    return _database.watchAllTracks().map(
          (rows) => rows.map(_trackItemFromRow).toList(growable: false),
        );
  }

  Stream<List<LibraryAlbum>> watchAlbums() {
    return _database
        .customSelect(
          '''
          SELECT
            album,
            album_artist,
            COALESCE(MAX(artwork_uri), '') AS artwork_uri,
            COALESCE(MAX(year), 0) AS year
          FROM tracks
          WHERE metadata_status = ?
            AND index_status != ?
            AND album != ''
            AND album_artist != ''
          GROUP BY album, album_artist
          ORDER BY album COLLATE NOCASE
          ''',
          variables: [
            Variable.withString(TrackMetadataStatus.ready.value),
            Variable.withString(TrackIndexStatus.removed.value),
          ],
          readsFrom: {_database.tracks},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
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
              )
              .toList(growable: false),
        );
  }

  Stream<List<LibraryArtist>> watchArtists() {
    return _database
        .customSelect(
          '''
          SELECT
            artist,
            COUNT(*) AS song_count,
            COALESCE(MAX(artwork_uri), '') AS artwork_uri
          FROM tracks
          WHERE metadata_status = ?
            AND index_status != ?
            AND artist != ''
          GROUP BY artist
          ORDER BY artist COLLATE NOCASE
          ''',
          variables: [
            Variable.withString(TrackMetadataStatus.ready.value),
            Variable.withString(TrackIndexStatus.removed.value),
          ],
          readsFrom: {_database.tracks},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => LibraryArtist(
                  id: row.read<String>('artist'),
                  name: row.read<String>('artist'),
                  songCount: row.read<int>('song_count'),
                  imageUrl: row.read<String>('artwork_uri'),
                ),
              )
              .toList(growable: false),
        );
  }

  Stream<List<LibraryAlbumArtist>> watchAlbumArtists() {
    return _database
        .customSelect(
          '''
          SELECT
            album_artist,
            COUNT(DISTINCT album) AS album_count,
            COALESCE(MAX(artwork_uri), '') AS artwork_uri
          FROM tracks
          WHERE metadata_status = ?
            AND index_status != ?
            AND album_artist != ''
            AND album != ''
          GROUP BY album_artist
          ORDER BY album_artist COLLATE NOCASE
          ''',
          variables: [
            Variable.withString(TrackMetadataStatus.ready.value),
            Variable.withString(TrackIndexStatus.removed.value),
          ],
          readsFrom: {_database.tracks},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => LibraryAlbumArtist(
                  id: row.read<String>('album_artist'),
                  name: row.read<String>('album_artist'),
                  albumCount: row.read<int>('album_count'),
                  imageUrl: row.read<String>('artwork_uri'),
                ),
              )
              .toList(growable: false),
        );
  }

  Stream<List<LibraryGenre>> watchGenres() {
    return _database
        .customSelect(
          '''
          SELECT
            genre,
            COUNT(*) AS song_count,
            COALESCE(MAX(artwork_uri), '') AS artwork_uri
          FROM tracks
          WHERE metadata_status = ?
            AND index_status != ?
            AND genre != ''
          GROUP BY genre
          ORDER BY genre COLLATE NOCASE
          ''',
          variables: [
            Variable.withString(TrackMetadataStatus.ready.value),
            Variable.withString(TrackIndexStatus.removed.value),
          ],
          readsFrom: {_database.tracks},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => LibraryGenre(
                  id: row.read<String>('genre'),
                  name: row.read<String>('genre'),
                  songCount: row.read<int>('song_count'),
                  imageUrl: row.read<String>('artwork_uri'),
                ),
              )
              .toList(growable: false),
        );
  }

  Stream<LibraryInfoStats> watchInfoStats() {
    return _database
        .customSelect(
          '''
          SELECT
            (SELECT COUNT(*) FROM tracks WHERE index_status != ?) AS track_count,
            (SELECT SUM(CASE WHEN is_favorite = 1 THEN 1 ELSE 0 END) FROM tracks WHERE index_status != ?) AS favorite_count,
            (SELECT SUM((duration_ms * play_count) / 60000) FROM tracks WHERE index_status != ?) AS listening_minutes,
            (SELECT COUNT(*) FROM sync_roots) AS connected_roots
          ''',
          variables: [
            Variable.withString(TrackIndexStatus.removed.value),
            Variable.withString(TrackIndexStatus.removed.value),
            Variable.withString(TrackIndexStatus.removed.value),
          ],
          readsFrom: {_database.tracks, _database.syncRoots},
        )
        .watchSingle()
        .map(
          (row) => LibraryInfoStats(
            trackCount: row.read<int>('track_count'),
            favoriteCount: row.read<int?>('favorite_count') ?? 0,
            totalListeningMinutes: row.read<int?>('listening_minutes') ?? 0,
            connectedRoots: row.read<int>('connected_roots'),
          ),
        );
  }

  Stream<bool> watchHasTracks() {
    return _database.watchTrackCount().map((count) => count > 0);
  }

  Stream<int> watchCacheSizeBytes() => _database.watchCacheSizeBytes();

  Future<TrackItem?> getTrackItemById(int trackId) async {
    final row = await _database.getTrackById(trackId);
    return row == null ? null : _trackItemFromRow(row);
  }

  Future<List<TrackItem>> getTrackItemsByIds(List<int> trackIds) async {
    if (trackIds.isEmpty) {
      return const [];
    }

    final rows = await (_database.select(_database.tracks)
          ..where((table) => table.id.isIn(trackIds)))
        .get();
    final rowsById = {for (final row in rows) row.id: row};

    return trackIds
        .map((id) => rowsById[id])
        .whereType<Track>()
        .map(_trackItemFromRow)
        .toList(growable: false);
  }

  Future<LibraryAlbumDetail?> getAlbumDetail(String routeKey) async {
    final decoded = decodeAlbumRouteKey(routeKey);
    if (decoded == null) {
      return null;
    }

    final rows = await (_database.select(_database.tracks)
          ..where(
            (table) =>
                table.album.equals(decoded.album) &
                table.albumArtist.equals(decoded.albumArtist) &
                table.metadataStatus.equals(TrackMetadataStatus.ready.value) &
                table.indexStatus.isNotValue(TrackIndexStatus.removed.value),
          )
          ..orderBy([
            (table) => OrderingTerm(expression: table.discNumber),
            (table) => OrderingTerm(expression: table.trackNumber),
            (table) => OrderingTerm(expression: table.title),
          ]))
        .get();
    if (rows.isEmpty) {
      return null;
    }

    final first = rows.first;
    return LibraryAlbumDetail(
      album: LibraryAlbum(
        id: routeKey,
        title: decoded.album,
        artist: decoded.albumArtist,
        year: first.year ?? 0,
        imageUrl: first.artworkUri ?? '',
      ),
      tracks: rows.map(_trackItemFromRow).toList(growable: false),
    );
  }

  Future<void> clearCachedFiles() async {
    final rows = await (_database.select(_database.tracks)
          ..where((table) => table.cacheStatus.isNotValue('none')))
        .get();

    for (final row in rows) {
      final cachePath = row.cachePath;
      if (cachePath != null && cachePath.isNotEmpty) {
        final file = File(cachePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _database.updateTrackCache(
        row.id,
        cachePathValue: null,
        cacheStatusValue: 'none',
      );
    }
  }

  TrackItem _trackItemFromRow(Track row) {
    return TrackItem(
      id: row.id,
      title: row.title,
      artist: row.artist.isEmpty ? 'Google Drive' : row.artist,
      album: row.album.isEmpty ? row.fileName : row.album,
      durationSeconds: (row.durationMs / 1000).round(),
      imageUrl: row.artworkUri ?? '',
    );
  }
}

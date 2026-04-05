import 'dart:io';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/library_catalog_repository.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/models/library_models.dart';

void main() {
  test(
    'ensureProjectionBackfillStarted repairs legacy text timestamps in projection meta',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'aero_stream_library_catalog_test_',
      );
      final databaseFile = File(
        '${tempDir.path}${Platform.pathSeparator}library_catalog.sqlite',
      );

      final seededDatabase = AppDatabase(NativeDatabase(databaseFile));
      await seededDatabase.ensureLibraryProjectionMetaRow();
      await seededDatabase.customStatement('''
        UPDATE library_projection_meta
        SET last_backfill_at = CURRENT_TIMESTAMP
        WHERE id = 1
        ''');
      await seededDatabase.close();

      final reopenedDatabase = AppDatabase(NativeDatabase(databaseFile));
      addTearDown(() async {
        await reopenedDatabase.close();
        await tempDir.delete(recursive: true);
      });

      final repository = DatabaseLibraryCatalogRepository(reopenedDatabase);
      await repository.ensureProjectionBackfillStarted();

      final meta = await reopenedDatabase.getLibraryProjectionMeta();

      expect(meta, isNotNull);
      expect(meta!.backfillState, 'ready');
      expect(meta.lastBackfillAt, isNotNull);
    },
  );

  group('fetchSongsSlice', () {
    late AppDatabase database;
    late DatabaseLibraryCatalogRepository repository;
    late int rootId;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      repository = DatabaseLibraryCatalogRepository(database);

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
      await database.upsertRoot(
        SyncRootsCompanion.insert(
          accountId: account!.id,
          folderId: 'root-folder',
          folderName: 'Library',
          parentFolderId: const Value('root'),
          syncState: Value(DriveScanJobState.completed.value),
        ),
      );
      rootId = (await database.getRootByFolderId('root-folder'))!.id;
    });

    tearDown(() async {
      await database.close();
    });

    Future<void> seedTrack({
      required String driveFileId,
      required String fileName,
      required String title,
      required String artist,
      required String album,
      required int durationMs,
      required TrackIndexStatus indexStatus,
    }) {
      return database.upsertTrack(
        TracksCompanion.insert(
          rootId: rootId,
          driveFileId: driveFileId,
          fileName: fileName,
          title: title,
          titleSort: Value(_sortValue(title)),
          artist: artist,
          artistSort: Value(_sortValue(artist)),
          album: album,
          albumArtist: artist,
          genre: 'Electronic',
          durationMs: Value(durationMs),
          mimeType: 'audio/mpeg',
          metadataStatus: Value(TrackMetadataStatus.ready.value),
          artworkStatus: Value(TrackArtworkStatus.none.value),
          indexStatus: Value(indexStatus.value),
        ),
      );
    }

    test(
      'returns only active songs and matches totalCount to visible songs',
      () async {
        await seedTrack(
          driveFileId: 'active-alpha',
          fileName: 'active-alpha.mp3',
          title: 'Alpha',
          artist: 'Artist B',
          album: 'Album 1',
          durationMs: 240000,
          indexStatus: TrackIndexStatus.active,
        );
        await seedTrack(
          driveFileId: 'pending-beta',
          fileName: 'pending-beta.mp3',
          title: 'Beta',
          artist: 'Artist A',
          album: 'Album 2',
          durationMs: 210000,
          indexStatus: TrackIndexStatus.pendingDelete,
        );
        await seedTrack(
          driveFileId: 'removed-gamma',
          fileName: 'removed-gamma.mp3',
          title: 'Gamma',
          artist: 'Artist C',
          album: 'Album 3',
          durationMs: 180000,
          indexStatus: TrackIndexStatus.removed,
        );
        await seedTrack(
          driveFileId: 'active-delta',
          fileName: 'active-delta.mp3',
          title: 'Delta',
          artist: '',
          album: '',
          durationMs: 120000,
          indexStatus: TrackIndexStatus.active,
        );

        final slice = await repository.fetchSongsSlice(
          sort: LibrarySongSort.title,
          offset: 0,
          limit: 10,
        );

        expect(slice.totalCount, 2);
        expect(slice.offset, 0);
        expect(slice.items.map((item) => item.title).toList(), [
          'Alpha',
          'Delta',
        ]);
        expect(slice.items.map((item) => item.artist).toList(), [
          'Artist B',
          'Google Drive',
        ]);
        expect(slice.items.map((item) => item.album).toList(), [
          'Album 1',
          'active-delta.mp3',
        ]);
      },
    );

    test(
      'offset slices and fetchAllSongs ignore pending_delete and removed tracks',
      () async {
        for (var index = 0; index < 260; index++) {
          final label = index.toString().padLeft(3, '0');
          await seedTrack(
            driveFileId: 'active-$label',
            fileName: 'track-$label.mp3',
            title: 'Song $label',
            artist: 'Artist ${index % 5}',
            album: 'Album ${index % 8}',
            durationMs: 180000 + index,
            indexStatus: TrackIndexStatus.active,
          );
        }
        await seedTrack(
          driveFileId: 'pending-hidden',
          fileName: 'pending-hidden.mp3',
          title: 'Song 050.5',
          artist: 'Artist 9',
          album: 'Album 9',
          durationMs: 999999,
          indexStatus: TrackIndexStatus.pendingDelete,
        );
        await seedTrack(
          driveFileId: 'removed-hidden',
          fileName: 'removed-hidden.mp3',
          title: 'Song 075.5',
          artist: 'Artist 9',
          album: 'Album 9',
          durationMs: 999999,
          indexStatus: TrackIndexStatus.removed,
        );

        final firstSlice = await repository.fetchSongsSlice(
          sort: LibrarySongSort.title,
          offset: 0,
          limit: 100,
        );
        final secondSlice = await repository.fetchSongsSlice(
          sort: LibrarySongSort.title,
          offset: 100,
          limit: 100,
        );
        final thirdSlice = await repository.fetchSongsSlice(
          sort: LibrarySongSort.title,
          offset: 200,
          limit: 100,
        );
        final allSongs = await repository.fetchAllSongs(
          sort: LibrarySongSort.title,
        );

        expect(firstSlice.totalCount, 260);
        expect(firstSlice.offset, 0);
        expect(firstSlice.items, hasLength(100));
        expect(firstSlice.items.first.title, 'Song 000');
        expect(firstSlice.items.last.title, 'Song 099');

        expect(secondSlice.totalCount, 260);
        expect(secondSlice.offset, 100);
        expect(secondSlice.items, hasLength(100));
        expect(secondSlice.items.first.title, 'Song 100');
        expect(secondSlice.items.last.title, 'Song 199');

        expect(thirdSlice.totalCount, 260);
        expect(thirdSlice.offset, 200);
        expect(thirdSlice.items, hasLength(60));
        expect(thirdSlice.items.first.title, 'Song 200');
        expect(thirdSlice.items.last.title, 'Song 259');

        expect(allSongs, hasLength(260));
        expect(allSongs.first.title, 'Song 000');
        expect(allSongs.last.title, 'Song 259');
        expect(
          allSongs.where(
            (item) =>
                item.title.contains('050.5') || item.title.contains('075.5'),
          ),
          isEmpty,
        );
      },
    );

    test('songs queries use paging indexes for each sort', () async {
      for (var index = 0; index < 150; index++) {
        await seedTrack(
          driveFileId: 'plan-$index',
          fileName: 'plan-$index.mp3',
          title: 'Track ${index.toString().padLeft(3, '0')}',
          artist: 'Artist ${(149 - index).toString().padLeft(3, '0')}',
          album: 'Album ${index % 12}',
          durationMs: 120000 + index,
          indexStatus: TrackIndexStatus.active,
        );
      }

      final titlePlan = await _queryPlan(
        database,
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
        ORDER BY title_sort ASC, id ASC
        LIMIT ?
        OFFSET ?
        ''',
        variables: [
          Variable.withString(TrackIndexStatus.active.value),
          Variable.withInt(100),
          Variable.withInt(50),
        ],
      );
      final artistPlan = await _queryPlan(
        database,
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
        ORDER BY artist_sort ASC, title_sort ASC, id ASC
        LIMIT ?
        OFFSET ?
        ''',
        variables: [
          Variable.withString(TrackIndexStatus.active.value),
          Variable.withInt(100),
          Variable.withInt(50),
        ],
      );
      final durationPlan = await _queryPlan(
        database,
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
        ORDER BY duration_ms DESC, title_sort ASC, id ASC
        LIMIT ?
        OFFSET ?
        ''',
        variables: [
          Variable.withString(TrackIndexStatus.active.value),
          Variable.withInt(100),
          Variable.withInt(50),
        ],
      );

      expect(titlePlan, contains('idx_tracks_title_page'));
      expect(artistPlan, contains('idx_tracks_artist_page'));
      expect(durationPlan, contains('idx_tracks_duration_page'));
    });
  });
}

String _sortValue(String value) => value.trim().toLowerCase();

Future<String> _queryPlan(
  AppDatabase database,
  String sql, {
  List<Variable<Object>> variables = const [],
}) async {
  final rows = await database
      .customSelect(
        'EXPLAIN QUERY PLAN $sql',
        variables: variables,
        readsFrom: {database.tracks},
      )
      .get();
  return rows.map((row) => row.read<String>('detail')).join(' | ');
}

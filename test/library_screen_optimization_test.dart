import 'package:aero_stream/core/providers/cover_image_mode_provider.dart';
import 'package:aero_stream/core/providers/drive/library_catalog_providers.dart';
import 'package:aero_stream/core/providers/runtime_mode_provider.dart';
import 'package:aero_stream/data/drive/library_catalog_repository.dart';
import 'package:aero_stream/models/library_models.dart';
import 'package:aero_stream/models/track_item.dart';
import 'package:aero_stream/screens/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  Future<void> pumpLibraryScreen(
    WidgetTester tester, {
    required LibraryCatalogRepository repository,
    LibraryTab initialTab = LibraryTab.albums,
    LibraryViewMode initialViewMode = LibraryViewMode.list,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coverImageModeProvider.overrideWith(
            (ref) => CoverImageMode.placeholder,
          ),
          libraryCatalogRepositoryProvider.overrideWithValue(repository),
          useMockAppDataProvider.overrideWith((ref) => true),
        ],
        child: MaterialApp(
          home: LibraryScreen(
            initialTab: initialTab,
            initialViewMode: initialViewMode,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'albums stay browsable during optimization and show an inline status card',
    (tester) async {
      await pumpLibraryScreen(
        tester,
        repository: _LibraryScreenTestRepository(
          albums: const [
            LibraryAlbum(
              id: '0',
              title: 'Album 0',
              artist: 'Artist 0',
              year: 2026,
              imageUrl: '',
            ),
            LibraryAlbum(
              id: '1',
              title: 'Album 1',
              artist: 'Artist 1',
              year: 2025,
              imageUrl: '',
            ),
          ],
          trackCount: 24,
          projectionStatus: const LibraryProjectionStatusSnapshot(
            state: LibraryProjectionBackfillState.running,
            revision: 2,
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('library-projection-status-card')),
        findsOneWidget,
      );
      expect(find.text('Library optimization in progress'), findsOneWidget);
      expect(find.byKey(const ValueKey('library-utility-row')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('library-media-item-album-0')),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'albums show a preparing message instead of a blank list during optimization',
    (tester) async {
      await pumpLibraryScreen(
        tester,
        repository: _LibraryScreenTestRepository(
          albums: const [],
          trackCount: 12,
          projectionStatus: const LibraryProjectionStatusSnapshot(
            state: LibraryProjectionBackfillState.running,
            revision: 4,
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('library-projection-status-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('library-projection-empty-state')),
        findsOneWidget,
      );
      expect(find.text('Preparing grouped results'), findsOneWidget);
      expect(find.byKey(const ValueKey('library-utility-row')), findsOneWidget);
    },
  );

  testWidgets(
    'failed optimization still shows partial results with an error-toned status card',
    (tester) async {
      await pumpLibraryScreen(
        tester,
        repository: _LibraryScreenTestRepository(
          albums: const [
            LibraryAlbum(
              id: '0',
              title: 'Album 0',
              artist: 'Artist 0',
              year: 2026,
              imageUrl: '',
            ),
          ],
          trackCount: 12,
          projectionStatus: const LibraryProjectionStatusSnapshot(
            state: LibraryProjectionBackfillState.failed,
            revision: 5,
            errorMessage: 'Projection rebuild failed.',
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('library-projection-status-card')),
        findsOneWidget,
      );
      expect(find.text('Optimization paused'), findsOneWidget);
      expect(find.textContaining('Projection rebuild failed.'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('library-media-item-album-0')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'albums can continue paging while optimization is still running',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(580, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLibraryScreen(
        tester,
        repository: _LibraryScreenTestRepository.pagedAlbums(
          totalAlbums: 140,
          trackCount: 200,
          projectionStatus: const LibraryProjectionStatusSnapshot(
            state: LibraryProjectionBackfillState.running,
            revision: 7,
          ),
        ),
      );

      final scrollFinder = find.byKey(const ValueKey('library-scroll-view'));

      expect(
        find.byKey(const ValueKey('library-media-item-album-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('library-media-item-album-100')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('library-projection-status-card')),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('library-media-item-album-100')),
        800,
        scrollable: find.descendant(
          of: scrollFinder,
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('library-media-item-album-100')),
        findsOneWidget,
      );
    },
  );
}

class _LibraryScreenTestRepository implements LibraryCatalogRepository {
  _LibraryScreenTestRepository({
    required List<LibraryAlbum> albums,
    required this.trackCount,
    required this.projectionStatus,
  }) : _albums = albums;

  _LibraryScreenTestRepository.pagedAlbums({
    required int totalAlbums,
    required this.trackCount,
    required this.projectionStatus,
  }) : _albums = List<LibraryAlbum>.generate(
         totalAlbums,
         (index) => LibraryAlbum(
           id: '$index',
           title: 'Album $index',
           artist: 'Artist ${index % 7}',
           year: 2026 - (index % 5),
           imageUrl: '',
         ),
       );

  final List<LibraryAlbum> _albums;
  final int trackCount;
  final LibraryProjectionStatusSnapshot projectionStatus;

  @override
  Future<void> ensureProjectionBackfillStarted() async {}

  @override
  Future<List<TrackItem>> fetchAllSongs({required LibrarySongSort sort}) async {
    return const <TrackItem>[];
  }

  @override
  Future<LibraryPage<LibraryAlbum>> fetchAlbumsPage({
    required LibraryAlbumSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final start = cursor == null ? 0 : int.parse(cursor.value);
    final end = (start + limit).clamp(0, _albums.length);
    return LibraryPage<LibraryAlbum>(
      items: _albums.sublist(start, end),
      totalCount: _albums.length,
      nextCursor: end < _albums.length ? LibraryCursor(end.toString()) : null,
      hasMore: end < _albums.length,
      revision: projectionStatus.revision,
    );
  }

  @override
  Future<LibraryPage<LibraryAlbumArtist>> fetchAlbumArtistsPage({
    required LibraryAlbumArtistSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    return LibraryPage<LibraryAlbumArtist>(
      items: const <LibraryAlbumArtist>[],
      totalCount: 0,
      nextCursor: null,
      hasMore: false,
      revision: projectionStatus.revision,
    );
  }

  @override
  Future<LibraryPage<LibraryArtist>> fetchArtistsPage({
    required LibraryArtistSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    return LibraryPage<LibraryArtist>(
      items: const <LibraryArtist>[],
      totalCount: 0,
      nextCursor: null,
      hasMore: false,
      revision: projectionStatus.revision,
    );
  }

  @override
  Future<LibraryPage<LibraryGenre>> fetchGenresPage({
    required LibraryGenreSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    return LibraryPage<LibraryGenre>(
      items: const <LibraryGenre>[],
      totalCount: 0,
      nextCursor: null,
      hasMore: false,
      revision: projectionStatus.revision,
    );
  }

  @override
  Future<LibraryPage<TrackItem>> fetchSongsPage({
    required LibrarySongSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    return LibraryPage<TrackItem>(
      items: const <TrackItem>[],
      totalCount: 0,
      nextCursor: null,
      hasMore: false,
      revision: projectionStatus.revision,
    );
  }

  @override
  Stream<LibraryCounts> watchLibraryCounts() {
    return Stream.value(
      LibraryCounts(
        trackCount: trackCount,
        albumCount: _albums.length,
        artistCount: 0,
        albumArtistCount: 0,
        genreCount: 0,
      ),
    );
  }

  @override
  Stream<LibraryProjectionStatusSnapshot> watchProjectionStatus() {
    return Stream.value(projectionStatus);
  }

  @override
  Stream<int> watchLibraryRevision() => Stream.value(projectionStatus.revision);
}

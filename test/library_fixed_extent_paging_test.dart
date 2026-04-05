import 'package:aero_stream/core/notifications/local_notification_service.dart';
import 'package:aero_stream/core/permissions/notification_permission_state.dart';
import 'package:aero_stream/core/permissions/permission_service.dart';
import 'package:aero_stream/core/providers/cover_image_mode_provider.dart';
import 'package:aero_stream/core/providers/drive/library_catalog_providers.dart';
import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/core/providers/service_providers.dart';
import 'package:aero_stream/data/drive/library_catalog_repository.dart';
import 'package:aero_stream/models/library_models.dart';
import 'package:aero_stream/models/track_item.dart';
import 'package:aero_stream/screens/library_screen.dart';
import 'package:aero_stream/widgets/aero_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('Library keeps scroll extent stable while later pages load', (
    WidgetTester tester,
  ) async {
    final repository = _PagedAlbumLibraryRepository(totalAlbums: 140);

    await tester.binding.setSurfaceSize(const Size(580, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coverImageModeProvider.overrideWith(
            (ref) => CoverImageMode.placeholder,
          ),
          libraryCatalogRepositoryProvider.overrideWithValue(repository),
          useMockAppDataProvider.overrideWith((ref) => true),
          playbackTickerEnabledProvider.overrideWith((ref) => false),
          notificationServiceProvider.overrideWithValue(
            NoOpLocalNotificationService(),
          ),
          permissionServiceProvider.overrideWithValue(
            const NoOpPermissionService(
              NotificationPermissionState.notRequired,
            ),
          ),
        ],
        child: const MaterialApp(
          home: AeroShellScaffold(
            currentNavIndex: 1,
            padBodyForBottomChrome: false,
            body: LibraryScreen(
              initialTab: LibraryTab.albums,
              initialViewMode: LibraryViewMode.list,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollFinder = find.byKey(const ValueKey('library-scroll-view'));
    ScrollPosition scrollPosition() {
      return tester
          .state<ScrollableState>(
            find.descendant(
              of: scrollFinder,
              matching: find.byType(Scrollable),
            ),
          )
          .position;
    }

    final initialExtent = scrollPosition().maxScrollExtent;

    expect(initialExtent, greaterThan(0));
    expect(
      find.byKey(const ValueKey('library-media-item-album-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('library-media-item-album-100')),
      findsNothing,
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

    final extentAfterLoadingMore = scrollPosition().maxScrollExtent;
    expect(extentAfterLoadingMore, closeTo(initialExtent, 1));
    expect(
      find.byKey(const ValueKey('library-media-item-album-100')),
      findsOneWidget,
    );
  });

  testWidgets('Songs tab loads the target page directly after a deep jump', (
    WidgetTester tester,
  ) async {
    final repository = _PagedSongLibraryRepository(totalSongs: 10000);

    await tester.binding.setSurfaceSize(const Size(580, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coverImageModeProvider.overrideWith(
            (ref) => CoverImageMode.placeholder,
          ),
          libraryCatalogRepositoryProvider.overrideWithValue(repository),
          useMockAppDataProvider.overrideWith((ref) => true),
          playbackTickerEnabledProvider.overrideWith((ref) => false),
          notificationServiceProvider.overrideWithValue(
            NoOpLocalNotificationService(),
          ),
          permissionServiceProvider.overrideWithValue(
            const NoOpPermissionService(
              NotificationPermissionState.notRequired,
            ),
          ),
        ],
        child: const MaterialApp(
          home: AeroShellScaffold(
            currentNavIndex: 1,
            padBodyForBottomChrome: false,
            body: LibraryScreen(initialTab: LibraryTab.songs),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollFinder = find.byKey(const ValueKey('library-scroll-view'));
    ScrollPosition scrollPosition() {
      return tester
          .state<ScrollableState>(
            find.descendant(
              of: scrollFinder,
              matching: find.byType(Scrollable),
            ),
          )
          .position;
    }

    final initialExtent = scrollPosition().maxScrollExtent;

    expect(initialExtent, greaterThan(0));
    expect(
      find.byKey(const ValueKey('library-media-item-song-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('library-media-item-song-100')),
      findsNothing,
    );

    scrollPosition().jumpTo(_kLibrarySongRowExtent * 4995);
    await tester.pump();
    await tester.pumpAndSettle();

    final extentAfterLoadingMore = scrollPosition().maxScrollExtent;
    expect(extentAfterLoadingMore, closeTo(initialExtent, 1));
    expect(
      find.byKey(const ValueKey('library-media-item-song-5000')),
      findsOneWidget,
    );
    expect(repository.requestedOffsets, contains(5000));
    expect(repository.requestedOffsets, contains(4900));
    expect(repository.requestedOffsets, contains(5100));
    expect(
      repository.requestedOffsets.where((offset) => offset == 5000),
      hasLength(1),
    );
    expect(repository.requestedOffsets.toSet().length, lessThanOrEqualTo(8));
  });
}

const double _kLibrarySongRowExtent = 84.0;

class _PagedAlbumLibraryRepository implements LibraryCatalogRepository {
  _PagedAlbumLibraryRepository({required int totalAlbums})
    : albums = List<LibraryAlbum>.generate(
        totalAlbums,
        (index) => LibraryAlbum(
          id: '$index',
          title: 'Album $index',
          artist: 'Artist ${index % 7}',
          year: 2026 - (index % 5),
          imageUrl: '',
        ),
      );

  final List<LibraryAlbum> albums;

  @override
  Future<void> ensureProjectionBackfillStarted() async {}

  @override
  Future<List<TrackItem>> fetchAllSongs({required LibrarySongSort sort}) async {
    return const <TrackItem>[];
  }

  @override
  Future<LibrarySlice<LibraryAlbum>> fetchAlbumsSlice({
    required LibraryAlbumSort sort,
    required int offset,
    required int limit,
  }) async {
    final end = (offset + limit).clamp(0, albums.length);
    return LibrarySlice<LibraryAlbum>(
      offset: offset,
      items: albums.sublist(offset, end),
      totalCount: albums.length,
      revision: 1,
    );
  }

  @override
  Future<LibrarySlice<LibraryAlbumArtist>> fetchAlbumArtistsSlice({
    required LibraryAlbumArtistSort sort,
    required int offset,
    required int limit,
  }) async {
    return const LibrarySlice<LibraryAlbumArtist>(
      offset: 0,
      items: <LibraryAlbumArtist>[],
      totalCount: 0,
      revision: 1,
    );
  }

  @override
  Future<LibrarySlice<LibraryArtist>> fetchArtistsSlice({
    required LibraryArtistSort sort,
    required int offset,
    required int limit,
  }) async {
    return const LibrarySlice<LibraryArtist>(
      offset: 0,
      items: <LibraryArtist>[],
      totalCount: 0,
      revision: 1,
    );
  }

  @override
  Future<LibrarySlice<LibraryGenre>> fetchGenresSlice({
    required LibraryGenreSort sort,
    required int offset,
    required int limit,
  }) async {
    return const LibrarySlice<LibraryGenre>(
      offset: 0,
      items: <LibraryGenre>[],
      totalCount: 0,
      revision: 1,
    );
  }

  @override
  Future<LibrarySlice<TrackItem>> fetchSongsSlice({
    required LibrarySongSort sort,
    required int offset,
    required int limit,
  }) async {
    return const LibrarySlice<TrackItem>(
      offset: 0,
      items: <TrackItem>[],
      totalCount: 0,
      revision: 1,
    );
  }

  @override
  Stream<LibraryCounts> watchLibraryCounts() {
    return Stream.value(
      LibraryCounts(
        trackCount: albums.length,
        albumCount: albums.length,
        artistCount: 0,
        albumArtistCount: 0,
        genreCount: 0,
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
}

class _PagedSongLibraryRepository implements LibraryCatalogRepository {
  _PagedSongLibraryRepository({required int totalSongs})
    : songs = List<TrackItem>.generate(
        totalSongs,
        (index) => TrackItem(
          id: index,
          title: 'Song $index',
          artist: 'Artist ${index % 7}',
          album: 'Album ${index % 5}',
          durationSeconds: 180 + index,
          imageUrl: '',
        ),
      );

  final List<TrackItem> songs;
  final List<int> requestedOffsets = <int>[];

  @override
  Future<void> ensureProjectionBackfillStarted() async {}

  @override
  Future<List<TrackItem>> fetchAllSongs({required LibrarySongSort sort}) async {
    return songs;
  }

  @override
  Future<LibrarySlice<LibraryAlbum>> fetchAlbumsSlice({
    required LibraryAlbumSort sort,
    required int offset,
    required int limit,
  }) async {
    return const LibrarySlice<LibraryAlbum>(
      offset: 0,
      items: <LibraryAlbum>[],
      totalCount: 0,
      revision: 1,
    );
  }

  @override
  Future<LibrarySlice<LibraryAlbumArtist>> fetchAlbumArtistsSlice({
    required LibraryAlbumArtistSort sort,
    required int offset,
    required int limit,
  }) async {
    return const LibrarySlice<LibraryAlbumArtist>(
      offset: 0,
      items: <LibraryAlbumArtist>[],
      totalCount: 0,
      revision: 1,
    );
  }

  @override
  Future<LibrarySlice<LibraryArtist>> fetchArtistsSlice({
    required LibraryArtistSort sort,
    required int offset,
    required int limit,
  }) async {
    return const LibrarySlice<LibraryArtist>(
      offset: 0,
      items: <LibraryArtist>[],
      totalCount: 0,
      revision: 1,
    );
  }

  @override
  Future<LibrarySlice<LibraryGenre>> fetchGenresSlice({
    required LibraryGenreSort sort,
    required int offset,
    required int limit,
  }) async {
    return const LibrarySlice<LibraryGenre>(
      offset: 0,
      items: <LibraryGenre>[],
      totalCount: 0,
      revision: 1,
    );
  }

  @override
  Future<LibrarySlice<TrackItem>> fetchSongsSlice({
    required LibrarySongSort sort,
    required int offset,
    required int limit,
  }) async {
    requestedOffsets.add(offset);
    final end = (offset + limit).clamp(0, songs.length);
    return LibrarySlice<TrackItem>(
      offset: offset,
      items: songs.sublist(offset, end),
      totalCount: songs.length,
      revision: 1,
    );
  }

  @override
  Stream<LibraryCounts> watchLibraryCounts() {
    return Stream.value(
      LibraryCounts(
        trackCount: songs.length,
        albumCount: 0,
        artistCount: 0,
        albumArtistCount: 0,
        genreCount: 0,
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
}

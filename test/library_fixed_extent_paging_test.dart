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
    expect(find.byKey(const ValueKey('library-media-item-album-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('library-media-item-album-100')), findsNothing);

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
}

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
  Future<LibraryPage<LibraryAlbum>> fetchAlbumsPage({
    required LibraryAlbumSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    final start = cursor == null ? 0 : int.parse(cursor.value);
    final end = (start + limit).clamp(0, albums.length);
    return LibraryPage<LibraryAlbum>(
      items: albums.sublist(start, end),
      totalCount: albums.length,
      nextCursor: end < albums.length ? LibraryCursor(end.toString()) : null,
      hasMore: end < albums.length,
      revision: 1,
    );
  }

  @override
  Future<LibraryPage<LibraryAlbumArtist>> fetchAlbumArtistsPage({
    required LibraryAlbumArtistSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    return const LibraryPage<LibraryAlbumArtist>(
      items: <LibraryAlbumArtist>[],
      totalCount: 0,
      nextCursor: null,
      hasMore: false,
      revision: 1,
    );
  }

  @override
  Future<LibraryPage<LibraryArtist>> fetchArtistsPage({
    required LibraryArtistSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    return const LibraryPage<LibraryArtist>(
      items: <LibraryArtist>[],
      totalCount: 0,
      nextCursor: null,
      hasMore: false,
      revision: 1,
    );
  }

  @override
  Future<LibraryPage<LibraryGenre>> fetchGenresPage({
    required LibraryGenreSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    return const LibraryPage<LibraryGenre>(
      items: <LibraryGenre>[],
      totalCount: 0,
      nextCursor: null,
      hasMore: false,
      revision: 1,
    );
  }

  @override
  Future<LibraryPage<TrackItem>> fetchSongsPage({
    required LibrarySongSort sort,
    LibraryCursor? cursor,
    required int limit,
  }) async {
    return const LibraryPage<TrackItem>(
      items: <TrackItem>[],
      totalCount: 0,
      nextCursor: null,
      hasMore: false,
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

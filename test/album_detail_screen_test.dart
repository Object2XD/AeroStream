import 'package:aero_stream/app.dart';
import 'package:aero_stream/app_routes.dart';
import 'package:aero_stream/core/notifications/local_notification_service.dart';
import 'package:aero_stream/core/permissions/notification_permission_state.dart';
import 'package:aero_stream/core/permissions/permission_service.dart';
import 'package:aero_stream/core/providers/cover_image_mode_provider.dart';
import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/core/providers/service_providers.dart';
import 'package:aero_stream/data/mock_library.dart';
import 'package:aero_stream/screens/library/album_detail_screen.dart';
import 'package:aero_stream/widgets/mini_player_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testOverrides() {
    return [
      coverImageModeProvider.overrideWith((ref) => CoverImageMode.placeholder),
      useMockAppDataProvider.overrideWith((ref) => true),
      playbackTickerEnabledProvider.overrideWith((ref) => false),
      notificationServiceProvider.overrideWithValue(
        NoOpLocalNotificationService(),
      ),
      permissionServiceProvider.overrideWithValue(
        const NoOpPermissionService(NotificationPermissionState.notRequired),
      ),
    ];
  }

  Future<void> pumpAppAtSurfaceSize(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const AeroStreamApp()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpAppAtDesktopNarrowSize(WidgetTester tester) async {
    await pumpAppAtSurfaceSize(tester, const Size(512, 923));
  }

  testWidgets('album tap opens AlbumDetail from Library', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const AeroStreamApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('library-media-item-album-1')),
    );
    await tester.tap(find.byKey(const ValueKey('library-media-item-album-1')));
    await tester.pumpAndSettle();

    expect(find.text('Neon Nights'), findsWidgets);
    expect(find.text('Album • 2024 • 4 songs'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Shuffle'), findsOneWidget);
  });

  testWidgets('album detail stays inside the main shell chrome', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const AeroStreamApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('library-media-item-album-1')),
    );
    await tester.tap(find.byKey(const ValueKey('library-media-item-album-1')));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(MiniPlayerBar), findsOneWidget);
    expect(find.text('Album • 2024 • 4 songs'), findsOneWidget);
  });

  testWidgets(
    'album detail routed viewport matches home height at 512x923 desktop',
    (WidgetTester tester) async {
      await pumpAppAtDesktopNarrowSize(tester);

      final homeRect = tester.getRect(
        find.byKey(const ValueKey('home-scroll-view')),
      );

      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const ValueKey('library-media-item-album-1')),
      );
      await tester.tap(find.byKey(const ValueKey('library-media-item-album-1')));
      await tester.pumpAndSettle();

      final albumDetailRect = tester.getRect(
        find.byKey(const ValueKey('album-detail-scroll-view')),
      );

      expect(
        albumDetailRect.bottom,
        closeTo(homeRect.bottom, 0.01),
        reason:
            'Expected the routed shell/page contract to keep the album detail '
            'viewport bottom aligned with HomeScreen at 512x923, but '
            'home.bottom=${homeRect.bottom} and '
            'album.bottom=${albumDetailRect.bottom}.',
      );
    },
  );

  testWidgets(
    'album detail does not leave a large blank gap at scroll end on screenshot-sized desktop',
    (WidgetTester tester) async {
      await pumpAppAtSurfaceSize(tester, const Size(471, 913));

      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const ValueKey('library-media-item-album-1')),
      );
      await tester.tap(find.byKey(const ValueKey('library-media-item-album-1')));
      await tester.pumpAndSettle();

      final scrollFinder = find.byKey(
        const ValueKey('album-detail-scroll-view'),
      );
      final position = tester
          .state<ScrollableState>(
            find.descendant(
              of: scrollFinder,
              matching: find.byType(Scrollable),
            ),
          )
          .position;

      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();

      final miniPlayerTop = tester.getTopLeft(find.byType(MiniPlayerBar)).dy;
      final bottomTrackBottom = <double>[
        tester
            .getRect(find.byKey(const ValueKey('album-detail-track-101')))
            .bottom,
        tester
            .getRect(find.byKey(const ValueKey('album-detail-track-106')))
            .bottom,
        tester
            .getRect(find.byKey(const ValueKey('album-detail-track-107')))
            .bottom,
        tester
            .getRect(find.byKey(const ValueKey('album-detail-track-108')))
            .bottom,
      ].reduce((value, element) => value > element ? value : element);
      final trailingGap = miniPlayerTop - bottomTrackBottom;

      expect(
        trailingGap,
        lessThanOrEqualTo(48),
        reason:
            'Expected the routed AlbumDetail screen to finish close to the '
            'mini player at scroll end on a screenshot-sized desktop '
            'surface, but it left a trailing gap of $trailingGap px.',
      );
    },
  );

  testWidgets('album detail play, shuffle, and track tap drive playback', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(overrides: testOverrides());
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AeroStreamApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('library-media-item-album-1')),
    );
    await tester.tap(find.byKey(const ValueKey('library-media-item-album-1')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Play'));
    await tester.tap(find.widgetWithText(FilledButton, 'Play'));
    await tester.pumpAndSettle();

    final playbackAfterPlay = container.read(miniPlayerControllerProvider);
    final albumTracks = libraryAlbumTracksById('1')!;
    expect(playbackAfterPlay.currentTrack!.id, albumTracks.first.id);
    expect(playbackAfterPlay.queue.map((track) => track.id).toList(), [
      for (final track in albumTracks) track.id,
    ]);
    expect(find.text('Up Next'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Shuffle'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Shuffle'));
    await tester.pumpAndSettle();

    final playbackAfterShuffle = container.read(miniPlayerControllerProvider);
    expect(playbackAfterShuffle.queue.length, albumTracks.length);
    expect(
      playbackAfterShuffle.queue.map((track) => track.id).toSet(),
      albumTracks.map((track) => track.id).toSet(),
    );
    expect(
      albumTracks.any(
        (track) => track.id == playbackAfterShuffle.currentTrack!.id,
      ),
      isTrue,
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('album-detail-track-108')),
    );
    await tester.tap(find.byKey(const ValueKey('album-detail-track-108')));
    await tester.pumpAndSettle();

    final playbackAfterTrackTap = container.read(miniPlayerControllerProvider);
    expect(playbackAfterTrackTap.currentTrack!.id, 108);
    expect(playbackAfterTrackTap.queue.length, albumTracks.length);
    expect(find.text('After Hours Bloom'), findsWidgets);
  });

  testWidgets('invalid album id shows not found view', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(),
        child: MaterialApp(home: const AlbumDetailScreen(albumId: '9999')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Album not found'), findsOneWidget);
    expect(
      find.text(
        'This album could not be loaded. Try returning to your library and opening another album.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('album detail route helper builds expected path', (
    WidgetTester tester,
  ) async {
    expect(AppRoutes.libraryAlbumDetail('12'), '/library/album/12');
  });
}

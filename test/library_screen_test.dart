import 'package:aero_stream/app.dart';
import 'package:aero_stream/core/notifications/local_notification_service.dart';
import 'package:aero_stream/core/permissions/notification_permission_state.dart';
import 'package:aero_stream/core/permissions/permission_service.dart';
import 'package:aero_stream/core/providers/cover_image_mode_provider.dart';
import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/core/providers/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('Library screen supports sort, toggle, and song playback', (
    WidgetTester tester,
  ) async {
    ScrollPosition libraryScrollPosition() {
      return tester
          .state<ScrollableState>(
            find.descendant(
              of: find.byKey(const ValueKey('library-scroll-view')),
              matching: find.byType(Scrollable),
            ),
          )
          .position;
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coverImageModeProvider.overrideWith(
            (ref) => CoverImageMode.placeholder,
          ),
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
        child: const AeroStreamApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    expect(find.text('Albums'), findsOneWidget);
    expect(find.byKey(const ValueKey('library-view-grid')), findsOneWidget);
    expect(find.byKey(const ValueKey('library-view-list')), findsOneWidget);

    final initialUtilityY = tester
        .getTopLeft(find.byKey(const ValueKey('library-utility-row')))
        .dy;
    await tester.drag(
      find.byKey(const ValueKey('library-scroll-view')),
      const Offset(0, -20),
    );
    await tester.pumpAndSettle();

    final scrolledUtilityY = tester
        .getTopLeft(find.byKey(const ValueKey('library-utility-row')))
        .dy;
    expect(scrolledUtilityY, lessThan(initialUtilityY));

    await tester.tap(find.byKey(const ValueKey('library-add-button')));
    await tester.pumpAndSettle();
    expect(find.text('Information'), findsOneWidget);
    expect(find.text('Google Drive'), findsOneWidget);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('library-view-list')));
    await tester.pumpAndSettle();

    final utilityAfterViewToggleY = tester
        .getTopLeft(find.byKey(const ValueKey('library-utility-row')))
        .dy;
    expect(utilityAfterViewToggleY, lessThan(initialUtilityY));

    await tester.ensureVisible(
      find.byKey(const ValueKey('library-media-item-album-1')),
    );
    await tester.tap(find.byKey(const ValueKey('library-media-item-album-1')));
    await tester.pumpAndSettle();
    expect(find.text('Album • 2024 • 4 songs'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('library-album-overflow-1')));
    await tester.pumpAndSettle();
    expect(find.text('Album actions are coming soon.'), findsOneWidget);

    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    libraryScrollPosition().jumpTo(0);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('library-sort-button')));
    await tester.tap(find.byKey(const ValueKey('library-sort-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Year').last);
    await tester.pumpAndSettle();

    final resetAfterSortY = tester
        .getTopLeft(find.byKey(const ValueKey('library-utility-row')))
        .dy;
    expect(resetAfterSortY, closeTo(initialUtilityY, 1));

    final neonNightsTop = tester.getTopLeft(
      find.byKey(const ValueKey('library-media-item-album-1')),
    );
    final rockAnthemsTop = tester.getTopLeft(
      find.byKey(const ValueKey('library-media-item-album-4')),
    );
    expect(neonNightsTop.dy, lessThan(rockAnthemsTop.dy));

    await tester.ensureVisible(find.text('Songs'));
    await tester.tap(find.text('Songs'));
    await tester.pumpAndSettle();

    final resetAfterTabChangeY = tester
        .getTopLeft(find.byKey(const ValueKey('library-utility-row')))
        .dy;
    expect(resetAfterTabChangeY, closeTo(initialUtilityY, 1));

    expect(find.byKey(const ValueKey('library-view-grid')), findsNothing);
    expect(find.byKey(const ValueKey('library-view-list')), findsNothing);

    await tester.ensureVisible(find.byKey(const ValueKey('library-sort-button')));
    await tester.tap(find.byKey(const ValueKey('library-sort-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duration').last);
    await tester.pumpAndSettle();

    final silentWavesTop = tester.getTopLeft(
      find.byKey(const ValueKey('library-media-item-song-104')),
    );
    final midnightDreamsTop = tester.getTopLeft(
      find.byKey(const ValueKey('library-media-item-song-101')),
    );
    expect(silentWavesTop.dy, lessThan(midnightDreamsTop.dy));

    final midnightDreamsFinder = find.byKey(
      const ValueKey('library-media-item-song-101'),
    );
    await tester.ensureVisible(midnightDreamsFinder);
    await tester.drag(
      find.byKey(const ValueKey('library-scroll-view')),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.tap(midnightDreamsFinder);
    await tester.pumpAndSettle();

    expect(find.text('Midnight Dreams'), findsWidgets);
    expect(find.text('Up Next'), findsOneWidget);
  });
}

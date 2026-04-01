import 'package:aero_stream/core/notifications/local_notification_service.dart';
import 'package:aero_stream/core/permissions/notification_permission_state.dart';
import 'package:aero_stream/core/permissions/permission_service.dart';
import 'package:aero_stream/core/providers/cover_image_mode_provider.dart';
import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/core/providers/service_providers.dart';
import 'package:aero_stream/models/library_models.dart';
import 'package:aero_stream/screens/home_screen.dart';
import 'package:aero_stream/screens/library_screen.dart';
import 'package:aero_stream/widgets/aero_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  Future<void> pumpHomeScreen(WidgetTester tester, Size surfaceSize) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
        child: const MaterialApp(
          home: AeroShellScaffold(
            currentNavIndex: 0,
            padBodyForBottomChrome: false,
            body: HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpLibraryScreen(
    WidgetTester tester,
    Size surfaceSize,
    LibraryTab tab,
  ) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
        child: MaterialApp(
          home: KeyedSubtree(
            key: ValueKey(
              'library-screen-${tab.name}-${surfaceSize.width}-${surfaceSize.height}',
            ),
            child: AeroShellScaffold(
              currentNavIndex: 1,
              padBodyForBottomChrome: false,
              body: LibraryScreen(initialTab: tab),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Rect homeViewportRect(WidgetTester tester) {
    final homeScrollView = find.byKey(const ValueKey('home-scroll-view'));
    expect(homeScrollView, findsOneWidget);
    return tester.getRect(homeScrollView);
  }

  Rect libraryViewportRect(WidgetTester tester) {
    final libraryScrollView = find.byKey(const ValueKey('library-scroll-view'));
    expect(libraryScrollView, findsOneWidget);
    return tester.getRect(libraryScrollView);
  }

  const surfaceSizes = <Size>[Size(1400, 800), Size(1400, 1100)];

  for (final surfaceSize in surfaceSizes) {
    for (final tab in LibraryTab.values) {
      testWidgets('Library viewport matches home height for ${tab.name} at '
          '${surfaceSize.width.toInt()}x${surfaceSize.height.toInt()}', (
        tester,
      ) async {
        await pumpHomeScreen(tester, surfaceSize);
        final homeRect = homeViewportRect(tester);

        await pumpLibraryScreen(tester, surfaceSize, tab);
        final libraryRect = libraryViewportRect(tester);

        expect(
          libraryRect.top,
          closeTo(homeRect.top + 48, 0.01),
          reason:
              'Expected the library viewport top to sit only below the 48px '
              'tab bar at $surfaceSize for ${tab.name}, but '
              'home.top=${homeRect.top} and library.top=${libraryRect.top}.',
        );

        expect(
          libraryRect.bottom,
          closeTo(homeRect.bottom, 0.01),
          reason:
              'Expected the library viewport bottom to match HomeScreen at '
              '$surfaceSize for ${tab.name}, but '
              'home.bottom=${homeRect.bottom} and '
              'library.bottom=${libraryRect.bottom}.',
        );
      });
    }
  }
}

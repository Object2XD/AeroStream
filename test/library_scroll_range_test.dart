import 'package:aero_stream/core/notifications/local_notification_service.dart';
import 'package:aero_stream/core/permissions/notification_permission_state.dart';
import 'package:aero_stream/core/permissions/permission_service.dart';
import 'package:aero_stream/core/providers/cover_image_mode_provider.dart';
import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/core/providers/service_providers.dart';
import 'package:aero_stream/models/library_models.dart';
import 'package:aero_stream/screens/library_screen.dart';
import 'package:aero_stream/widgets/aero_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  Future<void> pumpLibraryAlbumsList(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(580, 900));
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
  }

  testWidgets('Library albums list does not allow extra scrolling', (
    WidgetTester tester,
  ) async {
    await pumpLibraryAlbumsList(tester);

    final scrollFinder = find.byKey(const ValueKey('library-scroll-view'));
    final position = tester
        .state<ScrollableState>(
          find.descendant(
            of: scrollFinder,
            matching: find.byType(Scrollable),
          ),
        )
        .position;
    final utilityFinder = find.byKey(const ValueKey('library-utility-row'));
    final initialUtilityTop = tester.getTopLeft(utilityFinder).dy;

    expect(
      position.maxScrollExtent,
      closeTo(0, 0.01),
      reason:
          'Expected albums list content to fit without extra scroll range, '
          'but measured maxScrollExtent=${position.maxScrollExtent}.',
    );

    await tester.drag(scrollFinder, const Offset(0, -50));
    await tester.pumpAndSettle();

    final draggedUtilityTop = tester.getTopLeft(utilityFinder).dy;

    expect(
      draggedUtilityTop,
      closeTo(initialUtilityTop, 0.01),
      reason:
          'Expected the utility row to stay fixed when there is no scrollable '
          'overflow, but it moved from $initialUtilityTop to $draggedUtilityTop.',
    );
  });
}

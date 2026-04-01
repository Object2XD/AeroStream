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
  Future<void> pumpAppAtDesktopNarrowSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(512, 923));
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
        child: const AeroStreamApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'listening time routed viewport matches home height at 512x923 desktop',
    (tester) async {
      await pumpAppAtDesktopNarrowSize(tester);

      final homeRect = tester.getRect(
        find.byKey(const ValueKey('home-scroll-view')),
      );

      await tester.tap(find.text('Info'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Total Listening Time'));
      await tester.pumpAndSettle();

      final listeningTimeRect = tester.getRect(
        find.byKey(const ValueKey('listening-time-scroll-view')),
      );

      expect(
        listeningTimeRect.bottom,
        closeTo(homeRect.bottom, 0.01),
        reason:
            'Expected the routed shell/page contract to keep the listening '
            'time viewport bottom aligned with HomeScreen at 512x923, but '
            'home.bottom=${homeRect.bottom} and '
            'detail.bottom=${listeningTimeRect.bottom}.',
      );
    },
  );
}

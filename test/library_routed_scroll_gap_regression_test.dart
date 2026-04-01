import 'package:aero_stream/app.dart';
import 'package:aero_stream/core/notifications/local_notification_service.dart';
import 'package:aero_stream/core/permissions/notification_permission_state.dart';
import 'package:aero_stream/core/permissions/permission_service.dart';
import 'package:aero_stream/core/providers/cover_image_mode_provider.dart';
import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/core/providers/service_providers.dart';
import 'package:aero_stream/widgets/mini_player_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets(
    'Library routed albums grid should not leave a large blank gap at scroll end on narrow desktop',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(471, 913));
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

      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();

      final scrollFinder = find.byKey(const ValueKey('library-scroll-view'));
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
      final bottomRowBottom = <double>[
        tester
            .getRect(find.byKey(const ValueKey('library-media-item-album-1')))
            .bottom,
        tester
            .getRect(find.byKey(const ValueKey('library-media-item-album-2')))
            .bottom,
        tester
            .getRect(find.byKey(const ValueKey('library-media-item-album-3')))
            .bottom,
        tester
            .getRect(find.byKey(const ValueKey('library-media-item-album-4')))
            .bottom,
      ].reduce((value, element) => value > element ? value : element);
      final trailingGap = miniPlayerTop - bottomRowBottom;

      expect(
        trailingGap,
        lessThanOrEqualTo(48),
        reason:
            'Expected the routed Library albums grid to finish close to the mini player '
            'when scrolled to the end on a screenshot-sized desktop surface, '
            'but it left a trailing gap of $trailingGap px. '
            'This indicates the routed shell/page path is adding too much bottom scroll space.',
      );
    },
  );
}

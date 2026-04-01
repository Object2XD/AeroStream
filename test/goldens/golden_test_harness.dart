import 'package:aero_stream/core/notifications/local_notification_service.dart';
import 'package:aero_stream/core/permissions/notification_permission_state.dart';
import 'package:aero_stream/core/permissions/permission_service.dart';
import 'package:aero_stream/core/providers/cover_image_mode_provider.dart';
import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/core/providers/service_providers.dart';
import 'package:aero_stream/core/theme/app_theme.dart';
import 'package:aero_stream/widgets/aero_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Widget buildGoldenApp(Widget child) {
  return ProviderScope(
    overrides: [
      coverImageModeProvider.overrideWith((ref) => CoverImageMode.placeholder),
      useMockAppDataProvider.overrideWith((ref) => true),
      playbackTickerEnabledProvider.overrideWith((ref) => false),
      notificationServiceProvider.overrideWithValue(
        NoOpLocalNotificationService(),
      ),
      permissionServiceProvider.overrideWithValue(
        const NoOpPermissionService(NotificationPermissionState.notRequired),
      ),
    ],
    child: MaterialApp(theme: buildAeroTheme(), home: child),
  );
}

Future<void> loadAeroFonts() async {
  await loadAppFonts();
}

Widget wrapWithShell(Widget child, {required int currentNavIndex}) {
  return AeroShellScaffold(
    currentNavIndex: currentNavIndex,
    padBodyForBottomChrome: false,
    body: child,
  );
}

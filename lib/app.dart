import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/providers/drive/drive_providers.dart';
import 'core/providers/app_settings_controller.dart';
import 'core/providers/runtime_mode_provider.dart';
import 'core/providers/service_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class AeroStreamApp extends HookConsumerWidget {
  const AeroStreamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      unawaited(_bootstrap(ref));
      return null;
    }, const []);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AeroStream',
      routerConfig: router,
      theme: buildAeroTheme(),
    );
  }

  Future<void> _bootstrap(WidgetRef ref) async {
    await ref.read(notificationServiceProvider).initialize();
    await ref.read(appSettingsProvider.notifier).syncNotificationPermission();
    if (ref.read(useMockAppDataProvider)) {
      return;
    }

    unawaited(ref.read(playbackRepositoryProvider).initialize());
    unawaited(ref.read(googleDriveControllerProvider.future));
  }
}

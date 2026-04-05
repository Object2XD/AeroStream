import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/providers/app_settings_controller.dart';
import 'core/providers/drive/drive_providers.dart';
import 'core/providers/runtime_mode_provider.dart';
import 'core/providers/service_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class AeroStreamApp extends ConsumerStatefulWidget {
  const AeroStreamApp({super.key});

  @override
  ConsumerState<AeroStreamApp> createState() => _AeroStreamAppState();
}

class _AeroStreamAppState extends ConsumerState<AeroStreamApp> {
  bool _bootstrapStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _bootstrapStarted) {
        return;
      }
      _bootstrapStarted = true;
      unawaited(_bootstrap());
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AeroStream',
      routerConfig: router,
      theme: buildAeroTheme(),
    );
  }

  Future<void> _bootstrap() async {
    try {
      await ref.read(notificationServiceProvider).initialize();
      if (!mounted) {
        return;
      }

      await ref.read(appSettingsProvider.notifier).syncNotificationPermission();
      if (!mounted || ref.read(useMockAppDataProvider)) {
        return;
      }

      _startGuardedWarmUp(
        label: 'playback repository warm-up',
        start: () => ref.read(playbackRepositoryProvider).initialize(),
      );
      _startGuardedWarmUp(
        label: 'Google Drive controller warm-up',
        start: () => ref.read(googleDriveControllerProvider.future),
      );
    } catch (error, stackTrace) {
      _reportBootstrapError(
        error,
        stackTrace,
        context: 'initial startup bootstrap',
      );
    }
  }

  void _startGuardedWarmUp({
    required String label,
    required Future<Object?> Function() start,
  }) {
    try {
      final future = start();
      unawaited(
        future.catchError((Object error, StackTrace stackTrace) {
          _reportBootstrapError(error, stackTrace, context: label);
          return null;
        }),
      );
    } catch (error, stackTrace) {
      _reportBootstrapError(error, stackTrace, context: label);
    }
  }

  void _reportBootstrapError(
    Object error,
    StackTrace stackTrace, {
    required String context,
  }) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'AeroStreamApp bootstrap',
        context: ErrorDescription('while running $context'),
      ),
    );
  }
}

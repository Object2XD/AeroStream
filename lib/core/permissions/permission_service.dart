import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'notification_permission_state.dart';

abstract class PermissionService {
  Future<NotificationPermissionState> checkNotificationPermission();

  Future<NotificationPermissionState> requestNotificationPermission();

  Future<bool> openSettings();
}

class PlatformPermissionService implements PermissionService {
  PlatformPermissionService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<NotificationPermissionState> checkNotificationPermission() async {
    if (kIsWeb) {
      return NotificationPermissionState.notRequired;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _checkAndroidPermission();
      case TargetPlatform.iOS:
        return _checkDarwinPermission(isMacOS: false);
      case TargetPlatform.macOS:
        return _checkDarwinPermission(isMacOS: true);
      case TargetPlatform.windows:
        return NotificationPermissionState.notRequired;
      case TargetPlatform.linux:
        return NotificationPermissionState.unsupported;
      case TargetPlatform.fuchsia:
        return NotificationPermissionState.unsupported;
    }
  }

  @override
  Future<NotificationPermissionState> requestNotificationPermission() async {
    if (kIsWeb) {
      return NotificationPermissionState.notRequired;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _requestAndroidPermission();
      case TargetPlatform.iOS:
        return _requestDarwinPermission(isMacOS: false);
      case TargetPlatform.macOS:
        return _requestDarwinPermission(isMacOS: true);
      case TargetPlatform.windows:
        return NotificationPermissionState.notRequired;
      case TargetPlatform.linux:
        return NotificationPermissionState.unsupported;
      case TargetPlatform.fuchsia:
        return NotificationPermissionState.unsupported;
    }
  }

  @override
  Future<bool> openSettings() async {
    if (kIsWeb) {
      return false;
    }

    try {
      return await openAppSettings();
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<NotificationPermissionState> _checkAndroidPermission() async {
    try {
      final status = await Permission.notification.status;
      return _mapPermissionStatus(status);
    } on MissingPluginException {
      return NotificationPermissionState.denied;
    } catch (_) {
      return NotificationPermissionState.denied;
    }
  }

  Future<NotificationPermissionState> _requestAndroidPermission() async {
    try {
      final status = await Permission.notification.request();
      return _mapPermissionStatus(status);
    } on MissingPluginException {
      return NotificationPermissionState.denied;
    } catch (_) {
      return NotificationPermissionState.denied;
    }
  }

  Future<NotificationPermissionState> _checkDarwinPermission({
    required bool isMacOS,
  }) async {
    try {
      final options = isMacOS
          ? await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.checkPermissions()
          : await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.checkPermissions();

      if (options == null) {
        return NotificationPermissionState.denied;
      }

      return options.isEnabled || options.isProvisionalEnabled
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    } on MissingPluginException {
      return NotificationPermissionState.denied;
    } catch (_) {
      return NotificationPermissionState.denied;
    }
  }

  Future<NotificationPermissionState> _requestDarwinPermission({
    required bool isMacOS,
  }) async {
    try {
      final granted = isMacOS
          ? await _plugin
                    .resolvePlatformSpecificImplementation<
                      MacOSFlutterLocalNotificationsPlugin
                    >()
                    ?.requestPermissions(
                      alert: true,
                      badge: true,
                      sound: true,
                    ) ??
                false
          : await _plugin
                    .resolvePlatformSpecificImplementation<
                      IOSFlutterLocalNotificationsPlugin
                    >()
                    ?.requestPermissions(
                      alert: true,
                      badge: true,
                      sound: true,
                    ) ??
                false;

      return granted
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    } on MissingPluginException {
      return NotificationPermissionState.denied;
    } catch (_) {
      return NotificationPermissionState.denied;
    }
  }

  NotificationPermissionState _mapPermissionStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return NotificationPermissionState.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return NotificationPermissionState.permanentlyDenied;
    }
    return NotificationPermissionState.denied;
  }
}

class NoOpPermissionService implements PermissionService {
  const NoOpPermissionService(this.state);

  final NotificationPermissionState state;

  @override
  Future<NotificationPermissionState> checkNotificationPermission() async {
    return state;
  }

  @override
  Future<bool> openSettings() async {
    return false;
  }

  @override
  Future<NotificationPermissionState> requestNotificationPermission() async {
    return state;
  }
}

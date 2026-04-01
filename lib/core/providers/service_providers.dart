import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../notifications/local_notification_service.dart';
import '../permissions/permission_service.dart';

final flutterLocalNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
      return FlutterLocalNotificationsPlugin();
    });

final notificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return PlatformLocalNotificationService(
    ref.watch(flutterLocalNotificationsPluginProvider),
  );
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PlatformPermissionService(
    ref.watch(flutterLocalNotificationsPluginProvider),
  );
});

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../permissions/notification_permission_state.dart';
import 'mini_player_controller.dart';
import 'service_providers.dart';

class AppSettingsState {
  const AppSettingsState({
    required this.notificationsEnabled,
    required this.notificationPermissionState,
    required this.isUpdatingNotifications,
  });

  final bool notificationsEnabled;
  final NotificationPermissionState notificationPermissionState;
  final bool isUpdatingNotifications;

  AppSettingsState copyWith({
    bool? notificationsEnabled,
    NotificationPermissionState? notificationPermissionState,
    bool? isUpdatingNotifications,
  }) {
    return AppSettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationPermissionState:
          notificationPermissionState ?? this.notificationPermissionState,
      isUpdatingNotifications:
          isUpdatingNotifications ?? this.isUpdatingNotifications,
    );
  }
}

class AppSettingsController extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() {
    return const AppSettingsState(
      notificationsEnabled: false,
      notificationPermissionState: NotificationPermissionState.denied,
      isUpdatingNotifications: false,
    );
  }

  Future<void> syncNotificationPermission() async {
    final status = await ref
        .read(permissionServiceProvider)
        .checkNotificationPermission();

    state = state.copyWith(
      notificationsEnabled: status.isAllowed,
      notificationPermissionState: status,
    );
  }

  Future<String> setNotificationsEnabled(bool enabled) async {
    final permissionService = ref.read(permissionServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);

    state = state.copyWith(isUpdatingNotifications: true);

    if (!enabled) {
      await notificationService.cancelAll();
      state = state.copyWith(
        notificationsEnabled: false,
        isUpdatingNotifications: false,
      );
      return 'Notifications turned off.';
    }

    var status = await permissionService.checkNotificationPermission();
    if (!status.isAllowed) {
      status = await permissionService.requestNotificationPermission();
    }

    if (status.isAllowed) {
      final track = ref.read(
        miniPlayerControllerProvider.select((value) => value.currentTrack),
      );
      if (track != null) {
        await notificationService.showNowPlayingReminder(track: track);
      }
      state = state.copyWith(
        notificationsEnabled: true,
        notificationPermissionState: status,
        isUpdatingNotifications: false,
      );
      return status == NotificationPermissionState.notRequired
          ? 'Notifications are available on this platform without an extra permission prompt.'
          : 'Notifications turned on.';
    }

    state = state.copyWith(
      notificationsEnabled: false,
      notificationPermissionState: status,
      isUpdatingNotifications: false,
    );

    return switch (status) {
      NotificationPermissionState.permanentlyDenied =>
        'Notifications are blocked. Open system settings to enable them.',
      NotificationPermissionState.unsupported =>
        'Notifications are not supported on this platform yet.',
      NotificationPermissionState.denied =>
        'Notifications permission was not granted.',
      _ => 'Notifications could not be enabled.',
    };
  }

  Future<String> openSystemSettings() async {
    final opened = await ref.read(permissionServiceProvider).openSettings();
    return opened
        ? 'Opened system settings.'
        : 'Could not open system settings.';
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettingsState>(
      AppSettingsController.new,
    );

import 'package:aero_stream/core/notifications/local_notification_service.dart';
import 'package:aero_stream/core/permissions/notification_permission_state.dart';
import 'package:aero_stream/core/permissions/permission_service.dart';
import 'package:aero_stream/core/providers/app_settings_controller.dart';
import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/core/providers/service_providers.dart';
import 'package:aero_stream/models/track_item.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPermissionService extends Mock implements PermissionService {}

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const TrackItem(
        id: 0,
        title: 'Fallback',
        artist: 'Fallback Artist',
        album: 'Fallback Album',
        durationSeconds: 0,
        imageUrl: 'fallback',
      ),
    );
  });

  test(
    'enabling notifications with granted permission shows reminder',
    () async {
      final permissionService = MockPermissionService();
      final notificationService = MockLocalNotificationService();

      when(
        () => permissionService.checkNotificationPermission(),
      ).thenAnswer((_) async => NotificationPermissionState.granted);
      when(
        () => notificationService.showNowPlayingReminder(
          track: any(named: 'track'),
        ),
      ).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          useMockAppDataProvider.overrideWith((ref) => true),
          playbackTickerEnabledProvider.overrideWith((ref) => false),
          permissionServiceProvider.overrideWithValue(permissionService),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
      );
      addTearDown(container.dispose);

      final message = await container
          .read(appSettingsProvider.notifier)
          .setNotificationsEnabled(true);

      expect(message, 'Notifications turned on.');
      expect(container.read(appSettingsProvider).notificationsEnabled, isTrue);
      expect(
        container.read(appSettingsProvider).notificationPermissionState,
        NotificationPermissionState.granted,
      );
      verify(
        () => notificationService.showNowPlayingReminder(
          track: any(named: 'track'),
        ),
      ).called(1);
    },
  );

  test('denied permission keeps notifications disabled', () async {
    final permissionService = MockPermissionService();
    final notificationService = MockLocalNotificationService();

    when(
      () => permissionService.checkNotificationPermission(),
    ).thenAnswer((_) async => NotificationPermissionState.denied);
    when(
      () => permissionService.requestNotificationPermission(),
    ).thenAnswer((_) async => NotificationPermissionState.permanentlyDenied);

      final container = ProviderContainer(
        overrides: [
          useMockAppDataProvider.overrideWith((ref) => true),
          playbackTickerEnabledProvider.overrideWith((ref) => false),
          permissionServiceProvider.overrideWithValue(permissionService),
          notificationServiceProvider.overrideWithValue(notificationService),
      ],
    );
    addTearDown(container.dispose);

    final message = await container
        .read(appSettingsProvider.notifier)
        .setNotificationsEnabled(true);

    expect(
      message,
      'Notifications are blocked. Open system settings to enable them.',
    );
    expect(container.read(appSettingsProvider).notificationsEnabled, isFalse);
    expect(
      container.read(appSettingsProvider).notificationPermissionState,
      NotificationPermissionState.permanentlyDenied,
    );
    verifyNever(
      () => notificationService.showNowPlayingReminder(
        track: any(named: 'track'),
      ),
    );
  });

  test('syncNotificationPermission reflects unsupported platforms', () async {
    final permissionService = MockPermissionService();
    final notificationService = MockLocalNotificationService();

    when(
      () => permissionService.checkNotificationPermission(),
    ).thenAnswer((_) async => NotificationPermissionState.unsupported);

      final container = ProviderContainer(
        overrides: [
          useMockAppDataProvider.overrideWith((ref) => true),
          playbackTickerEnabledProvider.overrideWith((ref) => false),
          permissionServiceProvider.overrideWithValue(permissionService),
          notificationServiceProvider.overrideWithValue(notificationService),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(appSettingsProvider.notifier)
        .syncNotificationPermission();

    expect(container.read(appSettingsProvider).notificationsEnabled, isFalse);
    expect(
      container.read(appSettingsProvider).notificationPermissionState,
      NotificationPermissionState.unsupported,
    );
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../models/track_item.dart';

abstract class LocalNotificationService {
  Future<void> initialize();

  Future<void> showNowPlayingReminder({required TrackItem track});

  Future<void> cancelAll();
}

class PlatformLocalNotificationService implements LocalNotificationService {
  PlatformLocalNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      linux: LinuxInitializationSettings(defaultActionName: 'Open AeroStream'),
      windows: WindowsInitializationSettings(
        appName: 'AeroStream',
        appUserModelId: 'com.example.aero_stream',
        guid: '9f4adf67-4e5d-43fc-bc16-8514d1d0d417',
      ),
    );

    try {
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );
      _initialized = true;
    } on MissingPluginException {
      _initialized = false;
    } catch (_) {
      _initialized = false;
    }
  }

  @override
  Future<void> showNowPlayingReminder({required TrackItem track}) async {
    await initialize();
    if (!_initialized || kIsWeb) {
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'aero_now_playing',
        'Now Playing',
        channelDescription:
            'Playback reminders for the current listening session',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(defaultActionName: 'Open AeroStream'),
      windows: WindowsNotificationDetails(),
    );

    try {
      await _plugin.show(
        id: 1001,
        title: 'Resume your listening session',
        body: '${track.title} by ${track.artist} is ready when you are.',
        notificationDetails: details,
        payload: 'track:${track.title}',
      );
    } on MissingPluginException {
      return;
    } catch (_) {
      return;
    }
  }

  @override
  Future<void> cancelAll() async {
    if (kIsWeb) {
      return;
    }

    try {
      await _plugin.cancelAll();
    } on MissingPluginException {
      return;
    } catch (_) {
      return;
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }
}

class NoOpLocalNotificationService implements LocalNotificationService {
  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showNowPlayingReminder({required TrackItem track}) async {}
}

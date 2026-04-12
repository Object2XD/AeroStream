import 'package:aero_stream/app.dart';
import 'package:aero_stream/core/notifications/local_notification_service.dart';
import 'package:aero_stream/core/permissions/notification_permission_state.dart';
import 'package:aero_stream/core/permissions/permission_service.dart';
import 'package:aero_stream/core/providers/drive/drive_providers.dart';
import 'package:aero_stream/core/providers/runtime_mode_provider.dart';
import 'package:aero_stream/core/providers/service_providers.dart';
import 'package:aero_stream/core/router/app_router.dart';
import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/drive_library_repository.dart';
import 'package:aero_stream/data/drive/drive_stream_proxy.dart';
import 'package:aero_stream/data/drive/drive_track_cache_service.dart';
import 'package:aero_stream/data/playback/playback_repository.dart';
import 'package:aero_stream/models/track_item.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

void main() {
  testWidgets(
    'AeroStreamApp runs startup work after build and skips warm-up in mock mode',
    (WidgetTester tester) async {
      final notificationService = _RecordingNotificationService();
      final permissionService = _RecordingPermissionService(
        NotificationPermissionState.notRequired,
      );
      final playbackRepository = _RecordingPlaybackRepository();
      final driveWorkspace = _RecordingDriveWorkspaceNotifier();
      final router = _buildTestRouter();

      addTearDown(router.dispose);
      addTearDown(playbackRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(router),
            useMockAppDataProvider.overrideWith((ref) => true),
            notificationServiceProvider.overrideWithValue(notificationService),
            permissionServiceProvider.overrideWithValue(permissionService),
            playbackRepositoryProvider.overrideWithValue(playbackRepository),
            driveWorkspaceProvider.overrideWith(() => driveWorkspace),
          ],
          child: const AeroStreamApp(),
        ),
      );
      await tester.pump();

      expect(notificationService.initializeCallCount, 1);
      expect(permissionService.checkCallCount, 1);
      expect(
        notificationService.schedulerPhases,
        isNot(contains(SchedulerPhase.persistentCallbacks)),
      );
      expect(
        permissionService.schedulerPhases,
        isNot(contains(SchedulerPhase.persistentCallbacks)),
      );
      expect(playbackRepository.initializeCallCount, 0);
      expect(driveWorkspace.buildCallCount, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AeroStreamApp warms playback and Drive after the first frame when not mocking',
    (WidgetTester tester) async {
      final notificationService = _RecordingNotificationService();
      final permissionService = _RecordingPermissionService(
        NotificationPermissionState.notRequired,
      );
      final playbackRepository = _RecordingPlaybackRepository();
      final driveWorkspace = _RecordingDriveWorkspaceNotifier();
      final router = _buildTestRouter();

      addTearDown(router.dispose);
      addTearDown(playbackRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(router),
            notificationServiceProvider.overrideWithValue(notificationService),
            permissionServiceProvider.overrideWithValue(permissionService),
            playbackRepositoryProvider.overrideWithValue(playbackRepository),
            driveWorkspaceProvider.overrideWith(() => driveWorkspace),
          ],
          child: const AeroStreamApp(),
        ),
      );
      await tester.pump();

      expect(notificationService.initializeCallCount, 1);
      expect(permissionService.checkCallCount, 1);
      expect(playbackRepository.initializeCallCount, 1);
      expect(driveWorkspace.buildCallCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AeroStreamApp reports warm-up errors without crashing the build',
    (WidgetTester tester) async {
      final notificationService = _RecordingNotificationService();
      final permissionService = _RecordingPermissionService(
        NotificationPermissionState.notRequired,
      );
      final playbackRepository = _RecordingPlaybackRepository(
        throwOnInitialize: true,
      );
      final driveWorkspace = _RecordingDriveWorkspaceNotifier();
      final router = _buildTestRouter();
      final reportedErrors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = reportedErrors.add;

      addTearDown(() {
        FlutterError.onError = previousOnError;
      });
      addTearDown(router.dispose);
      addTearDown(playbackRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(router),
            notificationServiceProvider.overrideWithValue(notificationService),
            permissionServiceProvider.overrideWithValue(permissionService),
            playbackRepositoryProvider.overrideWithValue(playbackRepository),
            driveWorkspaceProvider.overrideWith(() => driveWorkspace),
          ],
          child: const AeroStreamApp(),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        reportedErrors.any(
          (details) =>
              details.context?.toDescription().contains(
                'playback repository warm-up',
              ) ??
              false,
        ),
        isTrue,
      );
    },
  );
}

GoRouter _buildTestRouter() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SizedBox.shrink()),
    ],
  );
}

class _RecordingNotificationService implements LocalNotificationService {
  int initializeCallCount = 0;
  final List<SchedulerPhase> schedulerPhases = <SchedulerPhase>[];

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> initialize() async {
    initializeCallCount++;
    schedulerPhases.add(SchedulerBinding.instance.schedulerPhase);
  }

  @override
  Future<void> showNowPlayingReminder({required TrackItem track}) async {}
}

class _RecordingPermissionService implements PermissionService {
  _RecordingPermissionService(this.state);

  final NotificationPermissionState state;
  int checkCallCount = 0;
  final List<SchedulerPhase> schedulerPhases = <SchedulerPhase>[];

  @override
  Future<NotificationPermissionState> checkNotificationPermission() async {
    checkCallCount++;
    schedulerPhases.add(SchedulerBinding.instance.schedulerPhase);
    return state;
  }

  @override
  Future<bool> openSettings() async => false;

  @override
  Future<NotificationPermissionState> requestNotificationPermission() async {
    return state;
  }
}

class _RecordingDriveWorkspaceNotifier extends DriveWorkspaceNotifier {
  int buildCallCount = 0;

  @override
  Future<DriveWorkspaceState> build() async {
    buildCallCount++;
    return const DriveWorkspaceState(
      isConfigured: true,
      account: null,
      hasLinkedAccount: false,
      canAccessDrive: false,
      requiresReconnect: false,
      authErrorMessage: null,
      roots: <SyncRoot>[],
      cacheSizeBytes: 0,
      syncProgress: null,
      isMutating: false,
      configurationMessage: null,
      errorMessage: null,
    );
  }
}

class _RecordingPlaybackRepository extends PlaybackRepository {
  factory _RecordingPlaybackRepository({bool throwOnInitialize = false}) {
    final database = AppDatabase(NativeDatabase.memory());
    final httpClient = DriveHttpClient(
      authRepository: _NoOpDriveAuthRepository(),
    );
    return _RecordingPlaybackRepository._(
      database: database,
      httpClient: httpClient,
      throwOnInitialize: throwOnInitialize,
    );
  }

  // ignore: use_super_parameters
  _RecordingPlaybackRepository._({
    required AppDatabase database,
    required DriveHttpClient httpClient,
    required this.throwOnInitialize,
  }) : _database = database,
       super(
         database: database,
         libraryRepository: DriveLibraryRepository(database),
         driveStreamProxy: DriveStreamProxy(
           database: database,
           driveHttpClient: httpClient,
         ),
         trackCacheService: DriveTrackCacheService(
           database: database,
           driveHttpClient: httpClient,
         ),
       );

  final AppDatabase _database;
  final bool throwOnInitialize;
  int initializeCallCount = 0;

  @override
  Future<void> initialize() async {
    initializeCallCount++;
    if (throwOnInitialize) {
      throw StateError('playback warm-up failed');
    }
  }

  @override
  Future<void> dispose() async {
    await _database.close();
  }
}

class _NoOpDriveAuthRepository implements DriveAuthRepository {
  @override
  String? get configurationMessage => null;

  @override
  bool get isConfigured => true;

  @override
  Future<DriveAccountProfile> connect() {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<DriveAccountProfile?> restoreSession() async => null;

  @override
  Future<T> withClient<T>(Future<T> Function(http.Client client) action) {
    throw UnimplementedError();
  }
}

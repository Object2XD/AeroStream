import 'package:aero_stream/core/providers/drive/drive_providers.dart';
import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_artwork_extractor.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/drive_metadata_extractor.dart';
import 'package:aero_stream/data/drive/drive_scan_coordinator.dart';
import 'package:aero_stream/data/drive/drive_scan_execution_profile.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_track_cache_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

void main() {
  test(
    'controller keeps library data and marks reconnect required on invalid desktop session',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await database.setActiveAccount(
        SyncAccountsCompanion.insert(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'oauth_desktop',
          connectedAt: DateTime(2026, 3, 31),
          authSessionState: Value(DriveAuthSessionState.ready.value),
          authSessionError: const Value(null),
        ),
      );
      final account = (await database.getActiveAccount())!;
      final jobId = await database.createScanJob(
        ScanJobsCompanion.insert(
          accountId: account.id,
          kind: DriveScanJobKind.baseline.value,
          state: DriveScanJobState.running.value,
          phase: DriveScanPhase.baselineDiscovery.value,
        ),
      );
      await database.upsertRoot(
        SyncRootsCompanion.insert(
          accountId: account.id,
          folderId: 'folder-1',
          folderName: 'Music',
          syncState: Value(DriveScanJobState.running.value),
          activeJobId: Value(jobId),
        ),
      );
      final root = (await database.getRootByFolderId('folder-1'))!;
      await database.upsertTrack(
        TracksCompanion.insert(
          rootId: root.id,
          driveFileId: 'track-1',
          fileName: 'track-1.mp3',
          title: 'track-1',
          artist: '',
          album: '',
          albumArtist: '',
          genre: '',
          mimeType: 'audio/mpeg',
        ),
      );

      final authRepository = _FakeDriveAuthRepository(
        restoreSessionResult: null,
      );
      final coordinator = _RecordingDriveScanCoordinator(
        database: database,
        authRepository: authRepository,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          driveAuthRepositoryProvider.overrideWithValue(authRepository),
          driveScanCoordinatorProvider.overrideWithValue(coordinator),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(googleDriveControllerProvider.future);

      expect(authRepository.restoreCallCount, 1);
      expect(state.hasLinkedAccount, isTrue);
      expect(state.canAccessDrive, isFalse);
      expect(state.requiresReconnect, isTrue);
      expect(state.authErrorMessage, driveAuthReconnectRequiredMessage);
      expect(state.roots, hasLength(1));
      expect(await database.countTracks(), 1);
      expect(coordinator.bootstrapCallCount, 0);

      final updatedAccount = (await database.getActiveAccount())!;
      final updatedRoot = (await database.getRootById(root.id))!;
      final updatedJob = (await database.getScanJobById(jobId))!;
      expect(
        updatedAccount.authSessionState,
        DriveAuthSessionState.reauthRequired.value,
      );
      expect(updatedRoot.syncState, DriveScanJobState.failed.value);
      expect(updatedRoot.lastError, driveSyncReconnectRequiredMessage);
      expect(updatedJob.state, DriveScanJobState.failed.value);
      expect(updatedJob.lastError, driveSyncReconnectRequiredMessage);
    },
  );

  test(
    'controller blocks drive entrypoints with a reconnect-required message',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await database.setActiveAccount(
        SyncAccountsCompanion.insert(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'oauth_desktop',
          connectedAt: DateTime(2026, 3, 31),
          authSessionState: Value(DriveAuthSessionState.reauthRequired.value),
          authSessionError: const Value(driveAuthReconnectRequiredMessage),
        ),
      );

      final authRepository = _FakeDriveAuthRepository(
        restoreSessionResult: null,
      );
      final coordinator = _RecordingDriveScanCoordinator(
        database: database,
        authRepository: authRepository,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          driveAuthRepositoryProvider.overrideWithValue(authRepository),
          driveScanCoordinatorProvider.overrideWithValue(coordinator),
        ],
      );
      addTearDown(container.dispose);

      await container.read(googleDriveControllerProvider.future);

      await expectLater(
        container.read(googleDriveControllerProvider.notifier).listFolders(),
        throwsA(
          isA<DriveAuthException>().having(
            (error) => error.message,
            'message',
            driveAuthReconnectRequiredMessage,
          ),
        ),
      );
      await expectLater(
        container
            .read(googleDriveControllerProvider.notifier)
            .addRoot(
              const DriveFolderEntry(
                id: 'new-root',
                name: 'New Root',
                parentId: 'root',
              ),
            ),
        throwsA(
          isA<DriveAuthException>().having(
            (error) => error.message,
            'message',
            driveAuthReconnectRequiredMessage,
          ),
        ),
      );

      await container
          .read(googleDriveControllerProvider.notifier)
          .enqueueSync();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(googleDriveControllerProvider).value!;
      expect(state.errorMessage, driveAuthReconnectRequiredMessage);
      expect(coordinator.enqueueCallCount, 0);
    },
  );
}

class _FakeDriveAuthRepository implements DriveAuthRepository {
  _FakeDriveAuthRepository({required this.restoreSessionResult});

  final DriveAccountProfile? restoreSessionResult;

  int restoreCallCount = 0;

  @override
  bool get isConfigured => true;

  @override
  String? get configurationMessage => null;

  @override
  Future<DriveAccountProfile?> restoreSession() async {
    restoreCallCount += 1;
    return restoreSessionResult;
  }

  @override
  Future<DriveAccountProfile> connect() async {
    return const DriveAccountProfile(
      providerAccountId: 'drive-account',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: 'oauth_desktop',
    );
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<T> withClient<T>(Future<T> Function(http.Client client) action) {
    throw UnimplementedError();
  }
}

class _RecordingDriveScanCoordinator extends DriveScanCoordinator {
  _RecordingDriveScanCoordinator({
    required super.database,
    required DriveAuthRepository authRepository,
  }) : super(
         driveHttpClient: DriveHttpClient(authRepository: authRepository),
         metadataExtractor: DriveMetadataExtractor(
           driveHttpClient: DriveHttpClient(authRepository: authRepository),
         ),
         artworkExtractor: DriveArtworkExtractor(
           driveHttpClient: DriveHttpClient(authRepository: authRepository),
         ),
         trackCacheService: DriveTrackCacheService(
           database: database,
           driveHttpClient: DriveHttpClient(authRepository: authRepository),
         ),
         executionProfile: const DriveScanExecutionProfile(
           changeWorkers: 1,
           discoveryWorkers: 1,
           metadataWorkers: 1,
           artworkWorkers: 1,
           artworkWorkersWhileMetadataPending: 0,
           metadataHighWatermark: 0,
           pageSize: 1000,
           trackProjectionBatchSize: 100,
         ),
         autoRun: false,
       );

  int bootstrapCallCount = 0;
  int enqueueCallCount = 0;

  @override
  Future<void> bootstrap() async {
    bootstrapCallCount += 1;
  }

  @override
  Future<int?> enqueueSync({int? rootId}) async {
    enqueueCallCount += 1;
    return null;
  }
}

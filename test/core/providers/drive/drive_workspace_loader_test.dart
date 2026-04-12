import 'package:aero_stream/core/providers/drive/drive_providers.dart';
import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../support/drive_test_helpers.dart';

void main() {
  test(
    'workspace loader keeps library data and marks reconnect required on invalid desktop session',
    () async {
      final database = makeTestDatabase();
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

      final authRepository = FakeDriveAuthRepository(
        restoreSessionResult: null,
      );
      final runner = RecordingDriveScanRunner(
        database: database,
        authRepository: authRepository,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          driveAuthRepositoryProvider.overrideWithValue(authRepository),
          driveScanRunnerProvider.overrideWithValue(runner),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(driveWorkspaceProvider.future);

      expect(authRepository.restoreCallCount, 1);
      expect(state.hasLinkedAccount, isTrue);
      expect(state.canAccessDrive, isFalse);
      expect(state.requiresReconnect, isTrue);
      expect(state.authErrorMessage, driveAuthReconnectRequiredMessage);
      expect(state.roots, hasLength(1));
      expect(await database.countTracks(), 1);
      expect(runner.bootstrapCallCount, 0);

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
}

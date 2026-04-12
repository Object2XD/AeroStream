import 'package:aero_stream/core/providers/drive/drive_providers.dart';
import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_scan_backlog.dart';
import 'package:aero_stream/data/drive/metadata_pipeline_backlog.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/extraction/drive_artwork_extractor.dart';
import 'package:aero_stream/data/drive/extraction/drive_metadata_extractor.dart';
import 'package:aero_stream/data/drive/drive_artwork_service.dart';
import 'package:aero_stream/data/drive/drive_discovery_service.dart';
import 'package:aero_stream/data/drive/drive_metadata_catch_up_planner.dart';
import 'package:aero_stream/data/drive/drive_metadata_orchestrator.dart';
import 'package:aero_stream/data/drive/drive_scan_runner.dart';
import 'package:aero_stream/data/drive/drive_scan_execution_profile.dart';
import 'package:aero_stream/data/drive/drive_scan_job_lifecycle.dart';
import 'package:aero_stream/data/drive/drive_scan_job_enqueuer.dart';
import 'package:aero_stream/data/drive/drive_scan_logger.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_codec.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_executor.dart';
import 'package:aero_stream/data/drive/drive_scan_progress_refresher.dart';
import 'package:aero_stream/data/drive/drive_scan_root_binder.dart';
import 'package:aero_stream/data/drive/drive_scan_root_resolver.dart';
import 'package:aero_stream/data/drive/drive_track_cache_service.dart';
import 'package:aero_stream/data/drive/drive_track_projector.dart';
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
      final runner = _RecordingDriveScanRunner(
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

      final state = await container.read(googleDriveControllerProvider.future);

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
      final runner = _RecordingDriveScanRunner(
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
      expect(runner.enqueueCallCount, 0);
    },
  );

  test(
    'controller marks reconnect required when listFolders hits runtime auth expiry',
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

      final authRepository = _FakeDriveAuthRepository(
        restoreSessionResult: const DriveAccountProfile(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'oauth_desktop',
        ),
      );
      final runner = _RecordingDriveScanRunner(
        database: database,
        authRepository: authRepository,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          driveAuthRepositoryProvider.overrideWithValue(authRepository),
          driveHttpClientProvider.overrideWithValue(
            _ExpiredSessionDriveHttpClient(),
          ),
          driveScanRunnerProvider.overrideWithValue(runner),
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

      final state = container.read(googleDriveControllerProvider).value!;
      final account = (await database.getActiveAccount())!;
      expect(state.requiresReconnect, isTrue);
      expect(state.canAccessDrive, isFalse);
      expect(state.errorMessage, driveAuthReconnectRequiredMessage);
      expect(
        account.authSessionState,
        DriveAuthSessionState.reauthRequired.value,
      );
    },
  );

  test(
    'controller marks reconnect required when addRoot hits runtime auth expiry',
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
      await database.upsertRoot(
        SyncRootsCompanion.insert(
          accountId: account.id,
          folderId: 'existing-root',
          folderName: 'Existing Root',
          parentFolderId: const Value('parent-folder'),
        ),
      );

      final authRepository = _FakeDriveAuthRepository(
        restoreSessionResult: const DriveAccountProfile(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'oauth_desktop',
        ),
      );
      final runner = _RecordingDriveScanRunner(
        database: database,
        authRepository: authRepository,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          driveAuthRepositoryProvider.overrideWithValue(authRepository),
          driveHttpClientProvider.overrideWithValue(
            _ExpiredSessionDriveHttpClient(),
          ),
          driveScanRunnerProvider.overrideWithValue(runner),
        ],
      );
      addTearDown(container.dispose);

      await container.read(googleDriveControllerProvider.future);

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

      final state = container.read(googleDriveControllerProvider).value!;
      expect(state.requiresReconnect, isTrue);
      expect(state.errorMessage, driveAuthReconnectRequiredMessage);
    },
  );

  test(
    'controller keeps scan speed across cache-triggered reloads until stalled',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await database.setActiveAccount(
        SyncAccountsCompanion.insert(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'mock',
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
          phase: DriveScanPhase.metadataEnrichment.value,
          startedAt: Value(DateTime(2026, 4, 4, 13, 0, 0)),
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
          fileName: 'track-1.m4a',
          title: 'track-1',
          artist: '',
          album: '',
          albumArtist: '',
          genre: '',
          mimeType: 'audio/mp4',
          sizeBytes: const Value(8192),
        ),
      );
      final track = (await database.getTrackByDriveFileId('track-1'))!;

      final authRepository = _FakeDriveAuthRepository(
        restoreSessionResult: null,
      );
      final runner = _RecordingDriveScanRunner(
        database: database,
        authRepository: authRepository,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          driveAuthRepositoryProvider.overrideWithValue(authRepository),
          driveScanRunnerProvider.overrideWithValue(runner),
          scanSpeedTickIntervalProvider.overrideWithValue(
            const Duration(milliseconds: 10),
          ),
          scanSpeedRollingWindowProvider.overrideWithValue(
            const Duration(milliseconds: 80),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(googleDriveControllerProvider.future);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await database.updateScanJob(
        jobId,
        const ScanJobsCompanion(metadataReadyCount: Value(6)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 25));

      final afterProgress = container
          .read(googleDriveControllerProvider)
          .value!;
      expect(afterProgress.scanProgress, isNot(equals(null)));
      expect(afterProgress.scanProgress!.itemsPerSecond, greaterThan(0.0));

      await database.updateTrackCache(
        track.id,
        cachePathValue: 'cached-file',
        cacheStatusValue: 'cached',
      );
      await Future<void>.delayed(const Duration(milliseconds: 25));

      final afterCacheReload = container
          .read(googleDriveControllerProvider)
          .value!;
      expect(afterCacheReload.scanProgress, isNot(equals(null)));
      expect(afterCacheReload.scanProgress!.itemsPerSecond, greaterThan(0.0));

      await Future<void>.delayed(const Duration(milliseconds: 90));

      final stalled = container.read(googleDriveControllerProvider).value!;
      expect(stalled.scanProgress, isNot(equals(null)));
      expect(stalled.scanProgress!.itemsPerSecond, 0.0);
    },
  );

  test('controller patches pipeline backlog when scan tasks change', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.setActiveAccount(
      SyncAccountsCompanion.insert(
        providerAccountId: 'drive-account',
        email: 'listener@example.com',
        displayName: 'Listener',
        authKind: 'mock',
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
        phase: DriveScanPhase.metadataEnrichment.value,
      ),
    );

    await database.enqueueScanTasks([
      ScanTasksCompanion.insert(
        jobId: jobId,
        kind: DriveScanTaskKind.extractTags.value,
        dedupeKey: const Value('tags:1'),
        payloadJson: const Value('{}'),
      ),
      ScanTasksCompanion.insert(
        jobId: jobId,
        kind: DriveScanTaskKind.extractArtwork.value,
        dedupeKey: const Value('art:1'),
        payloadJson: const Value('{}'),
      ),
    ]);

    final authRepository = _FakeDriveAuthRepository(restoreSessionResult: null);
    final runner = _RecordingDriveScanRunner(
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

    final initial = await container.read(googleDriveControllerProvider.future);
    expect(initial.scanProgress, isNot(equals(null)));
    expect(
      initial.scanProgress!.pipelineBacklog,
      const ScanPipelineBacklog(
        metadata: ScanTaskBacklogEntry(queuedCount: 1),
        artwork: ScanTaskBacklogEntry(queuedCount: 1),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 25));
    final baselineState = container.read(googleDriveControllerProvider).value!;

    final task = (await database.takeQueuedScanTasks(
      jobId,
      kind: DriveScanTaskKind.extractTags.value,
      limit: 1,
    )).single;
    await Future<void>.delayed(const Duration(milliseconds: 25));

    final afterStart = container.read(googleDriveControllerProvider).value!;
    expect(
      afterStart.scanProgress!.pipelineBacklog,
      const ScanPipelineBacklog(
        metadata: ScanTaskBacklogEntry(runningCount: 1),
        artwork: ScanTaskBacklogEntry(queuedCount: 1),
      ),
    );
    expect(identical(afterStart.account, baselineState.account), isTrue);
    expect(identical(afterStart.roots, baselineState.roots), isTrue);

    await database.failScanTasks([task.id], error: 'boom');
    await Future<void>.delayed(const Duration(milliseconds: 25));

    final afterFail = container.read(googleDriveControllerProvider).value!;
    expect(
      afterFail.scanProgress!.pipelineBacklog,
      const ScanPipelineBacklog(
        metadata: ScanTaskBacklogEntry(failedCount: 1),
        artwork: ScanTaskBacklogEntry(queuedCount: 1),
      ),
    );
    expect(identical(afterFail.account, afterStart.account), isTrue);
    expect(identical(afterFail.roots, afterStart.roots), isTrue);
  });

  test('controller ignores runtime-only scan task updates', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.setActiveAccount(
      SyncAccountsCompanion.insert(
        providerAccountId: 'drive-account',
        email: 'listener@example.com',
        displayName: 'Listener',
        authKind: 'mock',
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
        phase: DriveScanPhase.metadataEnrichment.value,
      ),
    );

    await database.enqueueScanTasks([
      ScanTasksCompanion.insert(
        jobId: jobId,
        kind: DriveScanTaskKind.extractTags.value,
        dedupeKey: const Value('tags:1'),
        payloadJson: const Value('{}'),
      ),
    ]);

    final authRepository = _FakeDriveAuthRepository(restoreSessionResult: null);
    final runner = _RecordingDriveScanRunner(
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

    await container.read(googleDriveControllerProvider.future);
    final task = (await database.takeQueuedScanTasks(
      jobId,
      kind: DriveScanTaskKind.extractTags.value,
      limit: 1,
    )).single;
    await Future<void>.delayed(const Duration(milliseconds: 25));

    var updateCount = 0;
    final subscription = container.listen<AsyncValue<GoogleDriveState>>(
      googleDriveControllerProvider,
      (previousValue, nextValue) {
        updateCount += 1;
      },
      fireImmediately: false,
    );
    addTearDown(subscription.close);
    await Future<void>.delayed(const Duration(milliseconds: 25));
    final baselineUpdateCount = updateCount;
    final baselineState = container.read(googleDriveControllerProvider).value!;

    await database.updateScanTaskRuntimeState(
      task.id,
      runtimeStageValue: 'fetch_head',
      heartbeatAt: DateTime(2026, 4, 5, 12, 0, 0),
    );
    await Future<void>.delayed(const Duration(milliseconds: 25));

    final state = container.read(googleDriveControllerProvider).value!;
    expect(updateCount, baselineUpdateCount);
    expect(state.scanProgress, isNot(equals(null)));
    expect(
      state.scanProgress!.pipelineBacklog,
      const ScanPipelineBacklog(
        metadata: ScanTaskBacklogEntry(runningCount: 1),
      ),
    );
    expect(identical(state.account, baselineState.account), isTrue);
    expect(identical(state.roots, baselineState.roots), isTrue);
  });

  test(
    'controller patches metadata telemetry without rebuilding full state',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await database.setActiveAccount(
        SyncAccountsCompanion.insert(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'mock',
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
          phase: DriveScanPhase.metadataEnrichment.value,
        ),
      );

      final authRepository = _FakeDriveAuthRepository(
        restoreSessionResult: null,
      );
      final runner = _RecordingDriveScanRunner(
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
      addTearDown(() {
        MetadataPipelineTelemetryHub.instance.clearJob(jobId);
        container.dispose();
      });

      await container.read(googleDriveControllerProvider.future);
      await Future<void>.delayed(const Duration(milliseconds: 25));
      final baselineState = container
          .read(googleDriveControllerProvider)
          .value!;
      var updateCount = 0;
      final subscription = container.listen<AsyncValue<GoogleDriveState>>(
        googleDriveControllerProvider,
        (previousValue, nextValue) {
          updateCount += 1;
        },
        fireImmediately: false,
      );
      addTearDown(subscription.close);
      await Future<void>.delayed(const Duration(milliseconds: 25));
      final baselineUpdateCount = updateCount;

      MetadataPipelineTelemetryHub.instance.updateJob(
        jobId,
        const MetadataPipelineBacklog(
          fetchHead: MetadataPipelineStageBacklog(
            queuedCount: 2,
            runningCount: 1,
          ),
          analyzeHead: MetadataPipelineStageBacklog(runningCount: 1),
          fetch: MetadataPipelineStageBacklog(runningCount: 3),
          activeFormatBreakdown: MetadataPipelineFormatBreakdown(m4aRunning: 3),
        ),
        immediate: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 25));

      final state = container.read(googleDriveControllerProvider).value!;
      expect(state.scanProgress, isNot(equals(null)));
      expect(
        state.scanProgress!.metadataPipelineBacklog,
        const MetadataPipelineBacklog(
          fetchHead: MetadataPipelineStageBacklog(
            queuedCount: 2,
            runningCount: 1,
          ),
          analyzeHead: MetadataPipelineStageBacklog(runningCount: 1),
          fetch: MetadataPipelineStageBacklog(runningCount: 3),
          activeFormatBreakdown: MetadataPipelineFormatBreakdown(m4aRunning: 3),
        ),
      );
      expect(updateCount, baselineUpdateCount + 1);
      expect(identical(state.account, baselineState.account), isTrue);
      expect(identical(state.roots, baselineState.roots), isTrue);
    },
  );

  test('scan speed tracker reports a rolling 30-second average', () {
    var now = DateTime(2026, 4, 4, 12, 0, 0);
    final tracker = ScanSpeedTracker(
      now: () => now,
      rollingWindow: const Duration(seconds: 30),
    );

    tracker.observe(
      _buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.running.value,
        indexedCount: 120,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 10));
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 1));
    tracker.observe(
      _buildScanJob(
        phase: DriveScanPhase.metadataEnrichment.value,
        state: DriveScanJobState.running.value,
        metadataReadyCount: 50,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 5));
    tracker.observe(
      _buildScanJob(
        phase: DriveScanPhase.metadataEnrichment.value,
        state: DriveScanJobState.running.value,
        metadataReadyCount: 90,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), closeTo(8, 0.001));

    now = now.add(const Duration(seconds: 1));
    tracker.sampleNow();
    expect(tracker.currentRate(), closeTo(40 * 1000 / 6000, 0.001));

    now = now.add(const Duration(seconds: 24));
    tracker.sampleNow();
    expect(tracker.currentRate(), closeTo(40 * 1000 / 30000, 0.001));

    now = now.add(const Duration(seconds: 1));
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 1));
    tracker.observe(
      _buildScanJob(
        phase: DriveScanPhase.artworkEnrichment.value,
        state: DriveScanJobState.running.value,
        artworkReadyCount: 12,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 1));
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 4));
    tracker.observe(
      _buildScanJob(
        phase: DriveScanPhase.artworkEnrichment.value,
        state: DriveScanJobState.running.value,
        artworkReadyCount: 28,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), closeTo(16 * 1000 / 5000, 0.001));
  });

  test('scan speed tracker resets after pause and resume', () {
    var now = DateTime(2026, 4, 4, 13, 0, 0);
    final tracker = ScanSpeedTracker(
      now: () => now,
      rollingWindow: const Duration(seconds: 30),
    );

    tracker.observe(
      _buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.running.value,
        indexedCount: 100,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 10));
    tracker.observe(
      _buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.running.value,
        indexedCount: 100,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    tracker.observe(
      _buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.paused.value,
        indexedCount: 100,
      ),
    );
    expect(tracker.currentRate(), equals(null));

    now = now.add(const Duration(seconds: 5));
    tracker.observe(
      _buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.running.value,
        indexedCount: 100,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 4));
    tracker.observe(
      _buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.running.value,
        indexedCount: 140,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), closeTo(10, 0.001));
  });
}

ScanJob _buildScanJob({
  int id = 42,
  int accountId = 1,
  int? rootId,
  String kind = 'baseline',
  required String state,
  required String phase,
  DateTime? startedAt,
  int indexedCount = 0,
  int metadataReadyCount = 0,
  int artworkReadyCount = 0,
  int failedCount = 0,
}) {
  return ScanJob(
    id: id,
    accountId: accountId,
    rootId: rootId,
    kind: kind,
    state: state,
    phase: phase,
    checkpointToken: null,
    startPageToken: null,
    indexedCount: indexedCount,
    metadataReadyCount: metadataReadyCount,
    artworkReadyCount: artworkReadyCount,
    failedCount: failedCount,
    lastError: null,
    createdAt: startedAt ?? DateTime(2026, 4, 4, 0, 0, 0),
    startedAt: startedAt,
    finishedAt: null,
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

class _PassiveDriveAuthRepository implements DriveAuthRepository {
  @override
  bool get isConfigured => true;

  @override
  String? get configurationMessage => null;

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

class _ExpiredSessionDriveHttpClient extends DriveHttpClient {
  _ExpiredSessionDriveHttpClient()
    : super(authRepository: _PassiveDriveAuthRepository());

  @override
  Future<List<DriveFolderEntry>> listFolders({String parentId = 'root'}) async {
    throw const DriveAuthSessionExpiredException();
  }

  @override
  Future<Map<String, dynamic>> getFolderMetadata(String folderId) async {
    throw const DriveAuthSessionExpiredException();
  }
}

class _RecordingDriveScanRunner extends DriveScanRunner {
  // ignore: use_super_parameters
  _RecordingDriveScanRunner({
    required AppDatabase database,
    required DriveAuthRepository authRepository,
  }) : this._internal(
         database: database,
         graph: _buildRunnerGraph(database, authRepository),
       );

  _RecordingDriveScanRunner._internal({
    required AppDatabase database,
    required _RunnerGraph graph,
  }) : super(
         database: database,
         jobEnqueuer: graph.jobEnqueuer,
         catchUpPlanner: graph.catchUpPlanner,
         jobLifecycle: graph.jobLifecycle,
         phaseExecutor: graph.phaseExecutor,
         logger: const NoOpDriveScanLogger(),
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

class _RunnerGraph {
  const _RunnerGraph({
    required this.jobEnqueuer,
    required this.catchUpPlanner,
    required this.jobLifecycle,
    required this.phaseExecutor,
  });

  final DriveScanJobEnqueuer jobEnqueuer;
  final DriveMetadataCatchUpPlanner catchUpPlanner;
  final DriveScanJobLifecycle jobLifecycle;
  final DriveScanPhaseExecutor phaseExecutor;
}

_RunnerGraph _buildRunnerGraph(
  AppDatabase database,
  DriveAuthRepository authRepository,
) {
  const logger = NoOpDriveScanLogger();
  const executionProfile = DriveScanExecutionProfile(
    changeWorkers: 1,
    discoveryWorkers: 1,
    metadataWorkers: 1,
    artworkWorkers: 1,
    artworkWorkersWhileMetadataPending: 0,
    metadataHighWatermark: 0,
    pageSize: 1000,
    trackProjectionBatchSize: 100,
  );
  final httpClient = DriveHttpClient(authRepository: authRepository);
  final trackCacheService = DriveTrackCacheService(
    database: database,
    driveHttpClient: httpClient,
  );
  final phaseCodec = const DriveScanPhaseCodec();
  final rootResolver = DriveScanRootResolver(database: database);
  final rootBinder = DriveScanRootBinder(
    database: database,
    phaseCodec: phaseCodec,
  );
  final catchUpPlanner = DriveMetadataCatchUpPlanner(
    database: database,
    rootResolver: rootResolver,
    rootBinder: rootBinder,
    logger: logger,
  );
  final jobEnqueuer = DriveScanJobEnqueuer(
    database: database,
    rootResolver: rootResolver,
    rootBinder: rootBinder,
    catchUpPlanner: catchUpPlanner,
    logger: logger,
  );
  final progressRefresher = DriveScanProgressRefresher(
    database: database,
    rootResolver: rootResolver,
    logger: logger,
  );
  final metadataOrchestrator = DriveMetadataOrchestrator(
    database: database,
    metadataExtractor: DriveMetadataExtractor(driveHttpClient: httpClient),
    executionProfile: executionProfile,
    progressRefresher: progressRefresher,
    logger: logger,
  );
  final artworkService = DriveArtworkService(
    database: database,
    artworkExtractor: DriveArtworkExtractor(driveHttpClient: httpClient),
    trackCacheService: trackCacheService,
    logger: logger,
  );
  final jobLifecycle = DriveScanJobLifecycle(
    database: database,
    driveHttpClient: httpClient,
    rootResolver: rootResolver,
    metadataOrchestrator: metadataOrchestrator,
    progressRefresher: progressRefresher,
    artworkService: artworkService,
    logger: logger,
  );
  final phaseExecutor = DriveScanPhaseExecutor(
    database: database,
    phaseCodec: phaseCodec,
    discoveryService: DriveDiscoveryService(
      database: database,
      driveHttpClient: httpClient,
      trackProjector: DriveTrackProjector(
        database: database,
        trackCacheService: trackCacheService,
      ),
      trackCacheService: trackCacheService,
      executionProfile: executionProfile,
      metadataCatchUpPlanner: catchUpPlanner,
      logger: logger,
    ),
    metadataOrchestrator: metadataOrchestrator,
    artworkService: artworkService,
    jobLifecycle: jobLifecycle,
    progressRefresher: progressRefresher,
    executionProfile: executionProfile,
    logger: logger,
  );
  return _RunnerGraph(
    jobEnqueuer: jobEnqueuer,
    catchUpPlanner: catchUpPlanner,
    jobLifecycle: jobLifecycle,
    phaseExecutor: phaseExecutor,
  );
}

import 'package:aero_stream/core/providers/drive/drive_providers.dart';
import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_scan_backlog.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/metadata_pipeline_backlog.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../support/drive_test_helpers.dart';

void main() {
  test(
    'workspace runtime binder keeps scan speed across cache-triggered reloads until stalled',
    () async {
      final database = makeTestDatabase();
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
          scanSpeedTickIntervalProvider.overrideWithValue(
            const Duration(milliseconds: 10),
          ),
          scanSpeedRollingWindowProvider.overrideWithValue(
            const Duration(milliseconds: 80),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(driveWorkspaceProvider.future);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await database.updateScanJob(
        jobId,
        const ScanJobsCompanion(metadataReadyCount: Value(6)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 25));

      final afterProgress = container.read(driveWorkspaceProvider).value!;
      expect(afterProgress.syncProgress, isNot(equals(null)));
      expect(afterProgress.syncProgress!.itemsPerSecond, greaterThan(0.0));

      await database.updateTrackCache(
        track.id,
        cachePathValue: 'cached-file',
        cacheStatusValue: 'cached',
      );
      await Future<void>.delayed(const Duration(milliseconds: 25));

      final afterCacheReload = container.read(driveWorkspaceProvider).value!;
      expect(afterCacheReload.syncProgress, isNot(equals(null)));
      expect(afterCacheReload.syncProgress!.itemsPerSecond, greaterThan(0.0));

      await Future<void>.delayed(const Duration(milliseconds: 90));

      final stalled = container.read(driveWorkspaceProvider).value!;
      expect(stalled.syncProgress, isNot(equals(null)));
      expect(stalled.syncProgress!.itemsPerSecond, 0.0);
    },
  );

  test(
    'workspace runtime binder patches pipeline backlog when scan tasks change',
    () async {
      final database = makeTestDatabase();
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

      final initial = await container.read(driveWorkspaceProvider.future);
      expect(initial.syncProgress, isNot(equals(null)));
      expect(
        initial.syncProgress!.pipelineBacklog,
        const ScanPipelineBacklog(
          metadata: ScanTaskBacklogEntry(queuedCount: 1),
          artwork: ScanTaskBacklogEntry(queuedCount: 1),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 25));
      final baselineState = container.read(driveWorkspaceProvider).value!;

      final task = (await database.takeQueuedScanTasks(
        jobId,
        kind: DriveScanTaskKind.extractTags.value,
        limit: 1,
      )).single;
      await Future<void>.delayed(const Duration(milliseconds: 25));

      final afterStart = container.read(driveWorkspaceProvider).value!;
      expect(
        afterStart.syncProgress!.pipelineBacklog,
        const ScanPipelineBacklog(
          metadata: ScanTaskBacklogEntry(runningCount: 1),
          artwork: ScanTaskBacklogEntry(queuedCount: 1),
        ),
      );
      expect(identical(afterStart.account, baselineState.account), isTrue);
      expect(identical(afterStart.roots, baselineState.roots), isTrue);

      await database.failScanTasks([task.id], error: 'boom');
      await Future<void>.delayed(const Duration(milliseconds: 25));

      final afterFail = container.read(driveWorkspaceProvider).value!;
      expect(
        afterFail.syncProgress!.pipelineBacklog,
        const ScanPipelineBacklog(
          metadata: ScanTaskBacklogEntry(failedCount: 1),
          artwork: ScanTaskBacklogEntry(queuedCount: 1),
        ),
      );
      expect(identical(afterFail.account, afterStart.account), isTrue);
      expect(identical(afterFail.roots, afterStart.roots), isTrue);
    },
  );

  test(
    'workspace runtime binder ignores runtime-only scan task updates',
    () async {
      final database = makeTestDatabase();
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

      await container.read(driveWorkspaceProvider.future);
      final task = (await database.takeQueuedScanTasks(
        jobId,
        kind: DriveScanTaskKind.extractTags.value,
        limit: 1,
      )).single;
      await Future<void>.delayed(const Duration(milliseconds: 25));

      var updateCount = 0;
      final subscription = container.listen<AsyncValue<DriveWorkspaceState>>(
        driveWorkspaceProvider,
        (previousValue, nextValue) {
          updateCount += 1;
        },
        fireImmediately: false,
      );
      addTearDown(subscription.close);
      await Future<void>.delayed(const Duration(milliseconds: 25));
      final baselineUpdateCount = updateCount;
      final baselineState = container.read(driveWorkspaceProvider).value!;

      await database.updateScanTaskRuntimeState(
        task.id,
        runtimeStageValue: 'fetch_head',
        heartbeatAt: DateTime(2026, 4, 5, 12, 0, 0),
      );
      await Future<void>.delayed(const Duration(milliseconds: 25));

      final state = container.read(driveWorkspaceProvider).value!;
      expect(updateCount, baselineUpdateCount);
      expect(state.syncProgress, isNot(equals(null)));
      expect(
        state.syncProgress!.pipelineBacklog,
        const ScanPipelineBacklog(
          metadata: ScanTaskBacklogEntry(runningCount: 1),
        ),
      );
      expect(identical(state.account, baselineState.account), isTrue);
      expect(identical(state.roots, baselineState.roots), isTrue);
    },
  );

  test(
    'workspace runtime binder patches metadata telemetry without rebuilding full state',
    () async {
      final database = makeTestDatabase();
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
      addTearDown(() {
        MetadataPipelineTelemetryHub.instance.clearJob(jobId);
        container.dispose();
      });

      await container.read(driveWorkspaceProvider.future);
      await Future<void>.delayed(const Duration(milliseconds: 25));
      final baselineState = container.read(driveWorkspaceProvider).value!;
      var updateCount = 0;
      final subscription = container.listen<AsyncValue<DriveWorkspaceState>>(
        driveWorkspaceProvider,
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

      final state = container.read(driveWorkspaceProvider).value!;
      expect(state.syncProgress, isNot(equals(null)));
      expect(
        state.syncProgress!.metadataPipelineBacklog,
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
      buildScanJob(
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
      buildScanJob(
        phase: DriveScanPhase.metadataEnrichment.value,
        state: DriveScanJobState.running.value,
        metadataReadyCount: 50,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 5));
    tracker.observe(
      buildScanJob(
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
      buildScanJob(
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
      buildScanJob(
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
      buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.running.value,
        indexedCount: 100,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 10));
    tracker.observe(
      buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.running.value,
        indexedCount: 100,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    tracker.observe(
      buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.paused.value,
        indexedCount: 100,
      ),
    );
    expect(tracker.currentRate(), equals(null));

    now = now.add(const Duration(seconds: 5));
    tracker.observe(
      buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.running.value,
        indexedCount: 100,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), equals(0.0));

    now = now.add(const Duration(seconds: 4));
    tracker.observe(
      buildScanJob(
        phase: DriveScanPhase.baselineDiscovery.value,
        state: DriveScanJobState.running.value,
        indexedCount: 140,
      ),
    );
    tracker.sampleNow();
    expect(tracker.currentRate(), closeTo(10, 0.001));
  });
}

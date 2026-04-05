import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_scan_backlog.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'watchScanPipelineBacklog ignores runtime-stage-only task updates',
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

      await database.enqueueScanTasks([
        ScanTasksCompanion.insert(
          jobId: jobId,
          kind: DriveScanTaskKind.extractTags.value,
          dedupeKey: const Value('tags:1'),
          payloadJson: const Value('{}'),
        ),
      ]);

      final events = <ScanPipelineBacklog>[];
      final subscription = database
          .watchScanPipelineBacklog(jobId)
          .listen(events.add);
      addTearDown(subscription.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 25));
      expect(events, [
        const ScanPipelineBacklog(
          metadata: ScanTaskBacklogEntry(queuedCount: 1),
        ),
      ]);
      events.clear();

      final task = (await database.takeQueuedScanTasks(
        jobId,
        kind: DriveScanTaskKind.extractTags.value,
        limit: 1,
      )).single;
      await Future<void>.delayed(const Duration(milliseconds: 25));
      expect(events, [
        const ScanPipelineBacklog(
          metadata: ScanTaskBacklogEntry(runningCount: 1),
        ),
      ]);
      events.clear();

      await database.updateScanTaskRuntimeState(
        task.id,
        runtimeStageValue: 'fetch_head',
        heartbeatAt: DateTime(2026, 4, 5, 12, 0, 0),
      );
      await Future<void>.delayed(const Duration(milliseconds: 25));
      expect(events, isEmpty);
    },
  );
}

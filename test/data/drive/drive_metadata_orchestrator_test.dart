import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/drive_metadata_orchestrator.dart';
import 'package:aero_stream/data/drive/drive_scan_execution_profile.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_scan_progress_refresher.dart';
import 'package:aero_stream/data/drive/drive_scan_root_resolver.dart';
import 'package:aero_stream/data/drive/extraction/drive_metadata_extractor.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'test_drive_scan_logger.dart';

void main() {
  late AppDatabase database;
  late RecordingDriveScanLogger logger;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    logger = RecordingDriveScanLogger();
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'recoverMetadataTasks requeues stale running work and logs reclaim',
    () async {
      final rootResolver = DriveScanRootResolver(database: database);
      final orchestrator = DriveMetadataOrchestrator(
        database: database,
        metadataExtractor: DriveMetadataExtractor(
          driveHttpClient: DriveHttpClient(
            authRepository: _StubAuthRepository(),
          ),
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
          metadataTaskLeaseTimeout: Duration(milliseconds: 100),
        ),
        progressRefresher: DriveScanProgressRefresher(
          database: database,
          rootResolver: rootResolver,
          logger: logger,
        ),
        logger: logger,
      );
      final accountId = await _seedAccount(database);
      final jobId = await database.createScanJob(
        ScanJobsCompanion.insert(
          accountId: accountId,
          kind: DriveScanJobKind.incremental.value,
          state: DriveScanJobState.running.value,
          phase: DriveScanPhase.metadataEnrichment.value,
        ),
      );
      final staleAt = DateTime.now().subtract(const Duration(seconds: 1));
      await database.enqueueScanTasks([
        ScanTasksCompanion.insert(
          jobId: jobId,
          kind: DriveScanTaskKind.extractTags.value,
          targetDriveId: const Value('track-stale'),
          dedupeKey: const Value('tags:track-stale'),
          payloadJson: const Value('{}'),
          priority: const Value(20),
        ),
      ]);
      final taskId = await database
          .customSelect(
            'SELECT id FROM scan_tasks WHERE job_id = ?',
            variables: [Variable.withInt(jobId)],
            readsFrom: {database.scanTasks},
          )
          .getSingle()
          .then((row) => row.read<int>('id'));
      await database.customUpdate(
        '''
      UPDATE scan_tasks
      SET state = ?, runtime_stage = ?, locked_at = ?, updated_at = ?
      WHERE id = ?
      ''',
        variables: [
          Variable.withString(DriveScanTaskState.running.value),
          Variable.withString(DriveMetadataTaskRuntimeStage.plan.value),
          Variable.withDateTime(staleAt),
          Variable.withDateTime(staleAt),
          Variable.withInt(taskId),
        ],
        updates: {database.scanTasks},
      );

      final job = (await database.getScanJobById(jobId))!;
      await orchestrator.recoverMetadataTasks(job, reason: 'test');

      final task = await database
          .customSelect(
            'SELECT state, runtime_stage FROM scan_tasks WHERE id = ?',
            variables: [Variable.withInt(taskId)],
            readsFrom: {database.scanTasks},
          )
          .getSingle();
      expect(task.read<String>('state'), DriveScanTaskState.queued.value);
      expect(task.read<String?>('runtime_stage'), isNull);
      expect(logger.containsOperation('metadata_stale_task_reclaimed'), isTrue);
    },
  );
}

Future<int> _seedAccount(AppDatabase database) async {
  await database.setActiveAccount(
    SyncAccountsCompanion.insert(
      providerAccountId: 'account-1',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: 'oauth_desktop',
      connectedAt: DateTime(2026, 4, 1),
    ),
  );
  return (await database.getActiveAccount())!.id;
}

class _StubAuthRepository implements DriveAuthRepository {
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

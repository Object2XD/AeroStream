import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'drive_auth_repository.dart';
import 'drive_entities.dart';
import 'drive_http_client.dart';
import 'drive_metadata_catch_up_planner.dart';
import 'drive_scan_logger.dart';
import 'drive_scan_models.dart';
import 'drive_scan_root_binder.dart';
import 'drive_scan_root_resolver.dart';

class DriveScanJobEnqueuer {
  DriveScanJobEnqueuer({
    required AppDatabase database,
    required DriveScanRootResolver rootResolver,
    required DriveScanRootBinder rootBinder,
    required DriveMetadataCatchUpPlanner catchUpPlanner,
    required DriveScanLogger logger,
  }) : _database = database,
       _rootResolver = rootResolver,
       _rootBinder = rootBinder,
       _catchUpPlanner = catchUpPlanner,
       _logger = logger;

  final AppDatabase _database;
  final DriveScanRootResolver _rootResolver;
  final DriveScanRootBinder _rootBinder;
  final DriveMetadataCatchUpPlanner _catchUpPlanner;
  final DriveScanLogger _logger;

  Future<int?> enqueueSync({
    int? rootId,
    required bool autoRun,
    required void Function() ensureRunner,
  }) async {
    final account = await _database.getActiveAccount();
    if (account == null) {
      _logWarning(
        'job_enqueue_blocked',
        message: 'Google Drive is not connected.',
      );
      throw const DriveAuthException('Connect Google Drive first.');
    }
    if (account.authSessionState ==
        DriveAuthSessionState.reauthRequired.value) {
      _logWarning(
        'job_enqueue_blocked',
        details: <String, Object?>{
          'accountId': account.id,
          'reason': 'reauth_required',
        },
        message: driveAuthReconnectRequiredMessage,
      );
      throw const DriveAuthException(driveAuthReconnectRequiredMessage);
    }

    final existingJob = await _database.getLatestActiveScanJob(
      accountId: account.id,
    );
    if (existingJob != null) {
      final catchUpPlan = await _catchUpPlanner.enqueueMetadataCatchUpTasks(
        jobId: existingJob.id,
        accountId: account.id,
        mergedIntoExistingJob: true,
      );
      if (!catchUpPlan.isEmpty) {
        await _rootBinder.attachRootsToJob(
          existingJob.id,
          catchUpPlan.affectedRootIds,
          syncStateValue: existingJob.state == DriveScanJobState.running.value
              ? DriveScanJobState.running.value
              : DriveScanJobState.queued.value,
        );
        await _rootBinder.rewindJobToMetadataEnrichmentIfNeeded(existingJob);
        if (autoRun && existingJob.state != DriveScanJobState.paused.value) {
          ensureRunner();
        }
      }
      _logInfo(
        'job_enqueue_reused',
        context: _jobContext(existingJob),
        details: <String, Object?>{
          'requestedRootId': rootId,
          'metadataCatchUpTaskCount': catchUpPlan.tasks.length,
        },
      );
      return existingJob.id;
    }

    final roots = await _rootResolver.resolveRootsForEnqueue(
      account.id,
      rootId: rootId,
    );
    if (roots.isEmpty) {
      _logWarning(
        'job_enqueue_skipped',
        details: <String, Object?>{
          'accountId': account.id,
          'requestedRootId': rootId,
          'reason': 'no_roots',
        },
      );
      return null;
    }

    final shouldRunBaseline = this.shouldRunBaseline(account, roots);
    final jobId = await _database.createScanJob(
      ScanJobsCompanion.insert(
        accountId: account.id,
        rootId: Value(rootId),
        kind: shouldRunBaseline
            ? DriveScanJobKind.baseline.value
            : DriveScanJobKind.incremental.value,
        state: DriveScanJobState.queued.value,
        phase: shouldRunBaseline
            ? DriveScanPhase.baselineDiscovery.value
            : DriveScanPhase.incrementalChanges.value,
        checkpointToken: shouldRunBaseline
            ? const Value.absent()
            : Value(
                account.driveChangePageToken ?? account.driveStartPageToken,
              ),
        startPageToken: shouldRunBaseline
            ? const Value.absent()
            : Value(account.driveStartPageToken),
      ),
    );

    if (shouldRunBaseline) {
      await enqueueBaselineTasks(jobId, roots);
    } else {
      final pageToken =
          account.driveChangePageToken ?? account.driveStartPageToken;
      if (pageToken == null || pageToken.isEmpty) {
        await _database.updateScanJob(
          jobId,
          ScanJobsCompanion(
            kind: Value(DriveScanJobKind.baseline.value),
            phase: Value(DriveScanPhase.baselineDiscovery.value),
            checkpointToken: const Value(null),
          ),
        );
        await enqueueBaselineTasks(jobId, roots);
      } else {
        await _database.enqueueScanTasks([
          ScanTasksCompanion.insert(
            jobId: jobId,
            kind: DriveScanTaskKind.reconcileChange.value,
            dedupeKey: Value('changes:$pageToken'),
            payloadJson: Value(
              jsonEncode(<String, Object?>{'pageToken': pageToken}),
            ),
            priority: const Value(100),
          ),
        ]);
      }
    }

    final catchUpPlan = await _catchUpPlanner.enqueueMetadataCatchUpTasks(
      jobId: jobId,
      accountId: account.id,
    );

    await _rootBinder.attachRootsToJob(jobId, <int>{
      ...roots.map((root) => root.id),
      ...catchUpPlan.affectedRootIds,
    }, syncStateValue: DriveScanJobState.queued.value);

    if (autoRun) {
      ensureRunner();
    }
    _logInfo(
      'job_enqueue',
      context: DriveScanLogContext(
        jobId: jobId,
        rootId: rootId,
        phase: shouldRunBaseline
            ? DriveScanPhase.baselineDiscovery.value
            : DriveScanPhase.incrementalChanges.value,
      ),
      details: <String, Object?>{
        'rootCount': roots.length,
        'requestedRootId': rootId,
        'metadataCatchUpTaskCount': catchUpPlan.tasks.length,
        'kind': shouldRunBaseline
            ? DriveScanJobKind.baseline.value
            : DriveScanJobKind.incremental.value,
      },
    );
    return jobId;
  }

  bool shouldRunBaseline(SyncAccount account, List<SyncRoot> roots) {
    if (account.driveStartPageToken == null ||
        account.driveStartPageToken!.isEmpty) {
      return true;
    }
    return roots.any((root) => root.lastSyncedAt == null);
  }

  Future<void> enqueueBaselineTasks(int jobId, List<SyncRoot> roots) async {
    final tasks = <ScanTasksCompanion>[];
    for (final root in roots) {
      await _upsertFolderObject(
        folderId: root.folderId,
        folderName: root.folderName,
        parentDriveId: root.parentFolderId,
        rootId: root.id,
        jobId: jobId,
      );
      tasks.add(
        ScanTasksCompanion.insert(
          jobId: jobId,
          kind: DriveScanTaskKind.discoverFolder.value,
          rootId: Value(root.id),
          targetDriveId: Value(root.folderId),
          dedupeKey: Value('discover:${root.id}:${root.folderId}:'),
          payloadJson: const Value('{}'),
          priority: const Value(100),
        ),
      );
    }
    await _database.enqueueScanTasks(tasks);
  }

  Future<void> _upsertFolderObject({
    required String folderId,
    required int rootId,
    required int jobId,
    String? folderName,
    String? parentDriveId,
  }) async {
    await _database.upsertDriveObject(
      DriveObjectsCompanion.insert(
        driveId: folderId,
        parentDriveId: Value(parentDriveId),
        name: folderName ?? 'Folder',
        mimeType: DriveHttpClient.folderMimeType,
        objectKind: DriveObjectKind.folder.value,
        rootIdsJson: Value(_encodeRootIds(rootId)),
        isTombstoned: const Value(false),
        lastSeenJobId: Value(jobId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  String _encodeRootIds(int? rootId) {
    return jsonEncode(rootId == null ? const <int>[] : <int>[rootId]);
  }

  void _logInfo(
    String operation, {
    DriveScanLogContext context = const DriveScanLogContext(),
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    _logger.info(
      prefix: 'DriveScan',
      subsystem: 'orchestration',
      operation: operation,
      context: context,
      message: message,
      details: details,
    );
  }

  void _logWarning(
    String operation, {
    DriveScanLogContext context = const DriveScanLogContext(),
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    _logger.warning(
      prefix: 'DriveScan',
      subsystem: 'orchestration',
      operation: operation,
      context: context,
      message: message,
      details: details,
    );
  }

  DriveScanLogContext _jobContext(
    ScanJob job, {
    int? rootId,
    int? taskId,
    String? phase,
    String? driveFileId,
    int? elapsedMs,
  }) {
    return DriveScanLogContext(
      jobId: job.id,
      rootId: rootId ?? job.rootId,
      taskId: taskId,
      phase: phase ?? job.phase,
      driveFileId: driveFileId,
      elapsedMs: elapsedMs,
    );
  }
}

import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'drive_scan_defaults.dart';
import 'drive_scan_logger.dart';
import 'drive_scan_models.dart';
import 'drive_scan_root_binder.dart';
import 'drive_scan_root_resolver.dart';

class DriveMetadataCatchUpPlan {
  const DriveMetadataCatchUpPlan({
    required this.tasks,
    required this.affectedRootIds,
    required this.pendingOrStaleCount,
    required this.schemaRepairCount,
  });

  final List<ScanTasksCompanion> tasks;
  final Set<int> affectedRootIds;
  final int pendingOrStaleCount;
  final int schemaRepairCount;

  bool get isEmpty => tasks.isEmpty;
}

class DriveMetadataCatchUpPlanner {
  DriveMetadataCatchUpPlanner({
    required AppDatabase database,
    required DriveScanRootResolver rootResolver,
    required DriveScanRootBinder rootBinder,
    required DriveScanLogger logger,
  }) : _database = database,
       _rootResolver = rootResolver,
       _rootBinder = rootBinder,
       _logger = logger;

  final AppDatabase _database;
  final DriveScanRootResolver _rootResolver;
  final DriveScanRootBinder _rootBinder;
  final DriveScanLogger _logger;

  Future<int?> enqueueMetadataCatchUpJobIfNeeded(
    SyncAccount account, {
    required bool autoRun,
    required void Function() ensureRunner,
  }) async {
    final catchUpTracks = await _database.getTracksNeedingMetadataCatchUp(
      accountId: account.id,
      metadataSchemaVersionBelow: currentTrackMetadataSchemaVersion,
    );
    if (catchUpTracks.isEmpty) {
      return null;
    }

    final affectedRootIds = catchUpTracks.map((track) => track.rootId).toSet();
    final roots = await _rootResolver.resolveRootsForEnqueue(account.id);
    final affectedRoots = roots
        .where((root) => affectedRootIds.contains(root.id))
        .toList(growable: false);
    if (affectedRoots.isEmpty) {
      return null;
    }

    final jobId = await _database.createScanJob(
      ScanJobsCompanion.insert(
        accountId: account.id,
        kind: DriveScanJobKind.incremental.value,
        state: DriveScanJobState.queued.value,
        phase: DriveScanPhase.metadataEnrichment.value,
        checkpointToken: Value(
          account.driveChangePageToken ?? account.driveStartPageToken,
        ),
        startPageToken: Value(account.driveStartPageToken),
      ),
    );
    final catchUpPlan = buildMetadataCatchUpPlan(
      jobId: jobId,
      tracks: catchUpTracks,
    );
    await _database.enqueueScanTasks(catchUpPlan.tasks);
    await _rootBinder.attachRootsToJob(
      jobId,
      catchUpPlan.affectedRootIds,
      syncStateValue: DriveScanJobState.queued.value,
    );
    if (autoRun) {
      ensureRunner();
    }
    _logInfo(
      'metadata_catchup_job_enqueue',
      context: DriveScanLogContext(
        jobId: jobId,
        phase: DriveScanPhase.metadataEnrichment.value,
      ),
      details: <String, Object?>{
        'taskCount': catchUpPlan.tasks.length,
        'pendingOrStaleCount': catchUpPlan.pendingOrStaleCount,
        'schemaRepairCount': catchUpPlan.schemaRepairCount,
        'affectedRootCount': affectedRoots.length,
      },
    );
    return jobId;
  }

  Future<DriveMetadataCatchUpPlan> enqueueMetadataCatchUpTasks({
    required int jobId,
    required int accountId,
    bool mergedIntoExistingJob = false,
  }) async {
    final catchUpTracks = await _database.getTracksNeedingMetadataCatchUp(
      accountId: accountId,
      metadataSchemaVersionBelow: currentTrackMetadataSchemaVersion,
    );
    if (catchUpTracks.isEmpty) {
      return const DriveMetadataCatchUpPlan(
        tasks: <ScanTasksCompanion>[],
        affectedRootIds: <int>{},
        pendingOrStaleCount: 0,
        schemaRepairCount: 0,
      );
    }

    final catchUpPlan = buildMetadataCatchUpPlan(
      jobId: jobId,
      tracks: catchUpTracks,
    );
    await _database.enqueueScanTasks(catchUpPlan.tasks);
    _logInfo(
      mergedIntoExistingJob
          ? 'metadata_catchup_tasks_merged'
          : 'metadata_catchup_tasks_enqueue',
      context: DriveScanLogContext(jobId: jobId),
      details: <String, Object?>{
        'taskCount': catchUpPlan.tasks.length,
        'pendingOrStaleCount': catchUpPlan.pendingOrStaleCount,
        'schemaRepairCount': catchUpPlan.schemaRepairCount,
        'affectedRootCount': catchUpPlan.affectedRootIds.length,
      },
    );
    return catchUpPlan;
  }

  DriveMetadataCatchUpPlan buildMetadataCatchUpPlan({
    required int jobId,
    required List<Track> tracks,
  }) {
    final tasks = <ScanTasksCompanion>[];
    final affectedRootIds = <int>{};
    var pendingOrStaleCount = 0;
    var schemaRepairCount = 0;

    for (final track in tracks) {
      affectedRootIds.add(track.rootId);
      final needsSchemaRepair =
          track.metadataStatus == TrackMetadataStatus.ready.value &&
          track.metadataSchemaVersion < currentTrackMetadataSchemaVersion;
      if (needsSchemaRepair) {
        schemaRepairCount += 1;
      } else {
        pendingOrStaleCount += 1;
      }
      tasks.add(
        buildExtractTagsTask(
          jobId: jobId,
          rootId: track.rootId,
          driveFileId: track.driveFileId,
          fingerprint: track.contentFingerprint ?? '',
          repairSchemaVersion: needsSchemaRepair
              ? currentTrackMetadataSchemaVersion
              : null,
        ),
      );
    }

    return DriveMetadataCatchUpPlan(
      tasks: tasks,
      affectedRootIds: affectedRootIds,
      pendingOrStaleCount: pendingOrStaleCount,
      schemaRepairCount: schemaRepairCount,
    );
  }

  ScanTasksCompanion buildExtractTagsTask({
    required int jobId,
    required int rootId,
    required String driveFileId,
    required String fingerprint,
    int? repairSchemaVersion,
  }) {
    final repairPayload = repairSchemaVersion == null
        ? null
        : <String, Object?>{'repairSchemaVersion': repairSchemaVersion};
    return ScanTasksCompanion.insert(
      jobId: jobId,
      kind: DriveScanTaskKind.extractTags.value,
      rootId: Value(rootId),
      targetDriveId: Value(driveFileId),
      dedupeKey: Value(
        repairSchemaVersion == null
            ? 'tags:$driveFileId:$fingerprint'
            : 'tag-repair:v$repairSchemaVersion:$driveFileId',
      ),
      payloadJson: Value(jsonEncode(<String, Object?>{...?repairPayload})),
      priority: Value(
        repairSchemaVersion == null
            ? driveExtractTagsTaskPriority
            : driveExtractTagsRepairTaskPriority,
      ),
    );
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
}

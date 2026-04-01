import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'drive_artwork_extractor.dart';
import 'drive_auth_repository.dart';
import 'drive_entities.dart';
import 'drive_http_client.dart';
import 'drive_metadata_extractor.dart';
import 'drive_scan_execution_profile.dart';
import 'drive_scan_logger.dart';
import 'drive_scan_models.dart';
import 'drive_track_cache_service.dart';

class _ProjectedTrackCandidate {
  const _ProjectedTrackCandidate({
    required this.row,
    required this.contentChanged,
    required this.shouldInvalidateCache,
  });

  final TracksCompanion row;
  final bool contentChanged;
  final bool shouldInvalidateCache;
}

class _MetadataTaskSuccess {
  const _MetadataTaskSuccess({
    required this.task,
    required this.track,
    required this.metadata,
    required this.shouldEnqueueArtwork,
  });

  final ScanTask task;
  final Track track;
  final DriveExtractedMetadata metadata;
  final bool shouldEnqueueArtwork;
}

class _MetadataTaskFailure {
  const _MetadataTaskFailure({
    required this.task,
    required this.track,
    required this.error,
  });

  final ScanTask task;
  final Track? track;
  final String error;
}

class _ArtworkTaskSuccess {
  const _ArtworkTaskSuccess({
    required this.task,
    required this.track,
    required this.artwork,
  });

  final ScanTask task;
  final Track track;
  final DriveExtractedArtwork? artwork;
}

class _ArtworkTaskFailure {
  const _ArtworkTaskFailure({
    required this.task,
    required this.track,
    required this.error,
  });

  final ScanTask task;
  final Track? track;
  final String error;
}

class _MetadataCatchUpPlan {
  const _MetadataCatchUpPlan({
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

class DriveScanCoordinator {
  DriveScanCoordinator({
    required AppDatabase database,
    required DriveHttpClient driveHttpClient,
    required DriveMetadataExtractor metadataExtractor,
    required DriveArtworkExtractor artworkExtractor,
    required DriveTrackCacheService trackCacheService,
    required DriveScanExecutionProfile executionProfile,
    DriveScanLogger logger = const NoOpDriveScanLogger(),
    bool autoRun = true,
  }) : _database = database,
       _driveHttpClient = driveHttpClient,
       _metadataExtractor = metadataExtractor,
       _artworkExtractor = artworkExtractor,
       _trackCacheService = trackCacheService,
       _executionProfile = executionProfile,
       _logger = logger,
       _autoRun = autoRun;

  final AppDatabase _database;
  final DriveHttpClient _driveHttpClient;
  final DriveMetadataExtractor _metadataExtractor;
  final DriveArtworkExtractor _artworkExtractor;
  final DriveTrackCacheService _trackCacheService;
  final DriveScanExecutionProfile _executionProfile;
  final DriveScanLogger _logger;
  final bool _autoRun;

  Future<void>? _runner;

  Future<void> bootstrap() async {
    final activeJob = await _database.getLatestActiveScanJob();
    if (activeJob == null) {
      final account = await _database.getActiveAccount();
      if (account == null) {
        _logInfo('bootstrap_idle');
        return;
      }
      _logInfo(
        'bootstrap_metadata_catchup_check',
        details: <String, Object?>{'accountId': account.id},
      );
      await _enqueueMetadataCatchUpJobIfNeeded(account);
      return;
    }

    _logInfo(
      'bootstrap_resume_job',
      context: _jobContext(activeJob),
      details: <String, Object?>{'state': activeJob.state},
    );
    await _database.requeueRunningScanTasks(activeJob.id);
    if (activeJob.state == DriveScanJobState.paused.value) {
      _logInfo(
        'bootstrap_paused_job',
        context: _jobContext(activeJob),
      );
      return;
    }

    if (_autoRun) {
      _ensureRunner();
    }
  }

  Future<int?> enqueueSync({int? rootId}) async {
    final account = await _database.getActiveAccount();
    if (account == null) {
      _logWarning(
        'job_enqueue_blocked',
        message: 'Google Drive is not connected.',
      );
      throw const DriveAuthException('Connect Google Drive first.');
    }

    final existingJob = await _database.getLatestActiveScanJob(accountId: account.id);
    if (existingJob != null) {
      final catchUpPlan = await _enqueueMetadataCatchUpTasks(
        jobId: existingJob.id,
        accountId: account.id,
        mergedIntoExistingJob: true,
      );
      if (!catchUpPlan.isEmpty) {
        await _attachRootsToJob(
          existingJob.id,
          catchUpPlan.affectedRootIds,
          syncStateValue: existingJob.state == DriveScanJobState.running.value
              ? DriveScanJobState.running.value
              : DriveScanJobState.queued.value,
        );
        await _rewindJobToMetadataEnrichmentIfNeeded(existingJob);
        if (_autoRun && existingJob.state != DriveScanJobState.paused.value) {
          _ensureRunner();
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

    final roots = await _resolveRootsForEnqueue(account.id, rootId: rootId);
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

    final shouldRunBaseline = _shouldRunBaseline(account, roots);
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
            : Value(account.driveChangePageToken ?? account.driveStartPageToken),
        startPageToken: shouldRunBaseline
            ? const Value.absent()
            : Value(account.driveStartPageToken),
      ),
    );

    if (shouldRunBaseline) {
      await _enqueueBaselineTasks(jobId, roots);
    } else {
      final pageToken = account.driveChangePageToken ?? account.driveStartPageToken;
      if (pageToken == null || pageToken.isEmpty) {
        await _database.updateScanJob(
          jobId,
          ScanJobsCompanion(
            kind: Value(DriveScanJobKind.baseline.value),
            phase: Value(DriveScanPhase.baselineDiscovery.value),
            checkpointToken: const Value(null),
          ),
        );
        await _enqueueBaselineTasks(jobId, roots);
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

    final catchUpPlan = await _enqueueMetadataCatchUpTasks(
      jobId: jobId,
      accountId: account.id,
    );

    await _attachRootsToJob(
      jobId,
      <int>{...roots.map((root) => root.id), ...catchUpPlan.affectedRootIds},
      syncStateValue: DriveScanJobState.queued.value,
    );

    if (_autoRun) {
      _ensureRunner();
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

  Future<void> pauseJob(int jobId) async {
    await _database.updateScanJob(
      jobId,
      ScanJobsCompanion(
        state: Value(DriveScanJobState.paused.value),
      ),
    );
    _logInfo(
      'job_pause',
      context: DriveScanLogContext(jobId: jobId),
    );
  }

  Future<void> resumeJob(int jobId) async {
    await _database.requeueRunningScanTasks(jobId);
    await _database.updateScanJob(
      jobId,
      ScanJobsCompanion(
        state: Value(DriveScanJobState.queued.value),
      ),
    );
    if (_autoRun) {
      _ensureRunner();
    }
    _logInfo(
      'job_resume',
      context: DriveScanLogContext(jobId: jobId),
    );
  }

  Future<void> cancelJob(int jobId) async {
    await _database.updateScanJob(
      jobId,
      ScanJobsCompanion(
        state: Value(DriveScanJobState.cancelRequested.value),
      ),
    );
    if (_autoRun) {
      _ensureRunner();
    }
    _logInfo(
      'job_cancel_requested',
      context: DriveScanLogContext(jobId: jobId),
    );
  }

  void _ensureRunner() {
    _runner ??= _runLoop().whenComplete(() => _runner = null);
  }

  Future<void> _runLoop() async {
    while (true) {
      final job = await _database.getNextRunnableScanJob();
      if (job == null) {
        _logInfo('runner_idle');
        return;
      }
      await _runJob(job.id);
    }
  }

  Future<void> _runJob(int jobId) async {
    final initialJob = await _database.getScanJobById(jobId);
    if (initialJob == null) {
      _logWarning(
        'job_missing',
        context: DriveScanLogContext(jobId: jobId),
      );
      return;
    }

    await _database.requeueRunningScanTasks(jobId);
    if (initialJob.state == DriveScanJobState.cancelRequested.value) {
      _logInfo(
        'job_cancel_requested_before_start',
        context: _jobContext(initialJob),
      );
      await _cancelJob(initialJob);
      return;
    }

    if (initialJob.state != DriveScanJobState.running.value) {
      await _database.updateScanJob(
        jobId,
        ScanJobsCompanion(
          state: Value(DriveScanJobState.running.value),
          startedAt: Value(initialJob.startedAt ?? DateTime.now()),
        ),
      );
    }
    _logInfo(
      'job_start',
      context: _jobContext(initialJob),
      details: <String, Object?>{
        'kind': initialJob.kind,
        'state': initialJob.state,
      },
    );

    final roots = await _resolveRootsForExistingJob(initialJob);
    for (final root in roots) {
      await _database.updateRootState(
        root.id,
        syncStateValue: DriveScanJobState.running.value,
        activeJobIdValue: jobId,
        lastErrorValue: null,
      );
    }

    while (true) {
      final job = await _database.getScanJobById(jobId);
      if (job == null) {
        return;
      }
      if (job.state == DriveScanJobState.paused.value) {
        _logInfo(
          'job_paused',
          context: _jobContext(job),
        );
        return;
      }
      if (job.state == DriveScanJobState.cancelRequested.value) {
        _logInfo(
          'job_canceling',
          context: _jobContext(job),
        );
        await _cancelJob(job);
        return;
      }

      try {
        _logInfo(
          'phase_enter',
          context: _jobContext(job),
        );
        switch (_phaseFromValue(job.phase)) {
          case DriveScanPhase.baselineDiscovery:
            final hasMore = await _processBaselineDiscovery(job);
            if (!hasMore) {
              _logInfo(
                'phase_complete',
                context: _jobContext(job),
              );
              await _database.updateScanJob(
                job.id,
                ScanJobsCompanion(
                  phase: Value(DriveScanPhase.metadataEnrichment.value),
                ),
              );
            }
          case DriveScanPhase.incrementalChanges:
            final hasMore = await _processIncrementalChanges(job);
            if (!hasMore) {
              _logInfo(
                'phase_complete',
                context: _jobContext(job),
              );
              await _database.updateScanJob(
                job.id,
                ScanJobsCompanion(
                  phase: Value(DriveScanPhase.metadataEnrichment.value),
                ),
              );
            }
          case DriveScanPhase.metadataEnrichment:
            final hasMore = await _processMetadataEnrichment(job);
            if (!hasMore) {
              _logInfo(
                'phase_complete',
                context: _jobContext(job),
              );
              await _database.updateScanJob(
                job.id,
                ScanJobsCompanion(
                  phase: Value(DriveScanPhase.artworkEnrichment.value),
                ),
              );
            }
          case DriveScanPhase.artworkEnrichment:
            final hasMore = await _processArtworkEnrichment(job);
            if (!hasMore) {
              _logInfo(
                'phase_complete',
                context: _jobContext(job),
              );
              await _database.updateScanJob(
                job.id,
                ScanJobsCompanion(
                  phase: Value(DriveScanPhase.finalize.value),
                ),
              );
            }
          case DriveScanPhase.finalize:
            await _finalizeJob(job);
            return;
        }
      } catch (error, stackTrace) {
        _logError(
          'job_run_fail',
          context: _jobContext(job),
          error: error,
          stackTrace: stackTrace,
        );
        await _failJob(job, error, stackTrace);
        return;
      }
    }
  }

  Future<bool> _processBaselineDiscovery(ScanJob job) async {
    final tasks = await _database.takeQueuedScanTasks(
      job.id,
      kind: DriveScanTaskKind.discoverFolder.value,
      limit: _executionProfile.discoveryWorkers,
    );
    if (tasks.isEmpty) {
      _logInfo(
        'phase_empty',
        context: _jobContext(job),
      );
      await _refreshJobProgress(job);
      return false;
    }

    final stopwatch = Stopwatch()..start();
    _logInfo(
      'discovery_batch_start',
      context: _jobContext(job),
      details: <String, Object?>{'taskCount': tasks.length},
    );
    final errors = <Object>[];
    await Future.wait(tasks.map((task) async {
      try {
        await _handleDiscoverTask(job, task);
        await _database.completeScanTasks([task.id]);
      } catch (error, stackTrace) {
        await _database.failScanTasks([task.id], error: error.toString());
        _logError(
          'task_fail',
          context: _jobContext(
            job,
            rootId: task.rootId,
            taskId: task.id,
            driveFileId: task.targetDriveId,
          ),
          details: const <String, Object?>{'kind': 'discover_folder'},
          error: error,
          stackTrace: stackTrace,
        );
        errors.add(error);
      }
    }));

    if (errors.isNotEmpty) {
      throw errors.first;
    }

    _logInfo(
      'discovery_batch_complete',
      context: _jobContext(job, elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{'taskCount': tasks.length},
    );
    await _refreshJobProgress(job);
    return true;
  }

  Future<bool> _processIncrementalChanges(ScanJob job) async {
    final tasks = await _database.takeQueuedScanTasks(
      job.id,
      kind: DriveScanTaskKind.reconcileChange.value,
      limit: _executionProfile.changeWorkers,
    );
    if (tasks.isEmpty) {
      _logInfo(
        'phase_empty',
        context: _jobContext(job),
      );
      await _refreshJobProgress(job);
      return false;
    }

    final stopwatch = Stopwatch()..start();
    _logInfo(
      'changes_batch_start',
      context: _jobContext(job),
      details: <String, Object?>{'taskCount': tasks.length},
    );
    final errors = <Object>[];
    await Future.wait(tasks.map((task) async {
      try {
        await _handleChangeTask(job, task);
        await _database.completeScanTasks([task.id]);
      } catch (error, stackTrace) {
        await _database.failScanTasks([task.id], error: error.toString());
        _logError(
          'task_fail',
          context: _jobContext(
            job,
            rootId: task.rootId,
            taskId: task.id,
            driveFileId: task.targetDriveId,
          ),
          details: const <String, Object?>{'kind': 'reconcile_change'},
          error: error,
          stackTrace: stackTrace,
        );
        errors.add(error);
      }
    }));

    if (errors.isNotEmpty) {
      throw errors.first;
    }

    _logInfo(
      'changes_batch_complete',
      context: _jobContext(job, elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{'taskCount': tasks.length},
    );
    await _refreshJobProgress(job);
    return true;
  }

  Future<bool> _processMetadataEnrichment(ScanJob job) async {
    final metadataTasks = await _database.takeQueuedScanTasks(
      job.id,
      kind: DriveScanTaskKind.extractTags.value,
      limit: _executionProfile.metadataWorkers,
    );
    final metadataBacklog = await _database.countQueuedScanTasks(
      job.id,
      kind: DriveScanTaskKind.extractTags.value,
      includeRunning: true,
    );
    if (metadataTasks.isEmpty) {
      _logInfo(
        'phase_empty',
        context: _jobContext(job),
      );
      await _refreshJobProgress(job);
      return false;
    }

    final canDrainArtworkDuringMetadata =
        metadataBacklog <= _executionProfile.metadataHighWatermark;
    final artworkLimit =
        canDrainArtworkDuringMetadata
            ? _executionProfile.artworkWorkersWhileMetadataPending
            : 0;
    _logInfo(
      'metadata_scheduler_state',
      context: _jobContext(job),
      details: <String, Object?>{
        'metadataTaskCount': metadataTasks.length,
        'metadataBacklog': metadataBacklog,
        'artworkWorkersWhileMetadataPending': artworkLimit,
        'artworkSuppressed': artworkLimit == 0,
      },
    );
    if (artworkLimit == 0) {
      _logWarning(
        'artwork_deferred',
        context: _jobContext(job),
        details: <String, Object?>{'metadataBacklog': metadataBacklog},
      );
    }
    final artworkTasks =
        artworkLimit == 0
            ? const <ScanTask>[]
            : await _database.takeQueuedScanTasks(
                job.id,
                kind: DriveScanTaskKind.extractArtwork.value,
                limit: artworkLimit,
              );

    await _flushMetadataTaskBatch(job, metadataTasks);
    await _flushArtworkTaskBatch(job, artworkTasks);

    await _refreshJobProgress(job);
    return true;
  }

  Future<bool> _processArtworkEnrichment(ScanJob job) async {
    final tasks = await _database.takeQueuedScanTasks(
      job.id,
      kind: DriveScanTaskKind.extractArtwork.value,
      limit: _executionProfile.artworkWorkers,
    );
    if (tasks.isEmpty) {
      _logInfo(
        'phase_empty',
        context: _jobContext(job),
      );
      await _refreshJobProgress(job);
      return false;
    }

    await _flushArtworkTaskBatch(job, tasks);

    await _refreshJobProgress(job);
    return true;
  }

  Future<void> _handleDiscoverTask(ScanJob job, ScanTask task) async {
    final rootId = task.rootId;
    final folderId = task.targetDriveId;
    if (rootId == null || folderId == null) {
      _logWarning(
        'discover_task_skipped',
        context: _jobContext(job, taskId: task.id),
        details: const <String, Object?>{'reason': 'missing_root_or_folder'},
      );
      return;
    }
    final stopwatch = Stopwatch()..start();
    final payload = _decodePayload(task.payloadJson);
    _logInfo(
      'discovery_page_start',
      context: _jobContext(
        job,
        rootId: rootId,
        taskId: task.id,
        driveFileId: folderId,
      ),
      details: <String, Object?>{
        'pageToken': payload['pageToken'] as String?,
      },
    );

    final root = await _database.getRootById(rootId);
    if (root == null) {
      _logWarning(
        'discover_task_skipped',
        context: _jobContext(
          job,
          rootId: rootId,
          taskId: task.id,
          driveFileId: folderId,
        ),
        details: const <String, Object?>{'reason': 'missing_root'},
      );
      return;
    }

    await _upsertFolderObject(
      folderId: folderId,
      folderName: folderId == root.folderId ? root.folderName : null,
      parentDriveId: folderId == root.folderId ? root.parentFolderId : null,
      rootId: rootId,
      jobId: job.id,
    );

    final page = await _driveHttpClient.listFolderPage(
      parentId: folderId,
      pageToken: payload['pageToken'] as String?,
      pageSize: _executionProfile.pageSize,
    );

    final objectRows = <DriveObjectsCompanion>[];
    final followUpTasks = <ScanTasksCompanion>[];
    final projectedTracks = <TracksCompanion>[];
    final cacheInvalidations = <Track>[];
    final audioEntries = <DriveObjectEntry>[];
    final now = DateTime.now();

    for (final entry in page.items) {
      final parentDriveId = entry.parentIds.isEmpty ? folderId : entry.parentIds.first;
      objectRows.add(
        DriveObjectsCompanion.insert(
          driveId: entry.id,
          parentDriveId: Value(parentDriveId),
          name: entry.name,
          mimeType: entry.mimeType,
          objectKind: entry.isFolder
              ? DriveObjectKind.folder.value
              : DriveObjectKind.file.value,
          resourceKey: Value(entry.resourceKey),
          sizeBytes: Value(entry.sizeBytes),
          md5Checksum: Value(entry.md5Checksum),
          modifiedTime: Value(entry.modifiedTime),
          rootIdsJson: Value(_encodeRootIds(rootId)),
          isTombstoned: const Value(false),
          lastSeenJobId: Value(job.id),
          updatedAt: Value(now),
        ),
      );

      if (entry.isFolder) {
        followUpTasks.add(
          ScanTasksCompanion.insert(
            jobId: job.id,
            kind: DriveScanTaskKind.discoverFolder.value,
            rootId: Value(rootId),
            targetDriveId: Value(entry.id),
            dedupeKey: Value('discover:$rootId:${entry.id}:'),
            payloadJson: const Value('{}'),
            priority: const Value(10),
          ),
        );
        continue;
      }

      if (!_isAudioFile(name: entry.name, mimeType: entry.mimeType)) {
        continue;
      }
      audioEntries.add(entry);
    }

    final existingTracks = await _database.getTracksByDriveFileIds(
      audioEntries.map((entry) => entry.id),
    );
    final existingTracksByDriveId = {
      for (final track in existingTracks) track.driveFileId: track,
    };

    for (final entry in audioEntries) {
      final existingTrack = existingTracksByDriveId[entry.id];
      final projection = _buildProjectedAudioCandidate(
        rootId: rootId,
        entry: entry,
        existingTrack: existingTrack,
      );
      projectedTracks.add(projection.row);
      if (projection.shouldInvalidateCache && existingTrack != null) {
        cacheInvalidations.add(existingTrack);
      }
      if (projection.contentChanged) {
        followUpTasks.add(
          _buildExtractTagsTask(
            jobId: job.id,
            rootId: rootId,
            driveFileId: entry.id,
            fingerprint: _contentFingerprintForEntry(entry),
          ),
        );
      }
    }

    if (page.nextPageToken != null && page.nextPageToken!.isNotEmpty) {
      followUpTasks.add(
        ScanTasksCompanion.insert(
          jobId: job.id,
          kind: DriveScanTaskKind.discoverFolder.value,
          rootId: Value(rootId),
          targetDriveId: Value(folderId),
          dedupeKey: Value('discover:$rootId:$folderId:${page.nextPageToken}'),
          payloadJson: Value(
            jsonEncode(<String, Object?>{
              'pageToken': page.nextPageToken,
            }),
          ),
          priority: const Value(100),
        ),
      );
    }

    await _trackCacheService.removeCachedTrackFiles(cacheInvalidations);
    await _database.transaction(() async {
      await _database.insertAllDriveObjectsOnConflictUpdate(objectRows);
      await _insertProjectedTracks(projectedTracks);
      await _database.enqueueScanTasks(followUpTasks);
    });
    _logInfo(
      'discovery_page_complete',
      context: _jobContext(
        job,
        rootId: rootId,
        taskId: task.id,
        driveFileId: folderId,
        elapsedMs: stopwatch.elapsedMilliseconds,
      ),
      details: <String, Object?>{
        'itemCount': page.items.length,
        'audioCandidateCount': audioEntries.length,
        'followUpTaskCount': followUpTasks.length,
        'nextPageToken': page.nextPageToken,
      },
    );
  }

  Future<void> _handleChangeTask(ScanJob job, ScanTask task) async {
    final payload = _decodePayload(task.payloadJson);
    final pageToken = payload['pageToken'] as String?;
    if (pageToken == null || pageToken.isEmpty) {
      _logWarning(
        'changes_page_skipped',
        context: _jobContext(job, taskId: task.id),
        details: const <String, Object?>{'reason': 'missing_page_token'},
      );
      return;
    }
    final stopwatch = Stopwatch()..start();
    _logInfo(
      'changes_page_start',
      context: _jobContext(job, taskId: task.id),
      details: <String, Object?>{'pageToken': pageToken},
    );

    final page = await _driveHttpClient.listChangesPage(
      pageToken: pageToken,
      pageSize: _executionProfile.pageSize,
    );
    await _database.updateScanJob(
      job.id,
      ScanJobsCompanion(
        checkpointToken: Value(
          page.nextPageToken ?? page.newStartPageToken ?? pageToken,
        ),
        startPageToken: page.newStartPageToken == null
            ? const Value.absent()
            : Value(page.newStartPageToken),
      ),
    );

    await _runWithConcurrencyLimit<DriveChangeEntry>(
      page.changes,
      limit: _executionProfile.changeWorkers,
      operation: (change) => _applyChange(job, change),
    );

    if (page.nextPageToken != null && page.nextPageToken!.isNotEmpty) {
      await _database.enqueueScanTasks([
        ScanTasksCompanion.insert(
          jobId: job.id,
          kind: DriveScanTaskKind.reconcileChange.value,
          dedupeKey: Value('changes:${page.nextPageToken}'),
          payloadJson: Value(
            jsonEncode(<String, Object?>{
              'pageToken': page.nextPageToken,
            }),
          ),
          priority: const Value(100),
        ),
      ]);
    }
    _logInfo(
      'changes_page_complete',
      context: _jobContext(job, taskId: task.id, elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{
        'changeCount': page.changes.length,
        'checkpointToken': page.nextPageToken ?? page.newStartPageToken ?? pageToken,
        'nextPageToken': page.nextPageToken,
        'newStartPageToken': page.newStartPageToken,
      },
    );
  }

  Future<void> _applyChange(ScanJob job, DriveChangeEntry change) async {
    final file = change.file;
    if (change.isRemoved || file == null) {
      await _markDriveObjectRemoved(change.fileId, job.id);
      return;
    }

    final rootId = await _resolveRootIdFromParents(file.parentIds);
    await _database.upsertDriveObject(
      DriveObjectsCompanion.insert(
        driveId: file.id,
        parentDriveId: Value(file.parentIds.isEmpty ? null : file.parentIds.first),
        name: file.name,
        mimeType: file.mimeType,
        objectKind: file.isFolder
            ? DriveObjectKind.folder.value
            : DriveObjectKind.file.value,
        resourceKey: Value(file.resourceKey),
        sizeBytes: Value(file.sizeBytes),
        md5Checksum: Value(file.md5Checksum),
        modifiedTime: Value(file.modifiedTime),
        rootIdsJson: Value(_encodeRootIds(rootId)),
        isTombstoned: const Value(false),
        lastSeenJobId: Value(job.id),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (file.isFolder) {
      await _reconcileFolderMembership(job.id, file.id, rootId);
      return;
    }

    final existingTrack = await _database.getTrackByDriveFileId(file.id);
    if (!_isAudioFile(name: file.name, mimeType: file.mimeType) || rootId == null) {
      if (existingTrack != null) {
        await _database.markTrackPendingDeleteByDriveFileId(file.id);
      }
      return;
    }

    final didChange = await _projectAudioCandidate(
      rootId: rootId,
      entry: file,
      existingTrack: existingTrack,
    );
    if (didChange) {
      await _database.enqueueScanTasks([
        _buildExtractTagsTask(
          jobId: job.id,
          rootId: rootId,
          driveFileId: file.id,
          fingerprint: _contentFingerprintForEntry(file),
        ),
      ]);
    }
  }

  Future<void> _flushMetadataTaskBatch(ScanJob job, List<ScanTask> tasks) async {
    if (tasks.isEmpty) {
      return;
    }
    final stopwatch = Stopwatch()..start();
    _logInfo(
      'metadata_batch_start',
      context: _jobContext(job),
      details: <String, Object?>{'taskCount': tasks.length},
    );

    final outcomes = await Future.wait(
      tasks.map(_extractMetadataOutcome),
    );
    final successes = outcomes.whereType<_MetadataTaskSuccess>().toList(growable: false);
    final failures = outcomes.whereType<_MetadataTaskFailure>().toList(growable: false);
    final skippedTaskIds = tasks
        .where((task) => !successes.any((success) => success.task.id == task.id))
        .where((task) => !failures.any((failure) => failure.task.id == task.id))
        .map((task) => task.id)
        .toList(growable: false);

    if (successes.isNotEmpty) {
      await _database.applyTrackMetadataBatch(
        successes
            .map(
              (success) => TrackMetadataBatchUpdate(
                trackId: success.track.id,
                titleValue: success.metadata.title,
                artistValue: success.metadata.artist,
                albumValue: success.metadata.album,
                albumArtistValue: success.metadata.albumArtist,
                genreValue: success.metadata.genre,
                yearValue: success.metadata.year,
                trackNumberValue: success.metadata.trackNumber,
                discNumberValue: success.metadata.discNumber,
                durationMsValue: success.metadata.durationMs,
                artworkUriValue: success.track.artworkUri,
                artworkBlobIdValue: success.track.artworkBlobId,
                metadataStatusValue: TrackMetadataStatus.ready.value,
                metadataSchemaVersionValue: currentTrackMetadataSchemaVersion,
                artworkStatusValue: success.shouldEnqueueArtwork
                    ? TrackArtworkStatus.pending.value
                    : TrackArtworkStatus.ready.value,
              ),
            )
            .toList(growable: false),
      );
      await _database.completeScanTasks(
        successes.map((success) => success.task.id),
      );

      final artworkTasks = successes
          .where((success) => success.shouldEnqueueArtwork)
          .map(
            (success) => ScanTasksCompanion.insert(
              jobId: job.id,
              kind: DriveScanTaskKind.extractArtwork.value,
              rootId: Value(success.track.rootId),
              targetDriveId: Value(success.track.driveFileId),
              dedupeKey: Value(
                'art:${success.track.driveFileId}:${success.track.contentFingerprint ?? ''}',
              ),
              payloadJson: const Value('{}'),
              priority: const Value(15),
            ),
          )
          .toList(growable: false);
      await _database.enqueueScanTasks(artworkTasks);
      _logInfo(
        'metadata_batch_artwork_enqueued',
        context: _jobContext(job),
        details: <String, Object?>{'artworkTaskCount': artworkTasks.length},
      );
    }

    if (failures.isNotEmpty) {
      final failedTrackUpdates = failures
          .where((failure) => failure.track != null)
          .map(
            (failure) => TrackMetadataBatchUpdate(
              trackId: failure.track!.id,
              titleValue: failure.track!.title,
              artistValue: failure.track!.artist,
              albumValue: failure.track!.album,
              albumArtistValue: failure.track!.albumArtist,
              genreValue: failure.track!.genre,
              yearValue: failure.track!.year,
              trackNumberValue: failure.track!.trackNumber,
              discNumberValue: failure.track!.discNumber,
              durationMsValue: failure.track!.durationMs,
              artworkUriValue: failure.track!.artworkUri,
              artworkBlobIdValue: failure.track!.artworkBlobId,
              metadataStatusValue: TrackMetadataStatus.failed.value,
              metadataSchemaVersionValue: failure.track!.metadataSchemaVersion,
              artworkStatusValue: failure.track!.artworkStatus,
            ),
          )
          .toList(growable: false);
      await _database.applyTrackMetadataBatch(failedTrackUpdates);
      for (final failure in failures) {
        await _database.failScanTasks([failure.task.id], error: failure.error);
      }
    }

    await _database.completeScanTasks(skippedTaskIds);
    _logInfo(
      'metadata_batch_complete',
      context: _jobContext(job, elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{
        'taskCount': tasks.length,
        'successCount': successes.length,
        'failureCount': failures.length,
        'skippedCount': skippedTaskIds.length,
      },
    );
  }

  Future<Object> _extractMetadataOutcome(ScanTask task) async {
    final driveId = task.targetDriveId;
    if (driveId == null) {
      return task;
    }

    final track = await _database.getTrackByDriveFileId(driveId);
    if (track == null || track.indexStatus == TrackIndexStatus.removed.value) {
      return task;
    }

    try {
      final metadata = await _metadataExtractor.extract(track);
      return _MetadataTaskSuccess(
        task: task,
        track: track,
        metadata: metadata,
        shouldEnqueueArtwork:
            track.artworkStatus != TrackArtworkStatus.ready.value,
      );
    } catch (error, stackTrace) {
      _logError(
        'task_fail',
        context: DriveScanLogContext(
          taskId: task.id,
          rootId: task.rootId,
          phase: DriveScanPhase.metadataEnrichment.value,
          driveFileId: track.driveFileId,
        ),
        details: const <String, Object?>{'kind': 'extract_tags'},
        error: error,
        stackTrace: stackTrace,
      );
      return _MetadataTaskFailure(
        task: task,
        track: track,
        error: error.toString(),
      );
    }
  }

  Future<void> _flushArtworkTaskBatch(ScanJob unusedJob, List<ScanTask> tasks) async {
    if (tasks.isEmpty) {
      return;
    }
    final stopwatch = Stopwatch()..start();
    _logInfo(
      'artwork_batch_start',
      context: _jobContext(unusedJob),
      details: <String, Object?>{'taskCount': tasks.length},
    );

    final outcomes = await Future.wait(
      tasks.map(_extractArtworkOutcome),
    );
    final successes = outcomes.whereType<_ArtworkTaskSuccess>().toList(growable: false);
    final failures = outcomes.whereType<_ArtworkTaskFailure>().toList(growable: false);
    final skippedTaskIds = tasks
        .where((task) => !successes.any((success) => success.task.id == task.id))
        .where((task) => !failures.any((failure) => failure.task.id == task.id))
        .map((task) => task.id)
        .toList(growable: false);

    if (successes.isNotEmpty) {
      final artworkByHash = await _database.getArtworkBlobsByHashes(
        successes
            .map((success) => success.artwork?.contentHash)
            .whereType<String>(),
      );
      final blobsByHash = {
        for (final blob in artworkByHash) blob.contentHash: blob,
      };

      final projectionUpdates = <TrackProjectionBatchUpdate>[];
      for (final success in successes) {
        final artwork = success.artwork;
        if (artwork == null) {
          projectionUpdates.add(
            TrackProjectionBatchUpdate(
              trackId: success.track.id,
              fileNameValue: success.track.fileName,
              mimeTypeValue: success.track.mimeType,
              sizeBytesValue: success.track.sizeBytes,
              md5ChecksumValue: success.track.md5Checksum,
              modifiedTimeValue: success.track.modifiedTime,
              resourceKeyValue: success.track.resourceKey,
              contentFingerprintValue: success.track.contentFingerprint ?? '',
              indexStatusValue: TrackIndexStatus.active.value,
              artworkStatusValue: TrackArtworkStatus.none.value,
              updatedAtValue: DateTime.now(),
              removedAtValue: null,
            ),
          );
          continue;
        }

        var blob = blobsByHash[artwork.contentHash];
        var blobId = blob?.id;
        if (blobId == null) {
          blobId = await _writeArtworkBlob(artwork.contentHash, artwork);
          blob = await _database.getArtworkBlobByHash(artwork.contentHash);
          if (blob != null) {
            blobsByHash[artwork.contentHash] = blob;
          }
        }

        projectionUpdates.add(
          TrackProjectionBatchUpdate(
            trackId: success.track.id,
            fileNameValue: success.track.fileName,
            mimeTypeValue: success.track.mimeType,
            sizeBytesValue: success.track.sizeBytes,
            md5ChecksumValue: success.track.md5Checksum,
            modifiedTimeValue: success.track.modifiedTime,
            resourceKeyValue: success.track.resourceKey,
            contentFingerprintValue: success.track.contentFingerprint ?? '',
            indexStatusValue: TrackIndexStatus.active.value,
            artworkUriValue: blob?.filePath,
            artworkBlobIdValue: blobId,
            artworkStatusValue: TrackArtworkStatus.ready.value,
            updatedAtValue: DateTime.now(),
            removedAtValue: null,
          ),
        );
      }

      await _database.applyTrackProjectionBatch(projectionUpdates);
      await _database.completeScanTasks(
        successes.map((success) => success.task.id),
      );
    }

    for (final failure in failures) {
      if (failure.track != null) {
        await _database.applyTrackProjectionBatch([
          TrackProjectionBatchUpdate(
            trackId: failure.track!.id,
            fileNameValue: failure.track!.fileName,
            mimeTypeValue: failure.track!.mimeType,
            sizeBytesValue: failure.track!.sizeBytes,
            md5ChecksumValue: failure.track!.md5Checksum,
            modifiedTimeValue: failure.track!.modifiedTime,
            resourceKeyValue: failure.track!.resourceKey,
            contentFingerprintValue: failure.track!.contentFingerprint ?? '',
            indexStatusValue: TrackIndexStatus.active.value,
            artworkStatusValue: TrackArtworkStatus.failed.value,
            updatedAtValue: DateTime.now(),
            removedAtValue: null,
          ),
        ]);
      }
      await _database.failScanTasks([failure.task.id], error: failure.error);
    }

    await _database.completeScanTasks(skippedTaskIds);
    _logInfo(
      'artwork_batch_complete',
      context: _jobContext(unusedJob, elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{
        'taskCount': tasks.length,
        'successCount': successes.length,
        'failureCount': failures.length,
        'skippedCount': skippedTaskIds.length,
      },
    );
  }

  Future<Object> _extractArtworkOutcome(ScanTask task) async {
    final driveId = task.targetDriveId;
    if (driveId == null) {
      return task;
    }

    final track = await _database.getTrackByDriveFileId(driveId);
    if (track == null || track.indexStatus == TrackIndexStatus.removed.value) {
      return task;
    }

    try {
      final artwork = await _artworkExtractor.extract(track);
      return _ArtworkTaskSuccess(task: task, track: track, artwork: artwork);
    } catch (error, stackTrace) {
      _logError(
        'task_fail',
        context: DriveScanLogContext(
          taskId: task.id,
          rootId: task.rootId,
          phase: DriveScanPhase.artworkEnrichment.value,
          driveFileId: track.driveFileId,
        ),
        details: const <String, Object?>{'kind': 'extract_artwork'},
        error: error,
        stackTrace: stackTrace,
      );
      return _ArtworkTaskFailure(
        task: task,
        track: track,
        error: error.toString(),
      );
    }
  }

  Future<void> _finalizeJob(ScanJob job) async {
    final pendingDeletion = await _database.tracksPendingDeletion();
    final stopwatch = Stopwatch()..start();
    _logInfo(
      'finalize_start',
      context: _jobContext(job),
      details: <String, Object?>{'pendingDeleteCount': pendingDeletion.length},
    );
    for (final track in pendingDeletion) {
      await _trackCacheService.removeCachedTrackFile(track);
      await _database.markTrackRemovedById(track.id);
    }

    final completedAt = DateTime.now();
    if (job.kind == DriveScanJobKind.baseline.value) {
      final startPageToken = await _driveHttpClient.getStartPageToken();
      await _database.updateAccountSyncCheckpoint(
        job.accountId,
        driveStartPageTokenValue: startPageToken,
        driveChangePageTokenValue: startPageToken,
        lastSuccessfulSyncAtValue: completedAt,
      );
    } else {
      final nextToken = job.startPageToken ?? job.checkpointToken;
      await _database.updateAccountSyncCheckpoint(
        job.accountId,
        driveStartPageTokenValue: nextToken,
        driveChangePageTokenValue: nextToken,
        lastSuccessfulSyncAtValue: completedAt,
      );
    }

    final roots = await _resolveRootsForExistingJob(job);
    for (final root in roots) {
      await _database.refreshRootProgress(root.id);
      await _database.updateRootState(
        root.id,
        syncStateValue: DriveScanJobState.completed.value,
        lastSyncedAtValue: completedAt,
        lastErrorValue: null,
        activeJobIdValue: null,
      );
    }

    await _refreshJobProgress(job);
    await _database.updateScanJob(
      job.id,
      ScanJobsCompanion(
        state: Value(DriveScanJobState.completed.value),
        finishedAt: Value(completedAt),
      ),
    );
    _logInfo(
      'job_complete',
      context: _jobContext(job, elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{'pendingDeleteCount': pendingDeletion.length},
    );
  }

  Future<void> _cancelJob(ScanJob job) async {
    await _database.cancelQueuedScanTasks(job.id);
    await _database.updateScanJob(
      job.id,
      ScanJobsCompanion(
        state: Value(DriveScanJobState.canceled.value),
        finishedAt: Value(DateTime.now()),
      ),
    );
    _logInfo(
      'job_canceled',
      context: _jobContext(job),
    );

    final roots = await _resolveRootsForExistingJob(job);
    for (final root in roots) {
      await _database.updateRootState(
        root.id,
        syncStateValue: DriveScanJobState.canceled.value,
        activeJobIdValue: null,
      );
    }
  }

  Future<void> _failJob(ScanJob job, Object error, StackTrace stackTrace) async {
    final summary = _summarizeError(error);
    await _database.updateScanJob(
      job.id,
      ScanJobsCompanion(
        state: Value(DriveScanJobState.failed.value),
        lastError: Value(summary),
        finishedAt: Value(DateTime.now()),
      ),
    );

    final roots = await _resolveRootsForExistingJob(job);
    for (final root in roots) {
      await _database.updateRootState(
        root.id,
        syncStateValue: DriveScanJobState.failed.value,
        lastErrorValue: summary,
        activeJobIdValue: null,
      );
    }
    _logError(
      'job_fail',
      context: _jobContext(job),
      message: summary,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> _refreshJobProgress(ScanJob job) async {
    final roots = await _resolveRootsForExistingJob(job);
    var indexedCount = 0;
    var metadataReadyCount = 0;
    var artworkReadyCount = 0;
    var failedCount = 0;

    for (final root in roots) {
      await _database.refreshRootProgress(root.id);
      final counts = await _database.getRootScanCounts(root.id);
      indexedCount += counts.indexedCount;
      metadataReadyCount += counts.metadataReadyCount;
      artworkReadyCount += counts.artworkReadyCount;
      failedCount += counts.failedCount;
    }

    await _database.updateScanJob(
      job.id,
      ScanJobsCompanion(
        indexedCount: Value(indexedCount),
        metadataReadyCount: Value(metadataReadyCount),
        artworkReadyCount: Value(artworkReadyCount),
        failedCount: Value(failedCount),
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
      subsystem: 'scan',
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
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.warning(
      prefix: 'DriveScan',
      subsystem: 'scan',
      operation: operation,
      context: context,
      message: message,
      details: details,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _logError(
    String operation, {
    DriveScanLogContext context = const DriveScanLogContext(),
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.error(
      prefix: 'DriveScan',
      subsystem: 'scan',
      operation: operation,
      context: context,
      message: message,
      details: details,
      error: error,
      stackTrace: stackTrace,
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

  String _summarizeError(Object error) {
    final text = error.toString().trim();
    if (text.isEmpty) {
      return 'Unknown scan error';
    }
    return text.split('\n').first.trim();
  }

  Future<void> _runWithConcurrencyLimit<T>(
    Iterable<T> items, {
    required int limit,
    required Future<void> Function(T item) operation,
  }) async {
    final queue = items.toList(growable: false);
    if (queue.isEmpty) {
      return;
    }

    var nextIndex = 0;
    Future<void> worker() async {
      while (nextIndex < queue.length) {
        final currentIndex = nextIndex;
        nextIndex += 1;
        await operation(queue[currentIndex]);
      }
    }

    final workerCount = limit < queue.length ? limit : queue.length;
    await Future.wait(
      List<Future<void>>.generate(workerCount, (_) => worker()),
    );
  }

  Future<List<SyncRoot>> _resolveRootsForEnqueue(
    int accountId, {
    int? rootId,
  }) async {
    final roots = await _database.getRoots();
    return roots.where((root) {
      if (root.accountId != accountId) {
        return false;
      }
      if (rootId != null && root.id != rootId) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  Future<List<SyncRoot>> _resolveRootsForExistingJob(ScanJob job) async {
    final roots = await _database.getRoots();
    return roots.where((root) {
      if (root.accountId != job.accountId) {
        return false;
      }
      if (job.rootId != null) {
        return root.id == job.rootId || root.activeJobId == job.id;
      }
      return root.activeJobId == job.id ||
          root.syncState == DriveScanJobState.running.value;
    }).toList(growable: false);
  }

  bool _shouldRunBaseline(SyncAccount account, List<SyncRoot> roots) {
    if (account.driveStartPageToken == null || account.driveStartPageToken!.isEmpty) {
      return true;
    }
    return roots.any((root) => root.lastSyncedAt == null);
  }

  Future<void> _enqueueBaselineTasks(int jobId, List<SyncRoot> roots) async {
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

  Future<int?> _enqueueMetadataCatchUpJobIfNeeded(SyncAccount account) async {
    final catchUpTracks = await _database.getTracksNeedingMetadataCatchUp(
      accountId: account.id,
      metadataSchemaVersionBelow: currentTrackMetadataSchemaVersion,
    );
    if (catchUpTracks.isEmpty) {
      return null;
    }

    final affectedRootIds = catchUpTracks.map((track) => track.rootId).toSet();
    final roots = await _resolveRootsForEnqueue(account.id);
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
    final catchUpPlan = _buildMetadataCatchUpPlan(
      jobId: jobId,
      tracks: catchUpTracks,
    );
    await _database.enqueueScanTasks(catchUpPlan.tasks);
    await _attachRootsToJob(
      jobId,
      catchUpPlan.affectedRootIds,
      syncStateValue: DriveScanJobState.queued.value,
    );
    if (_autoRun) {
      _ensureRunner();
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

  Future<_MetadataCatchUpPlan> _enqueueMetadataCatchUpTasks({
    required int jobId,
    required int accountId,
    bool mergedIntoExistingJob = false,
  }) async {
    final catchUpTracks = await _database.getTracksNeedingMetadataCatchUp(
      accountId: accountId,
      metadataSchemaVersionBelow: currentTrackMetadataSchemaVersion,
    );
    if (catchUpTracks.isEmpty) {
      return const _MetadataCatchUpPlan(
        tasks: <ScanTasksCompanion>[],
        affectedRootIds: <int>{},
        pendingOrStaleCount: 0,
        schemaRepairCount: 0,
      );
    }

    final catchUpPlan = _buildMetadataCatchUpPlan(
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

  _MetadataCatchUpPlan _buildMetadataCatchUpPlan({
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
        _buildExtractTagsTask(
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

    return _MetadataCatchUpPlan(
      tasks: tasks,
      affectedRootIds: affectedRootIds,
      pendingOrStaleCount: pendingOrStaleCount,
      schemaRepairCount: schemaRepairCount,
    );
  }

  Future<void> _attachRootsToJob(
    int jobId,
    Iterable<int> rootIds, {
    required String syncStateValue,
  }) async {
    final ids = rootIds.toSet();
    if (ids.isEmpty) {
      return;
    }

    for (final rootId in ids) {
      await _database.updateRootState(
        rootId,
        syncStateValue: syncStateValue,
        activeJobIdValue: jobId,
        lastErrorValue: null,
      );
    }
  }

  Future<void> _rewindJobToMetadataEnrichmentIfNeeded(ScanJob job) async {
    final phase = _phaseFromValue(job.phase);
    if (phase.index <= DriveScanPhase.metadataEnrichment.index) {
      return;
    }

    await _database.updateScanJob(
      job.id,
      ScanJobsCompanion(
        phase: Value(DriveScanPhase.metadataEnrichment.value),
      ),
    );
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

  Future<void> _markDriveObjectRemoved(String driveId, int jobId) async {
    final object = await _database.getDriveObjectById(driveId);
    if (object != null) {
      await _database.upsertDriveObject(
        DriveObjectsCompanion.insert(
          driveId: object.driveId,
          parentDriveId: Value(object.parentDriveId),
          name: object.name,
          mimeType: object.mimeType,
          objectKind: object.objectKind,
          resourceKey: Value(object.resourceKey),
          sizeBytes: Value(object.sizeBytes),
          md5Checksum: Value(object.md5Checksum),
          modifiedTime: Value(object.modifiedTime),
          rootIdsJson: const Value('[]'),
          isTombstoned: const Value(true),
          lastSeenJobId: Value(jobId),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    await _database.markTrackPendingDeleteByDriveFileId(driveId);
    final descendants = await _database.getAllDescendants(driveId);
    for (final descendant in descendants) {
      await _database.markTrackPendingDeleteByDriveFileId(descendant.driveId);
      await _database.upsertDriveObject(
        DriveObjectsCompanion.insert(
          driveId: descendant.driveId,
          parentDriveId: Value(descendant.parentDriveId),
          name: descendant.name,
          mimeType: descendant.mimeType,
          objectKind: descendant.objectKind,
          resourceKey: Value(descendant.resourceKey),
          sizeBytes: Value(descendant.sizeBytes),
          md5Checksum: Value(descendant.md5Checksum),
          modifiedTime: Value(descendant.modifiedTime),
          rootIdsJson: const Value('[]'),
          isTombstoned: const Value(true),
          lastSeenJobId: Value(jobId),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> _reconcileFolderMembership(
    int jobId,
    String folderDriveId,
    int? rootId,
  ) async {
    final descendants = await _database.getAllDescendants(folderDriveId);
    for (final descendant in descendants) {
      final resolvedRootId = await _resolveRootIdForDriveObject(descendant);
      await _database.upsertDriveObject(
        DriveObjectsCompanion.insert(
          driveId: descendant.driveId,
          parentDriveId: Value(descendant.parentDriveId),
          name: descendant.name,
          mimeType: descendant.mimeType,
          objectKind: descendant.objectKind,
          resourceKey: Value(descendant.resourceKey),
          sizeBytes: Value(descendant.sizeBytes),
          md5Checksum: Value(descendant.md5Checksum),
          modifiedTime: Value(descendant.modifiedTime),
          rootIdsJson: Value(_encodeRootIds(resolvedRootId ?? rootId)),
          isTombstoned: const Value(false),
          lastSeenJobId: Value(jobId),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (descendant.objectKind != DriveObjectKind.file.value ||
          !_isAudioFile(name: descendant.name, mimeType: descendant.mimeType)) {
        continue;
      }

      final existingTrack = await _database.getTrackByDriveFileId(descendant.driveId);
      if (resolvedRootId == null) {
        if (existingTrack != null) {
          await _database.markTrackPendingDeleteByDriveFileId(descendant.driveId);
        }
        continue;
      }

      final entry = DriveObjectEntry(
        id: descendant.driveId,
        name: descendant.name,
        mimeType: descendant.mimeType,
        modifiedTime: descendant.modifiedTime,
        resourceKey: descendant.resourceKey,
        sizeBytes: descendant.sizeBytes,
        md5Checksum: descendant.md5Checksum,
        parentIds: descendant.parentDriveId == null
            ? const <String>[]
            : <String>[descendant.parentDriveId!],
      );
      await _projectAudioCandidate(
        rootId: resolvedRootId,
        entry: entry,
        existingTrack: existingTrack,
      );
    }
  }

  Future<bool> _projectAudioCandidate({
    required int rootId,
    required DriveObjectEntry entry,
    required Track? existingTrack,
  }) async {
    final projection = _buildProjectedAudioCandidate(
      rootId: rootId,
      entry: entry,
      existingTrack: existingTrack,
    );
    if (projection.shouldInvalidateCache && existingTrack != null) {
      await _trackCacheService.removeCachedTrackFiles([existingTrack]);
    }
    await _database.upsertTrack(projection.row);
    return projection.contentChanged;
  }

  _ProjectedTrackCandidate _buildProjectedAudioCandidate({
    required int rootId,
    required DriveObjectEntry entry,
    required Track? existingTrack,
  }) {
    final fingerprint = _contentFingerprintForEntry(entry);
    final contentChanged =
        existingTrack == null || existingTrack.contentFingerprint != fingerprint;
    final defaultTitle = _defaultTitleFromFileName(entry.name);
    final shouldUseProjectedTitle =
        existingTrack == null ||
        existingTrack.metadataStatus != TrackMetadataStatus.ready.value;
    final projectedTitle =
        shouldUseProjectedTitle ? defaultTitle : existingTrack.title;
    final projectedArtist = existingTrack?.artist ?? '';

    return _ProjectedTrackCandidate(
      row: TracksCompanion.insert(
        id: existingTrack == null
            ? const Value.absent()
            : Value(existingTrack.id),
        rootId: rootId,
        driveFileId: entry.id,
        resourceKey: Value(entry.resourceKey),
        fileName: entry.name,
        title: projectedTitle,
        titleSort: Value(projectedTitle.trim().toLowerCase()),
        artist: projectedArtist,
        artistSort: Value(projectedArtist.trim().toLowerCase()),
        album: existingTrack?.album ?? '',
        albumArtist: existingTrack?.albumArtist ?? '',
        genre: existingTrack?.genre ?? '',
        year: Value(existingTrack?.year),
        trackNumber: Value(existingTrack?.trackNumber ?? 0),
        discNumber: Value(existingTrack?.discNumber ?? 0),
        durationMs: Value(existingTrack?.durationMs ?? 0),
        mimeType: entry.mimeType,
        sizeBytes: Value(entry.sizeBytes),
        md5Checksum: Value(entry.md5Checksum),
        modifiedTime: Value(entry.modifiedTime),
        artworkUri: Value(existingTrack?.artworkUri),
        artworkBlobId: Value(existingTrack?.artworkBlobId),
        artworkStatus: Value(
          existingTrack == null
              ? TrackArtworkStatus.pending.value
              : contentChanged
              ? TrackArtworkStatus.pending.value
              : existingTrack.artworkStatus,
        ),
        cachePath: contentChanged
            ? const Value(null)
            : Value(existingTrack.cachePath),
        cacheStatus: Value(
          contentChanged ? 'none' : existingTrack.cacheStatus,
        ),
        metadataStatus: Value(
          existingTrack == null
              ? TrackMetadataStatus.pending.value
              : contentChanged
              ? TrackMetadataStatus.stale.value
              : existingTrack.metadataStatus,
        ),
        metadataSchemaVersion: Value(
          existingTrack == null || contentChanged
              ? repairableTrackMetadataSchemaVersion
              : existingTrack.metadataSchemaVersion,
        ),
        indexStatus: Value(TrackIndexStatus.active.value),
        contentFingerprint: Value(fingerprint),
        updatedAt: Value(DateTime.now()),
        removedAt: const Value(null),
      ),
      contentChanged: contentChanged,
      shouldInvalidateCache: existingTrack != null && contentChanged,
    );
  }

  Future<int?> _resolveRootIdFromParents(List<String> parentIds) async {
    if (parentIds.isEmpty) {
      return null;
    }

    final roots = await _database.getRoots();
    final rootsByFolderId = {for (final root in roots) root.folderId: root};
    final queue = List<String>.from(parentIds);
    final visited = <String>{};

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (!visited.add(current)) {
        continue;
      }

      final root = rootsByFolderId[current];
      if (root != null) {
        return root.id;
      }

      final object = await _database.getDriveObjectById(current);
      final parentId = object?.parentDriveId;
      if (parentId != null && parentId.isNotEmpty) {
        queue.add(parentId);
      }
    }

    return null;
  }

  Future<int?> _resolveRootIdForDriveObject(DriveObject object) {
    return _resolveRootIdFromParents(
      object.parentDriveId == null ? const <String>[] : <String>[object.parentDriveId!],
    );
  }

  Future<int> _writeArtworkBlob(
    String hash,
    DriveExtractedArtwork artwork,
  ) async {
    final directory = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'artwork-cache'),
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final filePath = p.join(directory.path, '$hash${artwork.fileExtension}');
    final file = File(filePath);
    if (!await file.exists()) {
      await file.writeAsBytes(artwork.bytes, flush: true);
    }

    return _database.upsertArtworkBlob(
      ArtworkBlobsCompanion.insert(
        contentHash: hash,
        mimeType: artwork.mimeType,
        fileExtension: artwork.fileExtension,
        filePath: file.path,
        byteSize: artwork.bytes.length,
      ),
    );
  }

  Future<void> _insertProjectedTracks(List<TracksCompanion> rows) async {
    if (rows.isEmpty) {
      return;
    }

    final batchSize = _executionProfile.trackProjectionBatchSize;
    for (var start = 0; start < rows.length; start += batchSize) {
      final end = start + batchSize > rows.length ? rows.length : start + batchSize;
      await _database.insertAllTracksOnConflictUpdate(rows.sublist(start, end));
    }
  }

  ScanTasksCompanion _buildExtractTagsTask({
    required int jobId,
    required int rootId,
    required String driveFileId,
    required String fingerprint,
    int? repairSchemaVersion,
  }) {
    final repairPayload = repairSchemaVersion == null
        ? null
        : <String, Object?>{
            'repairSchemaVersion': repairSchemaVersion,
          };
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
      payloadJson: Value(
        jsonEncode(<String, Object?>{
          ...?repairPayload,
        }),
      ),
      priority: const Value(20),
    );
  }

  String _contentFingerprintForEntry(DriveObjectEntry entry) {
    return buildContentFingerprint(
      md5Checksum: entry.md5Checksum,
      sizeBytes: entry.sizeBytes,
      modifiedTime: entry.modifiedTime,
    );
  }

  Map<String, dynamic> _decodePayload(String payloadJson) {
    final decoded = jsonDecode(payloadJson);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return const <String, dynamic>{};
  }

  String _encodeRootIds(int? rootId) {
    return jsonEncode(rootId == null ? const <int>[] : <int>[rootId]);
  }

  bool _isAudioFile({
    required String name,
    required String mimeType,
  }) {
    if (mimeType.startsWith('audio/')) {
      return true;
    }

    final lowerName = name.toLowerCase();
    return lowerName.endsWith('.mp3') ||
        lowerName.endsWith('.m4a') ||
        lowerName.endsWith('.aac') ||
        lowerName.endsWith('.flac') ||
        lowerName.endsWith('.ogg') ||
        lowerName.endsWith('.opus') ||
        lowerName.endsWith('.wav');
  }

  String _defaultTitleFromFileName(String fileName) {
    final extension = p.extension(fileName);
    if (extension.isEmpty) {
      return fileName;
    }
    return fileName.substring(0, fileName.length - extension.length);
  }

  DriveScanPhase _phaseFromValue(String value) {
    return DriveScanPhase.values.firstWhere(
      (phase) => phase.value == value,
      orElse: () => DriveScanPhase.baselineDiscovery,
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'drive_entities.dart';
import 'drive_http_client.dart';
import 'drive_metadata_catch_up_planner.dart';
import 'drive_scan_execution_profile.dart';
import 'drive_scan_logger.dart';
import 'drive_scan_models.dart';
import 'drive_track_cache_service.dart';
import 'drive_track_projector.dart';

typedef DriveScanQueueDetailsLoader =
    Future<Map<String, Object?>> Function(int jobId);

class DriveDiscoveryService {
  DriveDiscoveryService({
    required AppDatabase database,
    required DriveHttpClient driveHttpClient,
    required DriveTrackProjector trackProjector,
    required DriveTrackCacheService trackCacheService,
    required DriveScanExecutionProfile executionProfile,
    required DriveMetadataCatchUpPlanner metadataCatchUpPlanner,
    required DriveScanLogger logger,
  }) : _database = database,
       _driveHttpClient = driveHttpClient,
       _trackProjector = trackProjector,
       _trackCacheService = trackCacheService,
       _executionProfile = executionProfile,
       _metadataCatchUpPlanner = metadataCatchUpPlanner,
       _logger = logger;

  final AppDatabase _database;
  final DriveHttpClient _driveHttpClient;
  final DriveTrackProjector _trackProjector;
  final DriveTrackCacheService _trackCacheService;
  final DriveScanExecutionProfile _executionProfile;
  final DriveMetadataCatchUpPlanner _metadataCatchUpPlanner;
  final DriveScanLogger _logger;

  Future<bool> processBaselineDiscovery(
    ScanJob job, {
    required DriveScanQueueDetailsLoader loadQueueBacklogDetails,
  }) async {
    final tasks = await _database.takeQueuedScanTasks(
      job.id,
      kind: DriveScanTaskKind.discoverFolder.value,
      limit: _executionProfile.discoveryWorkers,
    );
    if (tasks.isEmpty) {
      _logInfo('phase_empty', context: _jobContext(job));
      return false;
    }

    final stopwatch = Stopwatch()..start();
    _logInfo(
      'discovery_batch_start',
      context: _jobContext(job),
      details: <String, Object?>{
        'taskCount': tasks.length,
        ...await loadQueueBacklogDetails(job.id),
      },
    );
    final errors = <Object>[];
    await Future.wait(
      tasks.map((task) async {
        try {
          await handleDiscoverTask(job, task);
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
      }),
    );

    if (errors.isNotEmpty) {
      throw errors.first;
    }

    _logInfo(
      'discovery_batch_complete',
      context: _jobContext(job, elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{'taskCount': tasks.length},
    );
    return true;
  }

  Future<bool> processIncrementalChanges(
    ScanJob job, {
    required DriveScanQueueDetailsLoader loadQueueBacklogDetails,
  }) async {
    final tasks = await _database.takeQueuedScanTasks(
      job.id,
      kind: DriveScanTaskKind.reconcileChange.value,
      limit: _executionProfile.changeWorkers,
    );
    if (tasks.isEmpty) {
      _logInfo('phase_empty', context: _jobContext(job));
      return false;
    }

    final stopwatch = Stopwatch()..start();
    _logInfo(
      'changes_batch_start',
      context: _jobContext(job),
      details: <String, Object?>{
        'taskCount': tasks.length,
        ...await loadQueueBacklogDetails(job.id),
      },
    );
    final errors = <Object>[];
    await Future.wait(
      tasks.map((task) async {
        try {
          await handleChangeTask(job, task);
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
      }),
    );

    if (errors.isNotEmpty) {
      throw errors.first;
    }

    _logInfo(
      'changes_batch_complete',
      context: _jobContext(job, elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{'taskCount': tasks.length},
    );
    return true;
  }

  Future<void> handleDiscoverTask(ScanJob job, ScanTask task) async {
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
      details: <String, Object?>{'pageToken': payload['pageToken'] as String?},
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
      final parentDriveId = entry.parentIds.isEmpty
          ? folderId
          : entry.parentIds.first;
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
      final projection = _trackProjector.buildProjectedAudioCandidate(
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
          _metadataCatchUpPlanner.buildExtractTagsTask(
            jobId: job.id,
            rootId: rootId,
            driveFileId: entry.id,
            fingerprint: _trackProjector.contentFingerprintForEntry(entry),
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
            jsonEncode(<String, Object?>{'pageToken': page.nextPageToken}),
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

  Future<void> handleChangeTask(ScanJob job, ScanTask task) async {
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
            jsonEncode(<String, Object?>{'pageToken': page.nextPageToken}),
          ),
          priority: const Value(100),
        ),
      ]);
    }
    _logInfo(
      'changes_page_complete',
      context: _jobContext(
        job,
        taskId: task.id,
        elapsedMs: stopwatch.elapsedMilliseconds,
      ),
      details: <String, Object?>{
        'changeCount': page.changes.length,
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
        parentDriveId: Value(
          file.parentIds.isEmpty ? null : file.parentIds.first,
        ),
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

    if (!_isAudioFile(name: file.name, mimeType: file.mimeType) ||
        rootId == null) {
      return;
    }

    final existingTrack = await _database.getTrackByDriveFileId(file.id);
    final didChange = await _trackProjector.projectAudioCandidate(
      rootId: rootId,
      entry: file,
      existingTrack: existingTrack,
    );
    if (didChange) {
      await _database.enqueueScanTasks([
        _metadataCatchUpPlanner.buildExtractTagsTask(
          jobId: job.id,
          rootId: rootId,
          driveFileId: file.id,
          fingerprint: _trackProjector.contentFingerprintForEntry(file),
        ),
      ]);
    }
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

  Future<void> _insertProjectedTracks(List<TracksCompanion> rows) async {
    if (rows.isEmpty) {
      return;
    }

    final batchSize = _executionProfile.trackProjectionBatchSize;
    for (var start = 0; start < rows.length; start += batchSize) {
      final end = start + batchSize > rows.length
          ? rows.length
          : start + batchSize;
      await _database.insertAllTracksOnConflictUpdate(rows.sublist(start, end));
    }
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

      final existingTrack = await _database.getTrackByDriveFileId(
        descendant.driveId,
      );
      if (resolvedRootId == null) {
        if (existingTrack != null) {
          await _database.markTrackPendingDeleteByDriveFileId(
            descendant.driveId,
          );
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
      await _trackProjector.projectAudioCandidate(
        rootId: resolvedRootId,
        entry: entry,
        existingTrack: existingTrack,
      );
    }
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
      object.parentDriveId == null
          ? const <String>[]
          : <String>[object.parentDriveId!],
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

  bool _isAudioFile({required String name, required String mimeType}) {
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

  void _logError(
    String operation, {
    required DriveScanLogContext context,
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
    required Object error,
    required StackTrace stackTrace,
  }) {
    _logger.error(
      prefix: 'DriveScan',
      subsystem: 'orchestration',
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
}

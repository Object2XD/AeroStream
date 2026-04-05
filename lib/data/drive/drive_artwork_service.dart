import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'drive_download_debug_meter.dart';
import 'drive_scan_logger.dart';
import 'drive_scan_models.dart';
import 'drive_track_cache_service.dart';
import 'extraction/drive_artwork_extractor.dart';

typedef DriveArtworkProgressApplier =
    Future<void> Function(
      int jobId, {
      int metadataReadyDelta,
      int artworkReadyDelta,
      int failedCountDelta,
    });

typedef DriveScanQueueLogDetailsLoader =
    Future<Map<String, Object?>> Function(int jobId);

class DriveArtworkService {
  DriveArtworkService({
    required AppDatabase database,
    required DriveArtworkExtractor artworkExtractor,
    required DriveTrackCacheService trackCacheService,
    required DriveScanLogger logger,
  }) : _database = database,
       _artworkExtractor = artworkExtractor,
       _trackCacheService = trackCacheService,
       _logger = logger;

  final AppDatabase _database;
  final DriveArtworkExtractor _artworkExtractor;
  final DriveTrackCacheService _trackCacheService;
  final DriveScanLogger _logger;

  Future<bool> processArtworkEnrichment(
    ScanJob job, {
    required int artworkWorkers,
    required DriveScanQueueLogDetailsLoader loadQueueBacklogDetails,
    required DriveArtworkProgressApplier applyJobProgressDelta,
    required Future<bool> Function(int jobId) isCancelRequested,
  }) async {
    if (await isCancelRequested(job.id)) {
      _logWarning(
        'scan_cancel_detected',
        context: _jobContext(job),
        details: const <String, Object?>{'phase': 'artwork_enrichment'},
      );
      return true;
    }
    final tasks = await _database.takeQueuedScanTasks(
      job.id,
      kind: DriveScanTaskKind.extractArtwork.value,
      limit: artworkWorkers,
    );
    if (tasks.isEmpty) {
      _logInfo('phase_empty', context: _jobContext(job));
      return false;
    }

    await _flushArtworkTaskBatch(
      job,
      tasks,
      loadQueueBacklogDetails: loadQueueBacklogDetails,
      applyJobProgressDelta: applyJobProgressDelta,
      isCancelRequested: isCancelRequested,
    );
    return true;
  }

  Future<void> finalizePendingDeletes() async {
    final pendingDeletion = await _database.tracksPendingDeletion();
    for (final track in pendingDeletion) {
      await _trackCacheService.removeCachedTrackFile(track);
      await _database.markTrackRemovedById(track.id);
    }
  }

  Future<void> _flushArtworkTaskBatch(
    ScanJob job,
    List<ScanTask> tasks, {
    required DriveScanQueueLogDetailsLoader loadQueueBacklogDetails,
    required DriveArtworkProgressApplier applyJobProgressDelta,
    required Future<bool> Function(int jobId) isCancelRequested,
  }) async {
    if (tasks.isEmpty) {
      return;
    }
    final stopwatch = Stopwatch()..start();
    _logInfo(
      'artwork_batch_start',
      context: _jobContext(job),
      details: <String, Object?>{
        'taskCount': tasks.length,
        ...await loadQueueBacklogDetails(job.id),
      },
    );

    final outcomes = await Future.wait(
      tasks.map((task) => _extractArtworkOutcome(task, jobId: job.id)),
    );
    if (await isCancelRequested(job.id)) {
      await _database.cancelQueuedAndRunningScanTasks(
        job.id,
        kind: DriveScanTaskKind.extractArtwork.value,
      );
      _logWarning(
        'artwork_cancel_drop',
        context: _jobContext(job, elapsedMs: stopwatch.elapsedMilliseconds),
        details: <String, Object?>{'taskCount': tasks.length},
      );
      return;
    }
    final successes = outcomes.whereType<_ArtworkTaskSuccess>().toList(
      growable: false,
    );
    final failures = outcomes.whereType<_ArtworkTaskFailure>().toList(
      growable: false,
    );
    final skippedTaskIds = tasks
        .where(
          (task) => !successes.any((success) => success.task.id == task.id),
        )
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
    await applyJobProgressDelta(
      job.id,
      artworkReadyDelta:
          successes.fold<int>(0, (delta, success) {
            if (success.artwork != null &&
                success.track.artworkStatus != TrackArtworkStatus.ready.value) {
              return delta + 1;
            }
            if (success.artwork == null &&
                success.track.artworkStatus == TrackArtworkStatus.ready.value) {
              return delta - 1;
            }
            return delta;
          }) +
          failures.fold<int>(0, (delta, failure) {
            if (failure.track?.artworkStatus ==
                TrackArtworkStatus.ready.value) {
              return delta - 1;
            }
            return delta;
          }),
      failedCountDelta:
          successes
                  .where((success) => _doesSuccessClearFailure(success.track))
                  .length *
              -1 +
          failures
              .where(
                (failure) => _doesFailureIncreaseFailedCount(failure.track),
              )
              .length,
    );
    _logInfo(
      'artwork_batch_complete',
      context: _jobContext(job, elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{
        'taskCount': tasks.length,
        'successCount': successes.length,
        'failureCount': failures.length,
        'skippedCount': skippedTaskIds.length,
      },
    );
  }

  Future<Object> _extractArtworkOutcome(
    ScanTask task, {
    required int jobId,
  }) async {
    final driveId = task.targetDriveId;
    if (driveId == null) {
      return task;
    }

    final track = await _database.getTrackByDriveFileId(driveId);
    if (track == null || track.indexStatus == TrackIndexStatus.removed.value) {
      return task;
    }

    try {
      final artwork = await _artworkExtractor.extract(
        track,
        debugContext: DriveDownloadDebugContext(
          meter: DriveDownloadDebugMeter(),
          component: DriveDownloadDebugComponent.artwork,
          driveFileId: track.driveFileId,
          jobId: jobId,
          taskId: task.id,
        ),
      );
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

  bool _doesFailureIncreaseFailedCount(Track? track) {
    if (track == null) {
      return false;
    }
    return track.metadataStatus != TrackMetadataStatus.failed.value &&
        track.artworkStatus != TrackArtworkStatus.failed.value;
  }

  bool _doesSuccessClearFailure(Track track) {
    return track.metadataStatus != TrackMetadataStatus.failed.value &&
        track.artworkStatus == TrackArtworkStatus.failed.value;
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

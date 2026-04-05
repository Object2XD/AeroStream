import '../database/app_database.dart';
import 'drive_download_debug_meter.dart';
import 'drive_scan_models.dart';
import 'extraction/drive_metadata_extractor.dart';
import 'metadata_pipeline_backlog.dart';
import 'metadata_pipeline_flush_writer.dart';

typedef MetadataPipelineErrorLogger =
    void Function(
      String operation, {
      required ScanTask task,
      required Track? track,
      required Object error,
      required StackTrace stackTrace,
      Map<String, Object?> details,
    });

typedef MetadataPipelineStagePersister =
    Future<void> Function(
      int taskId, {
      required DriveMetadataTaskRuntimeStage stage,
    });

typedef MetadataPipelineWorkEnqueuer =
    Future<void> Function({
      required MetadataPipelineStage stage,
      required MetadataPipelineWorkItem item,
    });

typedef MetadataPipelineFlushEnqueuer =
    Future<void> Function(MetadataPipelineFlushItem item);
typedef MetadataPipelineCancellationChecker = Future<bool> Function();
typedef MetadataPipelineReadAbortChecker = bool Function();

class MetadataPipelineWorkItem {
  const MetadataPipelineWorkItem({
    required this.task,
    this.track,
    this.metadataSession,
    this.formatKey = 'other',
    this.downloadDebugContext,
  });

  final ScanTask task;
  final Track? track;
  final DrivePreparedMetadataSession? metadataSession;
  final String formatKey;
  final DriveDownloadDebugContext? downloadDebugContext;

  MetadataPipelineWorkItem copyWith({
    Track? track,
    DrivePreparedMetadataSession? metadataSession,
    String? formatKey,
    DriveDownloadDebugContext? downloadDebugContext,
  }) {
    return MetadataPipelineWorkItem(
      task: task,
      track: track ?? this.track,
      metadataSession: metadataSession ?? this.metadataSession,
      formatKey: formatKey ?? this.formatKey,
      downloadDebugContext: downloadDebugContext ?? this.downloadDebugContext,
    );
  }
}

class MetadataPipelineStageExecutor {
  MetadataPipelineStageExecutor({
    required AppDatabase database,
    required DriveMetadataExtractor metadataExtractor,
    required MetadataPipelineRuntimeTracker telemetry,
    required MetadataPipelineErrorLogger logError,
    required MetadataPipelineStagePersister persistTaskStage,
    required MetadataPipelineWorkEnqueuer enqueueStage,
    required MetadataPipelineFlushEnqueuer enqueueFlush,
    required MetadataPipelineCancellationChecker isCancellationRequested,
    required MetadataPipelineReadAbortChecker shouldAbortRead,
  }) : _database = database,
       _metadataExtractor = metadataExtractor,
       _telemetry = telemetry,
       _logError = logError,
       _persistTaskStage = persistTaskStage,
       _enqueueStage = enqueueStage,
       _enqueueFlush = enqueueFlush,
       _isCancellationRequested = isCancellationRequested,
       _shouldAbortRead = shouldAbortRead;

  final AppDatabase _database;
  final DriveMetadataExtractor _metadataExtractor;
  final MetadataPipelineRuntimeTracker _telemetry;
  final MetadataPipelineErrorLogger _logError;
  final MetadataPipelineStagePersister _persistTaskStage;
  final MetadataPipelineWorkEnqueuer _enqueueStage;
  final MetadataPipelineFlushEnqueuer _enqueueFlush;
  final MetadataPipelineCancellationChecker _isCancellationRequested;
  final MetadataPipelineReadAbortChecker _shouldAbortRead;

  Future<void> handle(
    MetadataPipelineStage stage,
    MetadataPipelineWorkItem item,
  ) {
    return switch (stage) {
      MetadataPipelineStage.fetchHead => _handleFetch(item),
      MetadataPipelineStage.analyzeHead => _handleFetch(item),
      MetadataPipelineStage.plan => _handleFetch(item),
      MetadataPipelineStage.fetch => _handleFetch(item),
      MetadataPipelineStage.parse => _handleParse(item),
      MetadataPipelineStage.flush => throw UnsupportedError(
        'Flush stage is handled by the flush worker.',
      ),
    };
  }

  Future<void> _handleFetch(MetadataPipelineWorkItem item) async {
    final task = item.task;
    final driveId = task.targetDriveId;
    if (driveId == null) {
      await _persistTaskStage(
        task.id,
        stage: DriveMetadataTaskRuntimeStage.fetch,
      );
      _telemetry.startStage(
        task.id,
        stage: MetadataPipelineStage.fetch,
        formatKey: item.formatKey,
      );
      _telemetry.completeStage(task.id, stage: MetadataPipelineStage.fetch);
      await _enqueueFlush(
        MetadataPipelineFlushItem.skipped(
          task: task,
          formatKey: item.formatKey,
        ),
      );
      return;
    }

    final track = item.track ?? await _database.getTrackByDriveFileId(driveId);
    final formatKey =
        _metadataExtractor.formatKeyForTrack(track) ?? item.formatKey;
    await _persistTaskStage(
      task.id,
      stage: DriveMetadataTaskRuntimeStage.fetch,
    );
    _telemetry.startStage(
      task.id,
      stage: MetadataPipelineStage.fetch,
      formatKey: formatKey,
    );
    if (track == null || track.indexStatus == TrackIndexStatus.removed.value) {
      _telemetry.completeStage(task.id, stage: MetadataPipelineStage.fetch);
      await _enqueueFlush(
        MetadataPipelineFlushItem.skipped(
          task: task,
          track: track,
          formatKey: formatKey,
        ),
      );
      return;
    }

    final debugContext =
        item.downloadDebugContext ??
        DriveDownloadDebugContext(
          meter: DriveDownloadDebugMeter(),
          component: DriveDownloadDebugComponent.metadata,
          driveFileId: track.driveFileId,
          jobId: task.jobId,
          taskId: task.id,
        );
    try {
      final session = _metadataExtractor.prepareSession(
        track,
        debugContext: debugContext,
        shouldAbortRead: _shouldAbortRead,
      );
      await session.probeAndPlanAndFetch();
      if (await _isCancellationRequested()) {
        _telemetry.completeStage(task.id, stage: MetadataPipelineStage.fetch);
        _metadataExtractor.finalizeMetadataDebugSession(
          debugContext,
          canceled: true,
        );
        await _enqueueFlush(
          MetadataPipelineFlushItem.canceled(task: task, formatKey: formatKey),
        );
        return;
      }
      _telemetry.completeStage(task.id, stage: MetadataPipelineStage.fetch);
      await _enqueueStage(
        stage: MetadataPipelineStage.parse,
        item: item.copyWith(
          track: track,
          metadataSession: session,
          formatKey: formatKey,
          downloadDebugContext: debugContext,
        ),
      );
    } catch (error, stackTrace) {
      if (await _isCancellationRequested()) {
        _telemetry.failStage(task.id, stage: MetadataPipelineStage.fetch);
        _metadataExtractor.finalizeMetadataDebugSession(
          debugContext,
          canceled: true,
        );
        await _enqueueFlush(
          MetadataPipelineFlushItem.canceled(task: task, formatKey: formatKey),
        );
        return;
      }
      _logError(
        'task_fail',
        task: task,
        track: track,
        error: error,
        stackTrace: stackTrace,
        details: const <String, Object?>{'kind': 'extract_tags'},
      );
      _telemetry.failStage(task.id, stage: MetadataPipelineStage.fetch);
      _metadataExtractor.finalizeMetadataDebugSession(debugContext);
      await _enqueueFlush(
        MetadataPipelineFlushItem.failure(
          task: task,
          track: track,
          error: error.toString(),
          formatKey: formatKey,
        ),
      );
    }
  }

  Future<void> _handleParse(MetadataPipelineWorkItem item) async {
    final task = item.task;
    final session = item.metadataSession;
    final track = item.track;
    final debugContext = item.downloadDebugContext;
    var canceled = false;
    if (session == null) {
      throw StateError('metadataSession must be prepared before parse stage');
    }
    if (track == null) {
      throw StateError('track must be available before parse stage');
    }
    await _persistTaskStage(
      task.id,
      stage: DriveMetadataTaskRuntimeStage.parse,
    );
    _telemetry.startStage(
      task.id,
      stage: MetadataPipelineStage.parse,
      formatKey: item.formatKey,
    );
    try {
      final metadata = await session.parse();
      if (await _isCancellationRequested()) {
        canceled = true;
        _telemetry.completeStage(task.id, stage: MetadataPipelineStage.parse);
        await _enqueueFlush(
          MetadataPipelineFlushItem.canceled(
            task: task,
            track: track,
            formatKey: item.formatKey,
          ),
        );
        return;
      }
      _telemetry.completeStage(task.id, stage: MetadataPipelineStage.parse);
      await _enqueueFlush(
        MetadataPipelineFlushItem.success(
          task: task,
          track: track,
          metadata: metadata,
          shouldEnqueueArtwork:
              track.artworkStatus != TrackArtworkStatus.ready.value,
          formatKey: item.formatKey,
        ),
      );
    } catch (error, stackTrace) {
      _logError(
        'task_fail',
        task: task,
        track: track,
        error: error,
        stackTrace: stackTrace,
        details: const <String, Object?>{'kind': 'extract_tags'},
      );
      _telemetry.failStage(task.id, stage: MetadataPipelineStage.parse);
      await _enqueueFlush(
        MetadataPipelineFlushItem.failure(
          task: task,
          track: track,
          error: error.toString(),
          formatKey: item.formatKey,
        ),
      );
    } finally {
      if (debugContext != null) {
        _metadataExtractor.finalizeMetadataDebugSession(
          debugContext,
          canceled: canceled,
        );
      }
    }
  }
}

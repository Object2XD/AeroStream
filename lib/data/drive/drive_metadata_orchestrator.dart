import '../database/app_database.dart';
import 'drive_scan_defaults.dart';
import 'drive_scan_execution_profile.dart';
import 'drive_scan_logger.dart';
import 'drive_scan_models.dart';
import 'drive_scan_progress_refresher.dart';
import 'metadata_pipeline_runtime.dart';
import 'extraction/drive_metadata_extractor.dart';

class DriveMetadataOrchestrator {
  DriveMetadataOrchestrator({
    required AppDatabase database,
    required DriveMetadataExtractor metadataExtractor,
    required DriveScanExecutionProfile executionProfile,
    required DriveScanProgressRefresher progressRefresher,
    required DriveScanLogger logger,
  }) : _database = database,
       _metadataExtractor = metadataExtractor,
       _executionProfile = executionProfile,
       _progressRefresher = progressRefresher,
       _logger = logger;

  final AppDatabase _database;
  final DriveMetadataExtractor _metadataExtractor;
  final DriveScanExecutionProfile _executionProfile;
  final DriveScanProgressRefresher _progressRefresher;
  final DriveScanLogger _logger;

  Future<bool> processPhase(
    ScanJob job, {
    required Future<Map<String, Object?>> Function(int jobId)
    loadQueueBacklogDetails,
    required Future<bool> Function(int jobId) isCancelRequested,
  }) async {
    await recoverMetadataTasks(job, reason: 'metadata_phase');
    await _database.rebalanceQueuedExtractTagsTaskPriorities(
      job.id,
      normalPriority: driveExtractTagsTaskPriority,
      repairPriority: driveExtractTagsRepairTaskPriority,
    );
    final metadataBacklog = await _database.countQueuedScanTasks(
      job.id,
      kind: DriveScanTaskKind.extractTags.value,
      includeRunning: true,
    );
    if (metadataBacklog == 0) {
      _logInfo('phase_empty', context: _jobContext(job));
      await _progressRefresher.refreshJobProgress(job, force: true);
      return false;
    }

    _logInfo(
      'metadata_scheduler_state',
      context: _jobContext(job),
      details: <String, Object?>{
        'metadataBacklog': metadataBacklog,
        ...await loadQueueBacklogDetails(job.id),
      },
    );
    final currentBacklog = await _database.getScanPipelineBacklog(job.id);
    if (currentBacklog.metadata.queuedCount >
        _executionProfile.metadataHighWatermark) {
      _logWarning(
        'metadata_queue_backlog_high',
        context: _jobContext(job),
        details: <String, Object?>{
          'queuedCount': currentBacklog.metadata.queuedCount,
          'highWatermark': _executionProfile.metadataHighWatermark,
        },
      );
    }

    final runtime = MetadataPipelineRuntime(
      database: _database,
      metadataExtractor: _metadataExtractor,
      job: job,
      config: MetadataPipelineRuntimeConfig.fromExecutionProfile(
        _executionProfile,
      ),
      artworkTaskPriority: driveExtractArtworkTaskPriority,
      logInfo: (operation, {details = const <String, Object?>{}}) {
        _logInfo(operation, context: _jobContext(job), details: details);
      },
      logWarning: (operation, {details = const <String, Object?>{}}) {
        _logWarning(operation, context: _jobContext(job), details: details);
      },
      logError:
          (
            operation, {
            required task,
            required track,
            required error,
            required stackTrace,
            details = const <String, Object?>{},
          }) {
            _logError(
              operation,
              context: DriveScanLogContext(
                jobId: job.id,
                taskId: task.id,
                rootId: task.rootId,
                phase: DriveScanPhase.metadataEnrichment.value,
                driveFileId: track?.driveFileId ?? task.targetDriveId,
              ),
              details: details,
              error: error,
              stackTrace: stackTrace,
            );
          },
      applyJobProgressDelta: ({metadataReadyDelta = 0, failedCountDelta = 0}) =>
          _progressRefresher.applyJobProgressDelta(
            job.id,
            metadataReadyDelta: metadataReadyDelta,
            failedCountDelta: failedCountDelta,
          ),
      loadQueueBacklogDetails: () => loadQueueBacklogDetails(job.id),
      cancelRequested: () => isCancelRequested(job.id),
    );
    final runtimeResult = await runtime.runUntilDrain();
    if (runtimeResult.canceled) {
      _logWarning('metadata_cancel_drain', context: _jobContext(job));
      return true;
    }
    await _progressRefresher.refreshJobProgress(job, force: true);
    return false;
  }

  Future<void> recoverMetadataTasks(
    ScanJob job, {
    required String reason,
    bool reclaimAllRunning = false,
  }) async {
    final staleBefore = reclaimAllRunning
        ? DateTime.now().add(const Duration(days: 3650))
        : DateTime.now().subtract(_executionProfile.metadataTaskLeaseTimeout);
    final reclaimed = await _database.reclaimStaleRunningScanTasks(
      job.id,
      staleBefore: staleBefore,
      kind: DriveScanTaskKind.extractTags.value,
    );
    if (reclaimed.isEmpty) {
      return;
    }

    _logWarning(
      'metadata_stale_task_reclaimed',
      context: _jobContext(job),
      details: <String, Object?>{
        'reason': reason,
        'reclaimedTaskCount': reclaimed.length,
        'leaseTimeoutMs':
            _executionProfile.metadataTaskLeaseTimeout.inMilliseconds,
        'taskIds': reclaimed.map((task) => task.id).toList(growable: false),
        'runtimeStages': reclaimed
            .map((task) => task.runtimeStage)
            .whereType<String>()
            .toList(growable: false),
      },
    );
    _logWarning(
      'metadata_pipeline_stall_detected',
      context: _jobContext(job),
      details: <String, Object?>{
        'reason': reason,
        'reclaimedTaskCount': reclaimed.length,
        'leaseTimeoutMs':
            _executionProfile.metadataTaskLeaseTimeout.inMilliseconds,
      },
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

  DriveScanLogContext _jobContext(ScanJob job) {
    return DriveScanLogContext(
      jobId: job.id,
      rootId: job.rootId,
      phase: job.phase,
    );
  }
}

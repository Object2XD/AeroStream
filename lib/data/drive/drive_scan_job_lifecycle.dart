import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'drive_artwork_service.dart';
import 'drive_http_client.dart';
import 'drive_metadata_orchestrator.dart';
import 'drive_scan_logger.dart';
import 'drive_scan_models.dart';
import 'drive_scan_progress_refresher.dart';
import 'drive_scan_root_resolver.dart';

class DriveScanJobStartResult {
  const DriveScanJobStartResult._({required this.job, required this.shouldRun});

  const DriveScanJobStartResult.ready(ScanJob job)
    : this._(job: job, shouldRun: true);

  const DriveScanJobStartResult.stop(ScanJob? job)
    : this._(job: job, shouldRun: false);

  final ScanJob? job;
  final bool shouldRun;
}

class DriveScanJobLifecycle {
  DriveScanJobLifecycle({
    required AppDatabase database,
    required DriveHttpClient driveHttpClient,
    required DriveScanRootResolver rootResolver,
    required DriveMetadataOrchestrator metadataOrchestrator,
    required DriveScanProgressRefresher progressRefresher,
    required DriveArtworkService artworkService,
    required DriveScanLogger logger,
  }) : _database = database,
       _driveHttpClient = driveHttpClient,
       _rootResolver = rootResolver,
       _metadataOrchestrator = metadataOrchestrator,
       _progressRefresher = progressRefresher,
       _artworkService = artworkService,
       _logger = logger;

  final AppDatabase _database;
  final DriveHttpClient _driveHttpClient;
  final DriveScanRootResolver _rootResolver;
  final DriveMetadataOrchestrator _metadataOrchestrator;
  final DriveScanProgressRefresher _progressRefresher;
  final DriveArtworkService _artworkService;
  final DriveScanLogger _logger;

  Future<ScanJob?> prepareBootstrapResume() async {
    final activeJob = await _database.getLatestActiveScanJob();
    if (activeJob == null) {
      return null;
    }
    _logInfo(
      'bootstrap_resume_job',
      context: _jobContext(activeJob),
      details: <String, Object?>{'state': activeJob.state},
    );
    await _metadataOrchestrator.recoverMetadataTasks(
      activeJob,
      reason: 'bootstrap',
      reclaimAllRunning: true,
    );
    await _database.requeueRunningScanTasks(activeJob.id);
    return activeJob;
  }

  Future<void> pauseJob(int jobId) async {
    await _database.updateScanJob(
      jobId,
      ScanJobsCompanion(state: Value(DriveScanJobState.paused.value)),
    );
    _logInfo('job_pause', context: DriveScanLogContext(jobId: jobId));
  }

  Future<void> resumeJob(int jobId) async {
    await _database.requeueRunningScanTasks(jobId);
    await _database.updateScanJob(
      jobId,
      ScanJobsCompanion(state: Value(DriveScanJobState.queued.value)),
    );
    _logInfo('job_resume', context: DriveScanLogContext(jobId: jobId));
  }

  Future<void> requestCancel(int jobId) async {
    await _database.updateScanJob(
      jobId,
      ScanJobsCompanion(state: Value(DriveScanJobState.cancelRequested.value)),
    );
    _logInfo(
      'job_cancel_requested',
      context: DriveScanLogContext(jobId: jobId),
    );
  }

  Future<bool> isCancelRequested(int jobId) async {
    final job = await _database.getScanJobById(jobId);
    return job?.state == DriveScanJobState.cancelRequested.value;
  }

  Future<DriveScanJobStartResult> prepareJobStart(int jobId) async {
    final initialJob = await _database.getScanJobById(jobId);
    if (initialJob == null) {
      _logWarning('job_missing', context: DriveScanLogContext(jobId: jobId));
      return const DriveScanJobStartResult.stop(null);
    }

    await _metadataOrchestrator.recoverMetadataTasks(
      initialJob,
      reason: 'job_start',
      reclaimAllRunning: true,
    );
    await _database.requeueRunningScanTasks(jobId);
    if (initialJob.state == DriveScanJobState.cancelRequested.value) {
      _logInfo(
        'job_cancel_requested_before_start',
        context: _jobContext(initialJob),
      );
      await cancelJob(initialJob);
      return DriveScanJobStartResult.stop(initialJob);
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

    final roots = await _rootResolver.resolveRootsForExistingJob(initialJob);
    for (final root in roots) {
      await _database.updateRootState(
        root.id,
        syncStateValue: DriveScanJobState.running.value,
        activeJobIdValue: jobId,
        lastErrorValue: null,
      );
    }
    return DriveScanJobStartResult.ready(initialJob);
  }

  Future<bool> handleControlState(ScanJob job) async {
    if (job.state == DriveScanJobState.paused.value) {
      _logInfo('job_paused', context: _jobContext(job));
      return true;
    }
    if (job.state == DriveScanJobState.cancelRequested.value) {
      _logInfo('job_canceling', context: _jobContext(job));
      await cancelJob(job);
      return true;
    }
    return false;
  }

  Future<void> finalizeJob(ScanJob job) async {
    final pendingDeletion = await _database.tracksPendingDeletion();
    final stopwatch = Stopwatch()..start();
    _logInfo(
      'finalize_start',
      context: _jobContext(job),
      details: <String, Object?>{'pendingDeleteCount': pendingDeletion.length},
    );
    await _artworkService.finalizePendingDeletes();

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

    final roots = await _rootResolver.resolveRootsForExistingJob(job);
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

    await _progressRefresher.refreshJobProgress(job, force: true);
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
    _progressRefresher.clearJob(job.id);
  }

  Future<void> cancelJob(ScanJob job) async {
    final stopwatch = Stopwatch()..start();
    await _database.cancelQueuedAndRunningScanTasks(job.id);
    await _database.updateScanJob(
      job.id,
      ScanJobsCompanion(
        state: Value(DriveScanJobState.canceled.value),
        finishedAt: Value(DateTime.now()),
      ),
    );
    _logInfo(
      'job_canceled',
      context: _jobContext(job, elapsedMs: stopwatch.elapsedMilliseconds),
    );

    final roots = await _rootResolver.resolveRootsForExistingJob(job);
    for (final root in roots) {
      await _database.updateRootState(
        root.id,
        syncStateValue: DriveScanJobState.canceled.value,
        activeJobIdValue: null,
      );
    }
    _progressRefresher.clearJob(job.id);
  }

  Future<void> failJob(ScanJob job, Object error, StackTrace stackTrace) async {
    final summary = _summarizeError(error);
    await _database.updateScanJob(
      job.id,
      ScanJobsCompanion(
        state: Value(DriveScanJobState.failed.value),
        lastError: Value(summary),
        finishedAt: Value(DateTime.now()),
      ),
    );

    final roots = await _rootResolver.resolveRootsForExistingJob(job);
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
    _progressRefresher.clearJob(job.id);
  }

  String _summarizeError(Object error) {
    final text = error.toString().trim();
    if (text.isEmpty) {
      return 'Unknown scan error';
    }
    return text.split('\n').first.trim();
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

  DriveScanLogContext _jobContext(ScanJob job, {int? elapsedMs}) {
    return DriveScanLogContext(
      jobId: job.id,
      rootId: job.rootId,
      phase: job.phase,
      elapsedMs: elapsedMs,
    );
  }
}

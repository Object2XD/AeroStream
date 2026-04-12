import 'dart:async';

import '../database/app_database.dart';
import 'drive_auth_repository.dart';
import 'drive_entities.dart';
import 'drive_metadata_catch_up_planner.dart';
import 'drive_scan_job_enqueuer.dart';
import 'drive_scan_job_lifecycle.dart';
import 'drive_scan_logger.dart';
import 'drive_scan_models.dart';
import 'drive_scan_phase_executor.dart';

class DriveScanRunner {
  DriveScanRunner({
    required AppDatabase database,
    DriveScanLogger logger = const NoOpDriveScanLogger(),
    bool autoRun = true,
    required DriveScanJobEnqueuer jobEnqueuer,
    required DriveMetadataCatchUpPlanner catchUpPlanner,
    required DriveScanJobLifecycle jobLifecycle,
    required DriveScanPhaseExecutor phaseExecutor,
  }) : _database = database,
       _logger = logger,
       _autoRun = autoRun,
       _jobEnqueuer = jobEnqueuer,
       _catchUpPlanner = catchUpPlanner,
       _jobLifecycle = jobLifecycle,
       _phaseExecutor = phaseExecutor;

  final AppDatabase _database;
  final DriveScanLogger _logger;
  final bool _autoRun;
  final DriveScanJobEnqueuer _jobEnqueuer;
  final DriveMetadataCatchUpPlanner _catchUpPlanner;
  final DriveScanJobLifecycle _jobLifecycle;
  final DriveScanPhaseExecutor _phaseExecutor;

  Future<void>? _runner;

  Future<void> bootstrap() async {
    final activeJob = await _jobLifecycle.prepareBootstrapResume();
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
      await _catchUpPlanner.enqueueMetadataCatchUpJobIfNeeded(
        account,
        autoRun: _autoRun,
        ensureRunner: _ensureRunner,
      );
      return;
    }
    if (activeJob.state == DriveScanJobState.paused.value) {
      _logInfo('bootstrap_paused_job', context: _jobContext(activeJob));
      return;
    }

    if (_autoRun) {
      _ensureRunner();
    }
  }

  Future<int?> enqueueSync({int? rootId}) {
    return _jobEnqueuer.enqueueSync(
      rootId: rootId,
      autoRun: _autoRun,
      ensureRunner: _ensureRunner,
    );
  }

  Future<void> pauseJob(int jobId) => _jobLifecycle.pauseJob(jobId);

  Future<void> resumeJob(int jobId) async {
    await _jobLifecycle.resumeJob(jobId);
    if (_autoRun) {
      _ensureRunner();
    }
  }

  Future<void> cancelJob(int jobId) async {
    await _jobLifecycle.requestCancel(jobId);
    if (_autoRun) {
      _ensureRunner();
    }
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
    final start = await _jobLifecycle.prepareJobStart(jobId);
    if (!start.shouldRun) {
      return;
    }

    while (true) {
      final job = await _database.getScanJobById(jobId);
      if (job == null) {
        return;
      }
      if (await _jobLifecycle.handleControlState(job)) {
        return;
      }

      try {
        final result = await _phaseExecutor.executeNextStep(job);
        if (result.isTerminal) {
          return;
        }
      } catch (error, stackTrace) {
        if (await _shouldDeferToReconnectState(job, error)) {
          _logInfo('job_reauth_required', context: _jobContext(job));
          return;
        }
        _logError(
          'job_run_fail',
          context: _jobContext(job),
          error: error,
          stackTrace: stackTrace,
        );
        await _jobLifecycle.failJob(job, error, stackTrace);
        return;
      }
    }
  }

  void _logInfo(
    String operation, {
    DriveScanLogContext context = const DriveScanLogContext(),
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    _logger.info(
      prefix: 'DriveScan',
      subsystem: 'runner',
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
      subsystem: 'runner',
      operation: operation,
      context: context,
      message: message,
      details: details,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<bool> _shouldDeferToReconnectState(ScanJob job, Object error) async {
    if (error is! DriveAuthSessionExpiredException) {
      return false;
    }
    final account = await _database.getActiveAccount();
    return account != null &&
        account.id == job.accountId &&
        account.authSessionState == DriveAuthSessionState.reauthRequired.value;
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

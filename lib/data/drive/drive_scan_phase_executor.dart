import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'drive_artwork_service.dart';
import 'drive_discovery_service.dart';
import 'drive_metadata_orchestrator.dart';
import 'drive_scan_execution_profile.dart';
import 'drive_scan_job_lifecycle.dart';
import 'drive_scan_logger.dart';
import 'drive_scan_models.dart';
import 'drive_scan_phase_codec.dart';
import 'drive_scan_progress_refresher.dart';

class DriveScanPhaseExecutionResult {
  const DriveScanPhaseExecutionResult({required this.isTerminal});

  final bool isTerminal;
}

class DriveScanPhaseExecutor {
  DriveScanPhaseExecutor({
    required AppDatabase database,
    required DriveScanPhaseCodec phaseCodec,
    required DriveDiscoveryService discoveryService,
    required DriveMetadataOrchestrator metadataOrchestrator,
    required DriveArtworkService artworkService,
    required DriveScanJobLifecycle jobLifecycle,
    required DriveScanProgressRefresher progressRefresher,
    required DriveScanExecutionProfile executionProfile,
    required DriveScanLogger logger,
  }) : _database = database,
       _phaseCodec = phaseCodec,
       _discoveryService = discoveryService,
       _metadataOrchestrator = metadataOrchestrator,
       _artworkService = artworkService,
       _jobLifecycle = jobLifecycle,
       _progressRefresher = progressRefresher,
       _executionProfile = executionProfile,
       _logger = logger;

  final AppDatabase _database;
  final DriveScanPhaseCodec _phaseCodec;
  final DriveDiscoveryService _discoveryService;
  final DriveMetadataOrchestrator _metadataOrchestrator;
  final DriveArtworkService _artworkService;
  final DriveScanJobLifecycle _jobLifecycle;
  final DriveScanProgressRefresher _progressRefresher;
  final DriveScanExecutionProfile _executionProfile;
  final DriveScanLogger _logger;

  Future<DriveScanPhaseExecutionResult> executeNextStep(ScanJob job) async {
    _logInfo(
      'phase_enter',
      context: _jobContext(job),
      details: await _queueBacklogLogDetails(job.id),
    );
    switch (_phaseCodec.phaseFromValue(job.phase)) {
      case DriveScanPhase.baselineDiscovery:
        final hasMore = await _discoveryService.processBaselineDiscovery(
          job,
          loadQueueBacklogDetails: _queueBacklogLogDetails,
        );
        if (!hasMore) {
          await _completePhase(
            job,
            nextPhase: DriveScanPhase.metadataEnrichment.value,
          );
        }
      case DriveScanPhase.incrementalChanges:
        final hasMore = await _discoveryService.processIncrementalChanges(
          job,
          loadQueueBacklogDetails: _queueBacklogLogDetails,
        );
        if (!hasMore) {
          await _completePhase(
            job,
            nextPhase: DriveScanPhase.metadataEnrichment.value,
          );
        }
      case DriveScanPhase.metadataEnrichment:
        final hasMore = await _metadataOrchestrator.processPhase(
          job,
          loadQueueBacklogDetails: _queueBacklogLogDetails,
          isCancelRequested: _jobLifecycle.isCancelRequested,
        );
        if (!hasMore) {
          await _completePhase(
            job,
            nextPhase: DriveScanPhase.artworkEnrichment.value,
          );
        }
      case DriveScanPhase.artworkEnrichment:
        final hasMore = await _artworkService.processArtworkEnrichment(
          job,
          artworkWorkers: _executionProfile.artworkWorkers,
          loadQueueBacklogDetails: _queueBacklogLogDetails,
          applyJobProgressDelta: _progressRefresher.applyJobProgressDelta,
          isCancelRequested: _jobLifecycle.isCancelRequested,
        );
        if (!hasMore) {
          await _completePhase(job, nextPhase: DriveScanPhase.finalize.value);
        }
      case DriveScanPhase.finalize:
        await _jobLifecycle.finalizeJob(job);
        return const DriveScanPhaseExecutionResult(isTerminal: true);
    }

    await _progressRefresher.refreshJobProgress(job);
    return const DriveScanPhaseExecutionResult(isTerminal: false);
  }

  Future<void> _completePhase(ScanJob job, {required String nextPhase}) async {
    _logInfo('phase_complete', context: _jobContext(job));
    await _database.updateScanJob(
      job.id,
      ScanJobsCompanion(phase: Value(nextPhase)),
    );
  }

  Future<Map<String, Object?>> _queueBacklogLogDetails(int jobId) async {
    final backlog = await _database.getScanPipelineBacklog(jobId);
    return <String, Object?>{
      'queuedByKind': backlog.queuedByKind(),
      'runningByKind': backlog.runningByKind(),
      'failedByKind': backlog.failedByKind(),
    };
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

  DriveScanLogContext _jobContext(ScanJob job) {
    return DriveScanLogContext(
      jobId: job.id,
      rootId: job.rootId,
      phase: job.phase,
    );
  }
}

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'drive_scan_defaults.dart';
import 'drive_scan_logger.dart';
import 'drive_scan_models.dart';
import 'drive_scan_root_resolver.dart';

class DriveScanProgressRefresher {
  DriveScanProgressRefresher({
    required AppDatabase database,
    required DriveScanRootResolver rootResolver,
    required DriveScanLogger logger,
    Duration metadataRefreshInterval = driveMetadataProgressRefreshInterval,
  }) : _database = database,
       _rootResolver = rootResolver,
       _logger = logger,
       _metadataRefreshInterval = metadataRefreshInterval;

  final AppDatabase _database;
  final DriveScanRootResolver _rootResolver;
  final DriveScanLogger _logger;
  final Duration _metadataRefreshInterval;
  final Map<int, DateTime> _lastMetadataProgressRefreshAt = <int, DateTime>{};

  Future<void> refreshJobProgress(ScanJob job, {bool force = false}) async {
    final shouldThrottle =
        !force &&
        job.phase == DriveScanPhase.metadataEnrichment.value &&
        !_shouldRefreshMetadataProgress(job.id);
    if (shouldThrottle) {
      _logInfo('job_progress_refresh_deferred', context: _jobContext(job));
      return;
    }

    _logInfo(
      'job_progress_refresh',
      context: _jobContext(job),
      details: <String, Object?>{'force': force},
    );
    final roots = await _rootResolver.resolveRootsForExistingJob(job);
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
    if (job.phase == DriveScanPhase.metadataEnrichment.value) {
      _lastMetadataProgressRefreshAt[job.id] = DateTime.now();
    }
  }

  Future<void> applyJobProgressDelta(
    int jobId, {
    int metadataReadyDelta = 0,
    int artworkReadyDelta = 0,
    int failedCountDelta = 0,
  }) async {
    if (metadataReadyDelta == 0 &&
        artworkReadyDelta == 0 &&
        failedCountDelta == 0) {
      return;
    }
    final job = await _database.getScanJobById(jobId);
    if (job == null) {
      return;
    }
    await _database.updateScanJob(
      jobId,
      ScanJobsCompanion(
        metadataReadyCount: Value(
          _clampNonNegative(job.metadataReadyCount + metadataReadyDelta),
        ),
        artworkReadyCount: Value(
          _clampNonNegative(job.artworkReadyCount + artworkReadyDelta),
        ),
        failedCount: Value(
          _clampNonNegative(job.failedCount + failedCountDelta),
        ),
      ),
    );
  }

  void clearJob(int jobId) {
    _lastMetadataProgressRefreshAt.remove(jobId);
  }

  bool _shouldRefreshMetadataProgress(int jobId) {
    final lastRefreshedAt = _lastMetadataProgressRefreshAt[jobId];
    if (lastRefreshedAt == null) {
      return true;
    }
    return DateTime.now().difference(lastRefreshedAt) >=
        _metadataRefreshInterval;
  }

  int _clampNonNegative(int value) => value < 0 ? 0 : value;

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

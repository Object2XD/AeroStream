import 'dart:async';

import '../database/app_database.dart';
import 'drive_scan_execution_profile.dart';
import 'drive_scan_models.dart';
import 'metadata_pipeline_backlog.dart';
import 'metadata_pipeline_flush_writer.dart';
import 'metadata_pipeline_stage_executor.dart';
import 'metadata_pipeline_stage_queue.dart';
import 'extraction/drive_metadata_extractor.dart';

typedef MetadataPipelineInfoLogger =
    void Function(String operation, {Map<String, Object?> details});
typedef MetadataPipelineWarningLogger =
    void Function(String operation, {Map<String, Object?> details});
typedef MetadataPipelineQueueDetailsLoader =
    Future<Map<String, Object?>> Function();
typedef MetadataPipelineCancelRequested = Future<bool> Function();

class MetadataPipelineRuntimeConfig {
  const MetadataPipelineRuntimeConfig({
    required this.fetchWorkers,
    required this.parseWorkers,
    required this.flushWorkers,
    required this.fetchQueueHighWatermark,
    required this.parseQueueHighWatermark,
    required this.maxParseQueuedBeforeRefillThrottle,
    required this.flushQueueHighWatermark,
    required this.flushBatchSize,
    required this.flushMaxLatency,
    required this.taskHeartbeatInterval,
    required this.stallWarningThreshold,
  });

  factory MetadataPipelineRuntimeConfig.fromExecutionProfile(
    DriveScanExecutionProfile profile,
  ) {
    return MetadataPipelineRuntimeConfig(
      fetchWorkers:
          profile.metadataFetchWorkers ??
          profile.metadataFetchHeadWorkers ??
          profile.metadataAnalyzeHeadWorkers ??
          profile.metadataPlanWorkers ??
          profile.metadataWorkers,
      parseWorkers: profile.metadataParseWorkers ?? profile.metadataWorkers,
      flushWorkers: 1,
      fetchQueueHighWatermark:
          profile.metadataFetchQueueHighWatermark ??
          profile.metadataFetchHeadQueueHighWatermark ??
          profile.metadataAnalyzeHeadQueueHighWatermark ??
          profile.metadataPlanQueueHighWatermark ??
          profile.metadataWorkers * 4,
      parseQueueHighWatermark:
          profile.metadataParseQueueHighWatermark ??
          profile.metadataWorkers * 2,
      maxParseQueuedBeforeRefillThrottle:
          profile.metadataParseQueueHighWatermark ??
          profile.metadataWorkers * 2,
      flushQueueHighWatermark:
          profile.metadataFlushQueueHighWatermark ??
          profile.metadataWorkers * 2,
      flushBatchSize: profile.metadataFlushBatchSize,
      flushMaxLatency: profile.metadataFlushMaxLatency,
      taskHeartbeatInterval: profile.metadataTaskHeartbeatInterval,
      stallWarningThreshold: profile.metadataTaskStallWarningThreshold,
    );
  }

  final int fetchWorkers;
  final int parseWorkers;
  final int flushWorkers;
  final int fetchQueueHighWatermark;
  final int parseQueueHighWatermark;
  final int maxParseQueuedBeforeRefillThrottle;
  final int flushQueueHighWatermark;
  final int flushBatchSize;
  final Duration flushMaxLatency;
  final Duration taskHeartbeatInterval;
  final Duration stallWarningThreshold;
}

class MetadataPipelineRuntimeResult {
  const MetadataPipelineRuntimeResult({
    required this.successCount,
    required this.failureCount,
    required this.skippedCount,
    required this.canceled,
  });

  final int successCount;
  final int failureCount;
  final int skippedCount;
  final bool canceled;
}

class MetadataPipelineRuntime {
  static const bool _emitSnapshotLogs = false;

  MetadataPipelineRuntime({
    required AppDatabase database,
    required DriveMetadataExtractor metadataExtractor,
    required ScanJob job,
    required MetadataPipelineRuntimeConfig config,
    required int artworkTaskPriority,
    required MetadataPipelineInfoLogger logInfo,
    required MetadataPipelineWarningLogger logWarning,
    required MetadataPipelineErrorLogger logError,
    required MetadataPipelineProgressApplier applyJobProgressDelta,
    required MetadataPipelineQueueDetailsLoader loadQueueBacklogDetails,
    required MetadataPipelineCancelRequested cancelRequested,
    MetadataPipelineTelemetryHub? telemetryHub,
  }) : _database = database,
       _job = job,
       _config = config,
       _logInfo = logInfo,
       _logWarning = logWarning,
       _loadQueueBacklogDetails = loadQueueBacklogDetails,
       _cancelRequested = cancelRequested,
       _telemetry = MetadataPipelineRuntimeTracker(
         jobId: job.id,
         hub: telemetryHub ?? MetadataPipelineTelemetryHub.instance,
       ),
       _fetchQueue = MetadataPipelineStageQueue<MetadataPipelineWorkItem>(
         watermark: config.fetchQueueHighWatermark,
       ),
       _parseQueue = MetadataPipelineStageQueue<MetadataPipelineWorkItem>(
         watermark: config.parseQueueHighWatermark,
       ),
       _flushQueue = MetadataPipelineStageQueue<MetadataPipelineFlushItem>(
         watermark: config.flushQueueHighWatermark,
       ) {
    _flushWriter = MetadataPipelineFlushWriter(
      database: database,
      job: job,
      artworkTaskPriority: artworkTaskPriority,
      applyJobProgressDelta: applyJobProgressDelta,
    );
    _stageExecutor = MetadataPipelineStageExecutor(
      database: database,
      metadataExtractor: metadataExtractor,
      telemetry: _telemetry,
      logError: logError,
      persistTaskStage: _persistTaskStage,
      enqueueStage: ({required stage, required item}) =>
          _enqueueStage(stage: stage, item: item),
      enqueueFlush: _enqueueFlush,
      isCancellationRequested: _isCancellationRequested,
      shouldAbortRead: _shouldAbortRead,
    );
  }

  final AppDatabase _database;
  final ScanJob _job;
  final MetadataPipelineRuntimeConfig _config;
  final MetadataPipelineInfoLogger _logInfo;
  final MetadataPipelineWarningLogger _logWarning;
  final MetadataPipelineQueueDetailsLoader _loadQueueBacklogDetails;
  final MetadataPipelineCancelRequested _cancelRequested;
  final MetadataPipelineRuntimeTracker _telemetry;
  late final MetadataPipelineFlushWriter _flushWriter;
  late final MetadataPipelineStageExecutor _stageExecutor;

  final MetadataPipelineStageQueue<MetadataPipelineWorkItem> _fetchQueue;
  final MetadataPipelineStageQueue<MetadataPipelineWorkItem> _parseQueue;
  final MetadataPipelineStageQueue<MetadataPipelineFlushItem> _flushQueue;

  final Completer<void> _done = Completer<void>();
  final Map<int, DriveMetadataTaskRuntimeStage> _activeTaskStages =
      <int, DriveMetadataTaskRuntimeStage>{};
  Future<void>? _sourceRefillInFlight;
  Timer? _taskHeartbeatTimer;
  int _totalTasks = 0;
  int _successCount = 0;
  int _failureCount = 0;
  int _skippedCount = 0;
  int? _sourceQueuedCount;
  int? _sourceRunningCount;
  bool _stopping = false;
  bool _canceled = false;
  bool _cancelLogged = false;
  Future<void>? _cancelInFlight;
  DateTime? _lastSnapshotLoggedAt;
  DateTime? _lastLeaseHeartbeatAt;
  DateTime? _lastPipelineProgressAt;
  bool _stallWarningEmitted = false;
  bool _parseRefillThrottled = false;

  Future<MetadataPipelineRuntimeResult> runUntilDrain() async {
    final stopwatch = Stopwatch()..start();
    _telemetry.clear();
    _logInfo(
      'metadata_pipeline_start',
      details: <String, Object?>{...await _loadQueueBacklogDetails()},
    );
    await _syncSourceBacklogCounts();
    _telemetry.publishNow();
    _lastPipelineProgressAt = DateTime.now();
    _startTaskHeartbeatTimer();

    final workers = <Future<void>>[
      ...List<Future<void>>.generate(
        _config.fetchWorkers,
        (_) => _runStageWorker(
          stage: MetadataPipelineStage.fetch,
          queue: _fetchQueue,
        ),
      ),
      ...List<Future<void>>.generate(
        _config.parseWorkers,
        (_) => _runStageWorker(
          stage: MetadataPipelineStage.parse,
          queue: _parseQueue,
        ),
      ),
      ...List<Future<void>>.generate(
        _config.flushWorkers,
        (_) => _runFlushWorker(),
      ),
    ];

    await _scheduleSourceRefill();
    await _done.future;
    _stopping = true;
    _taskHeartbeatTimer?.cancel();
    _taskHeartbeatTimer = null;
    _notifyAllQueues();
    await Future.wait(workers);
    await _syncSourceBacklogCounts();
    _telemetry.publishNow();

    _logInfo(
      'metadata_pipeline_complete',
      details: <String, Object?>{
        'taskCount': _totalTasks,
        'successCount': _successCount,
        'failureCount': _failureCount,
        'skippedCount': _skippedCount,
        'canceled': _canceled,
        'elapsedMs': stopwatch.elapsedMilliseconds,
      },
    );
    _logSnapshot(force: true);

    return MetadataPipelineRuntimeResult(
      successCount: _successCount,
      failureCount: _failureCount,
      skippedCount: _skippedCount,
      canceled: _canceled,
    );
  }

  Future<void> _runStageWorker({
    required MetadataPipelineStage stage,
    required MetadataPipelineStageQueue<MetadataPipelineWorkItem> queue,
  }) async {
    while (true) {
      await _checkCancelRequested();
      final item = await queue.take(
        shouldStop: () => _stopping || (_done.isCompleted && queue.isEmpty),
      );
      if (item == null) {
        return;
      }
      if (_canceled) {
        return;
      }
      if (stage == MetadataPipelineStage.fetch) {
        unawaited(_scheduleSourceRefill());
      }
      try {
        await _checkCancelRequested();
        await _stageExecutor.handle(stage, item);
      } finally {
        if (stage == MetadataPipelineStage.parse) {
          unawaited(_scheduleSourceRefill());
        }
        _logSnapshot();
        await _maybeComplete();
      }
    }
  }

  Future<void> _scheduleSourceRefill() {
    if (_stopping || _done.isCompleted) {
      return Future<void>.value();
    }
    return _sourceRefillInFlight ??= _refillSourceQueue().whenComplete(() {
      _sourceRefillInFlight = null;
      unawaited(_maybeComplete());
    });
  }

  Future<void> _refillSourceQueue() async {
    var projectedPipelineOccupancy =
        _fetchQueue.occupancy + _parseQueue.occupancy;
    while (!_stopping) {
      await _checkCancelRequested();
      if (_canceled) {
        break;
      }
      final fetchAvailableSlots = _fetchQueue.watermark - _fetchQueue.occupancy;
      if (fetchAvailableSlots <= 0) {
        break;
      }
      final parseCap = _config.maxParseQueuedBeforeRefillThrottle;
      final parseHeadroom = parseCap - projectedPipelineOccupancy;
      final admissionLimit = parseHeadroom <= 0
          ? 0
          : (fetchAvailableSlots < parseHeadroom
                ? fetchAvailableSlots
                : parseHeadroom);
      if (admissionLimit <= 0) {
        if (!_parseRefillThrottled) {
          _parseRefillThrottled = true;
          _logWarning(
            'metadata_source_refill_throttled',
            details: <String, Object?>{
              'reason': 'parse_queue_cap',
              'fetchAvailableSlots': fetchAvailableSlots,
              'parseOccupancy': _parseQueue.occupancy,
              'fetchOccupancy': _fetchQueue.occupancy,
              'projectedPipelineOccupancy': projectedPipelineOccupancy,
              'parseCap': parseCap,
              'admissionLimit': admissionLimit,
            },
          );
        }
        break;
      }
      final tasks = await _database.takeQueuedScanTasks(
        _job.id,
        kind: DriveScanTaskKind.extractTags.value,
        limit: admissionLimit,
      );
      await _checkCancelRequested();
      if (_canceled) {
        break;
      }
      if (tasks.isEmpty) {
        break;
      }

      _parseRefillThrottled = false;
      _totalTasks += tasks.length;
      for (final task in tasks) {
        _telemetry.queueStage(task.id, stage: MetadataPipelineStage.fetch);
        _fetchQueue.enqueue(MetadataPipelineWorkItem(task: task));
      }
      projectedPipelineOccupancy += tasks.length;
      _logInfo(
        'metadata_source_refill',
        details: <String, Object?>{
          'admittedTaskCount': tasks.length,
          'fetchQueueLength': _fetchQueue.length,
          'fetchAvailableSlots': fetchAvailableSlots,
          'parseOccupancy': _parseQueue.occupancy,
          'fetchOccupancy': _fetchQueue.occupancy,
          'projectedPipelineOccupancy': projectedPipelineOccupancy,
          'parseCap': parseCap,
          'admissionLimit': admissionLimit,
        },
      );
      _sourceQueuedCount = (_sourceQueuedCount ?? 0) - tasks.length;
      if (_sourceQueuedCount! < 0) {
        _sourceQueuedCount = 0;
      }
      _sourceRunningCount = (_sourceRunningCount ?? 0) + tasks.length;
      _telemetry.setSourceBacklog(
        queuedCount: _sourceQueuedCount!,
        runningCount: _sourceRunningCount!,
      );
      _telemetry.publishNow();
      _logSnapshot(force: true);
    }

    await _maybeComplete();
  }

  Future<void> _runFlushWorker() async {
    while (true) {
      await _checkCancelRequested();
      final first = await _flushQueue.take(
        shouldStop: () =>
            _stopping || (_done.isCompleted && _flushQueue.isEmpty),
      );
      if (first == null) {
        return;
      }
      if (_canceled) {
        return;
      }
      final batch = <MetadataPipelineFlushItem>[first];
      await _persistTaskStage(
        first.task.id,
        stage: DriveMetadataTaskRuntimeStage.flush,
      );
      _telemetry.startStage(
        first.task.id,
        stage: MetadataPipelineStage.flush,
        formatKey: first.formatKey,
      );
      final deadline = DateTime.now().add(_config.flushMaxLatency);
      while (batch.length < _config.flushBatchSize) {
        final remaining = deadline.difference(DateTime.now());
        if (remaining <= Duration.zero) {
          break;
        }
        final next = await _flushQueue.take(
          shouldStop: () =>
              _stopping || (_done.isCompleted && _flushQueue.isEmpty),
          timeout: remaining,
        );
        if (next == null) {
          break;
        }
        batch.add(next);
        await _persistTaskStage(
          next.task.id,
          stage: DriveMetadataTaskRuntimeStage.flush,
        );
        _telemetry.startStage(
          next.task.id,
          stage: MetadataPipelineStage.flush,
          formatKey: next.formatKey,
        );
      }
      await _checkCancelRequested();
      if (_canceled) {
        for (final item in batch) {
          _activeTaskStages.remove(item.task.id);
          _telemetry.completeStage(
            item.task.id,
            stage: MetadataPipelineStage.flush,
          );
        }
        _sourceRunningCount = (_sourceRunningCount ?? 0) - batch.length;
        if (_sourceRunningCount! < 0) {
          _sourceRunningCount = 0;
        }
        _telemetry.setSourceBacklog(
          queuedCount: _sourceQueuedCount ?? 0,
          runningCount: _sourceRunningCount!,
        );
        _telemetry.publishNow();
        await _maybeComplete();
        return;
      }
      final counters = await _flushWriter.flushBatch(batch);
      _successCount += counters.successCount;
      _failureCount += counters.failureCount;
      _skippedCount += counters.skippedCount;
      if (counters.successCount > 0 || counters.failureCount > 0) {
        _lastPipelineProgressAt = DateTime.now();
        _stallWarningEmitted = false;
      }
      for (final item in batch) {
        _activeTaskStages.remove(item.task.id);
        _telemetry.completeStage(
          item.task.id,
          stage: MetadataPipelineStage.flush,
        );
      }
      _sourceRunningCount = (_sourceRunningCount ?? 0) - batch.length;
      if (_sourceRunningCount! < 0) {
        _sourceRunningCount = 0;
      }
      _telemetry.setSourceBacklog(
        queuedCount: _sourceQueuedCount ?? 0,
        runningCount: _sourceRunningCount!,
      );
      _telemetry.publishNow();
      await _maybeComplete();
      _logInfo(
        'metadata_flush_batch',
        details: <String, Object?>{
          'flushBatchSize': batch.length,
          'stageOccupancy': _telemetry.snapshot.toJson(),
        },
      );
      _logSnapshot(force: true);
    }
  }

  Future<void> _enqueueStage({
    required MetadataPipelineStage stage,
    required MetadataPipelineWorkItem item,
  }) async {
    final queue = _queueForStage(stage);
    await _persistTaskStage(
      item.task.id,
      stage:
          DriveMetadataTaskRuntimeStage.fromMetadataPipelineStageName(
            stage.name,
          ) ??
          DriveMetadataTaskRuntimeStage.fetch,
    );
    _telemetry.queueStage(
      item.task.id,
      stage: stage,
      formatKey: item.formatKey,
    );
    if (_stopping) {
      return;
    }
    final admittedImmediately = queue.enqueue(
      item,
      onAdmitted: () => _telemetry.unblockStage(item.task.id, stage),
    );
    if (!admittedImmediately) {
      _telemetry.markBlocked(item.task.id, stage);
      _logWarning(
        'metadata_pipeline_stage_blocked',
        details: <String, Object?>{
          'stage': stage.name,
          'taskId': item.task.id,
          'highWatermark': queue.watermark,
        },
      );
    }
  }

  Future<void> _enqueueFlush(MetadataPipelineFlushItem item) async {
    await _persistTaskStage(
      item.task.id,
      stage: DriveMetadataTaskRuntimeStage.flush,
    );
    _telemetry.queueStage(
      item.task.id,
      stage: MetadataPipelineStage.flush,
      formatKey: item.formatKey,
    );
    if (_stopping) {
      return;
    }
    final admittedImmediately = _flushQueue.enqueue(
      item,
      onAdmitted: () =>
          _telemetry.unblockStage(item.task.id, MetadataPipelineStage.flush),
    );
    if (!admittedImmediately) {
      _telemetry.markBlocked(item.task.id, MetadataPipelineStage.flush);
      _logWarning(
        'metadata_pipeline_stage_blocked',
        details: <String, Object?>{
          'stage': MetadataPipelineStage.flush.name,
          'taskId': item.task.id,
          'highWatermark': _flushQueue.watermark,
        },
      );
    }
  }

  MetadataPipelineStageQueue<MetadataPipelineWorkItem> _queueForStage(
    MetadataPipelineStage stage,
  ) {
    return switch (stage) {
      MetadataPipelineStage.fetchHead => _fetchQueue,
      MetadataPipelineStage.analyzeHead => _parseQueue,
      MetadataPipelineStage.plan => _parseQueue,
      MetadataPipelineStage.fetch => _fetchQueue,
      MetadataPipelineStage.parse => _parseQueue,
      MetadataPipelineStage.flush => throw UnsupportedError(
        'Flush queue is managed separately.',
      ),
    };
  }

  bool _shouldAbortRead() => _canceled || _stopping;

  Future<bool> _isCancellationRequested() async {
    await _checkCancelRequested();
    return _canceled;
  }

  Future<void> _checkCancelRequested() async {
    if (_canceled || _done.isCompleted) {
      return;
    }
    final requested = await _cancelRequested();
    if (!requested) {
      return;
    }
    await _beginCancelDrain();
  }

  Future<void> _beginCancelDrain() async {
    if (_canceled) {
      return _cancelInFlight ?? Future<void>.value();
    }
    _canceled = true;
    _stopping = true;
    if (!_cancelLogged) {
      _cancelLogged = true;
      _logWarning(
        'scan_cancel_detected',
        details: const <String, Object?>{'phase': 'metadata_enrichment'},
      );
    }
    _notifyAllQueues();
    _cancelInFlight ??= _database
        .cancelQueuedAndRunningScanTasks(
          _job.id,
          kind: DriveScanTaskKind.extractTags.value,
        )
        .whenComplete(() {
          _cancelInFlight = null;
        });
    await _cancelInFlight;
    if (!_done.isCompleted) {
      _done.complete();
    }
  }

  Future<void> _syncSourceBacklogCounts() async {
    final sourceBacklog = await _database.getScanTaskBacklogEntry(
      _job.id,
      kind: DriveScanTaskKind.extractTags.value,
    );
    _sourceQueuedCount = sourceBacklog.queuedCount;
    _sourceRunningCount = sourceBacklog.runningCount;
    _telemetry.setSourceBacklog(
      queuedCount: _sourceQueuedCount!,
      runningCount: _sourceRunningCount!,
    );
  }

  void _startTaskHeartbeatTimer() {
    _taskHeartbeatTimer?.cancel();
    _taskHeartbeatTimer = Timer.periodic(_config.taskHeartbeatInterval, (_) {
      unawaited(_flushTaskHeartbeats());
    });
  }

  Future<void> _persistTaskStage(
    int taskId, {
    required DriveMetadataTaskRuntimeStage stage,
  }) async {
    _activeTaskStages[taskId] = stage;
    await _database.updateScanTaskRuntimeState(
      taskId,
      runtimeStageValue: stage.value,
    );
    _lastLeaseHeartbeatAt = DateTime.now();
  }

  Future<void> _flushTaskHeartbeats() async {
    if (_stopping || _done.isCompleted || _activeTaskStages.isEmpty) {
      return;
    }
    final heartbeatAt = DateTime.now();
    await _database.updateScanTaskRuntimeStates(<int, String?>{
      for (final entry in _activeTaskStages.entries)
        entry.key: entry.value.value,
    }, heartbeatAt: heartbeatAt);
    _lastLeaseHeartbeatAt = heartbeatAt;
    _emitStallWarningIfNeeded(heartbeatAt);
  }

  void _emitStallWarningIfNeeded(DateTime now) {
    if (_stallWarningEmitted || _activeTaskStages.isEmpty) {
      return;
    }
    final progressAt = _lastPipelineProgressAt;
    final heartbeatAt = _lastLeaseHeartbeatAt;
    if (progressAt == null || heartbeatAt == null) {
      return;
    }
    if (now.difference(progressAt) < _config.stallWarningThreshold) {
      return;
    }
    if (now.difference(heartbeatAt) < _config.stallWarningThreshold) {
      return;
    }
    _stallWarningEmitted = true;
    _logWarning(
      'metadata_pipeline_stall_detected',
      details: <String, Object?>{
        'activeTaskCount': _activeTaskStages.length,
        'lastProgressAt': progressAt.toIso8601String(),
        'lastLeaseHeartbeatAt': heartbeatAt.toIso8601String(),
        'stageOccupancy': _telemetry.snapshot.toJson(),
      },
    );
  }

  Future<void> _maybeComplete() async {
    if (_stopping || _done.isCompleted || _sourceRefillInFlight != null) {
      return;
    }
    if (_sourceQueuedCount == null || _sourceRunningCount == null) {
      await _syncSourceBacklogCounts();
    }
    final snapshot = _telemetry.snapshot;
    final activeRuntimeCount =
        snapshot.fetch.queuedCount +
        snapshot.fetch.runningCount +
        snapshot.fetch.blockedCount +
        snapshot.parse.queuedCount +
        snapshot.parse.runningCount +
        snapshot.parse.blockedCount +
        snapshot.flush.queuedCount +
        snapshot.flush.runningCount +
        snapshot.flush.blockedCount;
    if ((_sourceQueuedCount ?? snapshot.sourceQueuedCount) == 0 &&
        (_sourceRunningCount ?? snapshot.sourceRunningCount) == 0 &&
        activeRuntimeCount == 0) {
      _done.complete();
    }
  }

  void _notifyAllQueues() {
    _fetchQueue.notifyAll();
    _parseQueue.notifyAll();
    _flushQueue.notifyAll();
  }

  void _logSnapshot({bool force = false}) {
    if (!_emitSnapshotLogs) {
      return;
    }
    final now = DateTime.now();
    if (!force &&
        _lastSnapshotLoggedAt != null &&
        now.difference(_lastSnapshotLoggedAt!) < const Duration(seconds: 1)) {
      return;
    }
    _lastSnapshotLoggedAt = now;
    _logInfo(
      'metadata_pipeline_snapshot',
      details: <String, Object?>{
        'metadataPipelineBacklog': _telemetry.snapshot.toJson(),
      },
    );
  }
}

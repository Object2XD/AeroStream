import 'dart:async';

class MetadataPipelineStageBacklog {
  const MetadataPipelineStageBacklog({
    this.queuedCount = 0,
    this.runningCount = 0,
    this.completedCount = 0,
    this.failedCount = 0,
    this.blockedCount = 0,
  });

  final int queuedCount;
  final int runningCount;
  final int completedCount;
  final int failedCount;
  final int blockedCount;

  bool get isEmpty =>
      queuedCount == 0 &&
      runningCount == 0 &&
      completedCount == 0 &&
      failedCount == 0 &&
      blockedCount == 0;

  MetadataPipelineStageBacklog copyWith({
    int? queuedCount,
    int? runningCount,
    int? completedCount,
    int? failedCount,
    int? blockedCount,
  }) {
    return MetadataPipelineStageBacklog(
      queuedCount: queuedCount ?? this.queuedCount,
      runningCount: runningCount ?? this.runningCount,
      completedCount: completedCount ?? this.completedCount,
      failedCount: failedCount ?? this.failedCount,
      blockedCount: blockedCount ?? this.blockedCount,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'queued': queuedCount,
      'running': runningCount,
      'completed': completedCount,
      'failed': failedCount,
      'blocked': blockedCount,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is MetadataPipelineStageBacklog &&
        other.queuedCount == queuedCount &&
        other.runningCount == runningCount &&
        other.completedCount == completedCount &&
        other.failedCount == failedCount &&
        other.blockedCount == blockedCount;
  }

  @override
  int get hashCode => Object.hash(
    queuedCount,
    runningCount,
    completedCount,
    failedCount,
    blockedCount,
  );
}

class MetadataPipelineFormatBreakdown {
  const MetadataPipelineFormatBreakdown({
    this.mp3Running = 0,
    this.m4aRunning = 0,
    this.otherRunning = 0,
  });

  final int mp3Running;
  final int m4aRunning;
  final int otherRunning;

  bool get isEmpty =>
      mp3Running == 0 && m4aRunning == 0 && otherRunning == 0;

  MetadataPipelineFormatBreakdown copyWith({
    int? mp3Running,
    int? m4aRunning,
    int? otherRunning,
  }) {
    return MetadataPipelineFormatBreakdown(
      mp3Running: mp3Running ?? this.mp3Running,
      m4aRunning: m4aRunning ?? this.m4aRunning,
      otherRunning: otherRunning ?? this.otherRunning,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'mp3Running': mp3Running,
      'm4aRunning': m4aRunning,
      'otherRunning': otherRunning,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is MetadataPipelineFormatBreakdown &&
        other.mp3Running == mp3Running &&
        other.m4aRunning == m4aRunning &&
        other.otherRunning == otherRunning;
  }

  @override
  int get hashCode => Object.hash(mp3Running, m4aRunning, otherRunning);
}

class MetadataPipelineBacklog {
  const MetadataPipelineBacklog({
    this.sourceQueuedCount = 0,
    this.sourceRunningCount = 0,
    @Deprecated('Use fetch') MetadataPipelineStageBacklog? fetchHead,
    @Deprecated('Use parse') MetadataPipelineStageBacklog? analyzeHead,
    @Deprecated('Use parse') MetadataPipelineStageBacklog? plan,
    MetadataPipelineStageBacklog fetch = const MetadataPipelineStageBacklog(),
    MetadataPipelineStageBacklog parse = const MetadataPipelineStageBacklog(),
    this.flush = const MetadataPipelineStageBacklog(),
    this.activeFormatBreakdown = const MetadataPipelineFormatBreakdown(),
  }) : fetch = fetchHead ?? fetch,
       parse = analyzeHead ?? plan ?? parse;

  final int sourceQueuedCount;
  final int sourceRunningCount;
  final MetadataPipelineStageBacklog fetch;
  final MetadataPipelineStageBacklog parse;
  final MetadataPipelineStageBacklog flush;
  final MetadataPipelineFormatBreakdown activeFormatBreakdown;

  @Deprecated('Use fetch')
  MetadataPipelineStageBacklog get fetchHead => fetch;

  @Deprecated('Use parse')
  MetadataPipelineStageBacklog get analyzeHead => parse;

  @Deprecated('Use parse')
  MetadataPipelineStageBacklog get plan => parse;

  bool get isEmpty =>
      sourceQueuedCount == 0 &&
      sourceRunningCount == 0 &&
      fetch.isEmpty &&
      parse.isEmpty &&
      flush.isEmpty &&
      activeFormatBreakdown.isEmpty;

  MetadataPipelineBacklog copyWith({
    int? sourceQueuedCount,
    int? sourceRunningCount,
    MetadataPipelineStageBacklog? fetch,
    MetadataPipelineStageBacklog? parse,
    MetadataPipelineStageBacklog? flush,
    MetadataPipelineFormatBreakdown? activeFormatBreakdown,
  }) {
    return MetadataPipelineBacklog(
      sourceQueuedCount: sourceQueuedCount ?? this.sourceQueuedCount,
      sourceRunningCount: sourceRunningCount ?? this.sourceRunningCount,
      fetch: fetch ?? this.fetch,
      parse: parse ?? this.parse,
      flush: flush ?? this.flush,
      activeFormatBreakdown:
          activeFormatBreakdown ?? this.activeFormatBreakdown,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'sourceQueuedCount': sourceQueuedCount,
      'sourceRunningCount': sourceRunningCount,
      'fetch': fetch.toJson(),
      'parse': parse.toJson(),
      'flush': flush.toJson(),
      'activeFormatBreakdown': activeFormatBreakdown.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is MetadataPipelineBacklog &&
        other.sourceQueuedCount == sourceQueuedCount &&
        other.sourceRunningCount == sourceRunningCount &&
        other.fetch == fetch &&
        other.parse == parse &&
        other.flush == flush &&
        other.activeFormatBreakdown == activeFormatBreakdown;
  }

  @override
  int get hashCode => Object.hash(
    sourceQueuedCount,
    sourceRunningCount,
    fetch,
    parse,
    flush,
    activeFormatBreakdown,
  );
}

class MetadataPipelineTelemetryHub {
  MetadataPipelineTelemetryHub({
    Duration? publishCadence,
  }) : _publishCadence = publishCadence ?? const Duration(milliseconds: 100);

  static final MetadataPipelineTelemetryHub instance =
      MetadataPipelineTelemetryHub();

  final Map<int, MetadataPipelineBacklog> _snapshots =
      <int, MetadataPipelineBacklog>{};
  final Map<int, StreamController<MetadataPipelineBacklog>> _controllers =
      <int, StreamController<MetadataPipelineBacklog>>{};
  final Map<int, Timer> _publishTimers = <int, Timer>{};
  final Map<int, MetadataPipelineBacklog> _lastPublished =
      <int, MetadataPipelineBacklog>{};
  final Duration _publishCadence;

  MetadataPipelineBacklog snapshotForJob(int jobId) {
    return _snapshots[jobId] ?? const MetadataPipelineBacklog();
  }

  Stream<MetadataPipelineBacklog> watchJob(int jobId) {
    final controller = _controllers.putIfAbsent(
      jobId,
      () => StreamController<MetadataPipelineBacklog>.broadcast(),
    );
    return controller.stream;
  }

  void updateJob(
    int jobId,
    MetadataPipelineBacklog snapshot, {
    bool immediate = false,
  }) {
    _snapshots[jobId] = snapshot;
    if (immediate) {
      _publishTimers.remove(jobId)?.cancel();
      _publishNow(jobId);
      return;
    }
    if (_lastPublished[jobId] == snapshot || _publishTimers.containsKey(jobId)) {
      return;
    }
    _publishTimers[jobId] = Timer(_publishCadence, () {
      _publishTimers.remove(jobId);
      _publishNow(jobId);
    });
  }

  void clearJob(int jobId) {
    _snapshots.remove(jobId);
    _publishTimers.remove(jobId)?.cancel();
    const empty = MetadataPipelineBacklog();
    if (_lastPublished[jobId] == empty) {
      return;
    }
    _lastPublished[jobId] = empty;
    _controllers[jobId]?.add(empty);
  }

  void _publishNow(int jobId) {
    final snapshot = _snapshots[jobId] ?? const MetadataPipelineBacklog();
    if (_lastPublished[jobId] == snapshot) {
      return;
    }
    _lastPublished[jobId] = snapshot;
    _controllers[jobId]?.add(snapshot);
  }
}

enum MetadataPipelineStage {
  @Deprecated('Use fetch')
  fetchHead,
  @Deprecated('Use parse')
  analyzeHead,
  @Deprecated('Use parse')
  plan,
  fetch,
  parse,
  flush,
}

class MetadataPipelineRuntimeTracker {
  MetadataPipelineRuntimeTracker({
    required this.jobId,
    required this.hub,
  });

  final int jobId;
  final MetadataPipelineTelemetryHub hub;

  final Map<int, _MetadataPipelineTaskRuntime> _tasks =
      <int, _MetadataPipelineTaskRuntime>{};
  MetadataPipelineBacklog _snapshot = const MetadataPipelineBacklog();

  MetadataPipelineBacklog get snapshot => _snapshot;

  MetadataPipelineStage? stageForTask(int taskId) => _tasks[taskId]?.stage;

  void seedTasks(Iterable<int> taskIds) {
    for (final taskId in taskIds) {
      queueStage(taskId, stage: MetadataPipelineStage.fetch);
    }
  }

  void queueStage(
    int taskId, {
    required MetadataPipelineStage stage,
    String? formatKey,
  }) {
    stage = _normalizeStage(stage);
    final runtime = _tasks[taskId];
    final entry = _entryForStage(stage);
    _setEntry(
      stage,
      entry.copyWith(queuedCount: entry.queuedCount + 1),
    );
    _tasks[taskId] = _MetadataPipelineTaskRuntime(
      stage: stage,
      state: _MetadataPipelineTaskState.queued,
      formatKey: formatKey ?? runtime?.formatKey,
    );
    _refreshFormatBreakdown();
    _publish();
  }

  void startStage(
    int taskId, {
    required MetadataPipelineStage stage,
    required String formatKey,
  }) {
    stage = _normalizeStage(stage);
    final runtime = _tasks[taskId];
    if (runtime == null) {
      return;
    }
    final entry = _entryForStage(stage);
    _setEntry(
      stage,
      entry.copyWith(
        queuedCount: runtime.state == _MetadataPipelineTaskState.queued
            ? _decrement(entry.queuedCount)
            : entry.queuedCount,
        blockedCount: runtime.state == _MetadataPipelineTaskState.blocked
            ? _decrement(entry.blockedCount)
            : entry.blockedCount,
        runningCount: entry.runningCount + 1,
      ),
    );
    _tasks[taskId] = runtime.copyWith(
      stage: stage,
      state: _MetadataPipelineTaskState.running,
      formatKey: formatKey,
    );
    _refreshFormatBreakdown();
    _publish();
  }

  void completeStage(
    int taskId, {
    required MetadataPipelineStage stage,
  }) {
    stage = _normalizeStage(stage);
    final runtime = _tasks[taskId];
    if (runtime == null) {
      return;
    }
    final entry = _entryForStage(stage);
    _setEntry(
      stage,
      entry.copyWith(
        runningCount: _decrement(entry.runningCount),
        completedCount: entry.completedCount + 1,
      ),
    );
    _tasks.remove(taskId);
    _refreshFormatBreakdown();
    _publish();
  }

  void failStage(
    int taskId, {
    required MetadataPipelineStage stage,
  }) {
    stage = _normalizeStage(stage);
    final runtime = _tasks[taskId];
    if (runtime == null) {
      return;
    }
    final entry = _entryForStage(stage);
    _setEntry(
      stage,
      entry.copyWith(
        runningCount: _decrement(entry.runningCount),
        failedCount: entry.failedCount + 1,
      ),
    );
    _tasks.remove(taskId);
    _refreshFormatBreakdown();
    _publish();
  }

  void markBlocked(int taskId, MetadataPipelineStage stage) {
    stage = _normalizeStage(stage);
    final runtime = _tasks[taskId];
    if (runtime == null || runtime.state == _MetadataPipelineTaskState.blocked) {
      return;
    }
    final entry = _entryForStage(stage);
    _setEntry(
      stage,
      entry.copyWith(
        queuedCount: _decrement(entry.queuedCount),
        blockedCount: entry.blockedCount + 1,
      ),
    );
    _tasks[taskId] = runtime.copyWith(
      stage: stage,
      state: _MetadataPipelineTaskState.blocked,
    );
    _refreshFormatBreakdown();
    _publish();
  }

  void unblockStage(int taskId, MetadataPipelineStage stage) {
    stage = _normalizeStage(stage);
    final runtime = _tasks[taskId];
    if (runtime == null || runtime.state != _MetadataPipelineTaskState.blocked) {
      return;
    }
    final entry = _entryForStage(stage);
    _setEntry(
      stage,
      entry.copyWith(
        blockedCount: _decrement(entry.blockedCount),
        queuedCount: entry.queuedCount + 1,
      ),
    );
    _tasks[taskId] = runtime.copyWith(
      stage: stage,
      state: _MetadataPipelineTaskState.queued,
    );
    _refreshFormatBreakdown();
    _publish();
  }

  void abandonTask(int taskId) {
    final runtime = _tasks.remove(taskId);
    if (runtime == null) {
      return;
    }
    final entry = _entryForStage(runtime.stage);
    switch (runtime.state) {
      case _MetadataPipelineTaskState.queued:
        _setEntry(
          runtime.stage,
          entry.copyWith(queuedCount: _decrement(entry.queuedCount)),
        );
      case _MetadataPipelineTaskState.running:
        _setEntry(
          runtime.stage,
          entry.copyWith(runningCount: _decrement(entry.runningCount)),
        );
      case _MetadataPipelineTaskState.blocked:
        _setEntry(
          runtime.stage,
          entry.copyWith(blockedCount: _decrement(entry.blockedCount)),
        );
    }
    _refreshFormatBreakdown();
    _publish();
  }

  void clear() {
    _tasks.clear();
    _snapshot = const MetadataPipelineBacklog();
    hub.clearJob(jobId);
  }

  void publishNow() => _publish(immediate: true);

  void setSourceBacklog({
    required int queuedCount,
    required int runningCount,
  }) {
    _snapshot = _snapshot.copyWith(
      sourceQueuedCount: queuedCount,
      sourceRunningCount: runningCount,
    );
    _publish();
  }

  void logSnapshot(
    void Function(
      String operation, {
      Map<String, Object?> details,
    })
    sink, {
    required String operation,
  }) {
    sink(
      operation,
      details: <String, Object?>{
        'fetch': _snapshot.fetch.toJson(),
        'parse': _snapshot.parse.toJson(),
        'flush': _snapshot.flush.toJson(),
        'activeFormatBreakdown': _snapshot.activeFormatBreakdown.toJson(),
      },
    );
  }

  MetadataPipelineStageBacklog _entryForStage(MetadataPipelineStage stage) {
    return switch (stage) {
      MetadataPipelineStage.fetchHead => _snapshot.fetch,
      MetadataPipelineStage.analyzeHead => _snapshot.parse,
      MetadataPipelineStage.plan => _snapshot.parse,
      MetadataPipelineStage.fetch => _snapshot.fetch,
      MetadataPipelineStage.parse => _snapshot.parse,
      MetadataPipelineStage.flush => _snapshot.flush,
    };
  }

  void _setEntry(
    MetadataPipelineStage stage,
    MetadataPipelineStageBacklog entry,
  ) {
    _snapshot = switch (stage) {
      MetadataPipelineStage.fetchHead => _snapshot.copyWith(fetch: entry),
      MetadataPipelineStage.analyzeHead => _snapshot.copyWith(parse: entry),
      MetadataPipelineStage.plan => _snapshot.copyWith(parse: entry),
      MetadataPipelineStage.fetch => _snapshot.copyWith(fetch: entry),
      MetadataPipelineStage.parse => _snapshot.copyWith(parse: entry),
      MetadataPipelineStage.flush => _snapshot.copyWith(flush: entry),
    };
  }

  MetadataPipelineStage _normalizeStage(MetadataPipelineStage stage) {
    return switch (stage) {
      MetadataPipelineStage.fetchHead => MetadataPipelineStage.fetch,
      MetadataPipelineStage.analyzeHead => MetadataPipelineStage.parse,
      MetadataPipelineStage.plan => MetadataPipelineStage.parse,
      MetadataPipelineStage.fetch => MetadataPipelineStage.fetch,
      MetadataPipelineStage.parse => MetadataPipelineStage.parse,
      MetadataPipelineStage.flush => MetadataPipelineStage.flush,
    };
  }

  void _refreshFormatBreakdown() {
    var mp3Running = 0;
    var m4aRunning = 0;
    var otherRunning = 0;
    for (final runtime in _tasks.values) {
      if (runtime.state != _MetadataPipelineTaskState.running) {
        continue;
      }
      switch (runtime.formatKey) {
        case 'mp3':
          mp3Running += 1;
        case 'm4a':
          m4aRunning += 1;
        default:
          otherRunning += 1;
      }
    }
    _snapshot = _snapshot.copyWith(
      activeFormatBreakdown: MetadataPipelineFormatBreakdown(
        mp3Running: mp3Running,
        m4aRunning: m4aRunning,
        otherRunning: otherRunning,
      ),
    );
  }

  void _publish({bool immediate = false}) {
    hub.updateJob(jobId, _snapshot, immediate: immediate);
  }

  int _decrement(int value) => value > 0 ? value - 1 : 0;
}

enum _MetadataPipelineTaskState { queued, running, blocked }

class _MetadataPipelineTaskRuntime {
  const _MetadataPipelineTaskRuntime({
    required this.stage,
    required this.state,
    required this.formatKey,
  });

  final MetadataPipelineStage stage;
  final _MetadataPipelineTaskState state;
  final String? formatKey;

  _MetadataPipelineTaskRuntime copyWith({
    MetadataPipelineStage? stage,
    _MetadataPipelineTaskState? state,
    String? formatKey,
  }) {
    return _MetadataPipelineTaskRuntime(
      stage: stage ?? this.stage,
      state: state ?? this.state,
      formatKey: formatKey ?? this.formatKey,
    );
  }
}

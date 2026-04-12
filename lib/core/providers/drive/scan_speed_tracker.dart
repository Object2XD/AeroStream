import 'dart:collection';

import '../../../data/database/app_database.dart';
import '../../../data/drive/drive_scan_models.dart';

class ScanSpeedTracker {
  ScanSpeedTracker({DateTime Function()? now, Duration? rollingWindow})
    : _now = now ?? DateTime.now,
      _rollingWindow = rollingWindow ?? const Duration(seconds: 30);

  final DateTime Function() _now;
  final Duration _rollingWindow;
  _ScanSpeedJobRecord? _record;

  void observe(ScanJob? job) {
    if (job == null) {
      clear();
      return;
    }

    final trackedCount = _trackedCount(job);
    final previous = _record;
    final isRunning =
        job.state == DriveScanJobState.running.value && trackedCount != null;
    if (!isRunning) {
      _record = _ScanSpeedJobRecord(
        jobId: job.id,
        phase: job.phase,
        state: job.state,
        trackedCount: trackedCount,
        samples: ListQueue<_ScanSpeedSample>(),
      );
      return;
    }

    final shouldResetForJobChange =
        previous == null || previous.jobId != job.id;
    final shouldResetForPhaseChange =
        previous != null && previous.phase != job.phase;
    final shouldResetForResume =
        previous != null && previous.state != DriveScanJobState.running.value;
    final shouldResetForCountDecrease =
        previous != null &&
        previous.trackedCount != null &&
        trackedCount < previous.trackedCount!;

    if (shouldResetForJobChange ||
        shouldResetForPhaseChange ||
        shouldResetForResume ||
        shouldResetForCountDecrease) {
      _record = _ScanSpeedJobRecord(
        jobId: job.id,
        phase: job.phase,
        state: job.state,
        trackedCount: trackedCount,
        samples: ListQueue<_ScanSpeedSample>(),
      );
      return;
    }

    _record = previous.copyWith(state: job.state, trackedCount: trackedCount);
  }

  void sampleNow() {
    final record = _record;
    if (record == null ||
        record.state != DriveScanJobState.running.value ||
        record.trackedCount == null) {
      return;
    }

    final now = _now();
    final samples = ListQueue<_ScanSpeedSample>.from(record.samples)
      ..addLast(
        _ScanSpeedSample(trackedCount: record.trackedCount!, observedAt: now),
      );
    final windowStart = now.subtract(_rollingWindow);
    while (samples.length > 1 &&
        samples.first.observedAt.isBefore(windowStart)) {
      samples.removeFirst();
    }

    _record = record.copyWith(samples: samples);
  }

  double? currentRate() {
    final record = _record;
    if (record == null ||
        record.state != DriveScanJobState.running.value ||
        record.trackedCount == null) {
      return null;
    }

    if (record.samples.length < 2) {
      return 0.0;
    }

    final first = record.samples.first;
    final last = record.samples.last;
    final elapsedMs = last.observedAt
        .difference(first.observedAt)
        .inMilliseconds;
    if (elapsedMs <= 0) {
      return 0.0;
    }
    final countDelta = last.trackedCount - first.trackedCount;
    if (countDelta <= 0) {
      return 0.0;
    }
    return countDelta * 1000 / elapsedMs;
  }

  void clear() => _record = null;

  int? _trackedCount(ScanJob job) {
    return switch (job.phase) {
      'baseline_discovery' || 'incremental_changes' => job.indexedCount,
      'metadata_enrichment' => job.metadataReadyCount,
      'artwork_enrichment' => job.artworkReadyCount,
      _ => null,
    };
  }
}

class _ScanSpeedJobRecord {
  const _ScanSpeedJobRecord({
    required this.jobId,
    required this.phase,
    required this.state,
    required this.trackedCount,
    required this.samples,
  });

  final int jobId;
  final String phase;
  final String state;
  final int? trackedCount;
  final ListQueue<_ScanSpeedSample> samples;

  _ScanSpeedJobRecord copyWith({
    String? phase,
    String? state,
    int? trackedCount,
    ListQueue<_ScanSpeedSample>? samples,
  }) {
    return _ScanSpeedJobRecord(
      jobId: jobId,
      phase: phase ?? this.phase,
      state: state ?? this.state,
      trackedCount: trackedCount ?? this.trackedCount,
      samples: samples ?? ListQueue<_ScanSpeedSample>.from(this.samples),
    );
  }
}

class _ScanSpeedSample {
  const _ScanSpeedSample({
    required this.trackedCount,
    required this.observedAt,
  });

  final int trackedCount;
  final DateTime observedAt;
}

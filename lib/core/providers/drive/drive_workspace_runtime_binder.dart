import 'dart:async';

import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/drive/drive_scan_backlog.dart';
import '../../../data/drive/drive_scan_models.dart';
import '../../../data/drive/metadata_pipeline_backlog.dart';
import 'drive_sync_progress.dart';
import 'drive_workspace_state.dart';
import 'scan_speed_tracker.dart';

class DriveWorkspaceRuntimeBinder {
  DriveWorkspaceRuntimeBinder({
    required Ref ref,
    required AppDatabase database,
    required ScanSpeedTracker speedTracker,
    required Duration scanSpeedTickInterval,
    required Future<DriveWorkspaceState> Function({
      bool isMutating,
      String? errorMessage,
    })
    loadState,
    required AsyncValue<DriveWorkspaceState> Function() readState,
    required void Function(DriveWorkspaceState state) writeState,
  }) : _ref = ref,
       _database = database,
       _speedTracker = speedTracker,
       _scanSpeedTickInterval = scanSpeedTickInterval,
       _loadState = loadState,
       _readState = readState,
       _writeState = writeState;

  final Ref _ref;
  final AppDatabase _database;
  final ScanSpeedTracker _speedTracker;
  final Duration _scanSpeedTickInterval;
  final Future<DriveWorkspaceState> Function({
    bool isMutating,
    String? errorMessage,
  })
  _loadState;
  final AsyncValue<DriveWorkspaceState> Function() _readState;
  final void Function(DriveWorkspaceState state) _writeState;

  StreamSubscription<SyncAccount?>? _accountSubscription;
  StreamSubscription<List<SyncRoot>>? _rootsSubscription;
  StreamSubscription<int>? _cacheSubscription;
  StreamSubscription<ScanJob?>? _jobSubscription;
  StreamSubscription<ScanPipelineBacklog>? _taskBacklogSubscription;
  StreamSubscription<MetadataPipelineBacklog>? _metadataPipelineSubscription;
  Timer? _scanSpeedTimer;
  int? _taskBacklogJobId;
  int? _metadataPipelineJobId;

  void startWatchers() {
    _accountSubscription ??= _database.watchActiveAccount().listen((_) async {
      await _reloadStatePreservingUiFlags();
    });
    _rootsSubscription ??= _database.watchRoots().listen((_) async {
      await _reloadStatePreservingUiFlags();
    });
    _cacheSubscription ??= _database.watchCacheSizeBytes().listen((_) async {
      await _reloadStatePreservingUiFlags();
    });
    _jobSubscription ??= _database.watchLatestActiveScanJob().listen((_) async {
      await _reloadStatePreservingUiFlags();
    });
  }

  void attach(DriveSyncProgress? progress) {
    _syncTaskBacklogSubscription(progress);
    _syncMetadataPipelineSubscription(progress);
    _syncScanSpeedTimer(progress);
  }

  Future<void> dispose() async {
    _stopScanSpeedTimer();
    await _accountSubscription?.cancel();
    await _rootsSubscription?.cancel();
    await _cacheSubscription?.cancel();
    await _jobSubscription?.cancel();
    await _taskBacklogSubscription?.cancel();
    await _metadataPipelineSubscription?.cancel();
  }

  Future<void> _reloadStatePreservingUiFlags() async {
    if (!_ref.mounted) {
      return;
    }
    final currentState = _readState().asData?.value;
    final nextState = await _loadState(
      isMutating: currentState?.isMutating ?? false,
      errorMessage: currentState?.errorMessage,
    );
    if (!_ref.mounted) {
      return;
    }
    attach(nextState.syncProgress);
    _writeState(nextState);
  }

  void _syncTaskBacklogSubscription(DriveSyncProgress? progress) {
    final nextJobId = progress?.jobId;
    if (nextJobId == null) {
      unawaited(_taskBacklogSubscription?.cancel());
      _taskBacklogSubscription = null;
      _taskBacklogJobId = null;
      return;
    }
    if (_taskBacklogJobId == nextJobId && _taskBacklogSubscription != null) {
      return;
    }
    unawaited(_taskBacklogSubscription?.cancel());
    _taskBacklogJobId = nextJobId;
    _taskBacklogSubscription = _database
        .watchScanPipelineBacklog(nextJobId)
        .listen(_applyPipelineBacklogUpdate);
  }

  void _syncMetadataPipelineSubscription(DriveSyncProgress? progress) {
    final shouldWatch =
        progress != null &&
        progress.phase == DriveScanPhase.metadataEnrichment.value;
    final nextJobId = shouldWatch ? progress.jobId : null;
    if (nextJobId == null) {
      unawaited(_metadataPipelineSubscription?.cancel());
      _metadataPipelineSubscription = null;
      _metadataPipelineJobId = null;
      return;
    }
    if (_metadataPipelineJobId == nextJobId &&
        _metadataPipelineSubscription != null) {
      return;
    }
    unawaited(_metadataPipelineSubscription?.cancel());
    _metadataPipelineJobId = nextJobId;
    _metadataPipelineSubscription = MetadataPipelineTelemetryHub.instance
        .watchJob(nextJobId)
        .distinct()
        .listen(_applyMetadataPipelineBacklogUpdate);
  }

  void _applyPipelineBacklogUpdate(ScanPipelineBacklog backlog) {
    _updateSyncProgress((progress) {
      if (progress.jobId != _taskBacklogJobId) {
        return progress;
      }
      if (progress.pipelineBacklog == backlog) {
        return progress;
      }
      return progress.copyWith(pipelineBacklog: Value(backlog));
    });
  }

  void _applyMetadataPipelineBacklogUpdate(MetadataPipelineBacklog backlog) {
    _updateSyncProgress((progress) {
      if (progress.jobId != _metadataPipelineJobId ||
          progress.phase != DriveScanPhase.metadataEnrichment.value ||
          progress.metadataPipelineBacklog == backlog) {
        return progress;
      }
      return progress.copyWith(metadataPipelineBacklog: Value(backlog));
    });
  }

  void _updateSyncProgress(
    DriveSyncProgress Function(DriveSyncProgress progress) update,
  ) {
    if (!_ref.mounted) {
      return;
    }
    final currentState = _readState().asData?.value;
    final progress = currentState?.syncProgress;
    if (currentState == null || progress == null) {
      return;
    }

    final nextProgress = update(progress);
    if (identical(nextProgress, progress)) {
      return;
    }

    _writeState(currentState.copyWith(syncProgress: Value(nextProgress)));
  }

  void _syncScanSpeedTimer(DriveSyncProgress? progress) {
    if (progress?.isRunning == true) {
      _scanSpeedTimer ??= Timer.periodic(_scanSpeedTickInterval, (_) {
        _refreshScanSpeed();
      });
      return;
    }
    _stopScanSpeedTimer();
  }

  void _stopScanSpeedTimer() {
    _scanSpeedTimer?.cancel();
    _scanSpeedTimer = null;
  }

  void _refreshScanSpeed() {
    if (!_ref.mounted) {
      _stopScanSpeedTimer();
      return;
    }
    final currentState = _readState().asData?.value;
    final progress = currentState?.syncProgress;
    if (currentState == null || progress == null || !progress.isRunning) {
      _stopScanSpeedTimer();
      return;
    }

    _speedTracker.sampleNow();
    final nextRate = _speedTracker.currentRate();
    if (_ratesEqual(progress.itemsPerSecond, nextRate)) {
      return;
    }

    _writeState(
      currentState.copyWith(
        syncProgress: Value(progress.copyWith(itemsPerSecond: Value(nextRate))),
      ),
    );
  }

  bool _ratesEqual(double? left, double? right) {
    if (left == null || right == null) {
      return left == right;
    }
    return (left - right).abs() < 0.0001;
  }
}

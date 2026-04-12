import 'package:drift/drift.dart';

import '../../../data/drive/drive_scan_models.dart';
import '../../../data/drive/drive_scan_backlog.dart';
import '../../../data/drive/metadata_pipeline_backlog.dart';

class DriveSyncProgress {
  const DriveSyncProgress({
    required this.jobId,
    required this.phase,
    required this.state,
    required this.indexedCount,
    required this.metadataReadyCount,
    required this.artworkReadyCount,
    required this.failedCount,
    this.itemsPerSecond,
    this.pipelineBacklog,
    this.metadataPipelineBacklog,
  });

  final int jobId;
  final String phase;
  final String state;
  final int indexedCount;
  final int metadataReadyCount;
  final int artworkReadyCount;
  final int failedCount;
  final double? itemsPerSecond;
  final ScanPipelineBacklog? pipelineBacklog;
  final MetadataPipelineBacklog? metadataPipelineBacklog;

  bool get isRunning => state == DriveScanJobState.running.value;
  bool get isPaused => state == DriveScanJobState.paused.value;
  bool get canPause =>
      state == DriveScanJobState.running.value ||
      state == DriveScanJobState.queued.value;
  bool get canResume => state == DriveScanJobState.paused.value;
  bool get canCancel =>
      state == DriveScanJobState.queued.value ||
      state == DriveScanJobState.running.value ||
      state == DriveScanJobState.paused.value ||
      state == DriveScanJobState.cancelRequested.value;

  DriveSyncProgress copyWith({
    int? jobId,
    String? phase,
    String? state,
    int? indexedCount,
    int? metadataReadyCount,
    int? artworkReadyCount,
    int? failedCount,
    Value<double?>? itemsPerSecond,
    Value<ScanPipelineBacklog?>? pipelineBacklog,
    Value<MetadataPipelineBacklog?>? metadataPipelineBacklog,
  }) {
    return DriveSyncProgress(
      jobId: jobId ?? this.jobId,
      phase: phase ?? this.phase,
      state: state ?? this.state,
      indexedCount: indexedCount ?? this.indexedCount,
      metadataReadyCount: metadataReadyCount ?? this.metadataReadyCount,
      artworkReadyCount: artworkReadyCount ?? this.artworkReadyCount,
      failedCount: failedCount ?? this.failedCount,
      itemsPerSecond: itemsPerSecond == null
          ? this.itemsPerSecond
          : itemsPerSecond.value,
      pipelineBacklog: pipelineBacklog == null
          ? this.pipelineBacklog
          : pipelineBacklog.value,
      metadataPipelineBacklog: metadataPipelineBacklog == null
          ? this.metadataPipelineBacklog
          : metadataPipelineBacklog.value,
    );
  }
}

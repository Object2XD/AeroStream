enum DriveObjectKind {
  file('file'),
  folder('folder');

  const DriveObjectKind(this.value);

  final String value;
}

enum DriveScanJobKind {
  baseline('baseline'),
  incremental('incremental');

  const DriveScanJobKind(this.value);

  final String value;
}

enum DriveScanJobState {
  queued('queued'),
  running('running'),
  paused('paused'),
  failed('failed'),
  completed('completed'),
  cancelRequested('cancel_requested'),
  canceled('canceled');

  const DriveScanJobState(this.value);

  final String value;
}

enum DriveScanPhase {
  baselineDiscovery('baseline_discovery'),
  incrementalChanges('incremental_changes'),
  metadataEnrichment('metadata_enrichment'),
  artworkEnrichment('artwork_enrichment'),
  finalize('finalize');

  const DriveScanPhase(this.value);

  final String value;
}

enum DriveScanTaskKind {
  discoverFolder('discover_folder'),
  reconcileChange('reconcile_change'),
  extractTags('extract_tags'),
  extractArtwork('extract_artwork'),
  deleteProjection('delete_projection');

  const DriveScanTaskKind(this.value);

  final String value;
}

enum DriveScanTaskState {
  queued('queued'),
  running('running'),
  completed('completed'),
  failed('failed'),
  canceled('canceled');

  const DriveScanTaskState(this.value);

  final String value;
}

enum DriveMetadataTaskRuntimeStage {
  fetchHead('fetch_head'),
  analyzeHead('analyze_head'),
  plan('plan'),
  fetch('fetch'),
  parse('parse'),
  flush('flush');

  const DriveMetadataTaskRuntimeStage(this.value);

  final String value;

  static DriveMetadataTaskRuntimeStage? fromMetadataPipelineStageName(
    String? stageName,
  ) {
    return switch (stageName) {
      'fetch' => DriveMetadataTaskRuntimeStage.fetch,
      'parse' => DriveMetadataTaskRuntimeStage.parse,
      'flush' => DriveMetadataTaskRuntimeStage.flush,
      _ => null,
    };
  }
}

enum TrackIndexStatus {
  active('active'),
  pendingDelete('pending_delete'),
  removed('removed');

  const TrackIndexStatus(this.value);

  final String value;
}

enum TrackMetadataStatus {
  pending('pending'),
  ready('ready'),
  failed('failed'),
  stale('stale');

  const TrackMetadataStatus(this.value);

  final String value;
}

enum TrackArtworkStatus {
  pending('pending'),
  ready('ready'),
  failed('failed'),
  none('none');

  const TrackArtworkStatus(this.value);

  final String value;
}

String buildContentFingerprint({
  String? md5Checksum,
  int? sizeBytes,
  DateTime? modifiedTime,
}) {
  final modified = modifiedTime?.toUtc().toIso8601String() ?? '';
  return '${md5Checksum ?? ''}|${sizeBytes ?? -1}|$modified';
}

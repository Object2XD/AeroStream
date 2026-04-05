import 'drive_scan_models.dart';

class ScanTaskBacklogEntry {
  const ScanTaskBacklogEntry({
    this.queuedCount = 0,
    this.runningCount = 0,
    this.failedCount = 0,
  });

  final int queuedCount;
  final int runningCount;
  final int failedCount;

  bool get isEmpty =>
      queuedCount == 0 && runningCount == 0 && failedCount == 0;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'queued': queuedCount,
      'running': runningCount,
      'failed': failedCount,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ScanTaskBacklogEntry &&
        other.queuedCount == queuedCount &&
        other.runningCount == runningCount &&
        other.failedCount == failedCount;
  }

  @override
  int get hashCode => Object.hash(queuedCount, runningCount, failedCount);
}

class ScanPipelineBacklog {
  const ScanPipelineBacklog({
    this.discovery = const ScanTaskBacklogEntry(),
    this.changes = const ScanTaskBacklogEntry(),
    this.metadata = const ScanTaskBacklogEntry(),
    this.artwork = const ScanTaskBacklogEntry(),
    this.deleteProjection = const ScanTaskBacklogEntry(),
  });

  final ScanTaskBacklogEntry discovery;
  final ScanTaskBacklogEntry changes;
  final ScanTaskBacklogEntry metadata;
  final ScanTaskBacklogEntry artwork;
  final ScanTaskBacklogEntry deleteProjection;

  bool get isEmpty =>
      discovery.isEmpty &&
      changes.isEmpty &&
      metadata.isEmpty &&
      artwork.isEmpty &&
      deleteProjection.isEmpty;

  ScanTaskBacklogEntry forTaskKind(String kind) {
    return switch (kind) {
      'discover_folder' => discovery,
      'reconcile_change' => changes,
      'extract_tags' => metadata,
      'extract_artwork' => artwork,
      'delete_projection' => deleteProjection,
      _ => const ScanTaskBacklogEntry(),
    };
  }

  ScanTaskBacklogEntry forPhase(String phase) {
    return switch (phase) {
      'baseline_discovery' => discovery,
      'incremental_changes' => changes,
      'metadata_enrichment' => metadata,
      'artwork_enrichment' => artwork,
      'finalize' => deleteProjection,
      _ => const ScanTaskBacklogEntry(),
    };
  }

  Map<String, ScanTaskBacklogEntry> asTaskKindMap() {
    return <String, ScanTaskBacklogEntry>{
      DriveScanTaskKind.discoverFolder.value: discovery,
      DriveScanTaskKind.reconcileChange.value: changes,
      DriveScanTaskKind.extractTags.value: metadata,
      DriveScanTaskKind.extractArtwork.value: artwork,
      DriveScanTaskKind.deleteProjection.value: deleteProjection,
    };
  }

  Map<String, int> queuedByKind() {
    return asTaskKindMap().map(
      (kind, entry) => MapEntry(kind, entry.queuedCount),
    );
  }

  Map<String, int> runningByKind() {
    return asTaskKindMap().map(
      (kind, entry) => MapEntry(kind, entry.runningCount),
    );
  }

  Map<String, int> failedByKind() {
    return asTaskKindMap().map(
      (kind, entry) => MapEntry(kind, entry.failedCount),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'discovery': discovery.toJson(),
      'changes': changes.toJson(),
      'metadata': metadata.toJson(),
      'artwork': artwork.toJson(),
      'deleteProjection': deleteProjection.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ScanPipelineBacklog &&
        other.discovery == discovery &&
        other.changes == changes &&
        other.metadata == metadata &&
        other.artwork == artwork &&
        other.deleteProjection == deleteProjection;
  }

  @override
  int get hashCode => Object.hash(
    discovery,
    changes,
    metadata,
    artwork,
    deleteProjection,
  );
}

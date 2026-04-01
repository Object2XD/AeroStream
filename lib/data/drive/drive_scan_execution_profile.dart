class DriveScanExecutionProfile {
  const DriveScanExecutionProfile({
    required this.changeWorkers,
    required this.discoveryWorkers,
    required this.metadataWorkers,
    required this.artworkWorkers,
    required this.artworkWorkersWhileMetadataPending,
    required this.metadataHighWatermark,
    required this.pageSize,
    required this.trackProjectionBatchSize,
  }) : assert(changeWorkers > 0),
       assert(discoveryWorkers > 0),
       assert(metadataWorkers > 0),
       assert(artworkWorkers > 0),
       assert(artworkWorkersWhileMetadataPending >= 0),
       assert(metadataHighWatermark >= 0),
       assert(pageSize > 0),
       assert(trackProjectionBatchSize > 0);

  final int changeWorkers;
  final int discoveryWorkers;
  final int metadataWorkers;
  final int artworkWorkers;
  final int artworkWorkersWhileMetadataPending;
  final int metadataHighWatermark;
  final int pageSize;
  final int trackProjectionBatchSize;
}

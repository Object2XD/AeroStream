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
    this.metadataFetchWorkers,
    this.metadataParseWorkers,
    this.metadataFetchQueueHighWatermark,
    this.metadataParseQueueHighWatermark,
    this.metadataFlushQueueHighWatermark,
    @Deprecated('Use metadataFetchWorkers') this.metadataFetchHeadWorkers,
    @Deprecated('Use metadataFetchWorkers') this.metadataAnalyzeHeadWorkers,
    @Deprecated('Use metadataFetchWorkers') this.metadataPlanWorkers,
    @Deprecated('Use metadataFetchQueueHighWatermark')
    this.metadataFetchHeadQueueHighWatermark,
    @Deprecated('Use metadataFetchQueueHighWatermark')
    this.metadataAnalyzeHeadQueueHighWatermark,
    @Deprecated('Use metadataFetchQueueHighWatermark')
    this.metadataPlanQueueHighWatermark,
    this.metadataFlushBatchSize = 8,
    this.metadataFlushMaxLatency = const Duration(milliseconds: 250),
    this.metadataTaskLeaseTimeout = const Duration(minutes: 2),
    this.metadataTaskHeartbeatInterval = const Duration(seconds: 15),
    this.metadataTaskStallWarningThreshold = const Duration(minutes: 1),
  }) : assert(changeWorkers > 0),
       assert(discoveryWorkers > 0),
       assert(metadataWorkers > 0),
       assert(artworkWorkers > 0),
       assert(artworkWorkersWhileMetadataPending >= 0),
       assert(metadataHighWatermark >= 0),
       assert(pageSize > 0),
       assert(trackProjectionBatchSize > 0),
       assert(metadataFlushBatchSize > 0);

  final int changeWorkers;
  final int discoveryWorkers;
  final int metadataWorkers;
  final int artworkWorkers;
  final int artworkWorkersWhileMetadataPending;
  final int metadataHighWatermark;
  final int pageSize;
  final int trackProjectionBatchSize;
  final int? metadataFetchWorkers;
  final int? metadataParseWorkers;
  final int? metadataFetchQueueHighWatermark;
  final int? metadataParseQueueHighWatermark;
  final int? metadataFlushQueueHighWatermark;
  final int? metadataFetchHeadWorkers;
  final int? metadataAnalyzeHeadWorkers;
  final int? metadataPlanWorkers;
  final int? metadataFetchHeadQueueHighWatermark;
  final int? metadataAnalyzeHeadQueueHighWatermark;
  final int? metadataPlanQueueHighWatermark;
  final int metadataFlushBatchSize;
  final Duration metadataFlushMaxLatency;
  final Duration metadataTaskLeaseTimeout;
  final Duration metadataTaskHeartbeatInterval;
  final Duration metadataTaskStallWarningThreshold;
}

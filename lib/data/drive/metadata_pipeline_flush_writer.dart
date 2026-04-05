import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'drive_scan_models.dart';
import 'extraction/drive_metadata_extractor.dart';

typedef MetadataPipelineProgressApplier =
    Future<void> Function({int metadataReadyDelta, int failedCountDelta});

class MetadataPipelineRuntimeCounters {
  const MetadataPipelineRuntimeCounters({
    this.successCount = 0,
    this.failureCount = 0,
    this.skippedCount = 0,
  });

  final int successCount;
  final int failureCount;
  final int skippedCount;

  MetadataPipelineRuntimeCounters copyWith({
    int? successCount,
    int? failureCount,
    int? skippedCount,
  }) {
    return MetadataPipelineRuntimeCounters(
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      skippedCount: skippedCount ?? this.skippedCount,
    );
  }
}

enum MetadataPipelineFlushItemKind { success, failure, skipped, canceled }

class MetadataPipelineFlushItem {
  const MetadataPipelineFlushItem._({
    required this.kind,
    required this.task,
    required this.track,
    required this.metadata,
    required this.error,
    required this.shouldEnqueueArtwork,
    required this.formatKey,
  });

  factory MetadataPipelineFlushItem.success({
    required ScanTask task,
    required Track track,
    required DriveExtractedMetadata metadata,
    required bool shouldEnqueueArtwork,
    required String formatKey,
  }) {
    return MetadataPipelineFlushItem._(
      kind: MetadataPipelineFlushItemKind.success,
      task: task,
      track: track,
      metadata: metadata,
      error: null,
      shouldEnqueueArtwork: shouldEnqueueArtwork,
      formatKey: formatKey,
    );
  }

  factory MetadataPipelineFlushItem.failure({
    required ScanTask task,
    required Track? track,
    required String error,
    required String formatKey,
  }) {
    return MetadataPipelineFlushItem._(
      kind: MetadataPipelineFlushItemKind.failure,
      task: task,
      track: track,
      metadata: null,
      error: error,
      shouldEnqueueArtwork: false,
      formatKey: formatKey,
    );
  }

  factory MetadataPipelineFlushItem.skipped({
    required ScanTask task,
    Track? track,
    required String formatKey,
  }) {
    return MetadataPipelineFlushItem._(
      kind: MetadataPipelineFlushItemKind.skipped,
      task: task,
      track: track,
      metadata: null,
      error: null,
      shouldEnqueueArtwork: false,
      formatKey: formatKey,
    );
  }

  factory MetadataPipelineFlushItem.canceled({
    required ScanTask task,
    Track? track,
    required String formatKey,
  }) {
    return MetadataPipelineFlushItem._(
      kind: MetadataPipelineFlushItemKind.canceled,
      task: task,
      track: track,
      metadata: null,
      error: null,
      shouldEnqueueArtwork: false,
      formatKey: formatKey,
    );
  }

  final MetadataPipelineFlushItemKind kind;
  final ScanTask task;
  final Track? track;
  final DriveExtractedMetadata? metadata;
  final String? error;
  final bool shouldEnqueueArtwork;
  final String formatKey;
}

class MetadataPipelineFlushWriter {
  MetadataPipelineFlushWriter({
    required AppDatabase database,
    required ScanJob job,
    required int artworkTaskPriority,
    required MetadataPipelineProgressApplier applyJobProgressDelta,
  }) : _database = database,
       _job = job,
       _artworkTaskPriority = artworkTaskPriority,
       _applyJobProgressDelta = applyJobProgressDelta;

  final AppDatabase _database;
  final ScanJob _job;
  final int _artworkTaskPriority;
  final MetadataPipelineProgressApplier _applyJobProgressDelta;

  Future<MetadataPipelineRuntimeCounters> flushBatch(
    List<MetadataPipelineFlushItem> batch,
  ) async {
    final successes = batch
        .where((item) => item.kind == MetadataPipelineFlushItemKind.success)
        .toList(growable: false);
    final failures = batch
        .where((item) => item.kind == MetadataPipelineFlushItemKind.failure)
        .toList(growable: false);
    final skipped = batch
        .where((item) => item.kind == MetadataPipelineFlushItemKind.skipped)
        .toList(growable: false);
    final canceled = batch
        .where((item) => item.kind == MetadataPipelineFlushItemKind.canceled)
        .toList(growable: false);

    var counters = const MetadataPipelineRuntimeCounters();

    if (successes.isNotEmpty) {
      await _database.applyTrackMetadataBatch(
        successes
            .map(
              (item) => TrackMetadataBatchUpdate(
                trackId: item.track!.id,
                titleValue: item.metadata!.title,
                artistValue: item.metadata!.artist,
                albumValue: item.metadata!.album,
                albumArtistValue: item.metadata!.albumArtist,
                genreValue: item.metadata!.genre,
                yearValue: item.metadata!.year,
                trackNumberValue: item.metadata!.trackNumber,
                discNumberValue: item.metadata!.discNumber,
                durationMsValue: item.metadata!.durationMs,
                artworkUriValue: item.track!.artworkUri,
                artworkBlobIdValue: item.track!.artworkBlobId,
                metadataStatusValue: TrackMetadataStatus.ready.value,
                metadataSchemaVersionValue: currentTrackMetadataSchemaVersion,
                artworkStatusValue: item.shouldEnqueueArtwork
                    ? TrackArtworkStatus.pending.value
                    : TrackArtworkStatus.ready.value,
              ),
            )
            .toList(growable: false),
      );
      await _database.completeScanTasks(successes.map((item) => item.task.id));

      final artworkTasks = successes
          .where((item) => item.shouldEnqueueArtwork)
          .map(
            (item) => ScanTasksCompanion.insert(
              jobId: _job.id,
              kind: DriveScanTaskKind.extractArtwork.value,
              rootId: Value(item.track!.rootId),
              targetDriveId: Value(item.track!.driveFileId),
              dedupeKey: Value(
                'art:${item.track!.driveFileId}:${item.track!.contentFingerprint ?? ''}',
              ),
              payloadJson: const Value('{}'),
              priority: Value(_artworkTaskPriority),
            ),
          )
          .toList(growable: false);
      await _database.enqueueScanTasks(artworkTasks);

      await _applyJobProgressDelta(
        metadataReadyDelta: successes
            .where(
              (item) =>
                  item.track!.metadataStatus != TrackMetadataStatus.ready.value,
            )
            .length,
        failedCountDelta: -successes
            .where((item) => _doesSuccessClearFailure(item.track!))
            .length,
      );
      counters = counters.copyWith(successCount: successes.length);
    }

    if (failures.isNotEmpty) {
      final failedTrackUpdates = failures
          .where((item) => item.track != null)
          .map(
            (item) => TrackMetadataBatchUpdate(
              trackId: item.track!.id,
              titleValue: item.track!.title,
              artistValue: item.track!.artist,
              albumValue: item.track!.album,
              albumArtistValue: item.track!.albumArtist,
              genreValue: item.track!.genre,
              yearValue: item.track!.year,
              trackNumberValue: item.track!.trackNumber,
              discNumberValue: item.track!.discNumber,
              durationMsValue: item.track!.durationMs,
              artworkUriValue: item.track!.artworkUri,
              artworkBlobIdValue: item.track!.artworkBlobId,
              metadataStatusValue: TrackMetadataStatus.failed.value,
              metadataSchemaVersionValue: item.track!.metadataSchemaVersion,
              artworkStatusValue: item.track!.artworkStatus,
            ),
          )
          .toList(growable: false);
      await _database.applyTrackMetadataBatch(failedTrackUpdates);
      for (final failure in failures) {
        await _database.failScanTasks([failure.task.id], error: failure.error!);
      }
      await _applyJobProgressDelta(
        failedCountDelta: failures
            .where((item) => _doesFailureIncreaseFailedCount(item.track))
            .length,
      );
      counters = counters.copyWith(failureCount: failures.length);
    }

    if (skipped.isNotEmpty) {
      await _database.completeScanTasks(skipped.map((item) => item.task.id));
      counters = counters.copyWith(skippedCount: skipped.length);
    }

    if (canceled.isNotEmpty) {
      await _database.cancelQueuedAndRunningScanTasks(
        _job.id,
        kind: DriveScanTaskKind.extractTags.value,
      );
      counters = counters.copyWith(
        skippedCount: counters.skippedCount + canceled.length,
      );
    }

    return counters;
  }

  bool _doesFailureIncreaseFailedCount(Track? track) {
    if (track == null) {
      return false;
    }
    return track.metadataStatus != TrackMetadataStatus.failed.value &&
        track.artworkStatus != TrackArtworkStatus.failed.value;
  }

  bool _doesSuccessClearFailure(Track track) {
    return track.metadataStatus != TrackMetadataStatus.failed.value &&
        track.artworkStatus == TrackArtworkStatus.failed.value;
  }
}

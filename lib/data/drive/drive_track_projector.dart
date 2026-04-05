import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';
import 'drive_entities.dart';
import 'drive_scan_models.dart';
import 'drive_track_cache_service.dart';

class ProjectedTrackCandidate {
  const ProjectedTrackCandidate({
    required this.row,
    required this.contentChanged,
    required this.shouldInvalidateCache,
  });

  final TracksCompanion row;
  final bool contentChanged;
  final bool shouldInvalidateCache;
}

class DriveTrackProjector {
  DriveTrackProjector({
    required AppDatabase database,
    required DriveTrackCacheService trackCacheService,
  }) : _database = database,
       _trackCacheService = trackCacheService;

  final AppDatabase _database;
  final DriveTrackCacheService _trackCacheService;

  Future<bool> projectAudioCandidate({
    required int rootId,
    required DriveObjectEntry entry,
    required Track? existingTrack,
  }) async {
    final projection = buildProjectedAudioCandidate(
      rootId: rootId,
      entry: entry,
      existingTrack: existingTrack,
    );
    if (projection.shouldInvalidateCache && existingTrack != null) {
      await _trackCacheService.removeCachedTrackFiles([existingTrack]);
    }
    await _database.upsertTrack(projection.row);
    return projection.contentChanged;
  }

  ProjectedTrackCandidate buildProjectedAudioCandidate({
    required int rootId,
    required DriveObjectEntry entry,
    required Track? existingTrack,
  }) {
    final fingerprint = contentFingerprintForEntry(entry);
    final contentChanged =
        existingTrack == null ||
        existingTrack.contentFingerprint != fingerprint;
    final defaultTitle = defaultTitleFromFileName(entry.name);
    final shouldUseProjectedTitle =
        existingTrack == null ||
        existingTrack.metadataStatus != TrackMetadataStatus.ready.value;
    final projectedTitle = shouldUseProjectedTitle
        ? defaultTitle
        : existingTrack.title;
    final projectedArtist = existingTrack?.artist ?? '';

    return ProjectedTrackCandidate(
      row: TracksCompanion.insert(
        id: existingTrack == null
            ? const Value.absent()
            : Value(existingTrack.id),
        rootId: rootId,
        driveFileId: entry.id,
        resourceKey: Value(entry.resourceKey),
        fileName: entry.name,
        title: projectedTitle,
        titleSort: Value(projectedTitle.trim().toLowerCase()),
        artist: projectedArtist,
        artistSort: Value(projectedArtist.trim().toLowerCase()),
        album: existingTrack?.album ?? '',
        albumArtist: existingTrack?.albumArtist ?? '',
        genre: existingTrack?.genre ?? '',
        year: Value(existingTrack?.year),
        trackNumber: Value(existingTrack?.trackNumber ?? 0),
        discNumber: Value(existingTrack?.discNumber ?? 0),
        durationMs: Value(existingTrack?.durationMs ?? 0),
        mimeType: entry.mimeType,
        sizeBytes: Value(entry.sizeBytes),
        md5Checksum: Value(entry.md5Checksum),
        modifiedTime: Value(entry.modifiedTime),
        artworkUri: Value(existingTrack?.artworkUri),
        artworkBlobId: Value(existingTrack?.artworkBlobId),
        artworkStatus: Value(
          existingTrack == null
              ? TrackArtworkStatus.pending.value
              : contentChanged
              ? TrackArtworkStatus.pending.value
              : existingTrack.artworkStatus,
        ),
        cachePath: contentChanged
            ? const Value(null)
            : Value(existingTrack.cachePath),
        cacheStatus: Value(contentChanged ? 'none' : existingTrack.cacheStatus),
        metadataStatus: Value(
          existingTrack == null
              ? TrackMetadataStatus.pending.value
              : contentChanged
              ? TrackMetadataStatus.stale.value
              : existingTrack.metadataStatus,
        ),
        metadataSchemaVersion: Value(
          existingTrack == null || contentChanged
              ? repairableTrackMetadataSchemaVersion
              : existingTrack.metadataSchemaVersion,
        ),
        indexStatus: Value(TrackIndexStatus.active.value),
        contentFingerprint: Value(fingerprint),
        updatedAt: Value(DateTime.now()),
        removedAt: const Value(null),
      ),
      contentChanged: contentChanged,
      shouldInvalidateCache: existingTrack != null && contentChanged,
    );
  }

  String contentFingerprintForEntry(DriveObjectEntry entry) {
    return buildContentFingerprint(
      md5Checksum: entry.md5Checksum,
      sizeBytes: entry.sizeBytes,
      modifiedTime: entry.modifiedTime,
    );
  }

  String defaultTitleFromFileName(String fileName) {
    final extension = p.extension(fileName);
    if (extension.isEmpty) {
      return fileName;
    }
    return fileName.substring(0, fileName.length - extension.length);
  }
}

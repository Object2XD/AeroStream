import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_scan_logger.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_scan_progress_refresher.dart';
import 'package:aero_stream/data/drive/drive_scan_root_resolver.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriveScanRootResolver rootResolver;
  late DriveScanProgressRefresher refresher;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    rootResolver = DriveScanRootResolver(database: database);
    refresher = DriveScanProgressRefresher(
      database: database,
      rootResolver: rootResolver,
      logger: const NoOpDriveScanLogger(),
      metadataRefreshInterval: const Duration(days: 1),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('refreshJobProgress aggregates durable root counts', () async {
    final accountId = await _seedAccount(database);
    final rootId = await _seedRoot(database, accountId: accountId);
    final jobId = await database.createScanJob(
      ScanJobsCompanion.insert(
        accountId: accountId,
        rootId: Value(rootId),
        kind: DriveScanJobKind.incremental.value,
        state: DriveScanJobState.running.value,
        phase: DriveScanPhase.metadataEnrichment.value,
      ),
    );
    await database.upsertTrack(
      TracksCompanion.insert(
        rootId: rootId,
        driveFileId: 'track-1',
        fileName: 'track-1.mp3',
        title: 'track-1',
        artist: '',
        album: '',
        albumArtist: '',
        genre: '',
        mimeType: 'audio/mpeg',
        metadataStatus: Value(TrackMetadataStatus.ready.value),
        artworkStatus: Value(TrackArtworkStatus.ready.value),
      ),
    );
    await database.upsertTrack(
      TracksCompanion.insert(
        rootId: rootId,
        driveFileId: 'track-2',
        fileName: 'track-2.mp3',
        title: 'track-2',
        artist: '',
        album: '',
        albumArtist: '',
        genre: '',
        mimeType: 'audio/mpeg',
        metadataStatus: Value(TrackMetadataStatus.failed.value),
        artworkStatus: Value(TrackArtworkStatus.pending.value),
      ),
    );

    final job = (await database.getScanJobById(jobId))!;
    await refresher.refreshJobProgress(job, force: true);

    final updated = (await database.getScanJobById(jobId))!;
    expect(updated.indexedCount, 2);
    expect(updated.metadataReadyCount, 1);
    expect(updated.artworkReadyCount, 1);
    expect(updated.failedCount, 1);
  });
}

Future<int> _seedAccount(AppDatabase database) async {
  await database.setActiveAccount(
    SyncAccountsCompanion.insert(
      providerAccountId: 'account-1',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: 'oauth_desktop',
      connectedAt: DateTime(2026, 4, 1),
    ),
  );
  return (await database.getActiveAccount())!.id;
}

Future<int> _seedRoot(AppDatabase database, {required int accountId}) async {
  return database.upsertRoot(
    SyncRootsCompanion.insert(
      accountId: accountId,
      folderId: 'root-folder',
      folderName: 'Library',
    ),
  );
}

import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_metadata_catch_up_planner.dart';
import 'package:aero_stream/data/drive/drive_scan_logger.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_codec.dart';
import 'package:aero_stream/data/drive/drive_scan_root_binder.dart';
import 'package:aero_stream/data/drive/drive_scan_root_resolver.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriveMetadataCatchUpPlanner planner;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    final rootResolver = DriveScanRootResolver(database: database);
    planner = DriveMetadataCatchUpPlanner(
      database: database,
      rootResolver: rootResolver,
      rootBinder: DriveScanRootBinder(
        database: database,
        phaseCodec: const DriveScanPhaseCodec(),
      ),
      logger: const NoOpDriveScanLogger(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('buildMetadataCatchUpPlan classifies pending vs schema repair', () async {
    await _seedAndAssertPlan(database, planner);
  });
}

Future<void> _seedAndAssertPlan(
  AppDatabase database,
  DriveMetadataCatchUpPlanner planner,
) async {
  await database.setActiveAccount(
    SyncAccountsCompanion.insert(
      providerAccountId: 'account-1',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: 'oauth_desktop',
      connectedAt: DateTime(2026, 4, 1),
    ),
  );
  final account = (await database.getActiveAccount())!;
  final rootA = await database.upsertRoot(
    SyncRootsCompanion.insert(
      accountId: account.id,
      folderId: 'root-a',
      folderName: 'A',
    ),
  );
  final rootB = await database.upsertRoot(
    SyncRootsCompanion.insert(
      accountId: account.id,
      folderId: 'root-b',
      folderName: 'B',
    ),
  );
  await database.upsertTrack(
    TracksCompanion.insert(
      rootId: rootA,
      driveFileId: 'pending-track',
      fileName: 'pending-track.mp3',
      title: 'pending-track',
      artist: '',
      album: '',
      albumArtist: '',
      genre: '',
      mimeType: 'audio/mpeg',
      metadataStatus: Value(TrackMetadataStatus.pending.value),
      metadataSchemaVersion: Value(currentTrackMetadataSchemaVersion),
    ),
  );
  await database.upsertTrack(
    TracksCompanion.insert(
      rootId: rootB,
      driveFileId: 'repair-track',
      fileName: 'repair-track.mp3',
      title: 'repair-track',
      artist: '',
      album: '',
      albumArtist: '',
      genre: '',
      mimeType: 'audio/mpeg',
      metadataStatus: Value(TrackMetadataStatus.ready.value),
      metadataSchemaVersion: Value(currentTrackMetadataSchemaVersion - 1),
    ),
  );

  final tracks = await database.getTracksNeedingMetadataCatchUp(
    accountId: account.id,
    metadataSchemaVersionBelow: currentTrackMetadataSchemaVersion,
  );
  final plan = planner.buildMetadataCatchUpPlan(jobId: 10, tracks: tracks);

  expect(plan.pendingOrStaleCount, 1);
  expect(plan.schemaRepairCount, 1);
  expect(plan.tasks, hasLength(2));
  expect(plan.tasks.first.dedupeKey.value, 'tags:pending-track:');
  expect(
    plan.tasks.last.dedupeKey.value,
    'tag-repair:v$currentTrackMetadataSchemaVersion:repair-track',
  );
}

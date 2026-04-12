import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_metadata_catch_up_planner.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_scan_job_enqueuer.dart';
import 'package:aero_stream/data/drive/drive_scan_logger.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_codec.dart';
import 'package:aero_stream/data/drive/drive_scan_root_binder.dart';
import 'package:aero_stream/data/drive/drive_scan_root_resolver.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriveScanJobEnqueuer enqueuer;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    final rootResolver = DriveScanRootResolver(database: database);
    final rootBinder = DriveScanRootBinder(
      database: database,
      phaseCodec: const DriveScanPhaseCodec(),
    );
    final catchUpPlanner = DriveMetadataCatchUpPlanner(
      database: database,
      rootResolver: rootResolver,
      rootBinder: rootBinder,
      logger: const NoOpDriveScanLogger(),
    );
    enqueuer = DriveScanJobEnqueuer(
      database: database,
      rootResolver: rootResolver,
      rootBinder: rootBinder,
      catchUpPlanner: catchUpPlanner,
      logger: const NoOpDriveScanLogger(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('enqueueSync chooses baseline when checkpoint is missing', () async {
    final account = await _seedAccount(database, driveStartPageToken: null);
    await _seedRoot(database, accountId: account.id, folderId: 'root-folder');

    final jobId = await enqueuer.enqueueSync(
      autoRun: false,
      ensureRunner: () {},
    );
    final job = (await database.getScanJobById(jobId!))!;

    expect(job.kind, DriveScanJobKind.baseline.value);
    expect(job.phase, DriveScanPhase.baselineDiscovery.value);
  });

  test(
    'enqueueSync reuses active job and keeps single active job id',
    () async {
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      await _seedRoot(database, accountId: account.id, folderId: 'root-folder');

      final first = await enqueuer.enqueueSync(
        autoRun: false,
        ensureRunner: () {},
      );
      final second = await enqueuer.enqueueSync(
        autoRun: false,
        ensureRunner: () {},
      );

      expect(second, first);
    },
  );

  test('enqueueSync rejects reconnect-required accounts', () async {
    final account = await _seedAccount(
      database,
      driveStartPageToken: 'start-token',
    );
    await database.updateAccountAuthSession(
      account.id,
      authSessionStateValue: DriveAuthSessionState.reauthRequired.value,
      authSessionErrorValue: driveAuthReconnectRequiredMessage,
    );

    await expectLater(
      enqueuer.enqueueSync(autoRun: false, ensureRunner: () {}),
      throwsA(
        isA<DriveAuthException>().having(
          (error) => error.message,
          'message',
          driveAuthReconnectRequiredMessage,
        ),
      ),
    );
    expect(await database.getLatestActiveScanJob(), equals(null));
  });
}

Future<SyncAccount> _seedAccount(
  AppDatabase database, {
  required String? driveStartPageToken,
}) async {
  await database.setActiveAccount(
    SyncAccountsCompanion.insert(
      providerAccountId: 'account-1',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: 'oauth_desktop',
      connectedAt: DateTime(2026, 4, 1),
      driveStartPageToken: Value(driveStartPageToken),
      driveChangePageToken: Value(driveStartPageToken),
    ),
  );
  return (await database.getActiveAccount())!;
}

Future<int> _seedRoot(
  AppDatabase database, {
  required int accountId,
  required String folderId,
}) {
  return database.upsertRoot(
    SyncRootsCompanion.insert(
      accountId: accountId,
      folderId: folderId,
      folderName: folderId,
      lastSyncedAt: const Value(null),
    ),
  );
}

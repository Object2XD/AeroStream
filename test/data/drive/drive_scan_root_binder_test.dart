import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_codec.dart';
import 'package:aero_stream/data/drive/drive_scan_root_binder.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriveScanRootBinder binder;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    binder = DriveScanRootBinder(
      database: database,
      phaseCodec: const DriveScanPhaseCodec(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('attachRootsToJob updates root state and active job', () async {
    final accountId = await _seedAccount(database);
    final rootId = await database.upsertRoot(
      SyncRootsCompanion.insert(
        accountId: accountId,
        folderId: 'root-folder',
        folderName: 'Library',
      ),
    );

    await binder.attachRootsToJob(
      7,
      [rootId],
      syncStateValue: DriveScanJobState.queued.value,
    );
    final updated = (await database.getRootById(rootId))!;

    expect(updated.activeJobId, 7);
    expect(updated.syncState, DriveScanJobState.queued.value);
  });

  test('rewindJobToMetadataEnrichmentIfNeeded rewinds late phases', () async {
    final accountId = await _seedAccount(database);
    final jobId = await database.createScanJob(
      ScanJobsCompanion.insert(
        accountId: accountId,
        kind: DriveScanJobKind.incremental.value,
        state: DriveScanJobState.running.value,
        phase: DriveScanPhase.artworkEnrichment.value,
      ),
    );

    await binder.rewindJobToMetadataEnrichmentIfNeeded(
      (await database.getScanJobById(jobId))!,
    );
    final rewound = (await database.getScanJobById(jobId))!;

    expect(rewound.phase, DriveScanPhase.metadataEnrichment.value);
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

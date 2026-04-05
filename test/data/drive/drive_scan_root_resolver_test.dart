import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_scan_root_resolver.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriveScanRootResolver resolver;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    resolver = DriveScanRootResolver(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('resolveRootsForEnqueue filters account and root id', () async {
    final accountId = await _seedAccount(database);
    final otherAccountId = await _seedAccount(database, suffix: '2');
    final rootA = await _seedRoot(database, accountId: accountId, folderId: 'a');
    await _seedRoot(database, accountId: accountId, folderId: 'b');
    await _seedRoot(
      database,
      accountId: otherAccountId,
      folderId: 'other',
    );

    final roots = await resolver.resolveRootsForEnqueue(accountId, rootId: rootA);

    expect(roots.map((root) => root.id).toList(growable: false), [rootA]);
  });

  test('resolveRootsForExistingJob returns active roots', () async {
    final accountId = await _seedAccount(database);
    final jobId = await database.createScanJob(
      ScanJobsCompanion.insert(
        accountId: accountId,
        kind: DriveScanJobKind.incremental.value,
        state: DriveScanJobState.running.value,
        phase: DriveScanPhase.incrementalChanges.value,
      ),
    );
    await _seedRoot(
      database,
      accountId: accountId,
      folderId: 'active',
      activeJobId: jobId,
      syncState: DriveScanJobState.running.value,
    );
    await _seedRoot(database, accountId: accountId, folderId: 'idle');

    final job = (await database.getScanJobById(jobId))!;
    final roots = await resolver.resolveRootsForExistingJob(job);

    expect(roots, hasLength(1));
    expect(roots.single.folderId, 'active');
  });
}

Future<int> _seedAccount(AppDatabase database, {String suffix = '1'}) async {
  await database.setActiveAccount(
    SyncAccountsCompanion.insert(
      providerAccountId: 'account-$suffix',
      email: 'listener$suffix@example.com',
      displayName: 'Listener $suffix',
      authKind: 'oauth_desktop',
      connectedAt: DateTime(2026, 4, 1),
    ),
  );
  return (await database.getActiveAccount())!.id;
}

Future<int> _seedRoot(
  AppDatabase database, {
  required int accountId,
  required String folderId,
  int? activeJobId,
  String syncState = 'idle',
}) {
  return database.upsertRoot(
    SyncRootsCompanion.insert(
      accountId: accountId,
      folderId: folderId,
      folderName: folderId,
      activeJobId: Value(activeJobId),
      syncState: Value(syncState),
    ),
  );
}

import '../database/app_database.dart';
import 'drive_scan_models.dart';

class DriveScanRootResolver {
  DriveScanRootResolver({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<List<SyncRoot>> resolveRootsForEnqueue(
    int accountId, {
    int? rootId,
  }) async {
    final roots = await _database.getRoots();
    return roots
        .where((root) {
          if (root.accountId != accountId) {
            return false;
          }
          if (rootId != null && root.id != rootId) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  Future<List<SyncRoot>> resolveRootsForExistingJob(ScanJob job) async {
    final roots = await _database.getRoots();
    return roots
        .where((root) {
          if (root.accountId != job.accountId) {
            return false;
          }
          if (job.rootId != null) {
            return root.id == job.rootId || root.activeJobId == job.id;
          }
          return root.activeJobId == job.id ||
              root.syncState == DriveScanJobState.running.value;
        })
        .toList(growable: false);
  }
}

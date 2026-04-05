import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'drive_scan_models.dart';
import 'drive_scan_phase_codec.dart';

class DriveScanRootBinder {
  DriveScanRootBinder({
    required AppDatabase database,
    required DriveScanPhaseCodec phaseCodec,
  }) : _database = database,
       _phaseCodec = phaseCodec;

  final AppDatabase _database;
  final DriveScanPhaseCodec _phaseCodec;

  Future<void> attachRootsToJob(
    int jobId,
    Iterable<int> rootIds, {
    required String syncStateValue,
  }) async {
    final ids = rootIds.toSet();
    if (ids.isEmpty) {
      return;
    }

    for (final rootId in ids) {
      await _database.updateRootState(
        rootId,
        syncStateValue: syncStateValue,
        activeJobIdValue: jobId,
        lastErrorValue: null,
      );
    }
  }

  Future<void> rewindJobToMetadataEnrichmentIfNeeded(ScanJob job) async {
    final phase = _phaseCodec.phaseFromValue(job.phase);
    if (phase.index <= DriveScanPhase.metadataEnrichment.index) {
      return;
    }

    await _database.updateScanJob(
      job.id,
      ScanJobsCompanion(phase: Value(DriveScanPhase.metadataEnrichment.value)),
    );
  }
}

import 'drive_scan_models.dart';

class DriveScanPhaseCodec {
  const DriveScanPhaseCodec();

  DriveScanPhase phaseFromValue(String value) {
    return DriveScanPhase.values.firstWhere(
      (phase) => phase.value == value,
      orElse: () => DriveScanPhase.baselineDiscovery,
    );
  }
}

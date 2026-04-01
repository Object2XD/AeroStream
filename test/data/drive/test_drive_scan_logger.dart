import 'package:aero_stream/data/drive/drive_scan_logger.dart';

class RecordingDriveScanLogger extends DriveScanLogger {
  final List<DriveScanLogEntry> entries = <DriveScanLogEntry>[];

  @override
  void log(DriveScanLogEntry entry) {
    entries.add(entry);
  }

  Iterable<DriveScanLogEntry> byOperation(String operation) {
    return entries.where((entry) => entry.operation == operation);
  }

  bool containsOperation(String operation) {
    return entries.any((entry) => entry.operation == operation);
  }

  String joinedLines() => entries.map((entry) => entry.formattedLine).join('\n');
}

import 'dart:convert';
import 'dart:developer' as developer;

enum DriveScanLogLevel { info, warning, error }

class DriveScanLogContext {
  const DriveScanLogContext({
    this.jobId,
    this.rootId,
    this.taskId,
    this.phase,
    this.driveFileId,
    this.elapsedMs,
  });

  final int? jobId;
  final int? rootId;
  final int? taskId;
  final String? phase;
  final String? driveFileId;
  final int? elapsedMs;

  Map<String, Object?> toFields() {
    return <String, Object?>{
      if (jobId != null) 'jobId': jobId,
      if (rootId != null) 'rootId': rootId,
      if (taskId != null) 'taskId': taskId,
      if (phase != null && phase!.isNotEmpty) 'phase': phase,
      if (driveFileId != null && driveFileId!.isNotEmpty)
        'driveFileId': driveFileId,
      if (elapsedMs != null) 'elapsedMs': elapsedMs,
    };
  }
}

class DriveScanLogEntry {
  const DriveScanLogEntry({
    required this.prefix,
    required this.subsystem,
    required this.operation,
    required this.level,
    this.context = const DriveScanLogContext(),
    this.message,
    this.details = const <String, Object?>{},
    this.error,
    this.stackTrace,
  });

  final String prefix;
  final String subsystem;
  final String operation;
  final DriveScanLogLevel level;
  final DriveScanLogContext context;
  final String? message;
  final Map<String, Object?> details;
  final Object? error;
  final StackTrace? stackTrace;

  String get formattedLine {
    final parts = <String>[
      '$prefix $operation',
      'level=${level.name}',
      'subsystem=$subsystem',
      ..._formatFields(context.toFields()),
      ..._formatFields(details),
      if (message != null && message!.isNotEmpty)
        'message=${jsonEncode(message)}',
    ];
    return parts.join(' ');
  }

  String get loggerName => '$prefix.$subsystem';

  int get developerLevel => switch (level) {
    DriveScanLogLevel.info => 800,
    DriveScanLogLevel.warning => 900,
    DriveScanLogLevel.error => 1000,
  };

  List<String> _formatFields(Map<String, Object?> fields) {
    final formatted = <String>[];
    for (final entry in fields.entries) {
      final value = _sanitizeValue(entry.key, entry.value);
      if (value == null) {
        continue;
      }
      formatted.add('${entry.key}=${_formatValue(value)}');
    }
    return formatted;
  }

  Object? _sanitizeValue(String key, Object? value) {
    if (value == null) {
      return null;
    }

    final normalizedKey = key.toLowerCase();
    if (normalizedKey.contains('authorization')) {
      return '<redacted>';
    }
    if (normalizedKey.contains('resourcekey')) {
      return 'redacted';
    }
    if (normalizedKey.contains('pagetoken') || normalizedKey.endsWith('token')) {
      return value.toString().isEmpty ? 'absent' : 'present';
    }
    return value;
  }

  String _formatValue(Object value) {
    return switch (value) {
      num() || bool() => value.toString(),
      _ => jsonEncode(value.toString()),
    };
  }
}

abstract class DriveScanLogger {
  const DriveScanLogger();

  void log(DriveScanLogEntry entry);

  void info({
    required String prefix,
    required String subsystem,
    required String operation,
    DriveScanLogContext context = const DriveScanLogContext(),
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    log(
      DriveScanLogEntry(
        prefix: prefix,
        subsystem: subsystem,
        operation: operation,
        level: DriveScanLogLevel.info,
        context: context,
        message: message,
        details: details,
      ),
    );
  }

  void warning({
    required String prefix,
    required String subsystem,
    required String operation,
    DriveScanLogContext context = const DriveScanLogContext(),
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      DriveScanLogEntry(
        prefix: prefix,
        subsystem: subsystem,
        operation: operation,
        level: DriveScanLogLevel.warning,
        context: context,
        message: message,
        details: details,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  void error({
    required String prefix,
    required String subsystem,
    required String operation,
    DriveScanLogContext context = const DriveScanLogContext(),
    String? message,
    Map<String, Object?> details = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      DriveScanLogEntry(
        prefix: prefix,
        subsystem: subsystem,
        operation: operation,
        level: DriveScanLogLevel.error,
        context: context,
        message: message,
        details: details,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

class ConsoleDriveScanLogger extends DriveScanLogger {
  const ConsoleDriveScanLogger();

  @override
  void log(DriveScanLogEntry entry) {
    developer.log(
      entry.formattedLine,
      name: entry.loggerName,
      level: entry.developerLevel,
      error: entry.error,
      stackTrace: entry.stackTrace,
    );
  }
}

class NoOpDriveScanLogger extends DriveScanLogger {
  const NoOpDriveScanLogger();

  @override
  void log(DriveScanLogEntry entry) {}
}

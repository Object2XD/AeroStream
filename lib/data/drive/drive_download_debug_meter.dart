import '../../media_extraction/core/byte_range.dart';

enum DriveDownloadDebugComponent { metadata, artwork }

class DriveDownloadDebugContext {
  const DriveDownloadDebugContext({
    required this.meter,
    required this.component,
    required this.driveFileId,
    this.jobId,
    this.taskId,
  });

  final DriveDownloadDebugMeter meter;
  final DriveDownloadDebugComponent component;
  final String driveFileId;
  final int? jobId;
  final int? taskId;

  String get componentName => component.name;

  Map<String, Object?> toLogFields() {
    return <String, Object?>{
      'component': componentName,
      if (jobId != null) 'jobId': jobId,
      if (taskId != null) 'taskId': taskId,
      'driveFileId': driveFileId,
    };
  }
}

class DriveDownloadDebugSummary {
  const DriveDownloadDebugSummary({
    required this.downloadedBytes,
    required this.requestedBytes,
    required this.uniqueRequestedBytes,
    required this.requestCount,
  });

  final int downloadedBytes;
  final int requestedBytes;
  final int uniqueRequestedBytes;
  final int requestCount;

  int get overfetchBytes => requestedBytes - uniqueRequestedBytes;

  Map<String, Object?> toLogFields() {
    return <String, Object?>{
      'downloadedBytes': downloadedBytes,
      'requestedBytes': requestedBytes,
      'uniqueRequestedBytes': uniqueRequestedBytes,
      'requestCount': requestCount,
      'overfetchBytes': overfetchBytes,
    };
  }
}

class DriveDownloadDebugMeter {
  final Map<String, _DriveDownloadDebugSession> _sessions =
      <String, _DriveDownloadDebugSession>{};

  void beginSession(DriveDownloadDebugContext context) {
    _sessions.putIfAbsent(contextKey(context), _DriveDownloadDebugSession.new);
  }

  void recordRequestedRange(
    DriveDownloadDebugContext context,
    ByteRange range,
  ) {
    final session = _sessions.putIfAbsent(
      contextKey(context),
      _DriveDownloadDebugSession.new,
    );
    session.requestCount += 1;
    session.requestedBytes += range.length;
    session.addUniqueRange(range);
  }

  void recordDownloadedBytes(DriveDownloadDebugContext context, int byteCount) {
    final session = _sessions.putIfAbsent(
      contextKey(context),
      _DriveDownloadDebugSession.new,
    );
    session.downloadedBytes += byteCount;
  }

  DriveDownloadDebugSummary snapshot(DriveDownloadDebugContext context) {
    final session = _sessions[contextKey(context)];
    if (session == null) {
      return const DriveDownloadDebugSummary(
        downloadedBytes: 0,
        requestedBytes: 0,
        uniqueRequestedBytes: 0,
        requestCount: 0,
      );
    }
    return session.summary;
  }

  DriveDownloadDebugSummary endSession(DriveDownloadDebugContext context) {
    final key = contextKey(context);
    final session = _sessions.remove(key);
    if (session == null) {
      return const DriveDownloadDebugSummary(
        downloadedBytes: 0,
        requestedBytes: 0,
        uniqueRequestedBytes: 0,
        requestCount: 0,
      );
    }
    return session.summary;
  }

  String contextKey(DriveDownloadDebugContext context) {
    return '${context.componentName}|${context.jobId ?? '-'}|'
        '${context.taskId ?? '-'}|${context.driveFileId}';
  }
}

class _DriveDownloadDebugSession {
  int downloadedBytes = 0;
  int requestedBytes = 0;
  int requestCount = 0;
  final List<ByteRange> _uniqueRanges = <ByteRange>[];

  void addUniqueRange(ByteRange range) {
    if (_uniqueRanges.isEmpty) {
      _uniqueRanges.add(range);
      return;
    }
    final merged = <ByteRange>[];
    var candidate = range;
    var inserted = false;
    for (final existing in _uniqueRanges) {
      if (existing.endExclusive < candidate.start) {
        merged.add(existing);
        continue;
      }
      if (candidate.endExclusive < existing.start) {
        if (!inserted) {
          merged.add(candidate);
          inserted = true;
        }
        merged.add(existing);
        continue;
      }
      final start = existing.start < candidate.start
          ? existing.start
          : candidate.start;
      final end = existing.endExclusive > candidate.endExclusive
          ? existing.endExclusive
          : candidate.endExclusive;
      candidate = ByteRange(start, end);
    }
    if (!inserted) {
      merged.add(candidate);
    }
    _uniqueRanges
      ..clear()
      ..addAll(merged);
  }

  int get uniqueRequestedBytes => _uniqueRanges.fold<int>(
    0,
    (sum, range) => sum + range.length,
  );

  DriveDownloadDebugSummary get summary => DriveDownloadDebugSummary(
    downloadedBytes: downloadedBytes,
    requestedBytes: requestedBytes,
    uniqueRequestedBytes: uniqueRequestedBytes,
    requestCount: requestCount,
  );
}

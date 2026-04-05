import 'dart:math' as math;
import 'dart:typed_data';

import '../../../media_extraction/core/byte_range.dart';
import '../../../media_extraction/core/byte_range_reader.dart';
import '../../../media_extraction/core/byte_segment.dart';
import '../drive_download_debug_meter.dart';
import '../drive_http_client.dart';

enum DriveByteRangeFetchPolicy { minimumWindow, exact }

class DriveRangeReadBudget {
  const DriveRangeReadBudget({
    this.maxDownloadedBytes,
    this.maxRequestedBytes,
    this.maxRequestCount,
  });

  final int? maxDownloadedBytes;
  final int? maxRequestedBytes;
  final int? maxRequestCount;
}

class DriveRangeBudgetExceeded implements Exception {
  const DriveRangeBudgetExceeded({
    required this.reason,
    required this.limit,
    required this.actual,
  });

  final String reason;
  final int limit;
  final int actual;

  @override
  String toString() {
    return 'DriveRangeBudgetExceeded(reason: $reason, limit: $limit, actual: $actual)';
  }
}

class DriveRangeReadCanceled implements Exception {
  const DriveRangeReadCanceled([this.reason = 'range_read_canceled']);

  final String reason;

  @override
  String toString() => 'DriveRangeReadCanceled(reason: $reason)';
}

class DriveByteRangeReader implements ByteRangeReader {
  DriveByteRangeReader({
    required DriveHttpClient driveHttpClient,
    required String driveFileId,
    required String? resourceKey,
    required int? fileSize,
    Iterable<ByteSegment> prefetchedSegments = const <ByteSegment>[],
    DriveByteRangeFetchPolicy fetchPolicy =
        DriveByteRangeFetchPolicy.minimumWindow,
    DriveDownloadDebugContext? debugContext,
    DriveRangeReadBudget? readBudget,
    bool Function()? shouldAbort,
  }) : _driveHttpClient = driveHttpClient,
       _driveFileId = driveFileId,
       _resourceKey = resourceKey,
       _fileSize = fileSize,
       _segments = <ByteSegment>[...prefetchedSegments],
       _fetchPolicy = fetchPolicy,
       _debugContext = debugContext,
       _readBudget = readBudget,
       _shouldAbort = shouldAbort;

  static const _minimumFetchWindowBytes = 4096;

  final DriveHttpClient _driveHttpClient;
  final String _driveFileId;
  final String? _resourceKey;
  final int? _fileSize;
  final List<ByteSegment> _segments;
  final DriveByteRangeFetchPolicy _fetchPolicy;
  final DriveDownloadDebugContext? _debugContext;
  final DriveRangeReadBudget? _readBudget;
  final bool Function()? _shouldAbort;
  int _downloadedBytes = 0;
  int _requestedBytes = 0;
  int _requestCount = 0;

  @override
  Future<Uint8List> read(ByteRange range) async {
    _throwIfAborted();
    if (range.length == 0) {
      return Uint8List(0);
    }
    for (final segment in _segments) {
      if (segment.covers(range)) {
        return segment.slice(range);
      }
    }

    final fetchEnd = _resolvedFetchEnd(range);
    final fetchRange = ByteRange(range.start, fetchEnd);
    _enforceBudgetBeforeRequest(fetchRange);
    final debugContext = _debugContext;
    if (debugContext != null) {
      debugContext.meter.recordRequestedRange(debugContext, fetchRange);
    }
    final bytes = await _driveHttpClient.downloadBytes(
      fileId: _driveFileId,
      resourceKey: _resourceKey,
      rangeHeader: fetchRange.toHttpRangeHeader(),
    );
    _throwIfAborted();
    _enforceBudgetAfterDownload(bytes.length);
    if (debugContext != null) {
      debugContext.meter.recordDownloadedBytes(debugContext, bytes.length);
    }
    final segment = ByteSegment(start: fetchRange.start, bytes: bytes);
    _segments.add(segment);
    return segment.slice(range);
  }

  void _throwIfAborted() {
    if (_shouldAbort?.call() ?? false) {
      throw const DriveRangeReadCanceled();
    }
  }

  int _resolvedFetchEnd(ByteRange range) {
    final exactEnd = range.endExclusive;
    final fileSize = _fileSize;
    if (_fetchPolicy == DriveByteRangeFetchPolicy.exact ||
        fileSize == null ||
        range.length >= _minimumFetchWindowBytes) {
      return exactEnd;
    }
    return math.min(fileSize, range.start + _minimumFetchWindowBytes);
  }

  void _enforceBudgetBeforeRequest(ByteRange fetchRange) {
    final budget = _readBudget;
    if (budget == null) {
      return;
    }
    final nextRequestCount = _requestCount + 1;
    if (budget.maxRequestCount != null &&
        nextRequestCount > budget.maxRequestCount!) {
      throw DriveRangeBudgetExceeded(
        reason: 'range_budget_exceeded',
        limit: budget.maxRequestCount!,
        actual: nextRequestCount,
      );
    }
    final nextRequestedBytes = _requestedBytes + fetchRange.length;
    if (budget.maxRequestedBytes != null &&
        nextRequestedBytes > budget.maxRequestedBytes!) {
      throw DriveRangeBudgetExceeded(
        reason: 'range_budget_exceeded',
        limit: budget.maxRequestedBytes!,
        actual: nextRequestedBytes,
      );
    }
    _requestCount = nextRequestCount;
    _requestedBytes = nextRequestedBytes;
  }

  void _enforceBudgetAfterDownload(int downloadedBytes) {
    final budget = _readBudget;
    final nextDownloadedBytes = _downloadedBytes + downloadedBytes;
    if (budget != null &&
        budget.maxDownloadedBytes != null &&
        nextDownloadedBytes > budget.maxDownloadedBytes!) {
      throw DriveRangeBudgetExceeded(
        reason: 'range_budget_exceeded',
        limit: budget.maxDownloadedBytes!,
        actual: nextDownloadedBytes,
      );
    }
    _downloadedBytes = nextDownloadedBytes;
  }
}

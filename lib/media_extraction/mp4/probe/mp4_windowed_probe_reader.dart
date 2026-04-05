import 'dart:math' as math;
import 'dart:typed_data';

import '../../core/byte_range.dart';
import '../../core/byte_range_reader.dart';
import '../../core/byte_segment.dart';

class Mp4WindowedProbeReader implements ByteRangeReader {
  Mp4WindowedProbeReader({
    required ByteRangeReader delegate,
    required int fileSize,
    Iterable<ByteSegment> prefetchedSegments = const <ByteSegment>[],
    int initialWindowBytes = 64 * 1024,
    int maxWindowBytes = 256 * 1024,
    int sequentialGapBytes = 1024,
  }) : _delegate = delegate,
       _fileSize = fileSize,
       _segments = <ByteSegment>[...prefetchedSegments],
       _initialWindowBytes = initialWindowBytes,
       _maxWindowBytes = maxWindowBytes,
       _sequentialGapBytes = sequentialGapBytes,
       _nextWindowBytes = initialWindowBytes;

  final ByteRangeReader _delegate;
  final int _fileSize;
  final List<ByteSegment> _segments;
  final int _initialWindowBytes;
  final int _maxWindowBytes;
  final int _sequentialGapBytes;

  int _nextWindowBytes;
  int? _lastFetchEndExclusive;

  List<ByteSegment> get cachedSegments => List<ByteSegment>.unmodifiable(_segments);

  @override
  Future<Uint8List> read(ByteRange range) async {
    if (range.length == 0) {
      return Uint8List(0);
    }
    for (final segment in _segments) {
      if (segment.covers(range)) {
        return segment.slice(range);
      }
    }

    final fetchRange = _resolveFetchRange(range);
    final bytes = await _delegate.read(fetchRange);
    final segment = ByteSegment(start: fetchRange.start, bytes: bytes);
    _segments.add(segment);
    _updateWindowGrowth(fetchRange);
    return segment.slice(range);
  }

  ByteRange _resolveFetchRange(ByteRange requestedRange) {
    final desiredLength = math.max(requestedRange.length, _nextWindowBytes);
    final endExclusive = math.min(
      _fileSize,
      requestedRange.start + desiredLength,
    );
    return ByteRange(requestedRange.start, endExclusive);
  }

  void _updateWindowGrowth(ByteRange fetchRange) {
    final lastFetchEndExclusive = _lastFetchEndExclusive;
    if (lastFetchEndExclusive != null &&
        fetchRange.start <= lastFetchEndExclusive + _sequentialGapBytes) {
      _nextWindowBytes = math.min(_maxWindowBytes, _nextWindowBytes * 2);
    } else {
      _nextWindowBytes = _initialWindowBytes;
    }
    _lastFetchEndExclusive = fetchRange.endExclusive;
  }
}

import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../../media_extraction/core/extracted_artwork.dart';
import '../../../media_extraction/core/byte_range.dart';
import '../../database/app_database.dart';
import '../audio_extraction_exception.dart';
import '../drive_download_debug_meter.dart';
import '../drive_embedded_tag_parser.dart';
import '../drive_http_client.dart';
import '../drive_scan_logger.dart';
import 'drive_artwork_adapter.dart';
import 'drive_audio_object_descriptor.dart';
import 'drive_byte_range_reader.dart';
import 'm4a_drive_artwork_adapter.dart';
import 'mp3_drive_artwork_adapter.dart';

class DriveExtractedArtwork {
  const DriveExtractedArtwork({
    required this.bytes,
    required this.mimeType,
    required this.contentHash,
  });

  final Uint8List bytes;
  final String mimeType;
  final String contentHash;

  String get fileExtension => switch (mimeType) {
    'image/png' => '.png',
    'image/webp' => '.webp',
    _ => '.jpg',
  };
}

class DriveArtworkExtractor {
  DriveArtworkExtractor({
    required DriveHttpClient driveHttpClient,
    DriveScanLogger logger = const NoOpDriveScanLogger(),
    List<DriveArtworkAdapter>? artworkAdapters,
  }) : _driveHttpClient = driveHttpClient,
       _logger = logger,
       _artworkAdapters =
           artworkAdapters ??
           const <DriveArtworkAdapter>[
             Mp3DriveArtworkAdapter(),
             M4aDriveArtworkAdapter(),
           ];

  final DriveHttpClient _driveHttpClient;
  final DriveScanLogger _logger;
  final List<DriveArtworkAdapter> _artworkAdapters;

  static const _headBytesLength = 512 * 1024;
  static const _tailBytesLength = 256 * 1024;
  static const _maxArtworkDownloadedBytes = 32 * 1024 * 1024;
  static const _maxArtworkRequestedBytes = 48 * 1024 * 1024;
  static const _maxArtworkRequestCount = 256;

  Future<DriveExtractedArtwork?> extract(
    Track track, {
    DriveDownloadDebugContext? debugContext,
  }) async {
    final stopwatch = Stopwatch()..start();
    final context = debugContext;
    if (context != null) {
      context.meter.beginSession(context);
    }
    _logger.info(
      prefix: 'DriveScan',
      subsystem: 'extractor.artwork',
      operation: 'extract_start',
      context: DriveScanLogContext(
        jobId: context?.jobId,
        taskId: context?.taskId,
        driveFileId: track.driveFileId,
      ),
      details: <String, Object?>{
        'fileName': track.fileName,
        if (context != null) 'component': context.componentName,
      },
    );

    try {
      _logger.info(
        prefix: 'DriveScan',
        subsystem: 'extractor.artwork',
        operation: 'ranged_parse_start',
        context: DriveScanLogContext(
          jobId: context?.jobId,
          taskId: context?.taskId,
          driveFileId: track.driveFileId,
        ),
      details: <String, Object?>{
        'fileName': track.fileName,
        if (context != null) 'component': context.componentName,
      },
      );
      final artwork = await _extractWithRanges(track, debugContext: context);
      if (artwork == null) {
        _logger.warning(
          prefix: 'DriveScan',
          subsystem: 'extractor.artwork',
          operation: 'artwork_not_found',
          context: DriveScanLogContext(
            jobId: context?.jobId,
            taskId: context?.taskId,
            driveFileId: track.driveFileId,
            elapsedMs: stopwatch.elapsedMilliseconds,
          ),
          details: <String, Object?>{'fileName': track.fileName},
        );
      } else {
        _logger.info(
          prefix: 'DriveScan',
          subsystem: 'extractor.artwork',
          operation: 'ranged_parse_success',
          context: DriveScanLogContext(
            jobId: context?.jobId,
            taskId: context?.taskId,
            driveFileId: track.driveFileId,
            elapsedMs: stopwatch.elapsedMilliseconds,
          ),
          details: <String, Object?>{'fileName': track.fileName},
        );
      }
      return artwork;
    } on DriveRangedExtractionException catch (error, stackTrace) {
      _logger.warning(
        prefix: 'DriveScan',
        subsystem: 'extractor.artwork',
        operation: 'ranged_fast_fail',
        context: DriveScanLogContext(
          jobId: context?.jobId,
          taskId: context?.taskId,
          driveFileId: track.driveFileId,
        ),
        details: <String, Object?>{
          'fileName': track.fileName,
          'reason': error.reason,
        },
      );
      _logger.error(
        prefix: 'DriveScan',
        subsystem: 'extractor.artwork',
        operation: 'extract_fail',
        context: DriveScanLogContext(
          jobId: context?.jobId,
          taskId: context?.taskId,
          driveFileId: track.driveFileId,
          elapsedMs: stopwatch.elapsedMilliseconds,
        ),
        details: <String, Object?>{'fileName': track.fileName},
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } on DriveRangeBudgetExceeded catch (error, stackTrace) {
      final fastFail = DriveRangedExtractionException(
        error.reason,
        fileName: track.fileName,
        mimeType: track.mimeType,
        cause: error,
      );
      _logger.warning(
        prefix: 'DriveScan',
        subsystem: 'extractor.artwork',
        operation: 'ranged_fast_fail',
        context: DriveScanLogContext(
          jobId: context?.jobId,
          taskId: context?.taskId,
          driveFileId: track.driveFileId,
        ),
        details: <String, Object?>{
          'fileName': track.fileName,
          'reason': fastFail.reason,
        },
      );
      _logger.error(
        prefix: 'DriveScan',
        subsystem: 'extractor.artwork',
        operation: 'extract_fail',
        context: DriveScanLogContext(
          jobId: context?.jobId,
          taskId: context?.taskId,
          driveFileId: track.driveFileId,
          elapsedMs: stopwatch.elapsedMilliseconds,
        ),
        details: <String, Object?>{'fileName': track.fileName},
        error: fastFail,
        stackTrace: stackTrace,
      );
      throw fastFail;
    } catch (error, stackTrace) {
      final fastFail = DriveRangedExtractionException(
        'ranged_parse_failed',
        fileName: track.fileName,
        mimeType: track.mimeType,
        cause: error,
      );
      _logger.error(
        prefix: 'DriveScan',
        subsystem: 'extractor.artwork',
        operation: 'ranged_parse_fail',
        context: DriveScanLogContext(driveFileId: track.driveFileId),
        details: <String, Object?>{'fileName': track.fileName},
        error: error,
        stackTrace: stackTrace,
      );
      _logger.warning(
        prefix: 'DriveScan',
        subsystem: 'extractor.artwork',
        operation: 'ranged_fast_fail',
        context: DriveScanLogContext(
          jobId: context?.jobId,
          taskId: context?.taskId,
          driveFileId: track.driveFileId,
        ),
        details: <String, Object?>{
          'fileName': track.fileName,
          'reason': fastFail.reason,
        },
      );
      _logger.error(
        prefix: 'DriveScan',
        subsystem: 'extractor.artwork',
        operation: 'extract_fail',
        context: DriveScanLogContext(
          jobId: context?.jobId,
          taskId: context?.taskId,
          driveFileId: track.driveFileId,
          elapsedMs: stopwatch.elapsedMilliseconds,
        ),
        details: <String, Object?>{'fileName': track.fileName},
        error: fastFail,
        stackTrace: stackTrace,
      );
      throw fastFail;
    } finally {
      if (context != null) {
        finalizeArtworkDebugSession(context);
      }
    }
  }

  void finalizeArtworkDebugSession(DriveDownloadDebugContext context) {
    final summary = context.meter.endSession(context);
    _logger.info(
      prefix: 'DriveScan',
      subsystem: 'extractor.artwork',
      operation: 'artwork_download_summary',
      context: DriveScanLogContext(
        jobId: context.jobId,
        taskId: context.taskId,
        driveFileId: context.driveFileId,
      ),
      details: <String, Object?>{
        'component': context.componentName,
        ...summary.toLogFields(),
      },
    );
  }

  Future<DriveExtractedArtwork?> _extractWithRanges(
    Track track, {
    DriveDownloadDebugContext? debugContext,
  }) async {
    final headLength = _resolveHeadLength(track.sizeBytes);

    for (final adapter in _artworkAdapters) {
      if (!adapter.supports(track)) {
        continue;
      }
      final descriptor = DriveAudioObjectDescriptor.fromTrack(track);
      final reader = DriveByteRangeReader(
        driveHttpClient: _driveHttpClient,
        driveFileId: track.driveFileId,
        resourceKey: track.resourceKey,
        fileSize: track.sizeBytes,
        fetchPolicy: adapter.fetchPolicy,
        debugContext: debugContext,
        readBudget: const DriveRangeReadBudget(
          maxDownloadedBytes: _maxArtworkDownloadedBytes,
          maxRequestedBytes: _maxArtworkRequestedBytes,
          maxRequestCount: _maxArtworkRequestCount,
        ),
      );
      final extracted = await adapter.extract(
        DriveArtworkAdapterContext(
          track: track,
          descriptor: descriptor,
          reader: reader,
        ),
      );
      if (extracted == null) {
        return null;
      }
      return _buildExtractedArtwork(extracted);
    }

    final tailLength = _resolveTailLength(track.sizeBytes, headLength);
    final context = debugContext;
    if (context != null) {
      context.meter.beginSession(context);
    }
    final plannedRanges = <ByteRange>[
      ByteRange(0, headLength),
      if (tailLength > 0)
        ByteRange(
          (track.sizeBytes ?? headLength) - tailLength,
          (track.sizeBytes ?? headLength),
        ),
    ];
    if (context != null) {
      for (final planned in plannedRanges) {
        context.meter.recordRequestedRange(context, planned);
      }
    }
    _logger.info(
      prefix: 'DriveScan',
      subsystem: 'extractor.artwork',
      operation: 'range_fetch_plan_summary',
      context: DriveScanLogContext(
        jobId: context?.jobId,
        taskId: context?.taskId,
        driveFileId: track.driveFileId,
      ),
      details: <String, Object?>{
        'fileName': track.fileName,
        'rangeCount': plannedRanges.length,
        'plannedBytes': plannedRanges.fold<int>(
          0,
          (sum, range) => sum + range.length,
        ),
        if (context != null) 'component': context.componentName,
      },
    );
    final rangeResults = await Future.wait<Uint8List>([
      context == null
          ? _driveHttpClient.downloadBytes(
              fileId: track.driveFileId,
              resourceKey: track.resourceKey,
              rangeHeader: 'bytes=0-${headLength - 1}',
            )
          : _driveHttpClient
              .downloadBytes(
                fileId: track.driveFileId,
                resourceKey: track.resourceKey,
                rangeHeader: 'bytes=0-${headLength - 1}',
              )
              .then((bytes) {
                context.meter.recordDownloadedBytes(context, bytes.length);
                return bytes;
              }),
      if (tailLength > 0)
        context == null
            ? _driveHttpClient.downloadBytes(
                fileId: track.driveFileId,
                resourceKey: track.resourceKey,
                rangeHeader:
                    'bytes=${(track.sizeBytes ?? headLength) - tailLength}-${(track.sizeBytes ?? headLength) - 1}',
              )
            : _driveHttpClient
                .downloadBytes(
                  fileId: track.driveFileId,
                  resourceKey: track.resourceKey,
                  rangeHeader:
                      'bytes=${(track.sizeBytes ?? headLength) - tailLength}-${(track.sizeBytes ?? headLength) - 1}',
                )
                .then((bytes) {
                  context.meter.recordDownloadedBytes(context, bytes.length);
                  return bytes;
                }),
    ]);
    final headBytes = rangeResults.first;
    final tailBytes = tailLength == 0 ? headBytes : rangeResults.last;

    final parsed = await Isolate.run(
      () => _parseArtworkRange(
        headBytes: headBytes,
        tailBytes: tailBytes,
        mimeType: track.mimeType,
        fileName: track.fileName,
        fileSize: track.sizeBytes,
      ),
    );
    if (parsed == null) {
      return null;
    }

    return DriveExtractedArtwork(
      bytes: parsed['bytes']! as Uint8List,
      mimeType: parsed['mimeType']! as String,
      contentHash: parsed['contentHash']! as String,
    );
  }

  int _resolveHeadLength(int? sizeBytes) {
    final safeSize = sizeBytes ?? _headBytesLength;
    return math.max(1, math.min(_headBytesLength, safeSize));
  }

  int _resolveTailLength(int? sizeBytes, int headLength) {
    if (sizeBytes == null || sizeBytes <= headLength) {
      return 0;
    }
    final remaining = sizeBytes - headLength;
    return math.max(0, math.min(_tailBytesLength, remaining));
  }

  DriveExtractedArtwork _buildExtractedArtwork(ExtractedArtwork artwork) {
    return DriveExtractedArtwork(
      bytes: artwork.bytes,
      mimeType: artwork.mimeType,
      contentHash: sha1.convert(artwork.bytes).toString(),
    );
  }
}

Map<String, Object?>? _parseArtworkRange({
  required Uint8List headBytes,
  required Uint8List tailBytes,
  required String mimeType,
  required String fileName,
  required int? fileSize,
}) {
  final parsed = DriveEmbeddedTagParser.parse(
    headBytes: headBytes,
    tailBytes: tailBytes,
    mimeType: mimeType,
    fileName: fileName,
    fileSize: fileSize,
  );
  final artworkBytes = parsed?.artworkBytes;
  if (artworkBytes == null || artworkBytes.isEmpty) {
    return null;
  }
  return <String, Object?>{
    'bytes': artworkBytes,
    'mimeType': parsed?.artworkMimeType ?? 'image/jpeg',
    'contentHash': sha1.convert(artworkBytes).toString(),
  };
}

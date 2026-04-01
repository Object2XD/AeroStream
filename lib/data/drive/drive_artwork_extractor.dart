import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'drive_embedded_tag_parser.dart';
import 'drive_http_client.dart';
import 'drive_scan_logger.dart';

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
  }) : _driveHttpClient = driveHttpClient,
       _logger = logger;

  final DriveHttpClient _driveHttpClient;
  final DriveScanLogger _logger;

  static const _headBytesLength = 512 * 1024;
  static const _tailBytesLength = 256 * 1024;

  Future<DriveExtractedArtwork?> extract(Track track) async {
    final stopwatch = Stopwatch()..start();
    _logger.info(
      prefix: 'DriveScan',
      subsystem: 'extractor.artwork',
      operation: 'extract_start',
      context: DriveScanLogContext(driveFileId: track.driveFileId),
      details: <String, Object?>{'fileName': track.fileName},
    );

    try {
      try {
        _logger.info(
          prefix: 'DriveScan',
          subsystem: 'extractor.artwork',
          operation: 'ranged_parse_start',
          context: DriveScanLogContext(driveFileId: track.driveFileId),
          details: <String, Object?>{'fileName': track.fileName},
        );
        final ranged = await _extractWithRanges(track);
        if (ranged != null) {
          _logger.info(
            prefix: 'DriveScan',
            subsystem: 'extractor.artwork',
            operation: 'ranged_parse_success',
            context: DriveScanLogContext(
              driveFileId: track.driveFileId,
              elapsedMs: stopwatch.elapsedMilliseconds,
            ),
            details: <String, Object?>{'fileName': track.fileName},
          );
          return ranged;
        }
        _logger.warning(
          prefix: 'DriveScan',
          subsystem: 'extractor.artwork',
          operation: 'full_download_fallback',
          context: DriveScanLogContext(driveFileId: track.driveFileId),
          details: <String, Object?>{
            'fileName': track.fileName,
            'reason': 'ranged_artwork_unavailable',
          },
        );
      } catch (error, stackTrace) {
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
          operation: 'full_download_fallback',
          context: DriveScanLogContext(driveFileId: track.driveFileId),
          details: <String, Object?>{
            'fileName': track.fileName,
            'reason': 'ranged_parse_failed',
          },
        );
      }

      final artwork = await _extractWithFullDownload(track);
      if (artwork == null) {
        _logger.warning(
          prefix: 'DriveScan',
          subsystem: 'extractor.artwork',
          operation: 'artwork_not_found',
          context: DriveScanLogContext(
            driveFileId: track.driveFileId,
            elapsedMs: stopwatch.elapsedMilliseconds,
          ),
          details: <String, Object?>{'fileName': track.fileName},
        );
      } else {
        _logger.info(
          prefix: 'DriveScan',
          subsystem: 'extractor.artwork',
          operation: 'full_download_success',
          context: DriveScanLogContext(
            driveFileId: track.driveFileId,
            elapsedMs: stopwatch.elapsedMilliseconds,
          ),
          details: <String, Object?>{'fileName': track.fileName},
        );
      }
      return artwork;
    } catch (error, stackTrace) {
      _logger.error(
        prefix: 'DriveScan',
        subsystem: 'extractor.artwork',
        operation: 'extract_fail',
        context: DriveScanLogContext(
          driveFileId: track.driveFileId,
          elapsedMs: stopwatch.elapsedMilliseconds,
        ),
        details: <String, Object?>{'fileName': track.fileName},
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<DriveExtractedArtwork?> _extractWithRanges(Track track) async {
    final headLength = _resolveHeadLength(track.sizeBytes);
    final tailLength = _resolveTailLength(track.sizeBytes, headLength);

    final rangeResults = await Future.wait<Uint8List>([
      _driveHttpClient.downloadBytes(
        fileId: track.driveFileId,
        resourceKey: track.resourceKey,
        rangeHeader: 'bytes=0-${headLength - 1}',
      ),
      if (tailLength > 0)
        _driveHttpClient.downloadBytes(
          fileId: track.driveFileId,
          resourceKey: track.resourceKey,
          rangeHeader:
              'bytes=${(track.sizeBytes ?? headLength) - tailLength}-${(track.sizeBytes ?? headLength) - 1}',
        ),
    ]);
    final headBytes = rangeResults.first;
    final tailBytes = tailLength == 0 ? headBytes : rangeResults.last;

    final parsed = await Isolate.run(
      () => _parseArtworkRange(
        headBytes: headBytes,
        tailBytes: tailBytes,
        mimeType: track.mimeType,
        fileName: track.fileName,
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

  Future<DriveExtractedArtwork?> _extractWithFullDownload(Track track) async {
    final temporaryDirectory = await getTemporaryDirectory();
    final extension = _fileExtension(
      track.fileName,
      fallbackMimeType: track.mimeType,
    );
    final tempFile = File(
      p.join(temporaryDirectory.path, 'artwork-${track.id}$extension'),
    );

    final response = await _driveHttpClient.downloadFile(
      fileId: track.driveFileId,
      resourceKey: track.resourceKey,
    );
    final sink = tempFile.openWrite();
    await response.stream.pipe(sink);

    try {
      final metadata = readMetadata(tempFile, getImage: true);
      final pictures = metadata.pictures;
      if (pictures.isEmpty) {
        return null;
      }
      final bytes = pictures.first.bytes;
      return DriveExtractedArtwork(
        bytes: bytes,
        mimeType: pictures.first.mimetype,
        contentHash: sha1.convert(bytes).toString(),
      );
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
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

  String _fileExtension(
    String fileName, {
    required String fallbackMimeType,
  }) {
    final fromName = p.extension(fileName);
    if (fromName.isNotEmpty) {
      return fromName;
    }

    return switch (fallbackMimeType) {
      'audio/flac' => '.flac',
      'audio/aac' => '.aac',
      'audio/ogg' => '.ogg',
      'audio/opus' => '.opus',
      'audio/wav' || 'audio/x-wav' => '.wav',
      'audio/mp4' || 'audio/x-m4a' => '.m4a',
      _ => '.mp3',
    };
  }
}

Map<String, Object?>? _parseArtworkRange({
  required Uint8List headBytes,
  required Uint8List tailBytes,
  required String mimeType,
  required String fileName,
}) {
  final parsed = DriveEmbeddedTagParser.parse(
    headBytes: headBytes,
    tailBytes: tailBytes,
    mimeType: mimeType,
    fileName: fileName,
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

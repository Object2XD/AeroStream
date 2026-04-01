import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';
import 'drive_embedded_tag_parser.dart';
import 'drive_http_client.dart';
import 'legacy_text_decoder.dart';
import 'drive_scan_logger.dart';

class DriveExtractedMetadata {
  const DriveExtractedMetadata({
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArtist,
    required this.genre,
    required this.year,
    required this.trackNumber,
    required this.discNumber,
    required this.durationMs,
  });

  final String title;
  final String artist;
  final String album;
  final String albumArtist;
  final String genre;
  final int? year;
  final int trackNumber;
  final int discNumber;
  final int durationMs;
}

class DriveMetadataExtractor {
  DriveMetadataExtractor({
    required DriveHttpClient driveHttpClient,
    DriveScanLogger logger = const NoOpDriveScanLogger(),
  }) : _driveHttpClient = driveHttpClient,
       _logger = logger;

  final DriveHttpClient _driveHttpClient;
  final DriveScanLogger _logger;

  static const _headBytesLength = 512 * 1024;
  static const _tailBytesLength = 256 * 1024;

  Future<DriveExtractedMetadata> extract(Track track) async {
    final stopwatch = Stopwatch()..start();
    _logger.info(
      prefix: 'DriveScan',
      subsystem: 'extractor.metadata',
      operation: 'extract_start',
      context: DriveScanLogContext(driveFileId: track.driveFileId),
      details: <String, Object?>{'fileName': track.fileName},
    );

    try {
      try {
        _logger.info(
          prefix: 'DriveScan',
          subsystem: 'extractor.metadata',
          operation: 'ranged_parse_start',
          context: DriveScanLogContext(driveFileId: track.driveFileId),
          details: <String, Object?>{'fileName': track.fileName},
        );
        final ranged = await _extractWithRanges(track);
        if (ranged != null) {
          _logger.info(
            prefix: 'DriveScan',
            subsystem: 'extractor.metadata',
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
          subsystem: 'extractor.metadata',
          operation: 'full_download_fallback',
          context: DriveScanLogContext(driveFileId: track.driveFileId),
          details: <String, Object?>{
            'fileName': track.fileName,
            'reason': 'ranged_metadata_unavailable',
          },
        );
      } catch (error, stackTrace) {
        _logger.error(
          prefix: 'DriveScan',
          subsystem: 'extractor.metadata',
          operation: 'ranged_parse_fail',
          context: DriveScanLogContext(driveFileId: track.driveFileId),
          details: <String, Object?>{'fileName': track.fileName},
          error: error,
          stackTrace: stackTrace,
        );
        _logger.warning(
          prefix: 'DriveScan',
          subsystem: 'extractor.metadata',
          operation: 'full_download_fallback',
          context: DriveScanLogContext(driveFileId: track.driveFileId),
          details: <String, Object?>{
            'fileName': track.fileName,
            'reason': 'ranged_parse_failed',
          },
        );
      }
      final metadata = await _extractWithFullDownload(track);
      _logger.info(
        prefix: 'DriveScan',
        subsystem: 'extractor.metadata',
        operation: 'full_download_success',
        context: DriveScanLogContext(
          driveFileId: track.driveFileId,
          elapsedMs: stopwatch.elapsedMilliseconds,
        ),
        details: <String, Object?>{'fileName': track.fileName},
      );
      return metadata;
    } catch (error, stackTrace) {
      _logger.error(
        prefix: 'DriveScan',
        subsystem: 'extractor.metadata',
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

  Future<DriveExtractedMetadata?> _extractWithRanges(Track track) async {
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
      () => _parseMetadataRange(
        headBytes: headBytes,
        tailBytes: tailBytes,
        mimeType: track.mimeType,
        fileName: track.fileName,
      ),
    );
    if (parsed == null) {
      return null;
    }

    return DriveExtractedMetadata(
      title: _normalizeText(
        parsed['title'] as String?,
        fallback: _defaultTitleFromFileName(track.fileName),
      ),
      artist: _normalizeText(
        parsed['artist'] as String?,
        fallback: track.artist,
      ),
      album: _normalizeText(parsed['album'] as String?, fallback: track.album),
      albumArtist:
          _normalizeOptionalText(parsed['albumArtist'] as String?) ?? '',
      genre: _normalizeText(parsed['genre'] as String?, fallback: track.genre),
      year: parsed['year'] as int? ?? track.year,
      trackNumber: parsed['trackNumber'] as int? ?? track.trackNumber,
      discNumber: parsed['discNumber'] as int? ?? track.discNumber,
      durationMs: parsed['durationMs'] as int? ?? track.durationMs,
    );
  }

  Future<DriveExtractedMetadata> _extractWithFullDownload(Track track) async {
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'aero-stream-metadata-',
    );
    final extension = _fileExtension(
      track.fileName,
      fallbackMimeType: track.mimeType,
    );
    final tempFile = File(
      p.join(temporaryDirectory.path, 'metadata-${track.id}$extension'),
    );

    final response = await _driveHttpClient.downloadFile(
      fileId: track.driveFileId,
      resourceKey: track.resourceKey,
    );
    final sink = tempFile.openWrite();
    await response.stream.pipe(sink);

    try {
      final Object metadata = readAllMetadata(tempFile, getImage: false);
      return extractFromFullMetadata(track: track, metadata: metadata);
    } finally {
      if (await temporaryDirectory.exists()) {
        try {
          await temporaryDirectory.delete(recursive: true);
        } on FileSystemException {
          // Some desktop parsers keep the temp file open briefly. This is only
          // best-effort cleanup, so we can safely ignore deletion races here.
        }
      }
    }
  }

  static DriveExtractedMetadata extractFromFullMetadata({
    required Track track,
    required Object metadata,
  }) {
    final defaultTitle = _defaultTitleFromFileName(track.fileName);
    final fallback = switch (metadata) {
      Mp3Metadata mp3 => (
        title: repairMisdecodedLegacyText(mp3.songName),
        artist: repairMisdecodedLegacyText(
          mp3.leadPerformer ?? mp3.originalArtist,
        ),
        album: repairMisdecodedLegacyText(mp3.album),
        albumArtist: repairMisdecodedLegacyText(mp3.bandOrOrchestra),
        genres: repairMisdecodedLegacyTexts(mp3.genres),
        year: mp3.originalReleaseYear ?? mp3.year,
        trackNumber: mp3.trackNumber,
        discNumber: mp3.discNumber,
        durationMs: mp3.duration?.inMilliseconds,
      ),
      VorbisMetadata vorbis => (
        title: _firstOrNull(vorbis.title),
        artist: _firstOrNull(vorbis.artist),
        album: _firstOrNull(vorbis.album),
        albumArtist: null,
        genres: vorbis.genres,
        year: vorbis.date.isEmpty ? null : vorbis.date.first.year,
        trackNumber: vorbis.trackNumber.isEmpty
            ? null
            : vorbis.trackNumber.first,
        discNumber: vorbis.discNumber,
        durationMs: vorbis.duration?.inMilliseconds,
      ),
      Mp4Metadata mp4 => (
        title: mp4.title,
        artist: mp4.artist,
        album: mp4.album,
        albumArtist: null,
        genres: mp4.genre == null ? const <String>[] : <String>[mp4.genre!],
        year: _normalizeYear(mp4.year),
        trackNumber: mp4.trackNumber,
        discNumber: mp4.discNumber,
        durationMs: mp4.duration?.inMilliseconds,
      ),
      RiffMetadata riff => (
        title: repairMisdecodedLegacyText(riff.title),
        artist: repairMisdecodedLegacyText(riff.artist),
        album: repairMisdecodedLegacyText(riff.album),
        albumArtist: null,
        genres: riff.genre == null
            ? const <String>[]
            : switch (repairMisdecodedLegacyText(riff.genre)) {
                final value? => <String>[value],
                null => const <String>[],
              },
        year: _normalizeYear(riff.year),
        trackNumber: riff.trackNumber,
        discNumber: null,
        durationMs: riff.duration?.inMilliseconds,
      ),
      _ => (
        title: null,
        artist: null,
        album: null,
        albumArtist: null,
        genres: const <String>[],
        year: null,
        trackNumber: null,
        discNumber: null,
        durationMs: null,
      ),
    };

    return DriveExtractedMetadata(
      title: _normalizeText(fallback.title, fallback: defaultTitle),
      artist: _normalizeText(fallback.artist, fallback: track.artist),
      album: _normalizeText(fallback.album, fallback: track.album),
      albumArtist: _normalizeOptionalText(fallback.albumArtist) ?? '',
      genre: _normalizeGenre(fallback.genres, fallback: track.genre),
      year: fallback.year ?? track.year,
      trackNumber: fallback.trackNumber ?? track.trackNumber,
      discNumber: fallback.discNumber ?? track.discNumber,
      durationMs: fallback.durationMs ?? track.durationMs,
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

  static String _normalizeText(String? value, {required String fallback}) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
    final fallbackNormalized = fallback.trim();
    return fallbackNormalized;
  }

  static String? _normalizeOptionalText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static String _normalizeGenre(
    List<String> genres, {
    required String fallback,
  }) {
    for (final genre in genres) {
      final normalized = genre.trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return fallback.trim();
  }

  static int? _normalizeYear(DateTime? year) {
    final resolvedYear = year?.year;
    if (resolvedYear == null || resolvedYear <= 1) {
      return null;
    }
    return resolvedYear;
  }

  static String _defaultTitleFromFileName(String fileName) {
    final extension = p.extension(fileName);
    if (extension.isEmpty) {
      return fileName;
    }
    return fileName.substring(0, fileName.length - extension.length);
  }

  String _fileExtension(String fileName, {required String fallbackMimeType}) {
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

  static String? _firstOrNull(List<String> values) {
    for (final value in values) {
      final normalized = _normalizeOptionalText(value);
      if (normalized != null) {
        return normalized;
      }
    }
    return null;
  }
}

Map<String, Object?>? _parseMetadataRange({
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
  if (parsed == null || !parsed.hasAnyTag) {
    return null;
  }
  return <String, Object?>{
    'title': parsed.title,
    'artist': parsed.artist,
    'album': parsed.album,
    'albumArtist': parsed.albumArtist,
    'genre': parsed.genre,
    'year': parsed.year,
    'trackNumber': parsed.trackNumber,
    'discNumber': parsed.discNumber,
    'durationMs': parsed.durationMs,
  };
}

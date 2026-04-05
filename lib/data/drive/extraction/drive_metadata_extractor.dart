import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;

import '../../../media_extraction/core/audio_extraction_capabilities.dart';
import '../../../media_extraction/core/audio_extraction_cost_class.dart';
import '../../../media_extraction/core/byte_range.dart';
import '../../../media_extraction/core/extraction_failure.dart';
import '../../../media_extraction/core/extracted_metadata.dart';
import '../../database/app_database.dart';
import '../audio_extraction_exception.dart';
import '../drive_download_debug_meter.dart';
import '../drive_embedded_tag_parser.dart';
import '../drive_http_client.dart';
import '../drive_scan_logger.dart';
import '../legacy_text_decoder.dart';
import 'drive_audio_object_descriptor.dart';
import 'drive_metadata_adapter.dart';
import 'drive_byte_range_reader.dart';
import 'm4a_drive_metadata_adapter.dart';
import 'mp3_drive_metadata_adapter.dart';

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
    List<DriveMetadataAdapter>? metadataAdapters,
  }) : _driveHttpClient = driveHttpClient,
       _logger = logger,
       _metadataAdapters =
           metadataAdapters ??
           const <DriveMetadataAdapter>[
             Mp3DriveMetadataAdapter(),
             M4aDriveMetadataAdapter(),
           ];

  final DriveHttpClient _driveHttpClient;
  final DriveScanLogger _logger;
  final List<DriveMetadataAdapter> _metadataAdapters;

  static const _headBytesLength = 512 * 1024;
  static const _tailBytesLength = 256 * 1024;
  static const _maxMetadataDownloadedBytes = 8 * 1024 * 1024;
  static const _maxMetadataRequestedBytes = 16 * 1024 * 1024;
  static const _maxMetadataRequestCount = 256;
  static final _MetadataParseWorker _parseWorker = _MetadataParseWorker();

  String? formatKeyForTrack(Track? track) {
    if (track == null) {
      return null;
    }
    final adapter = _metadataAdapters.cast<DriveMetadataAdapter?>().firstWhere(
      (candidate) => candidate!.supports(track),
      orElse: () => null,
    );
    return adapter
        ?.createPipelineSession(
          DriveMetadataAdapterContext(
            track: track,
            descriptor: DriveAudioObjectDescriptor.fromTrack(track),
            reader: DriveByteRangeReader(
              driveHttpClient: _driveHttpClient,
              driveFileId: track.driveFileId,
              resourceKey: track.resourceKey,
              fileSize: track.sizeBytes,
              fetchPolicy: DriveByteRangeFetchPolicy.exact,
            ),
          ),
        )
        .formatKey;
  }

  Future<Uint8List> fetchFullBytes(Track track) {
    return fetchFullBytesWithDebug(track: track);
  }

  Future<Uint8List> fetchFullBytesWithDebug({
    required Track track,
    DriveDownloadDebugContext? debugContext,
  }) {
    final rangeHeader = _fullFileRangeHeader(track.sizeBytes);
    final context = debugContext;
    if (context != null) {
      context.meter.beginSession(context);
    }
    if (context != null && track.sizeBytes != null && track.sizeBytes! > 0) {
      context.meter.recordRequestedRange(
        context,
        ByteRange(0, track.sizeBytes!),
      );
    }
    final logContext = DriveScanLogContext(
      jobId: context?.jobId,
      taskId: context?.taskId,
      driveFileId: track.driveFileId,
    );
    final logDetails = <String, Object?>{
      'fileName': track.fileName,
      'sizeBytes': track.sizeBytes,
      'rangeHeader': rangeHeader,
      if (context != null) 'component': context.componentName,
    };
    if (context?.jobId != null && context?.taskId != null) {
      _logger.warning(
        prefix: 'DriveScan',
        subsystem: 'extractor.metadata',
        operation: 'full_fetch_requested_bytes',
        context: logContext,
        details: logDetails,
      );
    } else {
      _logger.info(
        prefix: 'DriveScan',
        subsystem: 'extractor.metadata',
        operation: 'full_fetch_requested_bytes',
        context: logContext,
        details: logDetails,
      );
    }
    return context == null
        ? _driveHttpClient.downloadBytes(
            fileId: track.driveFileId,
            resourceKey: track.resourceKey,
            rangeHeader: rangeHeader,
          )
        : _driveHttpClient
              .downloadBytes(
                fileId: track.driveFileId,
                resourceKey: track.resourceKey,
                rangeHeader: rangeHeader,
              )
              .then((bytes) {
                context.meter.recordDownloadedBytes(context, bytes.length);
                return bytes;
              });
  }

  Future<DriveExtractedMetadata> parseFullBytes({
    required Track track,
    required Uint8List bytes,
  }) async {
    if (bytes.isEmpty) {
      throw DriveRangedExtractionException(
        'full_fetch_empty',
        fileName: track.fileName,
        mimeType: track.mimeType,
      );
    }
    final parsed = await _parseMetadataRangeIsolate(
      headBytes: bytes,
      tailBytes: bytes,
      mimeType: track.mimeType,
      fileName: track.fileName,
      fileSize: track.sizeBytes ?? bytes.length,
    );
    if (parsed == null) {
      throw DriveRangedExtractionException(
        'full_metadata_unavailable',
        fileName: track.fileName,
        mimeType: track.mimeType,
      );
    }
    return _buildParsedMetadata(track, parsed);
  }

  DrivePreparedMetadataSession prepareSession(
    Track track, {
    DriveDownloadDebugContext? debugContext,
    bool Function()? shouldAbortRead,
  }) {
    final adapter = _metadataAdapters.cast<DriveMetadataAdapter?>().firstWhere(
      (candidate) => candidate!.supports(track),
      orElse: () => null,
    );
    if (adapter != null) {
      final descriptor = DriveAudioObjectDescriptor.fromTrack(track);
      final reader = DriveByteRangeReader(
        driveHttpClient: _driveHttpClient,
        driveFileId: track.driveFileId,
        resourceKey: track.resourceKey,
        fileSize: track.sizeBytes,
        fetchPolicy: adapter.fetchPolicy,
        debugContext: debugContext,
        shouldAbort: shouldAbortRead,
        readBudget: const DriveRangeReadBudget(
          maxDownloadedBytes: _maxMetadataDownloadedBytes,
          maxRequestedBytes: _maxMetadataRequestedBytes,
          maxRequestCount: _maxMetadataRequestCount,
        ),
      );
      return DrivePreparedMetadataSession(
        track: track,
        session: adapter.createPipelineSession(
          DriveMetadataAdapterContext(
            track: track,
            descriptor: descriptor,
            reader: reader,
          ),
        ),
        buildExtractedMetadata: (extracted) =>
            _buildExtractedMetadata(track, extracted),
      );
    }

    return _LegacyPreparedMetadataSession(
      track: track,
      extractLegacy: () =>
          _extractWithRanges(track, debugContext: debugContext),
    );
  }

  Future<DriveExtractedMetadata> extract(
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
      subsystem: 'extractor.metadata',
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
        subsystem: 'extractor.metadata',
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
      final metadata = await _extractWithRanges(track, debugContext: context);
      _logger.info(
        prefix: 'DriveScan',
        subsystem: 'extractor.metadata',
        operation: 'ranged_parse_success',
        context: DriveScanLogContext(
          jobId: context?.jobId,
          taskId: context?.taskId,
          driveFileId: track.driveFileId,
          elapsedMs: stopwatch.elapsedMilliseconds,
        ),
        details: <String, Object?>{'fileName': track.fileName},
      );
      return metadata;
    } on DriveRangedExtractionException catch (error, stackTrace) {
      _logger.warning(
        prefix: 'DriveScan',
        subsystem: 'extractor.metadata',
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
        subsystem: 'extractor.metadata',
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
    } on ExtractionFailure catch (error, stackTrace) {
      final fastFail = DriveRangedExtractionException(
        error.reason,
        fileName: track.fileName,
        mimeType: track.mimeType,
        cause: error,
      );
      _logger.warning(
        prefix: 'DriveScan',
        subsystem: 'extractor.metadata',
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
        subsystem: 'extractor.metadata',
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
    } on DriveRangeBudgetExceeded catch (error, stackTrace) {
      final fastFail = DriveRangedExtractionException(
        error.reason,
        fileName: track.fileName,
        mimeType: track.mimeType,
        cause: error,
      );
      _logger.warning(
        prefix: 'DriveScan',
        subsystem: 'extractor.metadata',
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
        subsystem: 'extractor.metadata',
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
        operation: 'ranged_fast_fail',
        context: DriveScanLogContext(driveFileId: track.driveFileId),
        details: <String, Object?>{
          'fileName': track.fileName,
          'reason': fastFail.reason,
        },
      );
      _logger.error(
        prefix: 'DriveScan',
        subsystem: 'extractor.metadata',
        operation: 'extract_fail',
        context: DriveScanLogContext(
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
        finalizeMetadataDebugSession(context);
      }
    }
  }

  void finalizeMetadataDebugSession(
    DriveDownloadDebugContext context, {
    bool canceled = false,
  }) {
    final summary = context.meter.endSession(context);
    _logger.info(
      prefix: 'DriveScan',
      subsystem: 'extractor.metadata',
      operation: 'metadata_download_summary',
      context: DriveScanLogContext(
        jobId: context.jobId,
        taskId: context.taskId,
        driveFileId: context.driveFileId,
      ),
      details: <String, Object?>{
        'component': context.componentName,
        'result': canceled ? 'canceled' : 'completed',
        ...summary.toLogFields(),
      },
    );
  }

  String? _fullFileRangeHeader(int? sizeBytes) {
    if (sizeBytes == null) {
      return null;
    }
    if (sizeBytes <= 0) {
      return null;
    }
    return 'bytes=0-${sizeBytes - 1}';
  }

  Future<DriveExtractedMetadata> _extractWithRanges(
    Track track, {
    DriveDownloadDebugContext? debugContext,
  }) async {
    final adapter = _metadataAdapters.cast<DriveMetadataAdapter?>().firstWhere(
      (candidate) => candidate!.supports(track),
      orElse: () => null,
    );

    if (adapter != null) {
      final session = prepareSession(track, debugContext: debugContext);
      _logger.info(
        prefix: 'DriveScan',
        subsystem: 'extractor.metadata',
        operation: 'range_fetch_plan_summary',
        context: DriveScanLogContext(
          jobId: debugContext?.jobId,
          taskId: debugContext?.taskId,
          driveFileId: track.driveFileId,
        ),
        details: <String, Object?>{
          'fileName': track.fileName,
          'mode': 'session_driven',
          'formatKey': session.formatKey,
          if (debugContext != null) 'component': debugContext.componentName,
        },
      );
      await session.fetchHead();
      await session.analyzeHead();
      while (!session.isHeadAnalysisResolved && session.canFetchMoreHeadBytes) {
        await session.fetchHead();
        await session.analyzeHead();
      }
      await session.plan();
      await session.fetch();
      return await session.parse();
    }

    final headLength = _resolveHeadLength(track.sizeBytes);
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
      subsystem: 'extractor.metadata',
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

    final parsed = await _parseMetadataRangeIsolate(
      headBytes: headBytes,
      tailBytes: tailBytes,
      mimeType: track.mimeType,
      fileName: track.fileName,
      fileSize: track.sizeBytes,
    );
    if (parsed == null) {
      throw DriveRangedExtractionException(
        'ranged_metadata_unavailable',
        fileName: track.fileName,
        mimeType: track.mimeType,
      );
    }

    return _buildParsedMetadata(track, parsed);
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

  Future<ParsedTagData?> _parseMetadataRangeIsolate({
    required Uint8List headBytes,
    required Uint8List tailBytes,
    required String mimeType,
    required String fileName,
    required int? fileSize,
  }) async {
    try {
      return await _parseWorker.parse(
        headBytes: headBytes,
        tailBytes: tailBytes,
        mimeType: mimeType,
        fileName: fileName,
        fileSize: fileSize,
      );
    } catch (_) {
      return Isolate.run(
        () => _parseMetadataRange(
          headBytes: headBytes,
          tailBytes: tailBytes,
          mimeType: mimeType,
          fileName: fileName,
          fileSize: fileSize,
        ),
      );
    }
  }

  DriveExtractedMetadata _buildParsedMetadata(
    Track track,
    ParsedTagData parsed,
  ) {
    return DriveExtractedMetadata(
      title: _normalizeText(
        parsed.title,
        fallback: _defaultTitleFromFileName(track.fileName),
      ),
      artist: _normalizeText(parsed.artist, fallback: track.artist),
      album: _normalizeText(parsed.album, fallback: track.album),
      albumArtist: _normalizeOptionalText(parsed.albumArtist) ?? '',
      genre: _normalizeText(parsed.genre, fallback: track.genre),
      year: parsed.year ?? track.year,
      trackNumber: parsed.trackNumber ?? track.trackNumber,
      discNumber: parsed.discNumber ?? track.discNumber,
      durationMs: parsed.durationMs ?? track.durationMs,
    );
  }

  DriveExtractedMetadata _buildExtractedMetadata(
    Track track,
    ExtractedMetadata extracted,
  ) {
    return DriveExtractedMetadata(
      title: _normalizeText(
        extracted.title,
        fallback: _defaultTitleFromFileName(track.fileName),
      ),
      artist: _normalizeText(extracted.artist, fallback: track.artist),
      album: _normalizeText(extracted.album, fallback: track.album),
      albumArtist: _normalizeOptionalText(extracted.albumArtist) ?? '',
      genre: _normalizeText(extracted.genre, fallback: track.genre),
      year: extracted.year ?? track.year,
      trackNumber: extracted.trackNumber ?? track.trackNumber,
      discNumber: extracted.discNumber ?? track.discNumber,
      durationMs: extracted.durationMs ?? track.durationMs,
    );
  }

  static String _normalizeText(String? value, {required String fallback}) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
    return fallback.trim();
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

class DrivePreparedMetadataSession {
  DrivePreparedMetadataSession({
    required this.track,
    required DriveMetadataPipelineSession session,
    required DriveExtractedMetadata Function(ExtractedMetadata extracted)
    buildExtractedMetadata,
  }) : _session = session,
       _buildExtractedMetadata = buildExtractedMetadata;

  final Track track;
  final DriveMetadataPipelineSession _session;
  final DriveExtractedMetadata Function(ExtractedMetadata extracted)
  _buildExtractedMetadata;

  String get formatKey => _session.formatKey;

  bool get isHeadAnalysisResolved => _session.isHeadAnalysisResolved;

  bool get canFetchMoreHeadBytes => _session.canFetchMoreHeadBytes;

  int get fetchedHeadBytes => _session.fetchedHeadBytes;

  int get headExpansionCount => _session.headExpansionCount;

  Future<void> fetchHead() => _session.fetchHead();

  Future<void> analyzeHead() => _session.analyzeHead();

  Future<void> probe() => _session.probe();

  Future<void> plan() => _session.plan();

  Future<void> fetch() => _session.fetch();

  Future<void> probeAndPlanAndFetch() async {
    await fetchHead();
    await analyzeHead();
    while (!isHeadAnalysisResolved && canFetchMoreHeadBytes) {
      await fetchHead();
      await analyzeHead();
    }
    await plan();
    await fetch();
  }

  Future<DriveExtractedMetadata> parse() async {
    final extracted = await _session.parse();
    return _buildExtractedMetadata(extracted);
  }
}

class _LegacyPreparedMetadataSession extends DrivePreparedMetadataSession {
  _LegacyPreparedMetadataSession({
    required super.track,
    required Future<DriveExtractedMetadata> Function() extractLegacy,
  }) : _extractLegacy = extractLegacy,
       super(
         session: const _DriveMetadataNoopPipelineSession(),
         buildExtractedMetadata: _identityMetadata,
       );

  final Future<DriveExtractedMetadata> Function() _extractLegacy;

  @override
  String get formatKey => 'other';

  @override
  Future<DriveExtractedMetadata> parse() => _extractLegacy();
}

class _DriveMetadataNoopPipelineSession
    implements DriveMetadataPipelineSession {
  const _DriveMetadataNoopPipelineSession();

  @override
  AudioExtractionCapabilities get capabilities =>
      const AudioExtractionCapabilities(
        supportsMetadata: true,
        supportsArtwork: false,
        costClass: AudioExtractionCostClass.light,
        maxProbeBytes: 0,
        maxPlannedRanges: 0,
      );

  @override
  String get formatKey => 'other';

  @override
  bool get isHeadAnalysisResolved => true;

  @override
  bool get canFetchMoreHeadBytes => false;

  @override
  int get fetchedHeadBytes => 0;

  @override
  int get headExpansionCount => 0;

  @override
  Future<void> fetchHead() async {}

  @override
  Future<void> analyzeHead() async {}

  @override
  Future<void> fetch() async {}

  @override
  Future<void> plan() async {}

  @override
  Future<void> probe() async {
    await fetchHead();
    await analyzeHead();
  }

  @override
  Future<ExtractedMetadata> parse() {
    throw UnimplementedError();
  }
}

DriveExtractedMetadata _identityMetadata(ExtractedMetadata extracted) {
  throw UnimplementedError();
}

ParsedTagData? _parseMetadataRange({
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
    includeArtwork: false,
  );
  if (parsed == null || !parsed.hasAnyTag) {
    return null;
  }
  return parsed;
}

class _MetadataParseWorker {
  _MetadataParseWorker();

  SendPort? _sendPort;
  Future<void>? _booting;
  int _nextRequestId = 0;
  final Map<int, Completer<ParsedTagData?>> _pending =
      <int, Completer<ParsedTagData?>>{};

  Future<ParsedTagData?> parse({
    required Uint8List headBytes,
    required Uint8List tailBytes,
    required String mimeType,
    required String fileName,
    required int? fileSize,
  }) async {
    await _ensureStarted();
    final requestId = _nextRequestId++;
    final completer = Completer<ParsedTagData?>();
    _pending[requestId] = completer;
    _sendPort!.send(<String, Object?>{
      'id': requestId,
      'headBytes': TransferableTypedData.fromList(<Uint8List>[headBytes]),
      'tailBytes': TransferableTypedData.fromList(<Uint8List>[tailBytes]),
      'mimeType': mimeType,
      'fileName': fileName,
      'fileSize': fileSize,
    });
    return completer.future;
  }

  Future<void> _ensureStarted() async {
    if (_sendPort != null) {
      return;
    }
    if (_booting != null) {
      await _booting;
      return;
    }
    _booting = _start();
    await _booting;
    _booting = null;
  }

  Future<void> _start() async {
    final receivePort = ReceivePort();
    final readyPort = Completer<SendPort>();

    receivePort.listen((dynamic message) {
      if (message is SendPort) {
        if (!readyPort.isCompleted) {
          readyPort.complete(message);
        }
        return;
      }
      if (message is! Map<Object?, Object?>) {
        return;
      }
      final idValue = message['id'];
      if (idValue is! int) {
        return;
      }
      final completer = _pending.remove(idValue);
      if (completer == null || completer.isCompleted) {
        return;
      }
      final ok = message['ok'] == true;
      if (!ok) {
        final error = message['error']?.toString() ?? 'parse_worker_failed';
        completer.completeError(StateError(error));
        return;
      }
      final parsedValue = message['parsed'];
      if (parsedValue == null) {
        completer.complete(null);
        return;
      }
      if (parsedValue is! Map<Object?, Object?>) {
        completer.completeError(StateError('parse_worker_invalid_payload'));
        return;
      }
      completer.complete(_parsedFromMap(parsedValue));
    });

    await Isolate.spawn<SendPort>(
      _metadataParseWorkerMain,
      receivePort.sendPort,
      debugName: 'metadata-parse-worker',
    );
    _sendPort = await readyPort.future.timeout(const Duration(seconds: 2));
  }

  ParsedTagData _parsedFromMap(Map<Object?, Object?> data) {
    return ParsedTagData(
      title: data['title'] as String?,
      artist: data['artist'] as String?,
      album: data['album'] as String?,
      albumArtist: data['albumArtist'] as String?,
      genre: data['genre'] as String?,
      year: data['year'] as int?,
      trackNumber: data['trackNumber'] as int?,
      discNumber: data['discNumber'] as int?,
      durationMs: data['durationMs'] as int?,
      artworkBytes: null,
      artworkMimeType: null,
    );
  }
}

void _metadataParseWorkerMain(SendPort hostSendPort) {
  final workerPort = ReceivePort();
  hostSendPort.send(workerPort.sendPort);

  workerPort.listen((dynamic message) {
    if (message is! Map<Object?, Object?>) {
      return;
    }
    final idValue = message['id'];
    if (idValue is! int) {
      return;
    }
    try {
      final headBytes = (message['headBytes'] as TransferableTypedData)
          .materialize()
          .asUint8List();
      final tailBytes = (message['tailBytes'] as TransferableTypedData)
          .materialize()
          .asUint8List();
      final parsed = _parseMetadataRange(
        headBytes: headBytes,
        tailBytes: tailBytes,
        mimeType: message['mimeType'] as String,
        fileName: message['fileName'] as String,
        fileSize: message['fileSize'] as int?,
      );
      hostSendPort.send(<String, Object?>{
        'id': idValue,
        'ok': true,
        'parsed': parsed == null
            ? null
            : <String, Object?>{
                'title': parsed.title,
                'artist': parsed.artist,
                'album': parsed.album,
                'albumArtist': parsed.albumArtist,
                'genre': parsed.genre,
                'year': parsed.year,
                'trackNumber': parsed.trackNumber,
                'discNumber': parsed.discNumber,
                'durationMs': parsed.durationMs,
              },
      });
    } catch (error, stackTrace) {
      hostSendPort.send(<String, Object?>{
        'id': idValue,
        'ok': false,
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });
    }
  });
}

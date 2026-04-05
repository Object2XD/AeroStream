import '../../../media_extraction/core/extracted_metadata.dart';
import '../../../media_extraction/core/audio_extraction_fetch_plan.dart';
import '../../../media_extraction/core/byte_range.dart';
import '../../../media_extraction/core/byte_segment.dart';
import '../../../media_extraction/core/audio_extraction_capabilities.dart';
import '../../../media_extraction/core/audio_extraction_cost_class.dart';
import '../../../media_extraction/core/extraction_failure.dart';
import '../../../media_extraction/mp3/model/mp3_metadata_plan_result.dart';
import '../../../media_extraction/mp3/model/mp3_metadata_probe_result.dart';
import '../../../media_extraction/mp3/parse/mp3_tag_parser.dart';
import '../../../media_extraction/mp3/service/mp3_metadata_service.dart';
import '../audio_extraction_exception.dart';
import 'drive_byte_range_reader.dart';
import 'drive_metadata_adapter.dart';

class Mp3DriveMetadataAdapter implements DriveMetadataAdapter {
  const Mp3DriveMetadataAdapter({Mp3MetadataService? service})
    : _service = service ?? const Mp3MetadataService();

  final Mp3MetadataService _service;

  @override
  bool supports(track) {
    final lowerName = track.fileName.toLowerCase();
    return track.mimeType == 'audio/mpeg' || lowerName.endsWith('.mp3');
  }

  @override
  AudioExtractionCapabilities get capabilities =>
      const AudioExtractionCapabilities(
        supportsMetadata: true,
        supportsArtwork: false,
        costClass: AudioExtractionCostClass.light,
        maxProbeBytes: 128 * 1024,
        maxPlannedRanges: 12,
      );

  @override
  DriveByteRangeFetchPolicy get fetchPolicy => DriveByteRangeFetchPolicy.exact;

  @override
  Future<ExtractedMetadata> extract(DriveMetadataAdapterContext context) async {
    try {
      return await _service.extract(
        descriptor: context.descriptor,
        reader: context.reader,
        initialSegments: const [],
      );
    } on ExtractionFailure catch (error) {
      throw DriveRangedExtractionException(
        error.reason,
        fileName: context.track.fileName,
        mimeType: context.track.mimeType,
        cause: error,
      );
    }
  }

  @override
  DriveMetadataPipelineSession createPipelineSession(
    DriveMetadataAdapterContext context,
  ) {
    return _Mp3DriveMetadataPipelineSession(
      context: context,
      service: _service,
      adapter: this,
    );
  }
}

class _Mp3DriveMetadataPipelineSession implements DriveMetadataPipelineSession {
  _Mp3DriveMetadataPipelineSession({
    required DriveMetadataAdapterContext context,
    required Mp3MetadataService service,
    required Mp3DriveMetadataAdapter adapter,
  }) : _context = context,
       _service = service,
       _adapter = adapter;

  final DriveMetadataAdapterContext _context;
  final Mp3MetadataService _service;
  final Mp3DriveMetadataAdapter _adapter;

  Mp3MetadataProbeResult? _probeResult;
  Mp3MetadataPlanResult? _planResult;
  List<ByteSegment> _segments = const <ByteSegment>[];

  @override
  String get formatKey => 'mp3';

  @override
  AudioExtractionCapabilities get capabilities => _adapter.capabilities;

  @override
  bool get isHeadAnalysisResolved => _probeResult != null;

  @override
  bool get canFetchMoreHeadBytes => false;

  @override
  int get fetchedHeadBytes => _segments.fold<int>(
    0,
    (sum, segment) => segment.start == 0 ? sum + segment.bytes.length : sum,
  );

  @override
  int get headExpansionCount => _segments.isEmpty ? 0 : 1;

  @override
  Future<void> fetchHead() async {
    final headLength = _context.descriptor.sizeBytes == null
        ? Mp3TagParser.id3HeaderLength
        : (_context.descriptor.sizeBytes! < Mp3TagParser.id3HeaderLength
              ? _context.descriptor.sizeBytes!
              : Mp3TagParser.id3HeaderLength);
    final headBytes = await _context.reader.read(ByteRange(0, headLength));
    _segments = <ByteSegment>[ByteSegment(start: 0, bytes: headBytes)];
  }

  @override
  Future<void> analyzeHead() async {
    if (_segments.isEmpty) {
      throw StateError('fetchHead must run before analyzeHead');
    }
    _probeResult = await _service.analyzeHead(
      descriptor: _context.descriptor,
      headBytes: _segments.first.bytes,
    );
    if (_probeResult == null) {
      throw ExtractionFailure(
        'mp3_metadata_unavailable',
        fileName: _context.track.fileName,
        mimeType: _context.track.mimeType,
      );
    }
  }

  @override
  Future<void> probe() async {
    await fetchHead();
    await analyzeHead();
  }

  @override
  Future<void> plan() async {
    if (_probeResult == null) {
      throw StateError('probe must run before plan');
    }
    _planResult = await _service.plan(
      descriptor: _context.descriptor,
      reader: _context.reader,
      probe: _probeResult!,
      initialSegments: _segments,
    );
  }

  @override
  Future<void> fetch() async {
    final plan = _planResult;
    if (plan == null) {
      throw StateError('probe must run before fetch');
    }
    _segments = await _service.fetch(
      reader: _context.reader,
      plan: plan.primaryPlan,
      initialSegments: _segments,
    );
  }

  @override
  Future<ExtractedMetadata> parse() async {
    final plan = _planResult;
    if (plan == null) {
      throw StateError('probe must run before parse');
    }

    var parsed = _service.parse(plan: plan, segments: _segments);
    if (_needsId3v1Fallback(parsed) && plan.optionalId3v1Range != null) {
      final fallbackPlan = AudioExtractionFetchPlan(
        ranges: <ByteRange>[plan.optionalId3v1Range!],
      );
      _segments = await _service.fetch(
        reader: _context.reader,
        plan: fallbackPlan,
        initialSegments: _segments,
      );
      final footerSegment = _segments.firstWhere(
        (segment) => segment.covers(plan.optionalId3v1Range!),
      );
      final tailBytes = footerSegment.slice(plan.optionalId3v1Range!);
      final fallback = Mp3TagParser.parseId3v1(tailBytes);
      if (fallback != null) {
        parsed = parsed == null ? fallback : parsed.merge(fallback);
      }
    }

    if (parsed == null || !parsed.hasAnyMetadata) {
      throw ExtractionFailure(
        'mp3_metadata_unavailable',
        fileName: _context.track.fileName,
        mimeType: _context.track.mimeType,
      );
    }

    return ExtractedMetadata(
      title: parsed.title,
      artist: parsed.artist,
      album: parsed.album,
      albumArtist: parsed.albumArtist,
      genre: parsed.genre,
      year: parsed.year,
      trackNumber: parsed.trackNumber,
      discNumber: parsed.discNumber,
    );
  }

  bool _needsId3v1Fallback(Mp3ParsedTagData? parsed) {
    return parsed == null ||
        parsed.title == null ||
        parsed.artist == null ||
        parsed.album == null ||
        parsed.year == null ||
        parsed.trackNumber == null;
  }
}

import 'dart:math' as math;

import '../../../media_extraction/core/byte_range.dart';
import '../../../media_extraction/core/byte_segment.dart';
import '../../../media_extraction/mp4/model/mp4_metadata_plan_result.dart';
import '../../../media_extraction/mp4/model/mp4_metadata_probe_result.dart';
import '../../../media_extraction/core/audio_extraction_capabilities.dart';
import '../../../media_extraction/core/audio_extraction_cost_class.dart';
import '../../../media_extraction/core/extraction_failure.dart';
import '../../../media_extraction/core/extracted_metadata.dart';
import '../../../media_extraction/mp4/service/mp4_metadata_service.dart';
import '../audio_extraction_exception.dart';
import 'drive_byte_range_reader.dart';
import 'drive_metadata_adapter.dart';

class M4aDriveMetadataAdapter implements DriveMetadataAdapter {
  const M4aDriveMetadataAdapter({Mp4MetadataService? service})
    : _service = service ?? const Mp4MetadataService();

  static const _headStepBytes = 8 * 1024;

  final Mp4MetadataService _service;

  @override
  bool supports(track) {
    final lowerName = track.fileName.toLowerCase();
    return track.mimeType == 'audio/mp4' ||
        track.mimeType == 'audio/x-m4a' ||
        lowerName.endsWith('.m4a') ||
        lowerName.endsWith('.mp4');
  }

  @override
  AudioExtractionCapabilities get capabilities =>
      const AudioExtractionCapabilities(
        supportsMetadata: true,
        supportsArtwork: false,
        costClass: AudioExtractionCostClass.exploratory,
        maxProbeBytes: 8 * 1024,
        maxPlannedRanges: 8,
      );

  @override
  DriveByteRangeFetchPolicy get fetchPolicy => DriveByteRangeFetchPolicy.exact;

  @override
  Future<ExtractedMetadata> extract(DriveMetadataAdapterContext context) async {
    try {
      final session = createPipelineSession(context);
      await session.probe();
      await session.plan();
      await session.fetch();
      return await session.parse();
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
    return _M4aDriveMetadataPipelineSession(
      context: context,
      service: _service,
      adapter: this,
    );
  }
}

class _M4aDriveMetadataPipelineSession implements DriveMetadataPipelineSession {
  _M4aDriveMetadataPipelineSession({
    required DriveMetadataAdapterContext context,
    required Mp4MetadataService service,
    required M4aDriveMetadataAdapter adapter,
  }) : _context = context,
       _service = service,
       _adapter = adapter;

  final DriveMetadataAdapterContext _context;
  final Mp4MetadataService _service;
  final M4aDriveMetadataAdapter _adapter;

  Mp4MetadataProbeResult? _probeResult;
  Mp4MetadataPlanResult? _planResult;
  List<ByteSegment> _segments = const <ByteSegment>[];
  int _fetchedHeadBytes = 0;
  int _headExpansionCount = 0;

  @override
  String get formatKey => 'm4a';

  @override
  AudioExtractionCapabilities get capabilities => _adapter.capabilities;

  @override
  bool get isHeadAnalysisResolved => _probeResult != null;

  @override
  bool get canFetchMoreHeadBytes {
    return false;
  }

  @override
  int get fetchedHeadBytes => _fetchedHeadBytes;

  @override
  int get headExpansionCount => _headExpansionCount;

  @override
  Future<void> fetchHead() async {
    final nextEndExclusive = _resolveNextHeadEndExclusive();
    if (nextEndExclusive <= _fetchedHeadBytes) {
      return;
    }
    final bytes = await _context.reader.read(
      ByteRange(_fetchedHeadBytes, nextEndExclusive),
    );
    if (bytes.isEmpty) {
      return;
    }
    _segments = <ByteSegment>[
      ..._segments,
      ByteSegment(start: _fetchedHeadBytes, bytes: bytes),
    ];
    _fetchedHeadBytes = nextEndExclusive;
    _headExpansionCount += 1;
  }

  @override
  Future<void> analyzeHead() async {
    if (_segments.isEmpty) {
      throw StateError('fetchHead must run before analyzeHead');
    }
    _probeResult = await _service.analyzeHead(
      descriptor: _context.descriptor,
      initialSegments: _segments,
    );
  }

  @override
  Future<void> probe() async {
    await fetchHead();
    await analyzeHead();
  }

  @override
  Future<void> plan() async {
    if (_segments.isEmpty) {
      throw StateError('fetchHead must run before plan');
    }
    _probeResult ??= await _service.probe(
      descriptor: _context.descriptor,
      reader: _context.reader,
      initialSegments: _segments,
    );
    _segments = _probeResult!.probeSegments;
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
      throw StateError('plan must run before fetch');
    }
    _segments = await _service.fetch(
      reader: _context.reader,
      plan: plan.plan,
      initialSegments: _segments,
    );
  }

  @override
  Future<ExtractedMetadata> parse() async {
    final plan = _planResult;
    if (plan == null) {
      throw StateError('plan must run before parse');
    }
    final extracted = _service.parse(plan: plan, segments: _segments);
    if (extracted == null ||
        (extracted.title == null &&
            extracted.artist == null &&
            extracted.album == null &&
            extracted.albumArtist == null &&
            extracted.genre == null &&
            extracted.year == null &&
            extracted.trackNumber == null &&
            extracted.discNumber == null)) {
      throw ExtractionFailure(
        'mp4_sparse_parse_failed',
        fileName: _context.track.fileName,
        mimeType: _context.track.mimeType,
      );
    }
    return extracted;
  }

  int _resolveNextHeadEndExclusive() {
    final nextEndExclusive =
        _fetchedHeadBytes + M4aDriveMetadataAdapter._headStepBytes;
    final sizeBytes = _context.descriptor.sizeBytes;
    if (sizeBytes == null) {
      return math.max(1, nextEndExclusive);
    }
    return math.max(1, math.min(sizeBytes, nextEndExclusive));
  }
}

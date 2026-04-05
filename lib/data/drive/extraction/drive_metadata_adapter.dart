import '../../../media_extraction/core/audio_object_descriptor.dart';
import '../../../media_extraction/core/audio_extraction_capabilities.dart';
import '../../../media_extraction/core/audio_extraction_cost_class.dart';
import '../../../media_extraction/core/byte_range_reader.dart';
import '../../../media_extraction/core/extracted_metadata.dart';
import '../../database/app_database.dart';
import 'drive_byte_range_reader.dart';

class DriveMetadataAdapterContext {
  const DriveMetadataAdapterContext({
    required this.track,
    required this.descriptor,
    required this.reader,
  });

  final Track track;
  final AudioObjectDescriptor descriptor;
  final ByteRangeReader reader;
}

abstract interface class DriveMetadataAdapter {
  bool supports(Track track);

  AudioExtractionCapabilities get capabilities =>
      const AudioExtractionCapabilities(
        supportsMetadata: true,
        supportsArtwork: false,
        costClass: AudioExtractionCostClass.exploratory,
        maxProbeBytes: 512 * 1024,
        maxPlannedRanges: 8,
      );

  DriveByteRangeFetchPolicy get fetchPolicy =>
      DriveByteRangeFetchPolicy.minimumWindow;

  Future<ExtractedMetadata> extract(DriveMetadataAdapterContext context);

  DriveMetadataPipelineSession createPipelineSession(
    DriveMetadataAdapterContext context,
  ) {
    return _LegacyDriveMetadataPipelineSession(adapter: this, context: context);
  }
}

abstract interface class DriveMetadataPipelineSession {
  String get formatKey;

  AudioExtractionCapabilities get capabilities;

  bool get isHeadAnalysisResolved;

  bool get canFetchMoreHeadBytes;

  int get fetchedHeadBytes;

  int get headExpansionCount;

  Future<void> fetchHead();

  Future<void> analyzeHead();

  Future<void> probe();

  Future<void> plan();

  Future<void> fetch();

  Future<ExtractedMetadata> parse();
}

class _LegacyDriveMetadataPipelineSession
    implements DriveMetadataPipelineSession {
  const _LegacyDriveMetadataPipelineSession({
    required DriveMetadataAdapter adapter,
    required DriveMetadataAdapterContext context,
  }) : _adapter = adapter,
       _context = context;

  final DriveMetadataAdapter _adapter;
  final DriveMetadataAdapterContext _context;

  @override
  String get formatKey => 'other';

  @override
  AudioExtractionCapabilities get capabilities => _adapter.capabilities;

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
  Future<void> probe() async {}

  @override
  Future<void> plan() async {}

  @override
  Future<void> fetch() async {}

  @override
  Future<ExtractedMetadata> parse() {
    return _adapter.extract(_context);
  }
}

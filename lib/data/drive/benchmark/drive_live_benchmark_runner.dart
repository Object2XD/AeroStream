import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/drive_oauth_config.dart';
import '../../database/app_database.dart';
import '../audio_extraction_exception.dart';
import '../drive_auth_repository.dart';
import 'drive_benchmark_read_model.dart';
import '../drive_entities.dart';
import '../drive_http_client.dart';
import '../extraction/drive_artwork_extractor.dart';
import '../extraction/drive_metadata_extractor.dart';
import '../drive_scan_logger.dart';
import '../drive_scan_models.dart';
import '../metadata_pipeline_backlog.dart';

enum DriveBenchmarkMode {
  extractor('extractor'),
  jobSample('job-sample');

  const DriveBenchmarkMode(this.cliValue);

  final String cliValue;

  static DriveBenchmarkMode? fromCli(String? value) {
    for (final candidate in values) {
      if (candidate.cliValue == value) {
        return candidate;
      }
    }
    return null;
  }
}

enum DriveBenchmarkKind {
  metadata('metadata'),
  artwork('artwork'),
  both('both');

  const DriveBenchmarkKind(this.cliValue);

  final String cliValue;

  bool get includesMetadata =>
      this == DriveBenchmarkKind.metadata || this == DriveBenchmarkKind.both;

  bool get includesArtwork =>
      this == DriveBenchmarkKind.artwork || this == DriveBenchmarkKind.both;

  static DriveBenchmarkKind? fromCli(String? value) {
    for (final candidate in values) {
      if (candidate.cliValue == value) {
        return candidate;
      }
    }
    return null;
  }
}

class DriveBenchmarkCommand {
  const DriveBenchmarkCommand({
    required this.mode,
    required this.kind,
    required this.source,
    required this.limit,
    required this.concurrency,
    required this.windowSeconds,
    required this.repeatCount,
    required this.jsonOutput,
    required this.failIfDownloadFileCalled,
    required this.driveFileIds,
    this.jobId,
    this.mimeType,
    this.outputPath,
    this.databasePath,
    this.failUnderMetadataPerSecond,
    this.failUnderArtworkPerSecond,
  });

  final DriveBenchmarkMode mode;
  final DriveBenchmarkKind kind;
  final DriveBenchmarkTrackSource source;
  final int limit;
  final int concurrency;
  final int windowSeconds;
  final int repeatCount;
  final bool jsonOutput;
  final bool failIfDownloadFileCalled;
  final List<String> driveFileIds;
  final int? jobId;
  final String? mimeType;
  final String? outputPath;
  final String? databasePath;
  final double? failUnderMetadataPerSecond;
  final double? failUnderArtworkPerSecond;
}

class DriveBenchmarkParseResult {
  const DriveBenchmarkParseResult({this.command, this.usage, this.error});

  final DriveBenchmarkCommand? command;
  final String? usage;
  final String? error;

  bool get hasError => error != null;
  bool get isHelp => usage != null && command == null && error == null;
}

class BenchmarkFailure {
  const BenchmarkFailure({
    required this.kind,
    required this.driveFileId,
    required this.fileName,
    required this.reason,
    this.message,
  });

  final String kind;
  final String driveFileId;
  final String fileName;
  final String reason;
  final String? message;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'kind': kind,
      'driveFileId': driveFileId,
      'fileName': fileName,
      'reason': reason,
      'message': message,
    };
  }
}

class BenchmarkWindowSample {
  const BenchmarkWindowSample({
    required this.index,
    required this.windowSeconds,
    required this.metadataDelta,
    required this.artworkDelta,
    required this.metadataPerSecond,
    required this.artworkPerSecond,
    required this.runningTasksChanged,
  });

  final int index;
  final int windowSeconds;
  final int metadataDelta;
  final int artworkDelta;
  final double metadataPerSecond;
  final double artworkPerSecond;
  final bool runningTasksChanged;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'index': index,
      'windowSeconds': windowSeconds,
      'metadataDelta': metadataDelta,
      'artworkDelta': artworkDelta,
      'metadataPerSecond': metadataPerSecond,
      'artworkPerSecond': artworkPerSecond,
      'runningTasksChanged': runningTasksChanged,
    };
  }
}

class BenchmarkReport {
  const BenchmarkReport({
    required this.mode,
    required this.exitCode,
    required Map<String, Object?> fields,
  }) : _fields = fields;

  final DriveBenchmarkMode mode;
  final int exitCode;
  final Map<String, Object?> _fields;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'mode': mode.cliValue,
      'exitCode': exitCode,
      ..._fields,
    };
  }
}

class BenchmarkRecordingDriveScanLogger extends DriveScanLogger {
  BenchmarkRecordingDriveScanLogger({DriveScanLogger? delegate})
    : _delegate = delegate;

  final DriveScanLogger? _delegate;
  final List<DriveScanLogEntry> entries = <DriveScanLogEntry>[];

  @override
  void log(DriveScanLogEntry entry) {
    entries.add(entry);
    _delegate?.log(entry);
  }

  Iterable<DriveScanLogEntry> byOperation(String operation) {
    return entries.where((entry) => entry.operation == operation);
  }

  bool containsOperation(String operation) {
    return entries.any((entry) => entry.operation == operation);
  }

  Iterable<DriveScanLogEntry> bySubsystem(String subsystem) {
    return entries.where((entry) => entry.subsystem == subsystem);
  }
}

class BenchmarkingDriveHttpClient extends DriveHttpClient {
  BenchmarkingDriveHttpClient({required DriveHttpClient inner})
    : _inner = inner,
      super(authRepository: const _BenchmarkNoopAuthRepository());

  final DriveHttpClient _inner;
  int downloadFileCallCount = 0;

  void resetCounters() {
    downloadFileCallCount = 0;
  }

  @override
  Future<Uint8List> downloadBytes({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) {
    return _inner.downloadBytes(
      fileId: fileId,
      resourceKey: resourceKey,
      rangeHeader: rangeHeader,
    );
  }

  @override
  Future<http.StreamedResponse> downloadFile({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) {
    downloadFileCallCount += 1;
    return _inner.downloadFile(
      fileId: fileId,
      resourceKey: resourceKey,
      rangeHeader: rangeHeader,
    );
  }

  @override
  Future<List<DriveFolderEntry>> listFolders({String parentId = 'root'}) {
    return _inner.listFolders(parentId: parentId);
  }

  @override
  Future<DriveFolderPage> listFolderPage({
    required String parentId,
    String? pageToken,
    int pageSize = 1000,
  }) {
    return _inner.listFolderPage(
      parentId: parentId,
      pageToken: pageToken,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<DriveFileEntry>> listAudioFilesRecursively(String parentId) {
    return _inner.listAudioFilesRecursively(parentId);
  }

  @override
  Future<Map<String, dynamic>> getFolderMetadata(String folderId) {
    return _inner.getFolderMetadata(folderId);
  }

  @override
  Future<String> getStartPageToken() {
    return _inner.getStartPageToken();
  }

  @override
  Future<DriveChangePage> listChangesPage({
    required String pageToken,
    int pageSize = 1000,
  }) {
    return _inner.listChangesPage(pageToken: pageToken, pageSize: pageSize);
  }
}

class _BenchmarkNoopAuthRepository implements DriveAuthRepository {
  const _BenchmarkNoopAuthRepository();

  @override
  String? get configurationMessage => null;

  @override
  bool get isConfigured => true;

  @override
  Future<DriveAccountProfile> connect() {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<DriveAccountProfile?> restoreSession() async => null;

  @override
  Future<T> withClient<T>(Future<T> Function(http.Client client) action) {
    throw UnimplementedError();
  }
}

DriveBenchmarkParseResult parseDriveBenchmarkArgs(List<String> args) {
  final parser = ArgParser()
    ..addFlag('help', negatable: false)
    ..addOption(
      'mode',
      allowed: DriveBenchmarkMode.values.map((mode) => mode.cliValue).toList(),
      defaultsTo: DriveBenchmarkMode.extractor.cliValue,
    )
    ..addOption(
      'kind',
      allowed: DriveBenchmarkKind.values.map((kind) => kind.cliValue).toList(),
      defaultsTo: DriveBenchmarkKind.metadata.cliValue,
    )
    ..addOption(
      'source',
      allowed: DriveBenchmarkTrackSource.values
          .map((source) => source.cliValue)
          .toList(),
      defaultsTo: DriveBenchmarkTrackSource.largestPending.cliValue,
    )
    ..addMultiOption('drive-file-id')
    ..addOption('mime', defaultsTo: 'audio/mp4')
    ..addOption('limit', defaultsTo: '10')
    ..addOption('concurrency', defaultsTo: '1')
    ..addOption('window-sec', defaultsTo: '30')
    ..addOption('repeat', defaultsTo: '1')
    ..addOption('job-id')
    ..addOption('output')
    ..addOption('db-path')
    ..addOption('fail-under-metadata-per-second')
    ..addOption('fail-under-artwork-per-second')
    ..addFlag('json', negatable: false)
    ..addFlag('fail-if-download-file-called', negatable: false);

  if (args.isEmpty) {
    return DriveBenchmarkParseResult(usage: parser.usage);
  }

  late final ArgResults parsed;
  try {
    parsed = parser.parse(args);
  } on FormatException catch (error) {
    return DriveBenchmarkParseResult(error: error.message, usage: parser.usage);
  }

  if (parsed['help'] as bool) {
    return DriveBenchmarkParseResult(usage: parser.usage);
  }

  final mode = DriveBenchmarkMode.fromCli(parsed['mode'] as String?);
  final kind = DriveBenchmarkKind.fromCli(parsed['kind'] as String?);
  final source = DriveBenchmarkTrackSource.fromCli(parsed['source'] as String?);
  if (mode == null || kind == null || source == null) {
    return DriveBenchmarkParseResult(
      error: 'Invalid benchmark mode, kind, or source.',
      usage: parser.usage,
    );
  }

  int? jobId;
  if ((parsed['job-id'] as String?)?.isNotEmpty ?? false) {
    jobId = int.tryParse(parsed['job-id'] as String);
    if (jobId == null) {
      return DriveBenchmarkParseResult(
        error: '--job-id must be an integer.',
        usage: parser.usage,
      );
    }
  }

  final limit = int.tryParse(parsed['limit'] as String? ?? '');
  final concurrency = int.tryParse(parsed['concurrency'] as String? ?? '');
  final windowSeconds = int.tryParse(parsed['window-sec'] as String? ?? '');
  final repeatCount = int.tryParse(parsed['repeat'] as String? ?? '');
  if (limit == null || limit <= 0) {
    return DriveBenchmarkParseResult(
      error: '--limit must be a positive integer.',
      usage: parser.usage,
    );
  }
  if (concurrency == null || concurrency <= 0) {
    return DriveBenchmarkParseResult(
      error: '--concurrency must be a positive integer.',
      usage: parser.usage,
    );
  }
  if (windowSeconds == null || windowSeconds <= 0) {
    return DriveBenchmarkParseResult(
      error: '--window-sec must be a positive integer.',
      usage: parser.usage,
    );
  }
  if (repeatCount == null || repeatCount <= 0) {
    return DriveBenchmarkParseResult(
      error: '--repeat must be a positive integer.',
      usage: parser.usage,
    );
  }

  final metadataThreshold = _parseDoubleOption(
    parsed['fail-under-metadata-per-second'] as String?,
  );
  if (metadataThreshold == _invalidDoubleOption) {
    return DriveBenchmarkParseResult(
      error: '--fail-under-metadata-per-second must be numeric.',
      usage: parser.usage,
    );
  }

  final artworkThreshold = _parseDoubleOption(
    parsed['fail-under-artwork-per-second'] as String?,
  );
  if (artworkThreshold == _invalidDoubleOption) {
    return DriveBenchmarkParseResult(
      error: '--fail-under-artwork-per-second must be numeric.',
      usage: parser.usage,
    );
  }

  final driveFileIds = (parsed['drive-file-id'] as List<String>)
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
  if (source == DriveBenchmarkTrackSource.driveFileId && driveFileIds.isEmpty) {
    return DriveBenchmarkParseResult(
      error: '--drive-file-id is required when --source drive-file-id is used.',
      usage: parser.usage,
    );
  }

  if (mode == DriveBenchmarkMode.jobSample && jobId == null) {
    return DriveBenchmarkParseResult(
      error: '--job-id is required when --mode job-sample is used.',
      usage: parser.usage,
    );
  }

  return DriveBenchmarkParseResult(
    command: DriveBenchmarkCommand(
      mode: mode,
      kind: kind,
      source: source,
      limit: limit,
      concurrency: concurrency,
      windowSeconds: windowSeconds,
      repeatCount: repeatCount,
      jsonOutput: parsed['json'] as bool,
      failIfDownloadFileCalled: parsed['fail-if-download-file-called'] as bool,
      driveFileIds: driveFileIds,
      jobId: jobId,
      mimeType: (parsed['mime'] as String?)?.trim().isEmpty ?? true
          ? null
          : (parsed['mime'] as String).trim(),
      outputPath: (parsed['output'] as String?)?.trim().isEmpty ?? true
          ? null
          : (parsed['output'] as String).trim(),
      databasePath: (parsed['db-path'] as String?)?.trim().isEmpty ?? true
          ? null
          : (parsed['db-path'] as String).trim(),
      failUnderMetadataPerSecond: metadataThreshold,
      failUnderArtworkPerSecond: artworkThreshold,
    ),
  );
}

const double _invalidDoubleOption = -1;

double? _parseDoubleOption(String? rawValue) {
  if (rawValue == null || rawValue.trim().isEmpty) {
    return null;
  }
  return double.tryParse(rawValue.trim()) ?? _invalidDoubleOption;
}

class DriveLiveBenchmarkRunner {
  DriveLiveBenchmarkRunner({
    required DriveBenchmarkReadModel readModel,
    required DriveAuthRepository authRepository,
    required BenchmarkingDriveHttpClient driveHttpClient,
    required DriveMetadataExtractor metadataExtractor,
    required DriveArtworkExtractor artworkExtractor,
    required BenchmarkRecordingDriveScanLogger logger,
    DateTime Function()? now,
    Future<void> Function(Duration duration)? sleep,
  }) : _readModel = readModel,
       _authRepository = authRepository,
       _driveHttpClient = driveHttpClient,
       _metadataExtractor = metadataExtractor,
       _artworkExtractor = artworkExtractor,
       _logger = logger,
       _now = now ?? DateTime.now,
       _sleep = sleep ?? Future<void>.delayed;

  final DriveBenchmarkReadModel _readModel;
  final DriveAuthRepository _authRepository;
  final BenchmarkingDriveHttpClient _driveHttpClient;
  final DriveMetadataExtractor _metadataExtractor;
  final DriveArtworkExtractor _artworkExtractor;
  final BenchmarkRecordingDriveScanLogger _logger;
  final DateTime Function() _now;
  final Future<void> Function(Duration duration) _sleep;

  static Future<DriveLiveBenchmarkRunner> createLive({
    String? databasePath,
  }) async {
    final readModel = await SqliteDriveBenchmarkReadModel.open(
      databasePath: databasePath,
    );
    final logger = BenchmarkRecordingDriveScanLogger();
    final authRepository = PlatformDriveAuthRepository(
      config: DriveOAuthConfig.fromEnvironment(),
      secureStorage: const FlutterSecureStorage(),
      logger: logger,
    );
    final innerHttpClient = DriveHttpClient(
      authRepository: authRepository,
      logger: logger,
    );
    final benchmarkingClient = BenchmarkingDriveHttpClient(
      inner: innerHttpClient,
    );
    final metadataExtractor = DriveMetadataExtractor(
      driveHttpClient: benchmarkingClient,
      logger: logger,
    );
    final artworkExtractor = DriveArtworkExtractor(
      driveHttpClient: benchmarkingClient,
      logger: logger,
    );
    return DriveLiveBenchmarkRunner(
      readModel: readModel,
      authRepository: authRepository,
      driveHttpClient: benchmarkingClient,
      metadataExtractor: metadataExtractor,
      artworkExtractor: artworkExtractor,
      logger: logger,
    );
  }

  Future<BenchmarkReport> run(DriveBenchmarkCommand command) async {
    return switch (command.mode) {
      DriveBenchmarkMode.extractor => _runExtractorBenchmark(command),
      DriveBenchmarkMode.jobSample => _runJobSample(command),
    };
  }

  void close() {
    _readModel.close();
  }

  Future<BenchmarkReport> _runExtractorBenchmark(
    DriveBenchmarkCommand command,
  ) async {
    final account = await _readModel.getActiveAccount();
    if (account == null) {
      return _buildUnavailableReport(
        mode: command.mode,
        message: 'No active Google Drive account was found in the local DB.',
      );
    }

    if (account.authSessionState ==
        DriveAuthSessionState.reauthRequired.value) {
      return _buildUnavailableReport(
        mode: command.mode,
        message: account.authSessionError ?? driveSyncReconnectRequiredMessage,
        extra: <String, Object?>{
          'accountEmail': account.email,
          'lastError': account.authSessionError,
        },
      );
    }

    _logger.entries.clear();
    final restoredProfile = await _authRepository.restoreSession();
    if (restoredProfile == null) {
      return _buildUnavailableReport(
        mode: command.mode,
        message: 'Google Drive is not connected in secure storage.',
        extra: <String, Object?>{
          'accountEmail': account.email,
          'lastError':
              account.authSessionError ?? driveAuthReconnectRequiredMessage,
          'authDiagnostics': _collectAuthDiagnostics(),
        },
      );
    }

    final tracks = await _readModel.selectTracks(
      source: command.source,
      filter: _buildTrackFilter(command),
    );
    if (tracks.isEmpty) {
      return BenchmarkReport(
        mode: command.mode,
        exitCode: 4,
        fields: <String, Object?>{
          'status': 'empty',
          'message': 'No benchmark targets matched the requested filter.',
          'source': command.source.cliValue,
          'kind': command.kind.cliValue,
          'mimeType': command.mimeType,
          'databasePath': _readModel.databasePath,
        },
      );
    }

    _logger.entries.clear();
    _driveHttpClient.resetCounters();
    final stopwatch = Stopwatch()..start();
    late final List<_TrackBenchmarkOutcome> outcomes;
    try {
      outcomes = await _runWithConcurrency(
        tracks,
        concurrency: command.concurrency,
        action: (candidate) =>
            _runTrackExtraction(candidate, kind: command.kind),
      );
    } on _BenchmarkAuthLossException catch (error) {
      stopwatch.stop();
      return _buildUnavailableReport(
        mode: command.mode,
        message: error.message,
        extra: <String, Object?>{
          'accountEmail': account.email,
          'lastError': error.message,
          'authDiagnostics': _collectAuthDiagnostics(),
        },
      );
    }
    stopwatch.stop();

    return _summarizeExtractorRun(
      command: command,
      targets: tracks,
      outcomes: outcomes,
      elapsed: stopwatch.elapsed,
    );
  }

  Future<BenchmarkReport> _runJobSample(DriveBenchmarkCommand command) async {
    final jobId = command.jobId;
    if (jobId == null) {
      return BenchmarkReport(
        mode: command.mode,
        exitCode: 4,
        fields: const <String, Object?>{
          'status': 'invalid_args',
          'message': '--job-id is required for --mode job-sample.',
        },
      );
    }

    final initial = await _readModel.getJobSample(jobId);
    if (initial == null) {
      return _buildUnavailableReport(
        mode: command.mode,
        message: 'Benchmark job was not found in the local DB.',
        extra: <String, Object?>{'jobId': jobId},
      );
    }

    final samples = <BenchmarkWindowSample>[];
    var current = initial;
    for (var index = 0; index < command.repeatCount; index += 1) {
      if (current.state != 'running') {
        return _buildJobSampleReport(
          command: command,
          current: current,
          samples: samples,
          exitCode: 3,
          status: 'unavailable',
        );
      }

      await _sleep(Duration(seconds: command.windowSeconds));
      final next = await _readModel.getJobSample(jobId);
      if (next == null) {
        return _buildUnavailableReport(
          mode: command.mode,
          message: 'Benchmark job disappeared while sampling.',
          extra: <String, Object?>{'jobId': jobId},
        );
      }

      samples.add(
        BenchmarkWindowSample(
          index: index + 1,
          windowSeconds: command.windowSeconds,
          metadataDelta: next.metadataReadyCount - current.metadataReadyCount,
          artworkDelta: next.artworkReadyCount - current.artworkReadyCount,
          metadataPerSecond:
              (next.metadataReadyCount - current.metadataReadyCount) /
              command.windowSeconds,
          artworkPerSecond:
              (next.artworkReadyCount - current.artworkReadyCount) /
              command.windowSeconds,
          runningTasksChanged:
              _runningTaskSignature(current.runningTasks) !=
              _runningTaskSignature(next.runningTasks),
        ),
      );
      current = next;
    }

    final thresholdExitCode = _evaluateJobSampleThresholds(
      command: command,
      samples: samples,
    );
    return _buildJobSampleReport(
      command: command,
      current: current,
      samples: samples,
      exitCode: thresholdExitCode,
      status: thresholdExitCode == 0 ? 'ok' : 'threshold_fail',
    );
  }

  DriveBenchmarkTrackFilter _buildTrackFilter(DriveBenchmarkCommand command) {
    Set<String> metadataStatuses = const <String>{};
    Set<String> artworkStatuses = const <String>{};
    switch (command.source) {
      case DriveBenchmarkTrackSource.largestPending:
        metadataStatuses = command.kind.includesMetadata
            ? <String>{TrackMetadataStatus.pending.value}
            : const <String>{};
        artworkStatuses = command.kind.includesArtwork
            ? <String>{TrackArtworkStatus.pending.value}
            : const <String>{};
      case DriveBenchmarkTrackSource.failed:
        metadataStatuses = command.kind.includesMetadata
            ? <String>{TrackMetadataStatus.failed.value}
            : const <String>{};
        artworkStatuses = command.kind.includesArtwork
            ? <String>{TrackArtworkStatus.failed.value}
            : const <String>{};
      case DriveBenchmarkTrackSource.runningTaskTargets:
      case DriveBenchmarkTrackSource.driveFileId:
        metadataStatuses = command.kind.includesMetadata
            ? <String>{TrackMetadataStatus.pending.value}
            : const <String>{};
        artworkStatuses = command.kind.includesArtwork
            ? <String>{TrackArtworkStatus.pending.value}
            : const <String>{};
    }

    return DriveBenchmarkTrackFilter(
      metadataStatuses: metadataStatuses,
      artworkStatuses: artworkStatuses,
      mimeType: command.mimeType,
      limit: command.source == DriveBenchmarkTrackSource.driveFileId
          ? math.max(command.limit, command.driveFileIds.length)
          : command.limit,
      driveFileIds: command.driveFileIds,
    );
  }

  Future<List<_TrackBenchmarkOutcome>> _runWithConcurrency(
    List<BenchmarkTrackCandidate> targets, {
    required int concurrency,
    required Future<_TrackBenchmarkOutcome> Function(
      BenchmarkTrackCandidate candidate,
    )
    action,
  }) async {
    final results = List<_TrackBenchmarkOutcome?>.filled(targets.length, null);
    var nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        final index = nextIndex;
        if (index >= targets.length) {
          return;
        }
        nextIndex += 1;
        results[index] = await action(targets[index]);
      }
    }

    final workerCount = math.max(1, math.min(concurrency, targets.length));
    await Future.wait(
      List<Future<void>>.generate(workerCount, (_) => worker()),
    );
    return results.cast<_TrackBenchmarkOutcome>();
  }

  Future<_TrackBenchmarkOutcome> _runTrackExtraction(
    BenchmarkTrackCandidate candidate, {
    required DriveBenchmarkKind kind,
  }) async {
    final operations = <_TrackBenchmarkOperationOutcome>[];
    if (kind.includesMetadata) {
      operations.add(await _runMetadataExtraction(candidate.track));
    }
    if (kind.includesArtwork) {
      operations.add(await _runArtworkExtraction(candidate.track));
    }
    return _TrackBenchmarkOutcome(candidate: candidate, operations: operations);
  }

  Future<_TrackBenchmarkOperationOutcome> _runMetadataExtraction(
    Track track,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      await _metadataExtractor.extract(track);
      stopwatch.stop();
      return _TrackBenchmarkOperationOutcome.success(
        kind: DriveBenchmarkKind.metadata.cliValue,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
    } catch (error) {
      stopwatch.stop();
      if (_isBenchmarkAuthLoss(error)) {
        throw _BenchmarkAuthLossException(_benchmarkFailureMessage(error));
      }
      return _TrackBenchmarkOperationOutcome.failure(
        kind: DriveBenchmarkKind.metadata.cliValue,
        elapsedMs: stopwatch.elapsedMilliseconds,
        reason: _benchmarkFailureReason(error),
        message: _benchmarkFailureMessage(error),
      );
    }
  }

  Future<_TrackBenchmarkOperationOutcome> _runArtworkExtraction(
    Track track,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final artwork = await _artworkExtractor.extract(track);
      stopwatch.stop();
      if (artwork == null) {
        return _TrackBenchmarkOperationOutcome.notFound(
          kind: DriveBenchmarkKind.artwork.cliValue,
          elapsedMs: stopwatch.elapsedMilliseconds,
        );
      }
      return _TrackBenchmarkOperationOutcome.success(
        kind: DriveBenchmarkKind.artwork.cliValue,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
    } catch (error) {
      stopwatch.stop();
      if (_isBenchmarkAuthLoss(error)) {
        throw _BenchmarkAuthLossException(_benchmarkFailureMessage(error));
      }
      return _TrackBenchmarkOperationOutcome.failure(
        kind: DriveBenchmarkKind.artwork.cliValue,
        elapsedMs: stopwatch.elapsedMilliseconds,
        reason: _benchmarkFailureReason(error),
        message: _benchmarkFailureMessage(error),
      );
    }
  }

  BenchmarkReport _summarizeExtractorRun({
    required DriveBenchmarkCommand command,
    required List<BenchmarkTrackCandidate> targets,
    required List<_TrackBenchmarkOutcome> outcomes,
    required Duration elapsed,
  }) {
    final failures = <BenchmarkFailure>[];
    final elapsedMs = <int>[];
    var successCount = 0;
    var failureCount = 0;
    var notFoundCount = 0;
    var metadataAttemptCount = 0;
    var artworkAttemptCount = 0;
    var metadataSuccessCount = 0;
    var artworkSuccessCount = 0;

    for (final outcome in outcomes) {
      for (final operation in outcome.operations) {
        elapsedMs.add(operation.elapsedMs);
        if (operation.kind == DriveBenchmarkKind.metadata.cliValue) {
          metadataAttemptCount += 1;
        }
        if (operation.kind == DriveBenchmarkKind.artwork.cliValue) {
          artworkAttemptCount += 1;
        }

        switch (operation.status) {
          case _BenchmarkOperationStatus.success:
            successCount += 1;
            if (operation.kind == DriveBenchmarkKind.metadata.cliValue) {
              metadataSuccessCount += 1;
            }
            if (operation.kind == DriveBenchmarkKind.artwork.cliValue) {
              artworkSuccessCount += 1;
            }
          case _BenchmarkOperationStatus.notFound:
            notFoundCount += 1;
          case _BenchmarkOperationStatus.failure:
            failureCount += 1;
            failures.add(
              BenchmarkFailure(
                kind: operation.kind,
                driveFileId: outcome.candidate.track.driveFileId,
                fileName: outcome.candidate.track.fileName,
                reason: operation.reason ?? 'unknown_failure',
                message: operation.message,
              ),
            );
        }
      }
    }

    final totalSeconds = math.max(0.001, elapsed.inMilliseconds / 1000);
    final directDownloadFileCalls = _driveHttpClient.downloadFileCallCount;
    var exitCode = 0;
    var status = 'ok';
    if (command.failIfDownloadFileCalled && directDownloadFileCalls > 0) {
      exitCode = 2;
      status = 'threshold_fail';
    }
    if (command.failUnderMetadataPerSecond != null &&
        command.kind.includesMetadata &&
        metadataSuccessCount / totalSeconds <
            command.failUnderMetadataPerSecond!) {
      exitCode = 2;
      status = 'threshold_fail';
    }
    if (command.failUnderArtworkPerSecond != null &&
        command.kind.includesArtwork &&
        artworkSuccessCount / totalSeconds <
            command.failUnderArtworkPerSecond!) {
      exitCode = 2;
      status = 'threshold_fail';
    }

    return BenchmarkReport(
      mode: command.mode,
      exitCode: exitCode,
      fields: <String, Object?>{
        'status': status,
        'databasePath': _readModel.databasePath,
        'kind': command.kind.cliValue,
        'source': command.source.cliValue,
        'mimeType': command.mimeType,
        'trackCount': targets.length,
        'successCount': successCount,
        'failureCount': failureCount,
        'notFoundCount': notFoundCount,
        'metadataAttemptCount': metadataAttemptCount,
        'artworkAttemptCount': artworkAttemptCount,
        'metadataPerSecond': metadataSuccessCount / totalSeconds,
        'artworkPerSecond': artworkSuccessCount / totalSeconds,
        'tracksPerSecond': targets.length / totalSeconds,
        'downloadBytes': _sumDownloadBytes(),
        'rangeRequestCount': _countRangeRequests(),
        'downloadFileCallCount': directDownloadFileCalls,
        'elapsedMsP50': _percentile(elapsedMs, 50),
        'elapsedMsP95': _percentile(elapsedMs, 95),
        'totalElapsedMs': elapsed.inMilliseconds,
        'concurrency': command.concurrency,
        'generatedAt': _now().toIso8601String(),
        'targets': targets
            .map((target) => target.toJson())
            .toList(growable: false),
        'failures': failures
            .map((failure) => failure.toJson())
            .toList(growable: false),
      },
    );
  }

  BenchmarkReport _buildJobSampleReport({
    required DriveBenchmarkCommand command,
    required BenchmarkJobSample current,
    required List<BenchmarkWindowSample> samples,
    required int exitCode,
    required String status,
  }) {
    final totalWindowSeconds = samples.fold<int>(
      0,
      (sum, sample) => sum + sample.windowSeconds,
    );
    final metadataDelta = samples.fold<int>(
      0,
      (sum, sample) => sum + sample.metadataDelta,
    );
    final artworkDelta = samples.fold<int>(
      0,
      (sum, sample) => sum + sample.artworkDelta,
    );
    final safeSeconds = math.max(1, totalWindowSeconds);
    final liveMetadataPipelineBacklog = MetadataPipelineTelemetryHub.instance
        .snapshotForJob(current.jobId);
    return BenchmarkReport(
      mode: command.mode,
      exitCode: exitCode,
      fields: <String, Object?>{
        'status': status,
        'databasePath': _readModel.databasePath,
        'jobId': current.jobId,
        'state': current.state,
        'phase': current.phase,
        'windowSeconds': command.windowSeconds,
        'repeatCount': command.repeatCount,
        'metadataDelta': metadataDelta,
        'artworkDelta': artworkDelta,
        'metadataPerSecond': metadataDelta / safeSeconds,
        'artworkPerSecond': artworkDelta / safeSeconds,
        'failedCount': current.failedCount,
        'generatedAt': _now().toIso8601String(),
        'pipelineBacklog': current.pipelineBacklog.toJson(),
        'readModelMetadataPipelineBacklog': current.metadataPipelineBacklog
            .toJson(),
        'liveMetadataPipelineBacklog': liveMetadataPipelineBacklog.toJson(),
        'runningTasks': current.runningTasks
            .map((task) => task.toJson())
            .toList(growable: false),
        'lastError': current.lastError,
        'samples': samples
            .map((sample) => sample.toJson())
            .toList(growable: false),
      },
    );
  }

  int _evaluateJobSampleThresholds({
    required DriveBenchmarkCommand command,
    required List<BenchmarkWindowSample> samples,
  }) {
    if (samples.isEmpty) {
      return 0;
    }
    final totalWindowSeconds = samples.fold<int>(
      0,
      (sum, sample) => sum + sample.windowSeconds,
    );
    final safeSeconds = math.max(1, totalWindowSeconds);
    final metadataPerSecond =
        samples.fold<int>(0, (sum, sample) => sum + sample.metadataDelta) /
        safeSeconds;
    final artworkPerSecond =
        samples.fold<int>(0, (sum, sample) => sum + sample.artworkDelta) /
        safeSeconds;
    if (command.failUnderMetadataPerSecond != null &&
        metadataPerSecond < command.failUnderMetadataPerSecond!) {
      return 2;
    }
    if (command.failUnderArtworkPerSecond != null &&
        artworkPerSecond < command.failUnderArtworkPerSecond!) {
      return 2;
    }
    return 0;
  }

  BenchmarkReport _buildUnavailableReport({
    required DriveBenchmarkMode mode,
    required String message,
    Map<String, Object?> extra = const <String, Object?>{},
  }) {
    return BenchmarkReport(
      mode: mode,
      exitCode: 3,
      fields: <String, Object?>{
        'status': 'unavailable',
        'message': message,
        'databasePath': _readModel.databasePath,
        'generatedAt': _now().toIso8601String(),
        ...extra,
      },
    );
  }

  int _sumDownloadBytes() {
    return _logger
        .byOperation('download_bytes_success')
        .map((entry) => (entry.details['byteCount'] as num?)?.toInt() ?? 0)
        .fold<int>(0, (sum, value) => sum + value);
  }

  int _countRangeRequests() {
    return _logger.byOperation('download_file_start').where((entry) {
      final rangeHeader = entry.details['rangeHeader']?.toString();
      return rangeHeader != null && rangeHeader.isNotEmpty;
    }).length;
  }

  int _percentile(List<int> values, int percentile) {
    if (values.isEmpty) {
      return 0;
    }
    final sorted = [...values]..sort();
    final index = ((sorted.length - 1) * percentile / 100).round();
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  String _runningTaskSignature(List<BenchmarkRunningTask> tasks) {
    return tasks
        .map(
          (task) => [
            task.id,
            task.kind,
            task.targetDriveId ?? '',
            task.runtimeStage ?? '',
            task.updatedAt?.toIso8601String() ?? '',
          ].join(':'),
        )
        .join('|');
  }

  String _benchmarkFailureReason(Object error) {
    if (error is DriveRangedExtractionException) {
      return error.reason;
    }
    if (error is DriveAuthException) {
      return 'drive_auth_error';
    }
    return 'unexpected_error';
  }

  String _benchmarkFailureMessage(Object error) {
    if (error is DriveAuthException) {
      return error.message;
    }
    return error.toString();
  }

  bool _isBenchmarkAuthLoss(Object error) {
    if (error is DriveAuthSessionExpiredException) {
      return true;
    }
    return error is DriveAuthException &&
        (error.message == driveAuthReconnectRequiredMessage ||
            error.message == driveSyncReconnectRequiredMessage);
  }

  List<Map<String, Object?>> _collectAuthDiagnostics({int limit = 12}) {
    final authEntries = _logger.bySubsystem('auth').toList(growable: false);
    final start = math.max(0, authEntries.length - limit);
    return authEntries
        .sublist(start)
        .map(
          (entry) => <String, Object?>{
            'operation': entry.operation,
            'level': entry.level.name,
            if (entry.message != null && entry.message!.isNotEmpty)
              'message': entry.message,
            if (entry.details.isNotEmpty) 'details': entry.details,
            if (entry.error != null) 'error': entry.error.toString(),
          },
        )
        .toList(growable: false);
  }
}

class _TrackBenchmarkOutcome {
  const _TrackBenchmarkOutcome({
    required this.candidate,
    required this.operations,
  });

  final BenchmarkTrackCandidate candidate;
  final List<_TrackBenchmarkOperationOutcome> operations;
}

enum _BenchmarkOperationStatus { success, failure, notFound }

class _TrackBenchmarkOperationOutcome {
  const _TrackBenchmarkOperationOutcome._({
    required this.kind,
    required this.status,
    required this.elapsedMs,
    this.reason,
    this.message,
  });

  const _TrackBenchmarkOperationOutcome.success({
    required String kind,
    required int elapsedMs,
  }) : this._(
         kind: kind,
         status: _BenchmarkOperationStatus.success,
         elapsedMs: elapsedMs,
       );

  const _TrackBenchmarkOperationOutcome.failure({
    required String kind,
    required int elapsedMs,
    required String reason,
    required String message,
  }) : this._(
         kind: kind,
         status: _BenchmarkOperationStatus.failure,
         elapsedMs: elapsedMs,
         reason: reason,
         message: message,
       );

  const _TrackBenchmarkOperationOutcome.notFound({
    required String kind,
    required int elapsedMs,
  }) : this._(
         kind: kind,
         status: _BenchmarkOperationStatus.notFound,
         elapsedMs: elapsedMs,
       );

  final String kind;
  final _BenchmarkOperationStatus status;
  final int elapsedMs;
  final String? reason;
  final String? message;
}

class _BenchmarkAuthLossException implements Exception {
  const _BenchmarkAuthLossException(this.message);

  final String message;
}

Future<int> runDriveBenchmarkCli(List<String> args) async {
  final parsed = parseDriveBenchmarkArgs(args);
  if (parsed.isHelp) {
    stdout.writeln(parsed.usage);
    return 0;
  }

  if (parsed.hasError) {
    final report = BenchmarkReport(
      mode: DriveBenchmarkMode.extractor,
      exitCode: 4,
      fields: <String, Object?>{
        'status': 'invalid_args',
        'message': parsed.error,
        if (parsed.usage != null) 'usage': parsed.usage,
      },
    );
    stdout.writeln(jsonEncode(report.toJson()));
    return 4;
  }

  final command = parsed.command!;
  if (!Platform.isWindows) {
    final report = BenchmarkReport(
      mode: command.mode,
      exitCode: 4,
      fields: const <String, Object?>{
        'status': 'unsupported_platform',
        'message': 'Drive benchmark mode is only supported on Windows today.',
      },
    );
    stdout.writeln(jsonEncode(report.toJson()));
    return 4;
  }

  final runner = await DriveLiveBenchmarkRunner.createLive(
    databasePath: command.databasePath,
  );
  try {
    final report = await runner.run(command);
    final json = jsonEncode(report.toJson());
    stdout.writeln(json);
    if (command.outputPath != null) {
      await File(command.outputPath!).writeAsString(json);
    }
    return report.exitCode;
  } finally {
    runner.close();
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/benchmark/drive_benchmark_read_model.dart';
import 'package:aero_stream/data/drive/benchmark/drive_live_benchmark_runner.dart';
import 'package:aero_stream/data/drive/drive_scan_backlog.dart';
import 'package:aero_stream/data/drive/metadata_pipeline_backlog.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/extraction/drive_artwork_extractor.dart';
import 'package:aero_stream/data/drive/extraction/drive_metadata_extractor.dart';
import 'package:aero_stream/data/drive/drive_scan_logger.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';

void main() {
  test(
    'parseDriveBenchmarkArgs returns help when benchmark target gets no args',
    () {
      final parsed = parseDriveBenchmarkArgs(const <String>[]);

      expect(parsed.hasError, isFalse);
      expect(parsed.isHelp, isTrue);
      expect(parsed.command, isNull);
    },
  );

  test('parseDriveBenchmarkArgs rejects invalid args', () {
    final parsed = parseDriveBenchmarkArgs(const <String>['--limit', 'zero']);

    expect(parsed.hasError, isTrue);
    expect(parsed.usage, isNotNull);
  });

  test('parseDriveBenchmarkArgs parses extractor command', () {
    final parsed = parseDriveBenchmarkArgs(const <String>[
      '--mode',
      'extractor',
      '--kind',
      'metadata',
      '--source',
      'drive-file-id',
      '--drive-file-id',
      'abc',
      '--limit',
      '4',
      '--concurrency',
      '2',
      '--fail-if-download-file-called',
    ]);

    expect(parsed.hasError, isFalse);
    expect(parsed.command, isNotNull);
    expect(parsed.command!.source, DriveBenchmarkTrackSource.driveFileId);
    expect(parsed.command!.driveFileIds, ['abc']);
    expect(parsed.command!.concurrency, 2);
    expect(parsed.command!.failIfDownloadFileCalled, isTrue);
  });

  test(
    'runner uses runtime metadata extractor and reports zero direct downloadFile calls',
    () async {
      final bytes = _buildMp3Bytes(
        title: 'Bench Title',
        artist: 'Bench Artist',
      );
      final logger = BenchmarkRecordingDriveScanLogger();
      final innerClient = _ByteDriveHttpClient({
        'track-1': bytes,
      }, logger: logger);
      final client = BenchmarkingDriveHttpClient(inner: innerClient);
      final metadataExtractor = DriveMetadataExtractor(
        driveHttpClient: client,
        logger: logger,
      );
      final artworkExtractor = DriveArtworkExtractor(
        driveHttpClient: client,
        logger: logger,
      );
      final runner = DriveLiveBenchmarkRunner(
        readModel: _FakeBenchmarkReadModel(
          account: const BenchmarkActiveAccount(
            id: 1,
            providerAccountId: 'account-1',
            email: 'listener@example.com',
            displayName: 'Listener',
            authKind: 'oauth_desktop',
            authSessionState: 'ready',
            authSessionError: null,
          ),
          tracks: <BenchmarkTrackCandidate>[
            BenchmarkTrackCandidate(
              track: _buildTrack(
                driveFileId: 'track-1',
                fileName: 'bench.mp3',
                mimeType: 'audio/mpeg',
                sizeBytes: bytes.length,
              ),
              source: DriveBenchmarkTrackSource.largestPending,
            ),
          ],
        ),
        authRepository: const _RestoringAuthRepository(),
        driveHttpClient: client,
        metadataExtractor: metadataExtractor,
        artworkExtractor: artworkExtractor,
        logger: logger,
      );
      addTearDown(runner.close);

      final report = await runner.run(
        const DriveBenchmarkCommand(
          mode: DriveBenchmarkMode.extractor,
          kind: DriveBenchmarkKind.metadata,
          source: DriveBenchmarkTrackSource.largestPending,
          limit: 1,
          concurrency: 1,
          windowSeconds: 5,
          repeatCount: 1,
          jsonOutput: true,
          failIfDownloadFileCalled: true,
          driveFileIds: <String>[],
          mimeType: 'audio/mpeg',
        ),
      );

      expect(report.exitCode, 0);
      expect(report.toJson()['successCount'], 1);
      expect(report.toJson()['downloadFileCallCount'], 0);
      expect(report.toJson()['rangeRequestCount'], greaterThan(0));
    },
  );

  test(
    'runner flags regression when metadata path directly calls downloadFile',
    () async {
      final innerClient = _ByteDriveHttpClient({'track-2': Uint8List(16)});
      final client = BenchmarkingDriveHttpClient(inner: innerClient);
      final logger = BenchmarkRecordingDriveScanLogger();
      final runner = DriveLiveBenchmarkRunner(
        readModel: _FakeBenchmarkReadModel(
          account: const BenchmarkActiveAccount(
            id: 1,
            providerAccountId: 'account-1',
            email: 'listener@example.com',
            displayName: 'Listener',
            authKind: 'oauth_desktop',
            authSessionState: 'ready',
            authSessionError: null,
          ),
          tracks: <BenchmarkTrackCandidate>[
            BenchmarkTrackCandidate(
              track: _buildTrack(
                driveFileId: 'track-2',
                fileName: 'regression.mp3',
                mimeType: 'audio/mpeg',
                sizeBytes: 16,
              ),
              source: DriveBenchmarkTrackSource.largestPending,
            ),
          ],
        ),
        authRepository: const _RestoringAuthRepository(),
        driveHttpClient: client,
        metadataExtractor: _DirectDownloadMetadataExtractor(client),
        artworkExtractor: DriveArtworkExtractor(
          driveHttpClient: client,
          logger: logger,
        ),
        logger: logger,
      );
      addTearDown(runner.close);

      final report = await runner.run(
        const DriveBenchmarkCommand(
          mode: DriveBenchmarkMode.extractor,
          kind: DriveBenchmarkKind.metadata,
          source: DriveBenchmarkTrackSource.largestPending,
          limit: 1,
          concurrency: 1,
          windowSeconds: 5,
          repeatCount: 1,
          jsonOutput: true,
          failIfDownloadFileCalled: true,
          driveFileIds: <String>[],
        ),
      );

      expect(report.exitCode, 2);
      expect(report.toJson()['downloadFileCallCount'], 1);
      expect(report.toJson()['status'], 'threshold_fail');
    },
  );

  test(
    'job-sample returns failed state and lastError without sleeping',
    () async {
      const readModelBacklog = MetadataPipelineBacklog(
        parse: MetadataPipelineStageBacklog(queuedCount: 3, runningCount: 1),
      );
      const liveBacklog = MetadataPipelineBacklog(
        fetch: MetadataPipelineStageBacklog(queuedCount: 2, runningCount: 1),
        activeFormatBreakdown: MetadataPipelineFormatBreakdown(m4aRunning: 1),
      );
      MetadataPipelineTelemetryHub.instance.updateJob(22, liveBacklog);
      final runner = DriveLiveBenchmarkRunner(
        readModel: _FakeBenchmarkReadModel(
          jobSample: const BenchmarkJobSample(
            jobId: 22,
            state: 'failed',
            phase: 'metadata_enrichment',
            metadataReadyCount: 9550,
            artworkReadyCount: 120,
            failedCount: 47,
            lastError: 'Reconnect Google Drive to continue syncing.',
            runningTasks: <BenchmarkRunningTask>[],
            pipelineBacklog: ScanPipelineBacklog(
              metadata: ScanTaskBacklogEntry(queuedCount: 12, runningCount: 6),
            ),
            metadataPipelineBacklog: readModelBacklog,
          ),
        ),
        authRepository: const _RestoringAuthRepository(),
        driveHttpClient: BenchmarkingDriveHttpClient(
          inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
        ),
        metadataExtractor: DriveMetadataExtractor(
          driveHttpClient: BenchmarkingDriveHttpClient(
            inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
          ),
        ),
        artworkExtractor: DriveArtworkExtractor(
          driveHttpClient: BenchmarkingDriveHttpClient(
            inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
          ),
        ),
        logger: BenchmarkRecordingDriveScanLogger(),
        sleep: (_) async {
          fail('sleep should not run for a failed job');
        },
      );
      addTearDown(() {
        MetadataPipelineTelemetryHub.instance.clearJob(22);
        runner.close();
      });

      final report = await runner.run(
        const DriveBenchmarkCommand(
          mode: DriveBenchmarkMode.jobSample,
          kind: DriveBenchmarkKind.metadata,
          source: DriveBenchmarkTrackSource.largestPending,
          limit: 1,
          concurrency: 1,
          windowSeconds: 5,
          repeatCount: 1,
          jsonOutput: true,
          failIfDownloadFileCalled: false,
          driveFileIds: <String>[],
          jobId: 22,
        ),
      );

      expect(report.exitCode, 3);
      expect(report.toJson()['state'], 'failed');
      expect(
        report.toJson()['lastError'],
        'Reconnect Google Drive to continue syncing.',
      );
      expect(
        report.toJson()['pipelineBacklog'],
        const ScanPipelineBacklog(
          metadata: ScanTaskBacklogEntry(queuedCount: 12, runningCount: 6),
        ).toJson(),
      );
      expect(
        report.toJson()['readModelMetadataPipelineBacklog'],
        readModelBacklog.toJson(),
      );
      expect(
        report.toJson()['liveMetadataPipelineBacklog'],
        liveBacklog.toJson(),
      );
    },
  );

  test(
    'job-sample treats runtime stage changes as running task progress',
    () async {
      final samples = <BenchmarkJobSample>[
        BenchmarkJobSample(
          jobId: 31,
          state: 'running',
          phase: 'metadata_enrichment',
          metadataReadyCount: 10,
          artworkReadyCount: 0,
          failedCount: 0,
          lastError: null,
          runningTasks: const <BenchmarkRunningTask>[
            BenchmarkRunningTask(
              id: 1,
              kind: 'extract_tags',
              state: 'running',
              targetDriveId: 'track-1',
              fileName: 'track-1.m4a',
              mimeType: 'audio/mp4',
              sizeBytes: 100,
              attempts: 0,
              lastError: null,
              runtimeStage: 'fetch',
              updatedAt: null,
            ),
          ],
        ),
        BenchmarkJobSample(
          jobId: 31,
          state: 'running',
          phase: 'metadata_enrichment',
          metadataReadyCount: 10,
          artworkReadyCount: 0,
          failedCount: 0,
          lastError: null,
          runningTasks: const <BenchmarkRunningTask>[
            BenchmarkRunningTask(
              id: 1,
              kind: 'extract_tags',
              state: 'running',
              targetDriveId: 'track-1',
              fileName: 'track-1.m4a',
              mimeType: 'audio/mp4',
              sizeBytes: 100,
              attempts: 0,
              lastError: null,
              runtimeStage: 'parse',
              updatedAt: null,
            ),
          ],
        ),
      ];
      final runner = DriveLiveBenchmarkRunner(
        readModel: _SequencedBenchmarkReadModel(samples),
        authRepository: const _RestoringAuthRepository(),
        driveHttpClient: BenchmarkingDriveHttpClient(
          inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
        ),
        metadataExtractor: DriveMetadataExtractor(
          driveHttpClient: BenchmarkingDriveHttpClient(
            inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
          ),
        ),
        artworkExtractor: DriveArtworkExtractor(
          driveHttpClient: BenchmarkingDriveHttpClient(
            inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
          ),
        ),
        logger: BenchmarkRecordingDriveScanLogger(),
        sleep: (_) async {},
      );
      addTearDown(runner.close);

      final report = await runner.run(
        const DriveBenchmarkCommand(
          mode: DriveBenchmarkMode.jobSample,
          kind: DriveBenchmarkKind.metadata,
          source: DriveBenchmarkTrackSource.largestPending,
          limit: 1,
          concurrency: 1,
          windowSeconds: 1,
          repeatCount: 1,
          jsonOutput: true,
          failIfDownloadFileCalled: false,
          driveFileIds: <String>[],
          jobId: 31,
        ),
      );

      final samplesJson = (report.toJson()['samples'] as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(samplesJson.single['runningTasksChanged'], isTrue);
    },
  );

  test(
    'job-sample treats runtime lease heartbeat changes as running task progress',
    () async {
      final samples = <BenchmarkJobSample>[
        BenchmarkJobSample(
          jobId: 32,
          state: 'running',
          phase: 'metadata_enrichment',
          metadataReadyCount: 10,
          artworkReadyCount: 0,
          failedCount: 0,
          lastError: null,
          runningTasks: <BenchmarkRunningTask>[
            BenchmarkRunningTask(
              id: 1,
              kind: 'extract_tags',
              state: 'running',
              targetDriveId: 'track-1',
              fileName: 'track-1.m4a',
              mimeType: 'audio/mp4',
              sizeBytes: 100,
              attempts: 0,
              lastError: null,
              runtimeStage: 'fetch',
              updatedAt: DateTime(2026, 4, 5, 11, 16, 57),
            ),
          ],
        ),
        BenchmarkJobSample(
          jobId: 32,
          state: 'running',
          phase: 'metadata_enrichment',
          metadataReadyCount: 10,
          artworkReadyCount: 0,
          failedCount: 0,
          lastError: null,
          runningTasks: <BenchmarkRunningTask>[
            BenchmarkRunningTask(
              id: 1,
              kind: 'extract_tags',
              state: 'running',
              targetDriveId: 'track-1',
              fileName: 'track-1.m4a',
              mimeType: 'audio/mp4',
              sizeBytes: 100,
              attempts: 0,
              lastError: null,
              runtimeStage: 'fetch',
              updatedAt: DateTime(2026, 4, 5, 11, 16, 58),
            ),
          ],
        ),
      ];
      final runner = DriveLiveBenchmarkRunner(
        readModel: _SequencedBenchmarkReadModel(samples),
        authRepository: const _RestoringAuthRepository(),
        driveHttpClient: BenchmarkingDriveHttpClient(
          inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
        ),
        metadataExtractor: DriveMetadataExtractor(
          driveHttpClient: BenchmarkingDriveHttpClient(
            inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
          ),
        ),
        artworkExtractor: DriveArtworkExtractor(
          driveHttpClient: BenchmarkingDriveHttpClient(
            inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
          ),
        ),
        logger: BenchmarkRecordingDriveScanLogger(),
        sleep: (_) async {},
      );
      addTearDown(runner.close);

      final report = await runner.run(
        const DriveBenchmarkCommand(
          mode: DriveBenchmarkMode.jobSample,
          kind: DriveBenchmarkKind.metadata,
          source: DriveBenchmarkTrackSource.largestPending,
          limit: 1,
          concurrency: 1,
          windowSeconds: 1,
          repeatCount: 1,
          jsonOutput: true,
          failIfDownloadFileCalled: false,
          driveFileIds: <String>[],
          jobId: 32,
        ),
      );

      final samplesJson = (report.toJson()['samples'] as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(samplesJson.single['runningTasksChanged'], isTrue);
    },
  );

  test(
    'sqlite replay fixture exposes runtime stage and stable updatedAt for stalled running tasks',
    () async {
      final fixture = await _loadReplayFixtureDatabase(
        'metadata_deadlock_replay.sql',
      );
      addTearDown(fixture.dispose);

      final readModel = await SqliteDriveBenchmarkReadModel.open(
        databasePath: fixture.databasePath,
      );
      addTearDown(readModel.close);

      final sample = await readModel.getJobSample(26);

      expect(sample, isNotNull);
      expect(sample!.state, 'running');
      expect(sample.phase, 'metadata_enrichment');
      expect(sample.metadataReadyCount, 47397);
      expect(sample.artworkReadyCount, 73);
      expect(sample.failedCount, 164);
      expect(sample.runningTasks.map((task) => task.runtimeStage).toSet(), {
        'fetch_head',
        'analyze_head',
      });
      expect(
        sample.runningTasks.map((task) => task.updatedAt).whereType<DateTime>(),
        everyElement(DateTime(2026, 4, 5, 11, 16, 57)),
      );
      expect(
        sample.pipelineBacklog.metadata,
        const ScanTaskBacklogEntry(queuedCount: 8, runningCount: 24),
      );
    },
  );

  test(
    'job-sample replay fixture reports frozen running task state without relying on live telemetry',
    () async {
      final fixture = await _loadReplayFixtureDatabase(
        'metadata_deadlock_replay.sql',
      );
      addTearDown(() {
        fixture.dispose();
      });

      final runner = await _createReplayRunner(fixture.databasePath);
      addTearDown(runner.close);

      final report = await runner.run(
        const DriveBenchmarkCommand(
          mode: DriveBenchmarkMode.jobSample,
          kind: DriveBenchmarkKind.metadata,
          source: DriveBenchmarkTrackSource.largestPending,
          limit: 1,
          concurrency: 1,
          windowSeconds: 1,
          repeatCount: 2,
          jsonOutput: true,
          failIfDownloadFileCalled: false,
          driveFileIds: <String>[],
          jobId: 26,
        ),
      );

      final json = report.toJson();
      final runningTasks = (json['runningTasks'] as List<Object?>)
          .cast<Map<String, Object?>>();
      final samples = (json['samples'] as List<Object?>)
          .cast<Map<String, Object?>>();

      expect(report.exitCode, 0);
      expect(json['state'], 'running');
      expect(json['phase'], 'metadata_enrichment');
      expect(json['metadataPerSecond'], 0.0);
      expect(json['artworkPerSecond'], 0.0);
      expect(
        json['readModelMetadataPipelineBacklog'],
        const MetadataPipelineBacklog().toJson(),
      );
      expect(
        json['liveMetadataPipelineBacklog'],
        const MetadataPipelineBacklog().toJson(),
      );
      expect(runningTasks.map((task) => task['runtimeStage']).toSet(), {
        'fetch_head',
        'analyze_head',
      });
      expect(runningTasks.map((task) => task['updatedAt']).toSet(), {
        '2026-04-05T11:16:57.000',
      });
      expect(
        samples.map((sample) => sample['runningTasksChanged']),
        everyElement(false),
      );
      expect(
        json['pipelineBacklog'],
        const ScanPipelineBacklog(
          metadata: ScanTaskBacklogEntry(queuedCount: 8, runningCount: 24),
        ).toJson(),
      );
    },
  );

  test(
    'job-sample keeps read-model and live telemetry metadata backlogs separate',
    () async {
      const readModelBacklog = MetadataPipelineBacklog(
        fetch: MetadataPipelineStageBacklog(
          queuedCount: 4,
          runningCount: 1,
        ),
      );
      const liveBacklog = MetadataPipelineBacklog(
        parse: MetadataPipelineStageBacklog(blockedCount: 2),
      );
      MetadataPipelineTelemetryHub.instance.updateJob(
        44,
        liveBacklog,
        immediate: true,
      );
      final runner = DriveLiveBenchmarkRunner(
        readModel: _FakeBenchmarkReadModel(
          jobSample: const BenchmarkJobSample(
            jobId: 44,
            state: 'failed',
            phase: 'metadata_enrichment',
            metadataReadyCount: 0,
            artworkReadyCount: 0,
            failedCount: 1,
            lastError: 'stopped',
            runningTasks: <BenchmarkRunningTask>[],
            metadataPipelineBacklog: readModelBacklog,
          ),
        ),
        authRepository: const _RestoringAuthRepository(),
        driveHttpClient: BenchmarkingDriveHttpClient(
          inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
        ),
        metadataExtractor: DriveMetadataExtractor(
          driveHttpClient: BenchmarkingDriveHttpClient(
            inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
          ),
        ),
        artworkExtractor: DriveArtworkExtractor(
          driveHttpClient: BenchmarkingDriveHttpClient(
            inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
          ),
        ),
        logger: BenchmarkRecordingDriveScanLogger(),
        sleep: (_) async {},
      );
      addTearDown(() {
        MetadataPipelineTelemetryHub.instance.clearJob(44);
        runner.close();
      });

      final report = await runner.run(
        const DriveBenchmarkCommand(
          mode: DriveBenchmarkMode.jobSample,
          kind: DriveBenchmarkKind.metadata,
          source: DriveBenchmarkTrackSource.largestPending,
          limit: 1,
          concurrency: 1,
          windowSeconds: 1,
          repeatCount: 1,
          jsonOutput: true,
          failIfDownloadFileCalled: false,
          driveFileIds: <String>[],
          jobId: 44,
        ),
      );

      expect(
        report.toJson()['readModelMetadataPipelineBacklog'],
        readModelBacklog.toJson(),
      );
      expect(
        report.toJson()['liveMetadataPipelineBacklog'],
        liveBacklog.toJson(),
      );
    },
  );

  test(
    'extractor unavailable report includes auth diagnostics when session restore fails',
    () async {
      final logger = BenchmarkRecordingDriveScanLogger();
      final runner = DriveLiveBenchmarkRunner(
        readModel: _FakeBenchmarkReadModel(
          account: const BenchmarkActiveAccount(
            id: 1,
            providerAccountId: 'account-1',
            email: 'listener@example.com',
            displayName: 'Listener',
            authKind: 'oauth_desktop',
            authSessionState: 'ready',
            authSessionError: null,
          ),
        ),
        authRepository: _LoggingMissingSessionAuthRepository(logger),
        driveHttpClient: BenchmarkingDriveHttpClient(
          inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
        ),
        metadataExtractor: DriveMetadataExtractor(
          driveHttpClient: BenchmarkingDriveHttpClient(
            inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
          ),
        ),
        artworkExtractor: DriveArtworkExtractor(
          driveHttpClient: BenchmarkingDriveHttpClient(
            inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
          ),
        ),
        logger: logger,
      );
      addTearDown(runner.close);

      final report = await runner.run(
        const DriveBenchmarkCommand(
          mode: DriveBenchmarkMode.extractor,
          kind: DriveBenchmarkKind.metadata,
          source: DriveBenchmarkTrackSource.largestPending,
          limit: 1,
          concurrency: 1,
          windowSeconds: 5,
          repeatCount: 1,
          jsonOutput: true,
          failIfDownloadFileCalled: false,
          driveFileIds: <String>[],
        ),
      );

      expect(report.exitCode, 3);
      expect(report.toJson()['status'], 'unavailable');
      final diagnostics = report.toJson()['authDiagnostics'] as List<Object?>;
      expect(diagnostics, isNotEmpty);
      expect(
        (diagnostics.single as Map<String, Object?>)['operation'],
        'session_missing',
      );
    },
  );
}

class _FakeBenchmarkReadModel implements DriveBenchmarkReadModel {
  _FakeBenchmarkReadModel({
    this.account,
    this.tracks = const <BenchmarkTrackCandidate>[],
    this.jobSample,
  });

  final BenchmarkActiveAccount? account;
  final List<BenchmarkTrackCandidate> tracks;
  final BenchmarkJobSample? jobSample;

  @override
  String get databasePath => 'memory';

  @override
  void close() {}

  @override
  Future<BenchmarkActiveAccount?> getActiveAccount() async => account;

  @override
  Future<BenchmarkJobSample?> getJobSample(int jobId) async => jobSample;

  @override
  Future<List<BenchmarkTrackCandidate>> selectTracks({
    required DriveBenchmarkTrackSource source,
    required DriveBenchmarkTrackFilter filter,
  }) async {
    return tracks;
  }
}

class _SequencedBenchmarkReadModel implements DriveBenchmarkReadModel {
  _SequencedBenchmarkReadModel(this.samples);

  final List<BenchmarkJobSample> samples;
  int _index = 0;

  @override
  String get databasePath => 'memory';

  @override
  void close() {}

  @override
  Future<BenchmarkActiveAccount?> getActiveAccount() async => null;

  @override
  Future<BenchmarkJobSample?> getJobSample(int jobId) async {
    if (samples.isEmpty) {
      return null;
    }
    final resolved =
        samples[_index < samples.length ? _index : samples.length - 1];
    _index += 1;
    return resolved;
  }

  @override
  Future<List<BenchmarkTrackCandidate>> selectTracks({
    required DriveBenchmarkTrackSource source,
    required DriveBenchmarkTrackFilter filter,
  }) async {
    return const <BenchmarkTrackCandidate>[];
  }
}

class _ReplayFixtureDatabase {
  _ReplayFixtureDatabase({required this.directory, required this.databasePath});

  final Directory directory;
  final String databasePath;

  void dispose() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}

class _RestoringAuthRepository implements DriveAuthRepository {
  const _RestoringAuthRepository();

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
  Future<DriveAccountProfile?> restoreSession() async {
    return const DriveAccountProfile(
      providerAccountId: 'account-1',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: 'oauth_desktop',
    );
  }

  @override
  Future<T> withClient<T>(Future<T> Function(http.Client client) action) {
    throw UnimplementedError();
  }
}

class _LoggingMissingSessionAuthRepository implements DriveAuthRepository {
  _LoggingMissingSessionAuthRepository(this.logger);

  final DriveScanLogger logger;

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
  Future<DriveAccountProfile?> restoreSession() async {
    logger.warning(
      prefix: 'DriveAuth',
      subsystem: 'auth',
      operation: 'session_missing',
      message: 'Desktop OAuth credentials are missing.',
    );
    return null;
  }

  @override
  Future<T> withClient<T>(Future<T> Function(http.Client client) action) {
    throw UnimplementedError();
  }
}

Future<_ReplayFixtureDatabase> _loadReplayFixtureDatabase(
  String fixtureFileName,
) async {
  final tempDir = await Directory.systemTemp.createTemp(
    'aero-metadata-deadlock-replay-',
  );
  final databasePath = p.join(tempDir.path, 'replay.sqlite');
  final database = AppDatabase(NativeDatabase(File(databasePath)));
  final fixturePath = p.join(
    Directory.current.path,
    'test',
    'data',
    'drive',
    'benchmark',
    'fixtures',
    fixtureFileName,
  );
  final script = await File(fixturePath).readAsString();
  for (final statement
      in script
          .split(';')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)) {
    await database.customStatement(statement);
  }
  await database.close();
  return _ReplayFixtureDatabase(directory: tempDir, databasePath: databasePath);
}

Future<DriveLiveBenchmarkRunner> _createReplayRunner(
  String databasePath,
) async {
  final readModel = await SqliteDriveBenchmarkReadModel.open(
    databasePath: databasePath,
  );
  final client = BenchmarkingDriveHttpClient(
    inner: _ByteDriveHttpClient(const <String, Uint8List>{}),
  );
  return DriveLiveBenchmarkRunner(
    readModel: readModel,
    authRepository: const _RestoringAuthRepository(),
    driveHttpClient: client,
    metadataExtractor: DriveMetadataExtractor(driveHttpClient: client),
    artworkExtractor: DriveArtworkExtractor(driveHttpClient: client),
    logger: BenchmarkRecordingDriveScanLogger(),
    sleep: (_) async {},
  );
}

class _ByteDriveHttpClient extends DriveHttpClient {
  _ByteDriveHttpClient(
    this.bytesByFileId, {
    this.logger = const NoOpDriveScanLogger(),
  }) : super(authRepository: const _NoopAuthRepository());

  final Map<String, Uint8List> bytesByFileId;
  final DriveScanLogger logger;

  @override
  Future<Uint8List> downloadBytes({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    final bytes = bytesByFileId[fileId];
    if (bytes == null) {
      throw StateError('Missing bytes for $fileId');
    }
    logger.info(
      prefix: 'DriveHTTP',
      subsystem: 'http',
      operation: 'download_file_start',
      context: DriveScanLogContext(driveFileId: fileId),
      details: <String, Object?>{'rangeHeader': rangeHeader},
    );
    if (rangeHeader == null || rangeHeader.isEmpty) {
      logger.info(
        prefix: 'DriveHTTP',
        subsystem: 'http',
        operation: 'download_bytes_success',
        context: DriveScanLogContext(driveFileId: fileId),
        details: <String, Object?>{
          'byteCount': bytes.length,
          'rangeHeader': rangeHeader,
        },
      );
      return bytes;
    }
    final match = RegExp(r'^bytes=(\d+)-(\d+)$').firstMatch(rangeHeader);
    if (match == null) {
      throw StateError('Unsupported range header: $rangeHeader');
    }
    final start = int.parse(match.group(1)!);
    final inclusiveEnd = int.parse(match.group(2)!);
    final end = inclusiveEnd >= bytes.length ? bytes.length : inclusiveEnd + 1;
    if (start >= end) {
      return Uint8List(0);
    }
    final slice = Uint8List.fromList(bytes.sublist(start, end));
    logger.info(
      prefix: 'DriveHTTP',
      subsystem: 'http',
      operation: 'download_bytes_success',
      context: DriveScanLogContext(driveFileId: fileId),
      details: <String, Object?>{
        'byteCount': slice.length,
        'rangeHeader': rangeHeader,
      },
    );
    return slice;
  }

  @override
  Future<http.StreamedResponse> downloadFile({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    final bytes = bytesByFileId[fileId];
    if (bytes == null) {
      throw StateError('Missing bytes for $fileId');
    }
    return http.StreamedResponse(Stream<List<int>>.value(bytes), 200);
  }
}

class _NoopAuthRepository implements DriveAuthRepository {
  const _NoopAuthRepository();

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

class _DirectDownloadMetadataExtractor extends DriveMetadataExtractor {
  _DirectDownloadMetadataExtractor(this.client)
    : super(driveHttpClient: client);

  final DriveHttpClient client;

  @override
  Future<DriveExtractedMetadata> extract(Track track) async {
    await client.downloadFile(fileId: track.driveFileId);
    return const DriveExtractedMetadata(
      title: 'Title',
      artist: 'Artist',
      album: 'Album',
      albumArtist: '',
      genre: '',
      year: null,
      trackNumber: 0,
      discNumber: 0,
      durationMs: 0,
    );
  }
}

Track _buildTrack({
  required String driveFileId,
  required String fileName,
  required String mimeType,
  required int sizeBytes,
}) {
  final now = DateTime(2026, 4, 4);
  return Track(
    id: 1,
    rootId: 1,
    driveFileId: driveFileId,
    resourceKey: null,
    fileName: fileName,
    title: 'Title',
    titleSort: 'title',
    artist: 'Artist',
    artistSort: 'artist',
    album: 'Album',
    albumArtist: '',
    genre: '',
    year: null,
    trackNumber: 1,
    discNumber: 1,
    durationMs: 180000,
    mimeType: mimeType,
    sizeBytes: sizeBytes,
    md5Checksum: 'md5',
    modifiedTime: now,
    artworkUri: null,
    artworkBlobId: null,
    artworkStatus: TrackArtworkStatus.pending.value,
    cachePath: null,
    cacheStatus: 'none',
    metadataStatus: TrackMetadataStatus.pending.value,
    indexStatus: TrackIndexStatus.active.value,
    metadataSchemaVersion: 3,
    contentFingerprint: 'fingerprint',
    playCount: 0,
    lastPlayedAt: null,
    isFavorite: false,
    insertedAt: now,
    discoveredAt: now,
    updatedAt: now,
    removedAt: null,
  );
}

Uint8List _buildMp3Bytes({required String title, required String artist}) {
  final frames = <int>[
    ..._textFrame('TIT2', title),
    ..._textFrame('TPE1', artist),
  ];

  return Uint8List.fromList([
    ...ascii.encode('ID3'),
    3,
    0,
    0,
    ..._synchsafe(frames.length),
    ...frames,
    ...List<int>.filled(32, 0),
  ]);
}

List<int> _textFrame(String id, String text) {
  final payload = <int>[0, ...latin1.encode(text)];
  return <int>[
    ...ascii.encode(id),
    ..._uint32(payload.length),
    0,
    0,
    ...payload,
  ];
}

List<int> _synchsafe(int value) {
  return <int>[
    (value >> 21) & 0x7f,
    (value >> 14) & 0x7f,
    (value >> 7) & 0x7f,
    value & 0x7f,
  ];
}

List<int> _uint32(int value) {
  return <int>[
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];
}

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_artwork_service.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/drive_download_debug_meter.dart';
import 'package:aero_stream/data/drive/drive_metadata_catch_up_planner.dart';
import 'package:aero_stream/data/drive/drive_metadata_orchestrator.dart';
import 'package:aero_stream/data/drive/extraction/drive_metadata_adapter.dart';
import 'package:aero_stream/data/drive/extraction/drive_artwork_extractor.dart';
import 'package:aero_stream/data/drive/extraction/drive_metadata_extractor.dart';
import 'package:aero_stream/data/drive/metadata_pipeline_backlog.dart';
import 'package:aero_stream/data/drive/drive_scan_runner.dart';
import 'package:aero_stream/data/drive/drive_scan_execution_profile.dart';
import 'package:aero_stream/data/drive/drive_scan_job_lifecycle.dart';
import 'package:aero_stream/data/drive/drive_scan_job_enqueuer.dart';
import 'package:aero_stream/data/drive/drive_scan_logger.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_codec.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_executor.dart';
import 'package:aero_stream/data/drive/drive_scan_progress_refresher.dart';
import 'package:aero_stream/data/drive/drive_scan_root_binder.dart';
import 'package:aero_stream/data/drive/drive_scan_root_resolver.dart';
import 'package:aero_stream/data/drive/drive_track_cache_service.dart';
import 'package:aero_stream/data/drive/drive_discovery_service.dart';
import 'package:aero_stream/data/drive/drive_track_projector.dart';
import 'package:aero_stream/media_extraction/core/audio_extraction_capabilities.dart';
import 'package:aero_stream/media_extraction/core/audio_extraction_cost_class.dart';
import 'package:aero_stream/media_extraction/core/extracted_metadata.dart';

import 'test_drive_scan_logger.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'enqueueSync creates a baseline job when no Drive checkpoint exists',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        autoRun: false,
      );
      final account = await _seedAccount(database, driveStartPageToken: null);
      await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: null,
      );

      final jobId = await runner.enqueueSync();
      final job = await database.getScanJobById(jobId!);
      final taskCount = await _countTasksOfKind(
        database,
        DriveScanTaskKind.discoverFolder.value,
      );

      expect(job, isNotNull);
      expect(job!.kind, DriveScanJobKind.baseline.value);
      expect(job.phase, DriveScanPhase.baselineDiscovery.value);
      expect(taskCount, 1);
    },
  );

  test(
    'enqueueSync creates an incremental job when Drive checkpoint exists',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        autoRun: false,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );

      final jobId = await runner.enqueueSync();
      final job = await database.getScanJobById(jobId!);
      final taskCount = await _countTasksOfKind(
        database,
        DriveScanTaskKind.reconcileChange.value,
      );

      expect(job, isNotNull);
      expect(job!.kind, DriveScanJobKind.incremental.value);
      expect(job.phase, DriveScanPhase.incrementalChanges.value);
      expect(taskCount, 1);
    },
  );

  test('enqueueSync reuses an existing active job', () async {
    final httpClient = _FakeDriveHttpClient();
    final runner = _buildRunner(
      database: database,
      httpClient: httpClient,
      autoRun: false,
    );
    final account = await _seedAccount(
      database,
      driveStartPageToken: 'start-token',
    );
    await _seedRoot(
      database,
      accountId: account.id,
      folderId: 'root-folder',
      folderName: 'Library',
      lastSyncedAt: DateTime(2026, 3, 1),
    );

    final firstJobId = await runner.enqueueSync();
    final secondJobId = await runner.enqueueSync();
    final activeJob = await database.getLatestActiveScanJob();

    expect(secondJobId, firstJobId);
    expect(activeJob, isNotNull);
    expect(activeJob!.id, firstJobId);
  });

  test(
    'enqueueSync processes metadata catch-up tasks even when changes are empty',
    () async {
      final httpClient = _FakeDriveHttpClient(
        changePages: const <String, DriveChangePage>{
          'start-token': DriveChangePage(
            changes: <DriveChangeEntry>[],
            nextPageToken: null,
            newStartPageToken: 'new-start-token',
          ),
        },
      );
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
        ),
        autoRun: true,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-pending',
        fileName: 'pending.mp3',
        title: 'Pending Title',
        md5Checksum: 'pending-md5',
        modifiedTime: DateTime(2026, 3, 20),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.pending.value,
      );

      final jobId = await runner.enqueueSync();
      final job = await _waitForTerminalJob(database, jobId!);
      final track = await database.getTrackByDriveFileId('track-pending');

      expect(job.state, DriveScanJobState.completed.value);
      expect(metadataExtractor.extractedDriveIds, contains('track-pending'));
      expect(track, isNotNull);
      expect(track!.metadataStatus, TrackMetadataStatus.ready.value);
    },
  );

  test(
    'enqueueSync merges metadata catch-up tasks into an existing job',
    () async {
      final logger = RecordingDriveScanLogger();
      final httpClient = _FakeDriveHttpClient();
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        autoRun: false,
        logger: logger,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-pending',
        fileName: 'pending.mp3',
        title: 'Pending Title',
        md5Checksum: 'pending-md5',
        modifiedTime: DateTime(2026, 3, 20),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.pending.value,
      );
      final existingJobId = await database.createScanJob(
        ScanJobsCompanion.insert(
          accountId: account.id,
          kind: DriveScanJobKind.incremental.value,
          state: DriveScanJobState.running.value,
          phase: DriveScanPhase.artworkEnrichment.value,
          checkpointToken: const Value('start-token'),
          startPageToken: const Value('start-token'),
        ),
      );
      await database.updateRootState(
        rootId,
        syncStateValue: DriveScanJobState.running.value,
        activeJobIdValue: existingJobId,
        lastErrorValue: null,
      );

      final jobId = await runner.enqueueSync();
      final job = await database.getScanJobById(existingJobId);
      final taskCount = await _countTasksOfKind(
        database,
        DriveScanTaskKind.extractTags.value,
      );

      expect(jobId, existingJobId);
      expect(job, isNotNull);
      expect(job!.phase, DriveScanPhase.metadataEnrichment.value);
      expect(taskCount, 1);
      expect(logger.containsOperation('metadata_catchup_tasks_merged'), isTrue);
    },
  );

  test('baseline discovery runs folder pages concurrently', () async {
    final httpClient = _FakeDriveHttpClient(
      listFolderDelay: const Duration(milliseconds: 80),
      folderPages: {
        _FakeDriveHttpClient.folderKey('root-a', null): const DriveFolderPage(
          items: <DriveObjectEntry>[],
          nextPageToken: null,
        ),
        _FakeDriveHttpClient.folderKey('root-b', null): const DriveFolderPage(
          items: <DriveObjectEntry>[],
          nextPageToken: null,
        ),
        _FakeDriveHttpClient.folderKey('root-c', null): const DriveFolderPage(
          items: <DriveObjectEntry>[],
          nextPageToken: null,
        ),
      },
    );
    final runner = _buildRunner(
      database: database,
      httpClient: httpClient,
      autoRun: true,
      executionProfile: const DriveScanExecutionProfile(
        changeWorkers: 1,
        discoveryWorkers: 3,
        metadataWorkers: 1,
        artworkWorkers: 1,
        artworkWorkersWhileMetadataPending: 0,
        metadataHighWatermark: 0,
        pageSize: 1000,
        trackProjectionBatchSize: 500,
      ),
    );
    final account = await _seedAccount(database, driveStartPageToken: null);
    await _seedRoot(
      database,
      accountId: account.id,
      folderId: 'root-a',
      folderName: 'A',
      lastSyncedAt: null,
    );
    await _seedRoot(
      database,
      accountId: account.id,
      folderId: 'root-b',
      folderName: 'B',
      lastSyncedAt: null,
    );
    await _seedRoot(
      database,
      accountId: account.id,
      folderId: 'root-c',
      folderName: 'C',
      lastSyncedAt: null,
    );

    final jobId = await runner.enqueueSync();
    final job = await _waitForTerminalJob(database, jobId!);

    if (job.state != DriveScanJobState.completed.value) {
      fail('Job failed with error: ${job.lastError}');
    }
    expect(httpClient.maxConcurrentFolderRequests, greaterThan(1));
  });

  test(
    'baseline discovery reuses metadata for unchanged tracks and batches new ones',
    () async {
      final httpClient = _FakeDriveHttpClient(
        folderPages: {
          _FakeDriveHttpClient.folderKey('root-folder', null): DriveFolderPage(
            items: <DriveObjectEntry>[
              _audioEntry(
                id: 'track-1',
                name: 'kept-title.mp3',
                md5Checksum: 'same-md5',
                modifiedTime: DateTime(2026, 3, 20),
              ),
              _audioEntry(
                id: 'track-2',
                name: 'new-track.mp3',
                md5Checksum: 'new-md5',
                modifiedTime: DateTime(2026, 3, 21),
              ),
            ],
            nextPageToken: null,
          ),
        },
      );
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
      );
      final artworkExtractor = _CountingArtworkExtractor(
        driveHttpClient: httpClient,
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: artworkExtractor,
        autoRun: true,
      );
      final account = await _seedAccount(database, driveStartPageToken: null);
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: null,
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-1',
        fileName: 'kept-title.mp3',
        title: 'Kept Title',
        md5Checksum: 'same-md5',
        modifiedTime: DateTime(2026, 3, 20),
        metadataStatus: TrackMetadataStatus.ready.value,
        artworkStatus: TrackArtworkStatus.ready.value,
      );

      final jobId = await runner.enqueueSync();
      final job = await _waitForTerminalJob(database, jobId!);
      final tracks = await database.getTracksByDriveFileIds([
        'track-1',
        'track-2',
      ]);

      if (job.state != DriveScanJobState.completed.value) {
        fail('Job failed with error: ${job.lastError}');
      }
      expect(tracks, hasLength(2));
      expect(tracks.map((track) => track.driveFileId).toSet(), {
        'track-1',
        'track-2',
      });
      expect(metadataExtractor.extractedDriveIds, ['track-2']);
      expect(artworkExtractor.extractedDriveIds, ['track-2']);
      final keptTrack = tracks.singleWhere(
        (track) => track.driveFileId == 'track-1',
      );
      final newTrack = tracks.singleWhere(
        (track) => track.driveFileId == 'track-2',
      );
      expect(keptTrack.title, 'Kept Title');
      expect(keptTrack.metadataStatus, TrackMetadataStatus.ready.value);
      expect(newTrack.metadataStatus, TrackMetadataStatus.ready.value);
    },
  );

  test('baseline discovery continues from the next page token', () async {
    final httpClient = _FakeDriveHttpClient(
      folderPages: {
        _FakeDriveHttpClient.folderKey('root-folder', null): DriveFolderPage(
          items: <DriveObjectEntry>[
            _audioEntry(
              id: 'track-1',
              name: 'first-page.mp3',
              md5Checksum: 'md5-1',
              modifiedTime: DateTime(2026, 3, 10),
            ),
          ],
          nextPageToken: 'page-2',
        ),
        _FakeDriveHttpClient.folderKey(
          'root-folder',
          'page-2',
        ): DriveFolderPage(
          items: <DriveObjectEntry>[
            _audioEntry(
              id: 'track-2',
              name: 'second-page.mp3',
              md5Checksum: 'md5-2',
              modifiedTime: DateTime(2026, 3, 11),
            ),
          ],
          nextPageToken: null,
        ),
      },
    );
    final runner = _buildRunner(
      database: database,
      httpClient: httpClient,
      metadataExtractor: _CountingMetadataExtractor(
        driveHttpClient: httpClient,
      ),
      artworkExtractor: _CountingArtworkExtractor(driveHttpClient: httpClient),
      autoRun: true,
    );
    final account = await _seedAccount(database, driveStartPageToken: null);
    await _seedRoot(
      database,
      accountId: account.id,
      folderId: 'root-folder',
      folderName: 'Library',
      lastSyncedAt: null,
    );

    final jobId = await runner.enqueueSync();
    final job = await _waitForTerminalJob(database, jobId!);
    final tracks = await database.getTracksByDriveFileIds([
      'track-1',
      'track-2',
    ]);

    expect(job.state, DriveScanJobState.completed.value);
    expect(tracks, hasLength(2));
    expect(
      httpClient.requestedFolderPages,
      containsAll([
        _FakeDriveHttpClient.folderKey('root-folder', null),
        _FakeDriveHttpClient.folderKey('root-folder', 'page-2'),
      ]),
    );
  });

  test(
    'metadata tasks still complete before artwork starts when artwork stays in a later phase',
    () async {
      final httpClient = _FakeDriveHttpClient(
        folderPages: {
          _FakeDriveHttpClient.folderKey('root-folder', null): DriveFolderPage(
            items: <DriveObjectEntry>[
              _audioEntry(
                id: 'track-a',
                name: 'a.mp3',
                md5Checksum: 'md5-a',
                modifiedTime: DateTime(2026, 3, 10),
              ),
              _audioEntry(
                id: 'track-b',
                name: 'b.mp3',
                md5Checksum: 'md5-b',
                modifiedTime: DateTime(2026, 3, 11),
              ),
            ],
            nextPageToken: null,
          ),
        },
      );
      final executionLog = <String>[];
      final logger = RecordingDriveScanLogger();
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: _CountingMetadataExtractor(
          driveHttpClient: httpClient,
          executionLog: executionLog,
        ),
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
          executionLog: executionLog,
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 2,
          metadataWorkers: 1,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
        ),
        autoRun: true,
        logger: logger,
      );
      final account = await _seedAccount(database, driveStartPageToken: null);
      await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: null,
      );

      final jobId = await runner.enqueueSync();
      final job = await _waitForTerminalJob(database, jobId!);

      expect(job.state, DriveScanJobState.completed.value);
      expect(
        executionLog,
        containsAllInOrder(<String>[
          'tag:track-a',
          'tag:track-b',
          'art:track-a',
          'art:track-b',
        ]),
      );
      expect(logger.containsOperation('metadata_pipeline_start'), isTrue);
      expect(logger.containsOperation('metadata_pipeline_complete'), isTrue);
    },
  );

  test(
    'metadata pipeline keeps later stages flowing while a slow probe is still running',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
        probeDelayByDriveId: const <String, Duration>{
          'track-slow': Duration(milliseconds: 180),
        },
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 2,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
        ),
        autoRun: true,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-slow',
        fileName: 'slow.mp3',
        title: 'Slow',
        md5Checksum: 'md5-slow',
        modifiedTime: DateTime(2026, 3, 20),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.ready.value,
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-fast',
        fileName: 'fast.mp3',
        title: 'Fast',
        md5Checksum: 'md5-fast',
        modifiedTime: DateTime(2026, 3, 21),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.ready.value,
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-refill-a',
        fileName: 'refill-a.mp3',
        title: 'Refill A',
        md5Checksum: 'md5-refill-a',
        modifiedTime: DateTime(2026, 3, 22),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.ready.value,
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-refill-b',
        fileName: 'refill-b.mp3',
        title: 'Refill B',
        md5Checksum: 'md5-refill-b',
        modifiedTime: DateTime(2026, 3, 23),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.ready.value,
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-refill-c',
        fileName: 'refill-c.mp3',
        title: 'Refill C',
        md5Checksum: 'md5-refill-c',
        modifiedTime: DateTime(2026, 3, 24),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.ready.value,
      );

      await runner.bootstrap();
      final runningJob = await _waitForActiveMetadataJob(database);
      final overlapSeen = await _waitForMetadataPipelineOverlap(runningJob.id);
      final refillSeen = await _waitForMetadataSourceRefill(runningJob.id);
      final job = await _waitForTerminalJob(database, runningJob.id);

      expect(job.state, DriveScanJobState.completed.value);
      expect(overlapSeen, isTrue);
      expect(refillSeen, isTrue);
    },
  );

  test(
    'metadata pipeline runs fetch -> parse for each metadata task',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final executionLog = <String>[];
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
        executionLog: executionLog,
        pipelineBehaviorByDriveId: const <String, _FakePipelineBehavior>{
          'track-retry': _FakePipelineBehavior(
            formatKey: 'm4a',
            unresolvedAnalyzeCount: 1,
          ),
          'track-fast-a': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-b': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-c': _FakePipelineBehavior(formatKey: 'm4a'),
        },
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 2,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
          metadataFetchHeadWorkers: 2,
          metadataAnalyzeHeadWorkers: 1,
          metadataPlanWorkers: 1,
          metadataFetchWorkers: 1,
          metadataParseWorkers: 1,
          metadataFetchHeadQueueHighWatermark: 2,
          metadataAnalyzeHeadQueueHighWatermark: 2,
          metadataPlanQueueHighWatermark: 2,
          metadataFetchQueueHighWatermark: 2,
          metadataParseQueueHighWatermark: 2,
          metadataFlushQueueHighWatermark: 2,
        ),
        autoRun: true,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      for (final trackId in const [
        'track-retry',
        'track-fast-a',
        'track-fast-b',
        'track-fast-c',
      ]) {
        await _seedTrack(
          database,
          rootId: rootId,
          driveFileId: trackId,
          fileName: '$trackId.m4a',
          title: trackId,
          md5Checksum: 'md5-$trackId',
          modifiedTime: DateTime(2026, 3, 20),
          metadataStatus: TrackMetadataStatus.pending.value,
          artworkStatus: TrackArtworkStatus.ready.value,
        );
      }

      await runner.bootstrap();
      final job = await _waitForLatestTerminalJob(database);
      final retrySequence = _stageEventsFor(executionLog, 'track-retry');

      expect(job.state, DriveScanJobState.completed.value);
      expect(retrySequence, containsAllInOrder(<String>['fetch', 'parse']));
      expect(retrySequence.where((event) => event == 'fetch'), hasLength(1));
    },
  );

  test(
    'metadata source refill is throttled by parse queue occupancy cap',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final logger = RecordingDriveScanLogger();
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
        parseDelayByDriveId: const <String, Duration>{
          'track-1': Duration(milliseconds: 250),
          'track-2': Duration(milliseconds: 250),
          'track-3': Duration(milliseconds: 250),
          'track-4': Duration(milliseconds: 250),
          'track-5': Duration(milliseconds: 250),
          'track-6': Duration(milliseconds: 250),
        },
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 2,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
          metadataFetchWorkers: 4,
          metadataParseWorkers: 1,
          metadataFetchQueueHighWatermark: 8,
          metadataParseQueueHighWatermark: 1,
          metadataFlushQueueHighWatermark: 2,
        ),
        autoRun: true,
        logger: logger,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      for (final trackId in const [
        'track-1',
        'track-2',
        'track-3',
        'track-4',
        'track-5',
        'track-6',
      ]) {
        await _seedTrack(
          database,
          rootId: rootId,
          driveFileId: trackId,
          fileName: '$trackId.mp3',
          title: trackId,
          md5Checksum: 'md5-$trackId',
          modifiedTime: DateTime(2026, 3, 20),
          metadataStatus: TrackMetadataStatus.pending.value,
          artworkStatus: TrackArtworkStatus.ready.value,
        );
      }

      await runner.bootstrap();
      final job = await _waitForLatestTerminalJob(database);
      final refillEntries = logger.byOperation('metadata_source_refill');

      expect(job.state, DriveScanJobState.completed.value);
      expect(refillEntries, isNotEmpty);
      for (final entry in refillEntries) {
        final details = entry.details;
        expect(details.containsKey('fetchAvailableSlots'), isTrue);
        expect(details.containsKey('parseOccupancy'), isTrue);
        expect(details.containsKey('parseCap'), isTrue);
        expect(details.containsKey('admissionLimit'), isTrue);
        expect((details['admissionLimit'] as num) <= 1, isTrue);
      }
      expect(
        logger.containsOperation('metadata_source_refill_throttled'),
        isTrue,
      );
    },
  );

  test(
    'metadata retry handoff survives source refill pressure on fetchHead queue',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final executionLog = <String>[];
      final logger = RecordingDriveScanLogger();
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
        executionLog: executionLog,
        pipelineBehaviorByDriveId: const <String, _FakePipelineBehavior>{
          'track-retry': _FakePipelineBehavior(
            formatKey: 'm4a',
            unresolvedAnalyzeCount: 1,
            analyzeDelay: Duration(milliseconds: 40),
          ),
          'track-fast-a': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-b': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-c': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-d': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-e': _FakePipelineBehavior(formatKey: 'm4a'),
        },
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 2,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
          metadataFetchHeadWorkers: 2,
          metadataAnalyzeHeadWorkers: 1,
          metadataPlanWorkers: 1,
          metadataFetchWorkers: 1,
          metadataParseWorkers: 1,
          metadataFetchHeadQueueHighWatermark: 2,
          metadataAnalyzeHeadQueueHighWatermark: 2,
          metadataPlanQueueHighWatermark: 2,
          metadataFetchQueueHighWatermark: 2,
          metadataParseQueueHighWatermark: 2,
          metadataFlushQueueHighWatermark: 2,
        ),
        autoRun: true,
        logger: logger,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      for (final trackId in const [
        'track-retry',
        'track-fast-a',
        'track-fast-b',
        'track-fast-c',
        'track-fast-d',
        'track-fast-e',
      ]) {
        await _seedTrack(
          database,
          rootId: rootId,
          driveFileId: trackId,
          fileName: '$trackId.m4a',
          title: trackId,
          md5Checksum: 'md5-$trackId',
          modifiedTime: DateTime(2026, 3, 20),
          metadataStatus: TrackMetadataStatus.pending.value,
          artworkStatus: TrackArtworkStatus.ready.value,
        );
      }

      await runner.bootstrap();
      await _waitForStageEvent(executionLog, 'track-retry', 'parse');
      final job = await _waitForLatestTerminalJob(database);
      final retrySequence = _stageEventsFor(executionLog, 'track-retry');

      expect(job.state, DriveScanJobState.completed.value);
      expect(retrySequence, containsAllInOrder(<String>['fetch', 'parse']));
      expect(logger.byOperation('metadata_source_refill').isNotEmpty, isTrue);
    },
  );

  test(
    'metadata pipeline restores forward progress after backlog pressure',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final executionLog = <String>[];
      final logger = RecordingDriveScanLogger();
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
        executionLog: executionLog,
        pipelineBehaviorByDriveId: const <String, _FakePipelineBehavior>{
          'track-retry': _FakePipelineBehavior(
            formatKey: 'm4a',
            unresolvedAnalyzeCount: 1,
            analyzeDelay: Duration(milliseconds: 120),
          ),
          'track-fast-a': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-b': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-c': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-d': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-e': _FakePipelineBehavior(formatKey: 'm4a'),
          'track-fast-f': _FakePipelineBehavior(formatKey: 'm4a'),
        },
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 2,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
          metadataFetchHeadWorkers: 1,
          metadataAnalyzeHeadWorkers: 1,
          metadataPlanWorkers: 1,
          metadataFetchWorkers: 1,
          metadataParseWorkers: 1,
          metadataFetchHeadQueueHighWatermark: 1,
          metadataAnalyzeHeadQueueHighWatermark: 1,
          metadataPlanQueueHighWatermark: 1,
          metadataFetchQueueHighWatermark: 1,
          metadataParseQueueHighWatermark: 1,
          metadataFlushQueueHighWatermark: 1,
        ),
        autoRun: true,
        logger: logger,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      for (final trackId in const [
        'track-retry',
        'track-fast-a',
        'track-fast-b',
        'track-fast-c',
        'track-fast-d',
      ]) {
        await _seedTrack(
          database,
          rootId: rootId,
          driveFileId: trackId,
          fileName: '$trackId.m4a',
          title: trackId,
          md5Checksum: 'md5-$trackId',
          modifiedTime: DateTime(2026, 3, 20),
          metadataStatus: TrackMetadataStatus.pending.value,
          artworkStatus: TrackArtworkStatus.ready.value,
        );
      }

      await runner.bootstrap();
      final completedJob = await _waitForLatestTerminalJob(database);
      final completedSnapshot = MetadataPipelineTelemetryHub.instance
          .snapshotForJob(completedJob.id);
      final retrySequence = _stageEventsFor(executionLog, 'track-retry');

      expect(completedJob.state, DriveScanJobState.completed.value);
      expect(completedSnapshot.fetch.blockedCount, 0);
      expect(completedSnapshot.parse.blockedCount, 0);
      expect(
        await _readActiveExtractTagTaskStates(database, completedJob.id),
        isEmpty,
      );
      expect(retrySequence, containsAllInOrder(<String>['fetch', 'parse']));
    },
    timeout: const Timeout(Duration(seconds: 10)),
    skip:
        'Legacy retry-pressure path removed by 3-stage fetch/parse/flush execution model.',
  );

  test(
    'metadata pipeline persists runtime stage heartbeats while a task is active',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
        probeDelayByDriveId: const <String, Duration>{
          'track-heartbeat': Duration(milliseconds: 2200),
        },
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 1,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
          metadataTaskHeartbeatInterval: Duration(milliseconds: 40),
          metadataTaskStallWarningThreshold: Duration(seconds: 5),
        ),
        autoRun: true,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-heartbeat',
        fileName: 'heartbeat.mp3',
        title: 'Heartbeat',
        md5Checksum: 'heartbeat-md5',
        modifiedTime: DateTime(2026, 3, 20),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.ready.value,
      );
      final jobId = await database.createScanJob(
        ScanJobsCompanion.insert(
          accountId: account.id,
          kind: DriveScanJobKind.incremental.value,
          state: DriveScanJobState.running.value,
          phase: DriveScanPhase.metadataEnrichment.value,
          checkpointToken: const Value('start-token'),
          startPageToken: const Value('start-token'),
        ),
      );
      await database.updateRootState(
        rootId,
        syncStateValue: DriveScanJobState.running.value,
        activeJobIdValue: jobId,
        lastErrorValue: null,
      );
      await database.enqueueScanTasks([
        ScanTasksCompanion.insert(
          jobId: jobId,
          kind: DriveScanTaskKind.extractTags.value,
          rootId: Value(rootId),
          targetDriveId: const Value('track-heartbeat'),
          dedupeKey: const Value('tags:track-heartbeat:heartbeat-md5'),
          payloadJson: const Value('{}'),
          priority: const Value(20),
        ),
      ]);

      await runner.bootstrap();
      final firstHeartbeat = await _waitForRunningTaskLease(
        database,
        'track-heartbeat',
      );
      await Future<void>.delayed(const Duration(milliseconds: 1300));
      final secondHeartbeat = await _readRunningTaskLease(
        database,
        'track-heartbeat',
      );
      final job = await _waitForTerminalJob(database, jobId);

      expect(firstHeartbeat, isNotNull);
      expect(firstHeartbeat!.$1, isNotNull);
      expect(secondHeartbeat, isNotNull);
      expect(
        secondHeartbeat!.$2.isAfter(firstHeartbeat.$2) ||
            secondHeartbeat.$1 != firstHeartbeat.$1,
        isTrue,
      );
      expect(job.state, DriveScanJobState.completed.value);
    },
  );

  test(
    'bootstrap reclaims stale running metadata tasks and processes them once',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final executionLog = <String>[];
      final logger = RecordingDriveScanLogger();
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
        executionLog: executionLog,
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
          executionLog: executionLog,
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 1,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
          metadataTaskLeaseTimeout: Duration(milliseconds: 150),
          metadataTaskHeartbeatInterval: Duration(milliseconds: 40),
        ),
        autoRun: true,
        logger: logger,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-stale',
        fileName: 'stale.mp3',
        title: 'Stale',
        md5Checksum: 'stale-md5',
        modifiedTime: DateTime(2026, 3, 20),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.ready.value,
      );
      final jobId = await database.createScanJob(
        ScanJobsCompanion.insert(
          accountId: account.id,
          kind: DriveScanJobKind.incremental.value,
          state: DriveScanJobState.running.value,
          phase: DriveScanPhase.metadataEnrichment.value,
          checkpointToken: const Value('start-token'),
          startPageToken: const Value('start-token'),
        ),
      );
      await database.updateRootState(
        rootId,
        syncStateValue: DriveScanJobState.running.value,
        activeJobIdValue: jobId,
        lastErrorValue: null,
      );
      final staleUpdatedAt = DateTime.now().subtract(
        const Duration(seconds: 1),
      );
      await database.enqueueScanTasks([
        ScanTasksCompanion.insert(
          jobId: jobId,
          kind: DriveScanTaskKind.extractTags.value,
          rootId: Value(rootId),
          targetDriveId: const Value('track-stale'),
          dedupeKey: const Value('tags:track-stale:stale-md5'),
          payloadJson: const Value('{}'),
          priority: const Value(20),
        ),
      ]);
      final taskId = await database
          .customSelect(
            '''
          SELECT id
          FROM scan_tasks
          WHERE job_id = ?
            AND target_drive_id = ?
          ORDER BY id DESC
          LIMIT 1
          ''',
            variables: [
              Variable.withInt(jobId),
              Variable.withString('track-stale'),
            ],
            readsFrom: {database.scanTasks},
          )
          .getSingle()
          .then((row) => row.read<int>('id'));
      await database.customUpdate(
        '''
        UPDATE scan_tasks
        SET state = ?, locked_at = ?, runtime_stage = ?, updated_at = ?
        WHERE id = ?
        ''',
        variables: [
          Variable.withString(DriveScanTaskState.running.value),
          Variable.withDateTime(staleUpdatedAt),
          Variable.withString(DriveMetadataTaskRuntimeStage.plan.value),
          Variable.withDateTime(staleUpdatedAt),
          Variable.withInt(taskId),
        ],
        updates: {database.scanTasks},
      );

      await runner.bootstrap();
      await _waitForTrackMetadataStatus(
        database,
        'track-stale',
        TrackMetadataStatus.ready.value,
      );
      final track = await database.getTrackByDriveFileId('track-stale');
      final recoveredTask = await database
          .customSelect(
            '''
          SELECT state, runtime_stage
          FROM scan_tasks
          WHERE id = ?
          ''',
            variables: [Variable.withInt(taskId)],
            readsFrom: {database.scanTasks},
          )
          .getSingle();

      expect(track, isNotNull);
      expect(track!.metadataStatus, TrackMetadataStatus.ready.value);
      expect(
        executionLog.where((entry) => entry == 'tag:track-stale'),
        hasLength(1),
      );
      expect(
        recoveredTask.read<String>('state'),
        DriveScanTaskState.completed.value,
      );
      expect(recoveredTask.read<String?>('runtime_stage'), equals(null));
      expect(logger.containsOperation('metadata_stale_task_reclaimed'), isTrue);
      expect(
        logger.containsOperation('metadata_pipeline_stall_detected'),
        isTrue,
      );
    },
  );

  test(
    'metadata progress refresh stays bounded during continuous metadata runtime',
    () async {
      final logger = RecordingDriveScanLogger();
      final httpClient = _FakeDriveHttpClient();
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: _CountingMetadataExtractor(
          driveHttpClient: httpClient,
        ),
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 1,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
        ),
        autoRun: true,
        logger: logger,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      for (final driveId in ['track-1', 'track-2', 'track-3']) {
        await _seedTrack(
          database,
          rootId: rootId,
          driveFileId: driveId,
          fileName: '$driveId.mp3',
          title: 'Pending',
          md5Checksum: 'md5-$driveId',
          modifiedTime: DateTime(2026, 3, 20),
          metadataStatus: TrackMetadataStatus.pending.value,
          artworkStatus: TrackArtworkStatus.ready.value,
        );
      }

      await runner.bootstrap();
      final job = await _waitForLatestTerminalJob(database);

      expect(job.state, DriveScanJobState.completed.value);
      final refreshes = logger.byOperation('job_progress_refresh').length;
      expect(refreshes, lessThan(6));
      expect(logger.containsOperation('metadata_pipeline_start'), isTrue);
      expect(logger.containsOperation('metadata_pipeline_complete'), isTrue);
    },
  );

  test('job failure stores a short lastError and logs stack traces', () async {
    final logger = RecordingDriveScanLogger();
    final httpClient = _FailingDriveHttpClient(
      error: StateError('boom\nmore detail'),
    );
    final runner = _buildRunner(
      database: database,
      httpClient: httpClient,
      autoRun: true,
      logger: logger,
    );
    final account = await _seedAccount(database, driveStartPageToken: null);
    final rootId = await _seedRoot(
      database,
      accountId: account.id,
      folderId: 'root-folder',
      folderName: 'Library',
      lastSyncedAt: null,
    );

    final jobId = await runner.enqueueSync();
    final job = await _waitForTerminalJob(database, jobId!);
    final root = await database.getRootById(rootId);

    expect(job.state, DriveScanJobState.failed.value);
    expect(job.lastError, isNotNull);
    expect(job.lastError, isNot(contains('\n')));
    expect(root!.lastError, job.lastError);
    final failEntries = logger.byOperation('job_fail').toList(growable: false);
    expect(failEntries, hasLength(1));
    expect(failEntries.single.stackTrace, isNotNull);
  });

  test(
    'runtime auth expiry preserves reconnect-required job and root state',
    () async {
      final logger = RecordingDriveScanLogger();
      final account = await _seedAccount(
        database,
        driveStartPageToken: null,
        authKind: 'oauth_desktop',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: null,
      );
      final httpClient = DriveHttpClient(
        authRepository: _ExpiringAuthRepository(
          database: database,
          accountId: account.id,
        ),
        logger: logger,
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        autoRun: true,
        logger: logger,
      );

      final jobId = await runner.enqueueSync();
      final job = await _waitForTerminalJob(database, jobId!);
      final root = await database.getRootById(rootId);
      final refreshedAccount = await database.getActiveAccount();

      expect(
        refreshedAccount!.authSessionState,
        DriveAuthSessionState.reauthRequired.value,
      );
      expect(job.state, DriveScanJobState.failed.value);
      expect(job.lastError, driveSyncReconnectRequiredMessage);
      expect(root!.lastError, driveSyncReconnectRequiredMessage);
      expect(logger.containsOperation('job_reauth_required'), isTrue);
      expect(logger.byOperation('job_fail'), isEmpty);
    },
  );

  test('successful baseline scan logs phase and runtime transitions', () async {
    final logger = RecordingDriveScanLogger();
    final httpClient = _FakeDriveHttpClient(
      folderPages: {
        _FakeDriveHttpClient.folderKey('root-folder', null): DriveFolderPage(
          items: <DriveObjectEntry>[
            _audioEntry(
              id: 'track-logged',
              name: 'logged.mp3',
              md5Checksum: 'logged-md5',
              modifiedTime: DateTime(2026, 3, 12),
            ),
          ],
          nextPageToken: null,
        ),
      },
    );
    final runner = _buildRunner(
      database: database,
      httpClient: httpClient,
      autoRun: true,
      logger: logger,
    );
    final account = await _seedAccount(database, driveStartPageToken: null);
    await _seedRoot(
      database,
      accountId: account.id,
      folderId: 'root-folder',
      folderName: 'Library',
      lastSyncedAt: null,
    );

    final jobId = await runner.enqueueSync();
    final job = await _waitForTerminalJob(database, jobId!);

    expect(job.state, DriveScanJobState.completed.value);
    expect(logger.containsOperation('job_enqueue'), isTrue);
    expect(logger.containsOperation('job_start'), isTrue);
    expect(logger.containsOperation('discovery_batch_start'), isTrue);
    expect(logger.containsOperation('discovery_page_complete'), isTrue);
    expect(logger.containsOperation('metadata_pipeline_start'), isTrue);
    expect(logger.containsOperation('metadata_pipeline_complete'), isTrue);
    expect(logger.containsOperation('artwork_batch_complete'), isTrue);
    expect(logger.containsOperation('job_complete'), isTrue);
  });

  test('incremental changes logs checkpoint-aware page processing', () async {
    final logger = RecordingDriveScanLogger();
    final httpClient = _FakeDriveHttpClient(
      changePages: {
        'start-token': DriveChangePage(
          changes: <DriveChangeEntry>[
            DriveChangeEntry(
              fileId: 'track-change',
              isRemoved: false,
              file: _audioEntry(
                id: 'track-change',
                name: 'change.mp3',
                md5Checksum: 'change-md5',
                modifiedTime: DateTime(2026, 3, 29),
              ),
            ),
          ],
          nextPageToken: null,
          newStartPageToken: 'new-start-token',
        ),
      },
    );
    final runner = _buildRunner(
      database: database,
      httpClient: httpClient,
      autoRun: true,
      logger: logger,
    );
    final account = await _seedAccount(
      database,
      driveStartPageToken: 'start-token',
    );
    await _seedRoot(
      database,
      accountId: account.id,
      folderId: 'root-folder',
      folderName: 'Library',
      lastSyncedAt: DateTime(2026, 3, 1),
    );

    final jobId = await runner.enqueueSync();
    final job = await _waitForTerminalJob(database, jobId!);

    expect(job.state, DriveScanJobState.completed.value);
    expect(logger.containsOperation('changes_page_start'), isTrue);
    expect(logger.containsOperation('changes_page_complete'), isTrue);
  });

  test(
    'metadata enrichment prioritizes pending tasks ahead of older schema repairs',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final executionLog = <String>[];
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: _CountingMetadataExtractor(
          driveHttpClient: httpClient,
          executionLog: executionLog,
        ),
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
          executionLog: executionLog,
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 1,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
        ),
        autoRun: true,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-repair-first',
        fileName: 'repair-first.mp3',
        title: 'Existing Repair',
        md5Checksum: 'repair-first-md5',
        modifiedTime: DateTime(2026, 3, 20),
        metadataStatus: TrackMetadataStatus.ready.value,
        artworkStatus: TrackArtworkStatus.ready.value,
        metadataSchemaVersion: currentTrackMetadataSchemaVersion - 1,
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-pending-second',
        fileName: 'pending-second.mp3',
        title: 'Pending Track',
        md5Checksum: 'pending-second-md5',
        modifiedTime: DateTime(2026, 3, 21),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.ready.value,
      );
      final jobId = await database.createScanJob(
        ScanJobsCompanion.insert(
          accountId: account.id,
          kind: DriveScanJobKind.incremental.value,
          state: DriveScanJobState.running.value,
          phase: DriveScanPhase.metadataEnrichment.value,
          checkpointToken: const Value('start-token'),
          startPageToken: const Value('start-token'),
        ),
      );
      await database.updateRootState(
        rootId,
        syncStateValue: DriveScanJobState.running.value,
        activeJobIdValue: jobId,
        lastErrorValue: null,
      );
      await database.enqueueScanTasks([
        ScanTasksCompanion.insert(
          jobId: jobId,
          kind: DriveScanTaskKind.extractTags.value,
          rootId: Value(rootId),
          targetDriveId: const Value('track-repair-first'),
          dedupeKey: const Value('tag-repair:v3:track-repair-first'),
          payloadJson: const Value('{"repairSchemaVersion":3}'),
          priority: const Value(20),
          createdAt: Value(DateTime(2026, 3, 30, 9, 0, 0)),
          updatedAt: Value(DateTime(2026, 3, 30, 9, 0, 0)),
        ),
        ScanTasksCompanion.insert(
          jobId: jobId,
          kind: DriveScanTaskKind.extractTags.value,
          rootId: Value(rootId),
          targetDriveId: const Value('track-pending-second'),
          dedupeKey: const Value(
            'tags:track-pending-second:pending-second-fingerprint',
          ),
          payloadJson: const Value('{}'),
          priority: const Value(20),
          createdAt: Value(DateTime(2026, 3, 30, 9, 0, 1)),
          updatedAt: Value(DateTime(2026, 3, 30, 9, 0, 1)),
        ),
      ]);

      await runner.bootstrap();
      final job = await _waitForTerminalJob(database, jobId);

      expect(job.state, DriveScanJobState.completed.value);
      expect(
        executionLog
            .where((entry) => entry.startsWith('tag:'))
            .take(2)
            .toList(),
        ['tag:track-pending-second', 'tag:track-repair-first'],
      );
    },
  );

  test(
    'bootstrap repairs ready tracks with an outdated metadata schema once',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
        metadataByDriveId: <String, DriveExtractedMetadata>{
          'track-repair': const DriveExtractedMetadata(
            title: '宇多田ヒカル',
            artist: '宇多田ヒカル',
            album: 'First Love',
            albumArtist: '宇多田ヒカル',
            genre: 'J-Pop',
            year: 1999,
            trackNumber: 1,
            discNumber: 1,
            durationMs: 180000,
          ),
        },
      );
      final artworkExtractor = _CountingArtworkExtractor(
        driveHttpClient: httpClient,
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: artworkExtractor,
        autoRun: true,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-repair',
        fileName: 'repair-me.mp3',
        title: 'Existing Title',
        md5Checksum: 'repair-md5',
        modifiedTime: DateTime(2026, 3, 22),
        metadataStatus: TrackMetadataStatus.ready.value,
        artworkStatus: TrackArtworkStatus.ready.value,
        metadataSchemaVersion: currentTrackMetadataSchemaVersion - 1,
      );

      await runner.bootstrap();
      await _waitForTrackMetadataSchemaVersion(
        database,
        'track-repair',
        currentTrackMetadataSchemaVersion,
      );

      final repairedTrack = await database.getTrackByDriveFileId(
        'track-repair',
      );

      expect(metadataExtractor.extractedDriveIds, ['track-repair']);
      expect(artworkExtractor.extractedDriveIds, isEmpty);
      expect(repairedTrack, isNotNull);
      expect(
        repairedTrack!.metadataSchemaVersion,
        currentTrackMetadataSchemaVersion,
      );
      expect(repairedTrack.title, '宇多田ヒカル');
      expect(repairedTrack.albumArtist, '宇多田ヒカル');
      expect(repairedTrack.artworkStatus, TrackArtworkStatus.ready.value);
    },
  );

  test(
    'enqueueSync deduplicates tag repair tasks for ready v2 tracks',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final logger = RecordingDriveScanLogger();
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        autoRun: false,
        logger: logger,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootId = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      await _seedTrack(
        database,
        rootId: rootId,
        driveFileId: 'track-repair-dedupe',
        fileName: 'repair-dedupe.mp3',
        title: 'Existing Title',
        md5Checksum: 'repair-dedupe-md5',
        modifiedTime: DateTime(2026, 3, 23),
        metadataStatus: TrackMetadataStatus.ready.value,
        artworkStatus: TrackArtworkStatus.ready.value,
        metadataSchemaVersion: currentTrackMetadataSchemaVersion - 1,
      );
      final existingJobId = await database.createScanJob(
        ScanJobsCompanion.insert(
          accountId: account.id,
          kind: DriveScanJobKind.incremental.value,
          state: DriveScanJobState.running.value,
          phase: DriveScanPhase.artworkEnrichment.value,
          checkpointToken: const Value('start-token'),
          startPageToken: const Value('start-token'),
        ),
      );
      await database.updateRootState(
        rootId,
        syncStateValue: DriveScanJobState.running.value,
        activeJobIdValue: existingJobId,
        lastErrorValue: null,
      );

      final firstJobId = await runner.enqueueSync();
      final secondJobId = await runner.enqueueSync();
      final job = await database.getScanJobById(existingJobId);
      final taskCount = await _countTasksOfKind(
        database,
        DriveScanTaskKind.extractTags.value,
      );

      expect(firstJobId, existingJobId);
      expect(secondJobId, existingJobId);
      expect(job, isNotNull);
      expect(job!.phase, DriveScanPhase.metadataEnrichment.value);
      expect(taskCount, 1);
      expect(logger.containsOperation('metadata_catchup_tasks_merged'), isTrue);
    },
  );

  test(
    'bootstrap creates a metadata catch-up job for pending tracks across all roots',
    () async {
      final httpClient = _FakeDriveHttpClient();
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
        ),
        autoRun: true,
      );
      final account = await _seedAccount(
        database,
        driveStartPageToken: 'start-token',
      );
      final rootA = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-a',
        folderName: 'A',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      final rootB = await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-b',
        folderName: 'B',
        lastSyncedAt: DateTime(2026, 3, 1),
      );
      await _seedTrack(
        database,
        rootId: rootA,
        driveFileId: 'track-pending-a',
        fileName: 'pending-a.mp3',
        title: 'Pending A',
        md5Checksum: 'pending-a-md5',
        modifiedTime: DateTime(2026, 3, 20),
        metadataStatus: TrackMetadataStatus.pending.value,
        artworkStatus: TrackArtworkStatus.pending.value,
      );
      await _seedTrack(
        database,
        rootId: rootB,
        driveFileId: 'track-pending-b',
        fileName: 'pending-b.mp3',
        title: 'Pending B',
        md5Checksum: 'pending-b-md5',
        modifiedTime: DateTime(2026, 3, 21),
        metadataStatus: TrackMetadataStatus.stale.value,
        artworkStatus: TrackArtworkStatus.pending.value,
      );
      await _seedTrack(
        database,
        rootId: rootB,
        driveFileId: 'track-failed',
        fileName: 'failed.mp3',
        title: 'Failed',
        md5Checksum: 'failed-md5',
        modifiedTime: DateTime(2026, 3, 22),
        metadataStatus: TrackMetadataStatus.failed.value,
        artworkStatus: TrackArtworkStatus.pending.value,
      );

      await runner.bootstrap();
      await _waitForTrackMetadataStatus(
        database,
        'track-pending-a',
        TrackMetadataStatus.ready.value,
      );
      await _waitForTrackMetadataStatus(
        database,
        'track-pending-b',
        TrackMetadataStatus.ready.value,
      );

      final failedTrack = await database.getTrackByDriveFileId('track-failed');

      expect(metadataExtractor.extractedDriveIds.toSet(), {
        'track-pending-a',
        'track-pending-b',
        'track-failed',
      });
      expect(failedTrack, isNotNull);
      expect(failedTrack!.metadataStatus, TrackMetadataStatus.ready.value);
    },
  );

  test(
    'cancel during metadata phase cancels running work and drops in-flight results',
    () async {
      final httpClient = _FakeDriveHttpClient(
        folderPages: {
          _FakeDriveHttpClient.folderKey('root-folder', null): DriveFolderPage(
            items: <DriveObjectEntry>[
              _audioEntry(
                id: 'track-slow',
                name: 'slow.mp3',
                md5Checksum: 'md5-slow',
                modifiedTime: DateTime(2026, 3, 10),
              ),
            ],
            nextPageToken: null,
          ),
        },
      );
      final metadataExtractor = _CountingMetadataExtractor(
        driveHttpClient: httpClient,
        probeDelayByDriveId: const <String, Duration>{
          'track-slow': Duration(seconds: 2),
        },
      );
      final runner = _buildRunner(
        database: database,
        httpClient: httpClient,
        metadataExtractor: metadataExtractor,
        artworkExtractor: _CountingArtworkExtractor(
          driveHttpClient: httpClient,
        ),
        autoRun: true,
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 1,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
        ),
      );
      final account = await _seedAccount(database, driveStartPageToken: null);
      await _seedRoot(
        database,
        accountId: account.id,
        folderId: 'root-folder',
        folderName: 'Library',
        lastSyncedAt: null,
      );

      final jobId = await runner.enqueueSync();
      await _waitForActiveMetadataJob(database);
      await runner.cancelJob(jobId!);
      final job = await _waitForTerminalJob(database, jobId);
      final track = await database.getTrackByDriveFileId('track-slow');
      final activeTasks = await database
          .customSelect(
            '''
      SELECT COUNT(*) AS count
      FROM scan_tasks
      WHERE job_id = ?
        AND kind = ?
        AND state IN (?, ?)
      ''',
            variables: [
              Variable.withInt(jobId),
              Variable.withString(DriveScanTaskKind.extractTags.value),
              Variable.withString(DriveScanTaskState.queued.value),
              Variable.withString(DriveScanTaskState.running.value),
            ],
            readsFrom: {database.scanTasks},
          )
          .getSingle();

      expect(job.state, DriveScanJobState.canceled.value);
      expect(track, isNotNull);
      expect(track!.metadataStatus, isNot(TrackMetadataStatus.ready.value));
      expect(activeTasks.read<int>('count'), 0);
    },
  );

  test('cancel during artwork phase drops in-flight artwork updates', () async {
    final httpClient = _FakeDriveHttpClient(
      folderPages: {
        _FakeDriveHttpClient.folderKey('root-folder', null): DriveFolderPage(
          items: <DriveObjectEntry>[
            _audioEntry(
              id: 'track-artwork-slow',
              name: 'artwork-slow.mp3',
              md5Checksum: 'md5-artwork-slow',
              modifiedTime: DateTime(2026, 3, 10),
            ),
          ],
          nextPageToken: null,
        ),
      },
    );
    final runner = _buildRunner(
      database: database,
      httpClient: httpClient,
      metadataExtractor: _CountingMetadataExtractor(
        driveHttpClient: httpClient,
      ),
      artworkExtractor: _CountingArtworkExtractor(
        driveHttpClient: httpClient,
        delayByDriveId: const <String, Duration>{
          'track-artwork-slow': Duration(seconds: 2),
        },
      ),
      autoRun: true,
      executionProfile: const DriveScanExecutionProfile(
        changeWorkers: 1,
        discoveryWorkers: 1,
        metadataWorkers: 1,
        artworkWorkers: 1,
        artworkWorkersWhileMetadataPending: 0,
        metadataHighWatermark: 0,
        pageSize: 1000,
        trackProjectionBatchSize: 500,
      ),
    );
    final account = await _seedAccount(database, driveStartPageToken: null);
    await _seedRoot(
      database,
      accountId: account.id,
      folderId: 'root-folder',
      folderName: 'Library',
      lastSyncedAt: null,
    );

    final jobId = await runner.enqueueSync();
    await _waitForActiveArtworkJob(database);
    await runner.cancelJob(jobId!);
    final job = await _waitForTerminalJob(database, jobId);
    final track = await database.getTrackByDriveFileId('track-artwork-slow');

    expect(job.state, DriveScanJobState.canceled.value);
    expect(track, isNotNull);
    expect(track!.artworkStatus, isNot(TrackArtworkStatus.ready.value));
  });
}

DriveScanRunner _buildRunner({
  required AppDatabase database,
  required DriveHttpClient httpClient,
  DriveMetadataExtractor? metadataExtractor,
  DriveArtworkExtractor? artworkExtractor,
  required bool autoRun,
  DriveScanExecutionProfile? executionProfile,
  DriveScanLogger logger = const NoOpDriveScanLogger(),
}) {
  final phaseCodec = const DriveScanPhaseCodec();
  final rootResolver = DriveScanRootResolver(database: database);
  final rootBinder = DriveScanRootBinder(
    database: database,
    phaseCodec: phaseCodec,
  );
  final catchUpPlanner = DriveMetadataCatchUpPlanner(
    database: database,
    rootResolver: rootResolver,
    rootBinder: rootBinder,
    logger: logger,
  );
  final jobEnqueuer = DriveScanJobEnqueuer(
    database: database,
    rootResolver: rootResolver,
    rootBinder: rootBinder,
    catchUpPlanner: catchUpPlanner,
    logger: logger,
  );
  final trackCacheService = DriveTrackCacheService(
    database: database,
    driveHttpClient: httpClient,
  );
  final progressRefresher = DriveScanProgressRefresher(
    database: database,
    rootResolver: rootResolver,
    logger: logger,
  );
  final metadataOrchestrator = DriveMetadataOrchestrator(
    database: database,
    metadataExtractor:
        metadataExtractor ??
        _CountingMetadataExtractor(driveHttpClient: httpClient),
    executionProfile:
        executionProfile ??
        const DriveScanExecutionProfile(
          changeWorkers: 2,
          discoveryWorkers: 8,
          metadataWorkers: 3,
          artworkWorkers: 2,
          artworkWorkersWhileMetadataPending: 1,
          metadataHighWatermark: 4,
          pageSize: 1000,
          trackProjectionBatchSize: 500,
        ),
    progressRefresher: progressRefresher,
    logger: logger,
  );
  final artworkService = DriveArtworkService(
    database: database,
    artworkExtractor:
        artworkExtractor ??
        _CountingArtworkExtractor(driveHttpClient: httpClient),
    trackCacheService: trackCacheService,
    logger: logger,
  );
  final lifecycle = DriveScanJobLifecycle(
    database: database,
    driveHttpClient: httpClient,
    rootResolver: rootResolver,
    metadataOrchestrator: metadataOrchestrator,
    progressRefresher: progressRefresher,
    artworkService: artworkService,
    logger: logger,
  );
  final resolvedExecutionProfile =
      executionProfile ??
      const DriveScanExecutionProfile(
        changeWorkers: 2,
        discoveryWorkers: 8,
        metadataWorkers: 3,
        artworkWorkers: 2,
        artworkWorkersWhileMetadataPending: 1,
        metadataHighWatermark: 4,
        pageSize: 1000,
        trackProjectionBatchSize: 500,
      );
  return DriveScanRunner(
    database: database,
    jobEnqueuer: jobEnqueuer,
    catchUpPlanner: catchUpPlanner,
    jobLifecycle: lifecycle,
    phaseExecutor: DriveScanPhaseExecutor(
      database: database,
      phaseCodec: phaseCodec,
      discoveryService: DriveDiscoveryService(
        database: database,
        driveHttpClient: httpClient,
        trackProjector: DriveTrackProjector(
          database: database,
          trackCacheService: trackCacheService,
        ),
        trackCacheService: trackCacheService,
        executionProfile: resolvedExecutionProfile,
        metadataCatchUpPlanner: catchUpPlanner,
        logger: logger,
      ),
      metadataOrchestrator: metadataOrchestrator,
      artworkService: artworkService,
      jobLifecycle: lifecycle,
      progressRefresher: progressRefresher,
      executionProfile: resolvedExecutionProfile,
      logger: logger,
    ),
    autoRun: autoRun,
    logger: logger,
  );
}

Future<SyncAccount> _seedAccount(
  AppDatabase database, {
  required String? driveStartPageToken,
  String authKind = 'test',
}) async {
  await database.setActiveAccount(
    SyncAccountsCompanion.insert(
      providerAccountId: 'account-1',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: authKind,
      connectedAt: DateTime(2026, 3, 30),
      isActive: const Value(true),
      driveStartPageToken: Value(driveStartPageToken),
      driveChangePageToken: Value(driveStartPageToken),
    ),
  );

  final account = await database.getActiveAccount();
  expect(account, isNotNull);
  return account!;
}

Future<int> _seedRoot(
  AppDatabase database, {
  required int accountId,
  required String folderId,
  required String folderName,
  required DateTime? lastSyncedAt,
}) {
  return database.upsertRoot(
    SyncRootsCompanion.insert(
      accountId: accountId,
      folderId: folderId,
      folderName: folderName,
      parentFolderId: const Value('root'),
      syncState: Value(DriveScanJobState.completed.value),
      lastSyncedAt: Value(lastSyncedAt),
    ),
  );
}

Future<void> _seedTrack(
  AppDatabase database, {
  required int rootId,
  required String driveFileId,
  required String fileName,
  required String title,
  required String md5Checksum,
  required DateTime modifiedTime,
  required String metadataStatus,
  required String artworkStatus,
  int metadataSchemaVersion = currentTrackMetadataSchemaVersion,
}) {
  return database.upsertTrack(
    TracksCompanion.insert(
      rootId: rootId,
      driveFileId: driveFileId,
      fileName: fileName,
      title: title,
      artist: 'Existing Artist',
      album: 'Existing Album',
      albumArtist: 'Existing Album Artist',
      genre: 'Existing Genre',
      year: const Value(2024),
      trackNumber: const Value(1),
      discNumber: const Value(1),
      durationMs: const Value(180000),
      mimeType: 'audio/mpeg',
      sizeBytes: const Value(1024),
      md5Checksum: Value(md5Checksum),
      modifiedTime: Value(modifiedTime),
      artworkStatus: Value(artworkStatus),
      metadataStatus: Value(metadataStatus),
      metadataSchemaVersion: Value(metadataSchemaVersion),
      indexStatus: Value(TrackIndexStatus.active.value),
      contentFingerprint: Value(
        buildContentFingerprint(
          md5Checksum: md5Checksum,
          sizeBytes: 1024,
          modifiedTime: modifiedTime,
        ),
      ),
    ),
  );
}

DriveObjectEntry _audioEntry({
  required String id,
  required String name,
  required String md5Checksum,
  required DateTime modifiedTime,
}) {
  return DriveObjectEntry(
    id: id,
    name: name,
    mimeType: 'audio/mpeg',
    modifiedTime: modifiedTime,
    resourceKey: null,
    sizeBytes: 1024,
    md5Checksum: md5Checksum,
    parentIds: const ['root-folder'],
  );
}

Future<ScanJob> _waitForTerminalJob(AppDatabase database, int jobId) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final job = await database.getScanJobById(jobId);
    if (job != null &&
        !{
          DriveScanJobState.queued.value,
          DriveScanJobState.running.value,
          DriveScanJobState.cancelRequested.value,
        }.contains(job.state)) {
      return job;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('Timed out waiting for scan job $jobId to finish.');
}

Future<ScanJob> _waitForLatestTerminalJob(AppDatabase database) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final job = await database.getLatestActiveScanJob();
    if (job == null) {
      final latest = await database
          .customSelect(
            '''
        SELECT *
        FROM scan_jobs
        ORDER BY created_at DESC
        LIMIT 1
        ''',
            readsFrom: {database.scanJobs},
          )
          .getSingleOrNull();
      if (latest != null) {
        final jobId = latest.read<int>('id');
        final resolved = await database.getScanJobById(jobId);
        if (resolved != null &&
            !{
              DriveScanJobState.queued.value,
              DriveScanJobState.running.value,
              DriveScanJobState.cancelRequested.value,
            }.contains(resolved.state)) {
          return resolved;
        }
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('Timed out waiting for the latest scan job to finish.');
}

Future<ScanJob> _waitForActiveMetadataJob(AppDatabase database) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final job = await database.getLatestActiveScanJob();
    if (job != null && job.phase == DriveScanPhase.metadataEnrichment.value) {
      return job;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('Timed out waiting for an active metadata job.');
}

Future<ScanJob> _waitForActiveArtworkJob(AppDatabase database) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final job = await database.getLatestActiveScanJob();
    if (job != null && job.phase == DriveScanPhase.artworkEnrichment.value) {
      return job;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('Timed out waiting for an active artwork job.');
}

Future<bool> _waitForMetadataPipelineOverlap(int jobId) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final snapshot = MetadataPipelineTelemetryHub.instance.snapshotForJob(
      jobId,
    );
    final headBusy = snapshot.fetch.runningCount > 0;
    final downstreamActive =
        snapshot.parse.runningCount > 0 ||
        snapshot.flush.runningCount > 0 ||
        snapshot.parse.completedCount > 0 ||
        snapshot.flush.completedCount > 0;
    if (headBusy && downstreamActive) {
      return true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  return false;
}

Future<bool> _waitForMetadataSourceRefill(int jobId) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final snapshot = MetadataPipelineTelemetryHub.instance.snapshotForJob(
      jobId,
    );
    final activeRuntime =
        snapshot.fetch.runningCount +
        snapshot.parse.runningCount +
        snapshot.flush.runningCount;
    final sourceAdmittedCount =
        snapshot.sourceQueuedCount + snapshot.sourceRunningCount;
    if (sourceAdmittedCount > 2 && activeRuntime > 0) {
      return true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  return false;
}

Future<(String?, DateTime)?> _waitForRunningTaskLease(
  AppDatabase database,
  String driveFileId,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final lease = await _readRunningTaskLease(database, driveFileId);
    if (lease != null && lease.$1 != null) {
      return lease;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  return null;
}

Future<(String?, DateTime)?> _readRunningTaskLease(
  AppDatabase database,
  String driveFileId,
) async {
  final row = await database
      .customSelect(
        '''
      SELECT runtime_stage, updated_at
      FROM scan_tasks
      WHERE target_drive_id = ?
        AND state = ?
      ORDER BY id DESC
      LIMIT 1
      ''',
        variables: [
          Variable.withString(driveFileId),
          Variable.withString(DriveScanTaskState.running.value),
        ],
        readsFrom: {database.scanTasks},
      )
      .getSingleOrNull();
  if (row == null) {
    return null;
  }
  return (row.read<String?>('runtime_stage'), row.read<DateTime>('updated_at'));
}

class _ActiveExtractTagTaskState {
  const _ActiveExtractTagTaskState({
    required this.id,
    required this.state,
    required this.runtimeStage,
    required this.updatedAt,
  });

  final int id;
  final String state;
  final String? runtimeStage;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) {
    return other is _ActiveExtractTagTaskState &&
        other.id == id &&
        other.state == state &&
        other.runtimeStage == runtimeStage &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, state, runtimeStage, updatedAt);
}

Future<List<_ActiveExtractTagTaskState>> _readActiveExtractTagTaskStates(
  AppDatabase database,
  int jobId,
) async {
  final rows = await database
      .customSelect(
        '''
      SELECT id, state, runtime_stage, updated_at
      FROM scan_tasks
      WHERE job_id = ?
        AND kind = ?
        AND state = ?
      ORDER BY id ASC
      ''',
        variables: [
          Variable.withInt(jobId),
          Variable.withString(DriveScanTaskKind.extractTags.value),
          Variable.withString(DriveScanTaskState.running.value),
        ],
        readsFrom: {database.scanTasks},
      )
      .get();
  return rows
      .map(
        (row) => _ActiveExtractTagTaskState(
          id: row.read<int>('id'),
          state: row.read<String>('state'),
          runtimeStage: row.read<String?>('runtime_stage'),
          updatedAt: row.read<DateTime>('updated_at'),
        ),
      )
      .toList(growable: false);
}

Future<void> _waitForTrackMetadataSchemaVersion(
  AppDatabase database,
  String driveFileId,
  int metadataSchemaVersion,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final track = await database.getTrackByDriveFileId(driveFileId);
    if (track != null && track.metadataSchemaVersion == metadataSchemaVersion) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail(
    'Timed out waiting for $driveFileId to reach metadata schema version '
    '$metadataSchemaVersion.',
  );
}

Future<void> _waitForTrackMetadataStatus(
  AppDatabase database,
  String driveFileId,
  String metadataStatus,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final track = await database.getTrackByDriveFileId(driveFileId);
    if (track != null && track.metadataStatus == metadataStatus) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail(
    'Timed out waiting for $driveFileId to reach metadata status '
    '$metadataStatus.',
  );
}

class _FakeDriveHttpClient extends DriveHttpClient {
  _FakeDriveHttpClient({
    this.folderPages = const <String, DriveFolderPage>{},
    this.changePages = const <String, DriveChangePage>{},
    this.listFolderDelay = Duration.zero,
  }) : super(authRepository: _FakeAuthRepository());

  final Map<String, DriveFolderPage> folderPages;
  final Map<String, DriveChangePage> changePages;
  final Duration listFolderDelay;

  final List<String> requestedFolderPages = <String>[];
  int concurrentFolderRequests = 0;
  int maxConcurrentFolderRequests = 0;

  static String folderKey(String parentId, String? pageToken) {
    return '$parentId|${pageToken ?? ''}';
  }

  @override
  Future<DriveFolderPage> listFolderPage({
    required String parentId,
    String? pageToken,
    int pageSize = 1000,
  }) async {
    final key = folderKey(parentId, pageToken);
    requestedFolderPages.add(key);
    concurrentFolderRequests += 1;
    if (concurrentFolderRequests > maxConcurrentFolderRequests) {
      maxConcurrentFolderRequests = concurrentFolderRequests;
    }

    try {
      if (listFolderDelay > Duration.zero) {
        await Future<void>.delayed(listFolderDelay);
      }
      return folderPages[key] ??
          const DriveFolderPage(
            items: <DriveObjectEntry>[],
            nextPageToken: null,
          );
    } finally {
      concurrentFolderRequests -= 1;
    }
  }

  @override
  Future<String> getStartPageToken() async => 'start-token';

  @override
  Future<DriveChangePage> listChangesPage({
    required String pageToken,
    int pageSize = 1000,
  }) async {
    return changePages[pageToken] ??
        const DriveChangePage(
          changes: <DriveChangeEntry>[],
          nextPageToken: null,
          newStartPageToken: null,
        );
  }
}

class _FailingDriveHttpClient extends _FakeDriveHttpClient {
  _FailingDriveHttpClient({required this.error});

  final Object error;

  @override
  Future<DriveFolderPage> listFolderPage({
    required String parentId,
    String? pageToken,
    int pageSize = 1000,
  }) async {
    throw error;
  }
}

class _CountingMetadataExtractor extends DriveMetadataExtractor {
  _CountingMetadataExtractor({
    required super.driveHttpClient,
    this.executionLog,
    this.metadataByDriveId,
    this.probeDelayByDriveId = const <String, Duration>{},
    this.parseDelayByDriveId = const <String, Duration>{},
    this.pipelineBehaviorByDriveId = const <String, _FakePipelineBehavior>{},
  });

  final List<String> extractedDriveIds = <String>[];
  final List<String>? executionLog;
  final Map<String, DriveExtractedMetadata>? metadataByDriveId;
  final Map<String, Duration> probeDelayByDriveId;
  final Map<String, Duration> parseDelayByDriveId;
  final Map<String, _FakePipelineBehavior> pipelineBehaviorByDriveId;

  @override
  Future<Uint8List> fetchFullBytes(Track track) async {
    final probeDelay = probeDelayByDriveId[track.driveFileId] ?? Duration.zero;
    if (probeDelay > Duration.zero) {
      await Future<void>.delayed(probeDelay);
    }
    final behavior = pipelineBehaviorByDriveId[track.driveFileId];
    if (behavior != null && behavior.analyzeDelay > Duration.zero) {
      await Future<void>.delayed(behavior.analyzeDelay);
    }
    executionLog?.add('stage:${track.driveFileId}:fetch');
    return Uint8List.fromList(<int>[1, 2, 3, 4]);
  }

  @override
  Future<DriveExtractedMetadata> parseFullBytes({
    required Track track,
    required Uint8List bytes,
  }) async {
    final parseDelay = parseDelayByDriveId[track.driveFileId] ?? Duration.zero;
    if (parseDelay > Duration.zero) {
      await Future<void>.delayed(parseDelay);
    }
    final override = metadataByDriveId?[track.driveFileId];
    final extracted =
        override ??
        DriveExtractedMetadata(
          title: 'Parsed ${track.fileName}',
          artist: 'Parsed Artist',
          album: 'Parsed Album',
          albumArtist: 'Parsed Album Artist',
          genre: 'Parsed Genre',
          year: 2026,
          trackNumber: 1,
          discNumber: 1,
          durationMs: 180000,
        );
    extractedDriveIds.add(track.driveFileId);
    executionLog?.add('stage:${track.driveFileId}:parse');
    executionLog?.add('tag:${track.driveFileId}');
    return extracted;
  }

  @override
  Future<DriveExtractedMetadata> extract(
    Track track, {
    DriveDownloadDebugContext? debugContext,
  }) async {
    extractedDriveIds.add(track.driveFileId);
    executionLog?.add('tag:${track.driveFileId}');
    final override = metadataByDriveId?[track.driveFileId];
    if (override != null) {
      return override;
    }
    return DriveExtractedMetadata(
      title: 'Parsed ${track.fileName}',
      artist: 'Parsed Artist',
      album: 'Parsed Album',
      albumArtist: 'Parsed Album Artist',
      genre: 'Parsed Genre',
      year: 2026,
      trackNumber: 1,
      discNumber: 1,
      durationMs: 180000,
    );
  }

  @override
  DrivePreparedMetadataSession prepareSession(
    Track track, {
    DriveDownloadDebugContext? debugContext,
    bool Function()? shouldAbortRead,
  }) {
    final extracted =
        metadataByDriveId?[track.driveFileId] ??
        DriveExtractedMetadata(
          title: 'Parsed ${track.fileName}',
          artist: 'Parsed Artist',
          album: 'Parsed Album',
          albumArtist: 'Parsed Album Artist',
          genre: 'Parsed Genre',
          year: 2026,
          trackNumber: 1,
          discNumber: 1,
          durationMs: 180000,
        );
    final behavior = pipelineBehaviorByDriveId[track.driveFileId];
    return DrivePreparedMetadataSession(
      track: track,
      session: behavior == null
          ? _FakeMetadataPipelineSession(
              driveFileId: track.driveFileId,
              executionLog: executionLog,
              extracted: extracted,
              probeDelay:
                  probeDelayByDriveId[track.driveFileId] ?? Duration.zero,
              onParse: () => extractedDriveIds.add(track.driveFileId),
            )
          : _RetryingMetadataPipelineSession(
              driveFileId: track.driveFileId,
              executionLog: executionLog,
              extracted: extracted,
              behavior: behavior,
              onParse: () => extractedDriveIds.add(track.driveFileId),
            ),
      buildExtractedMetadata: (metadata) => DriveExtractedMetadata(
        title: metadata.title ?? extracted.title,
        artist: metadata.artist ?? extracted.artist,
        album: metadata.album ?? extracted.album,
        albumArtist: metadata.albumArtist ?? extracted.albumArtist,
        genre: metadata.genre ?? extracted.genre,
        year: metadata.year ?? extracted.year,
        trackNumber: metadata.trackNumber ?? extracted.trackNumber,
        discNumber: metadata.discNumber ?? extracted.discNumber,
        durationMs: metadata.durationMs ?? extracted.durationMs,
      ),
    );
  }
}

class _FakePipelineBehavior {
  const _FakePipelineBehavior({
    required this.formatKey,
    this.unresolvedAnalyzeCount = 0,
    this.analyzeDelay = Duration.zero,
  });

  final String formatKey;
  final int unresolvedAnalyzeCount;
  final Duration analyzeDelay;
}

class _FakeMetadataPipelineSession implements DriveMetadataPipelineSession {
  _FakeMetadataPipelineSession({
    required this.driveFileId,
    required this.extracted,
    required this.probeDelay,
    required this.onParse,
    this.executionLog,
  });

  final String driveFileId;
  final DriveExtractedMetadata extracted;
  final Duration probeDelay;
  final void Function() onParse;
  final List<String>? executionLog;

  @override
  AudioExtractionCapabilities get capabilities =>
      const AudioExtractionCapabilities(
        supportsMetadata: true,
        supportsArtwork: false,
        costClass: AudioExtractionCostClass.light,
        maxProbeBytes: 1024,
        maxPlannedRanges: 1,
      );

  @override
  String get formatKey => 'mp3';

  @override
  bool get isHeadAnalysisResolved => true;

  @override
  bool get canFetchMoreHeadBytes => false;

  @override
  int get fetchedHeadBytes => 0;

  @override
  int get headExpansionCount => 0;

  @override
  Future<void> fetch() async {}

  @override
  Future<void> plan() async {}

  @override
  Future<void> fetchHead() async {}

  @override
  Future<void> analyzeHead() async {
    if (probeDelay > Duration.zero) {
      await Future<void>.delayed(probeDelay);
    }
  }

  @override
  Future<void> probe() async {
    await fetchHead();
    await analyzeHead();
  }

  @override
  Future<ExtractedMetadata> parse() async {
    onParse();
    executionLog?.add('tag:$driveFileId');
    return ExtractedMetadata(
      title: extracted.title,
      artist: extracted.artist,
      album: extracted.album,
      albumArtist: extracted.albumArtist,
      genre: extracted.genre,
      year: extracted.year,
      trackNumber: extracted.trackNumber,
      discNumber: extracted.discNumber,
      durationMs: extracted.durationMs,
    );
  }
}

class _RetryingMetadataPipelineSession implements DriveMetadataPipelineSession {
  _RetryingMetadataPipelineSession({
    required this.driveFileId,
    required this.extracted,
    required this.behavior,
    required this.onParse,
    this.executionLog,
  });

  final String driveFileId;
  final DriveExtractedMetadata extracted;
  final _FakePipelineBehavior behavior;
  final void Function() onParse;
  final List<String>? executionLog;

  int _fetchHeadCalls = 0;
  int _analyzeHeadCalls = 0;
  bool _resolved = false;

  @override
  AudioExtractionCapabilities get capabilities =>
      const AudioExtractionCapabilities(
        supportsMetadata: true,
        supportsArtwork: false,
        costClass: AudioExtractionCostClass.light,
        maxProbeBytes: 1024,
        maxPlannedRanges: 1,
      );

  @override
  String get formatKey => behavior.formatKey;

  @override
  bool get isHeadAnalysisResolved => _resolved;

  @override
  bool get canFetchMoreHeadBytes => !_resolved;

  @override
  int get fetchedHeadBytes => _fetchHeadCalls * 64 * 1024;

  @override
  int get headExpansionCount => _fetchHeadCalls;

  @override
  Future<void> fetch() async {
    executionLog?.add('stage:$driveFileId:fetch');
  }

  @override
  Future<void> plan() async {
    executionLog?.add('stage:$driveFileId:plan');
  }

  @override
  Future<void> fetchHead() async {
    _fetchHeadCalls += 1;
    executionLog?.add('stage:$driveFileId:fetchHead:$_fetchHeadCalls');
  }

  @override
  Future<void> analyzeHead() async {
    if (behavior.analyzeDelay > Duration.zero) {
      await Future<void>.delayed(behavior.analyzeDelay);
    }
    _analyzeHeadCalls += 1;
    final unresolved = _analyzeHeadCalls <= behavior.unresolvedAnalyzeCount;
    _resolved = !unresolved;
    executionLog?.add(
      'stage:$driveFileId:analyzeHead:${unresolved ? 'unresolved' : 'resolved'}:$_analyzeHeadCalls',
    );
  }

  @override
  Future<void> probe() async {
    await fetchHead();
    await analyzeHead();
  }

  @override
  Future<ExtractedMetadata> parse() async {
    onParse();
    executionLog?.add('stage:$driveFileId:parse');
    return ExtractedMetadata(
      title: extracted.title,
      artist: extracted.artist,
      album: extracted.album,
      albumArtist: extracted.albumArtist,
      genre: extracted.genre,
      year: extracted.year,
      trackNumber: extracted.trackNumber,
      discNumber: extracted.discNumber,
      durationMs: extracted.durationMs,
    );
  }
}

class _CountingArtworkExtractor extends DriveArtworkExtractor {
  _CountingArtworkExtractor({
    required super.driveHttpClient,
    this.executionLog,
    this.delayByDriveId = const <String, Duration>{},
  });

  final List<String> extractedDriveIds = <String>[];
  final List<String>? executionLog;
  final Map<String, Duration> delayByDriveId;

  @override
  Future<DriveExtractedArtwork?> extract(
    Track track, {
    DriveDownloadDebugContext? debugContext,
  }) async {
    final delay = delayByDriveId[track.driveFileId] ?? Duration.zero;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    extractedDriveIds.add(track.driveFileId);
    executionLog?.add('art:${track.driveFileId}');
    return null;
  }
}

class _FakeAuthRepository implements DriveAuthRepository {
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

class _ExpiringAuthRepository implements DriveAuthRepository {
  _ExpiringAuthRepository({required this.database, required this.accountId});

  final AppDatabase database;
  final int accountId;
  var _didExpire = false;

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
  Future<T> withClient<T>(Future<T> Function(http.Client client) action) async {
    if (!_didExpire) {
      _didExpire = true;
      await database.markAccountReauthRequired(accountId);
    }
    throw const DriveAuthSessionExpiredException();
  }
}

Future<int> _countTasksOfKind(AppDatabase database, String kind) async {
  final row = await database
      .customSelect(
        '''
    SELECT COUNT(*) AS count
    FROM scan_tasks
    WHERE kind = ?
    ''',
        variables: [Variable.withString(kind)],
        readsFrom: {database.scanTasks},
      )
      .getSingle();
  return row.read<int>('count');
}

List<String> _stageEventsFor(List<String> executionLog, String driveFileId) {
  final prefix = 'stage:$driveFileId:';
  return executionLog
      .where((entry) => entry.startsWith(prefix))
      .map((entry) => entry.substring(prefix.length))
      .toList(growable: false);
}

Future<void> _waitForStageEvent(
  List<String> executionLog,
  String driveFileId,
  String expectedEvent,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    if (_stageEventsFor(executionLog, driveFileId).contains(expectedEvent)) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('Timed out waiting for $driveFileId to record $expectedEvent.');
}

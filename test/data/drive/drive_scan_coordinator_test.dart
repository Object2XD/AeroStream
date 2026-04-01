import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_artwork_extractor.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/drive_metadata_extractor.dart';
import 'package:aero_stream/data/drive/drive_scan_coordinator.dart';
import 'package:aero_stream/data/drive/drive_scan_execution_profile.dart';
import 'package:aero_stream/data/drive/drive_scan_logger.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_track_cache_service.dart';

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
      final coordinator = _buildCoordinator(
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

      final jobId = await coordinator.enqueueSync();
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
      final coordinator = _buildCoordinator(
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

      final jobId = await coordinator.enqueueSync();
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
    final coordinator = _buildCoordinator(
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

    final firstJobId = await coordinator.enqueueSync();
    final secondJobId = await coordinator.enqueueSync();
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
      final coordinator = _buildCoordinator(
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

      final jobId = await coordinator.enqueueSync();
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
      final coordinator = _buildCoordinator(
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

      final jobId = await coordinator.enqueueSync();
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
    final coordinator = _buildCoordinator(
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

    final jobId = await coordinator.enqueueSync();
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
      final coordinator = _buildCoordinator(
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

      final jobId = await coordinator.enqueueSync();
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
    final coordinator = _buildCoordinator(
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

    final jobId = await coordinator.enqueueSync();
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
    'metadata tasks are drained before artwork when artwork is low priority',
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
      final coordinator = _buildCoordinator(
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

      final jobId = await coordinator.enqueueSync();
      final job = await _waitForTerminalJob(database, jobId!);

      expect(job.state, DriveScanJobState.completed.value);
      expect(executionLog, [
        'tag:track-a',
        'tag:track-b',
        'art:track-a',
        'art:track-b',
      ]);
      expect(logger.containsOperation('artwork_deferred'), isTrue);
    },
  );

  test('job failure stores a short lastError and logs stack traces', () async {
    final logger = RecordingDriveScanLogger();
    final httpClient = _FailingDriveHttpClient(
      error: StateError('boom\nmore detail'),
    );
    final coordinator = _buildCoordinator(
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

    final jobId = await coordinator.enqueueSync();
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

  test('successful baseline scan logs phase and batch transitions', () async {
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
    final coordinator = _buildCoordinator(
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

    final jobId = await coordinator.enqueueSync();
    final job = await _waitForTerminalJob(database, jobId!);

    expect(job.state, DriveScanJobState.completed.value);
    expect(logger.containsOperation('job_enqueue'), isTrue);
    expect(logger.containsOperation('job_start'), isTrue);
    expect(logger.containsOperation('discovery_batch_start'), isTrue);
    expect(logger.containsOperation('discovery_page_complete'), isTrue);
    expect(logger.containsOperation('metadata_batch_complete'), isTrue);
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
    final coordinator = _buildCoordinator(
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

    final jobId = await coordinator.enqueueSync();
    final job = await _waitForTerminalJob(database, jobId!);

    expect(job.state, DriveScanJobState.completed.value);
    expect(logger.containsOperation('changes_page_start'), isTrue);
    expect(logger.containsOperation('changes_page_complete'), isTrue);
  });

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
      final coordinator = _buildCoordinator(
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

      await coordinator.bootstrap();
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
      final coordinator = _buildCoordinator(
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

      final firstJobId = await coordinator.enqueueSync();
      final secondJobId = await coordinator.enqueueSync();
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
      final coordinator = _buildCoordinator(
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

      await coordinator.bootstrap();
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
      });
      expect(failedTrack, isNotNull);
      expect(failedTrack!.metadataStatus, TrackMetadataStatus.failed.value);
    },
  );
}

DriveScanCoordinator _buildCoordinator({
  required AppDatabase database,
  required DriveHttpClient httpClient,
  DriveMetadataExtractor? metadataExtractor,
  DriveArtworkExtractor? artworkExtractor,
  required bool autoRun,
  DriveScanExecutionProfile? executionProfile,
  DriveScanLogger logger = const NoOpDriveScanLogger(),
}) {
  return DriveScanCoordinator(
    database: database,
    driveHttpClient: httpClient,
    metadataExtractor:
        metadataExtractor ??
        _CountingMetadataExtractor(driveHttpClient: httpClient),
    artworkExtractor:
        artworkExtractor ??
        _CountingArtworkExtractor(driveHttpClient: httpClient),
    trackCacheService: DriveTrackCacheService(
      database: database,
      driveHttpClient: httpClient,
    ),
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
    autoRun: autoRun,
    logger: logger,
  );
}

Future<SyncAccount> _seedAccount(
  AppDatabase database, {
  required String? driveStartPageToken,
}) async {
  await database.setActiveAccount(
    SyncAccountsCompanion.insert(
      providerAccountId: 'account-1',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: 'test',
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
  });

  final List<String> extractedDriveIds = <String>[];
  final List<String>? executionLog;
  final Map<String, DriveExtractedMetadata>? metadataByDriveId;

  @override
  Future<DriveExtractedMetadata> extract(Track track) async {
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
}

class _CountingArtworkExtractor extends DriveArtworkExtractor {
  _CountingArtworkExtractor({
    required super.driveHttpClient,
    this.executionLog,
  });

  final List<String> extractedDriveIds = <String>[];
  final List<String>? executionLog;

  @override
  Future<DriveExtractedArtwork?> extract(Track track) async {
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

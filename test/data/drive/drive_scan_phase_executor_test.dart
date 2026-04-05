import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_artwork_service.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/drive_metadata_catch_up_planner.dart';
import 'package:aero_stream/data/drive/drive_metadata_orchestrator.dart';
import 'package:aero_stream/data/drive/drive_scan_execution_profile.dart';
import 'package:aero_stream/data/drive/drive_scan_job_lifecycle.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_codec.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_executor.dart';
import 'package:aero_stream/data/drive/drive_scan_progress_refresher.dart';
import 'package:aero_stream/data/drive/drive_scan_root_binder.dart';
import 'package:aero_stream/data/drive/drive_scan_root_resolver.dart';
import 'package:aero_stream/data/drive/drive_track_cache_service.dart';
import 'package:aero_stream/data/drive/drive_discovery_service.dart';
import 'package:aero_stream/data/drive/drive_track_projector.dart';
import 'package:aero_stream/data/drive/extraction/drive_artwork_extractor.dart';
import 'package:aero_stream/data/drive/extraction/drive_metadata_extractor.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'test_drive_scan_logger.dart';

void main() {
  late AppDatabase database;
  late RecordingDriveScanLogger logger;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    logger = RecordingDriveScanLogger();
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'executeNextStep advances empty metadata phase to artwork enrichment',
    () async {
      final accountId = await _seedAccount(database);
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
      final progressRefresher = DriveScanProgressRefresher(
        database: database,
        rootResolver: rootResolver,
        logger: logger,
      );
      final metadataOrchestrator = DriveMetadataOrchestrator(
        database: database,
        metadataExtractor: DriveMetadataExtractor(
          driveHttpClient: DriveHttpClient(
            authRepository: _StubAuthRepository(),
          ),
        ),
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 1,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 100,
        ),
        progressRefresher: progressRefresher,
        logger: logger,
      );
      final lifecycle = DriveScanJobLifecycle(
        database: database,
        driveHttpClient: DriveHttpClient(authRepository: _StubAuthRepository()),
        rootResolver: rootResolver,
        metadataOrchestrator: metadataOrchestrator,
        progressRefresher: progressRefresher,
        artworkService: DriveArtworkService(
          database: database,
          artworkExtractor: DriveArtworkExtractor(
            driveHttpClient: DriveHttpClient(
              authRepository: _StubAuthRepository(),
            ),
          ),
          trackCacheService: DriveTrackCacheService(
            database: database,
            driveHttpClient: DriveHttpClient(
              authRepository: _StubAuthRepository(),
            ),
          ),
          logger: logger,
        ),
        logger: logger,
      );
      final executor = DriveScanPhaseExecutor(
        database: database,
        phaseCodec: phaseCodec,
        discoveryService: DriveDiscoveryService(
          database: database,
          driveHttpClient: DriveHttpClient(
            authRepository: _StubAuthRepository(),
          ),
          trackProjector: DriveTrackProjector(
            database: database,
            trackCacheService: DriveTrackCacheService(
              database: database,
              driveHttpClient: DriveHttpClient(
                authRepository: _StubAuthRepository(),
              ),
            ),
          ),
          trackCacheService: DriveTrackCacheService(
            database: database,
            driveHttpClient: DriveHttpClient(
              authRepository: _StubAuthRepository(),
            ),
          ),
          executionProfile: const DriveScanExecutionProfile(
            changeWorkers: 1,
            discoveryWorkers: 1,
            metadataWorkers: 1,
            artworkWorkers: 1,
            artworkWorkersWhileMetadataPending: 0,
            metadataHighWatermark: 0,
            pageSize: 1000,
            trackProjectionBatchSize: 100,
          ),
          metadataCatchUpPlanner: catchUpPlanner,
          logger: logger,
        ),
        metadataOrchestrator: metadataOrchestrator,
        artworkService: DriveArtworkService(
          database: database,
          artworkExtractor: DriveArtworkExtractor(
            driveHttpClient: DriveHttpClient(
              authRepository: _StubAuthRepository(),
            ),
          ),
          trackCacheService: DriveTrackCacheService(
            database: database,
            driveHttpClient: DriveHttpClient(
              authRepository: _StubAuthRepository(),
            ),
          ),
          logger: logger,
        ),
        jobLifecycle: lifecycle,
        progressRefresher: progressRefresher,
        executionProfile: const DriveScanExecutionProfile(
          changeWorkers: 1,
          discoveryWorkers: 1,
          metadataWorkers: 1,
          artworkWorkers: 1,
          artworkWorkersWhileMetadataPending: 0,
          metadataHighWatermark: 0,
          pageSize: 1000,
          trackProjectionBatchSize: 100,
        ),
        logger: logger,
      );
      final jobId = await database.createScanJob(
        ScanJobsCompanion.insert(
          accountId: accountId,
          kind: DriveScanJobKind.incremental.value,
          state: DriveScanJobState.running.value,
          phase: DriveScanPhase.metadataEnrichment.value,
        ),
      );

      final result = await executor.executeNextStep(
        (await database.getScanJobById(jobId))!,
      );
      final updated = (await database.getScanJobById(jobId))!;

      expect(result.isTerminal, isFalse);
      expect(updated.phase, DriveScanPhase.artworkEnrichment.value);
      expect(logger.containsOperation('phase_complete'), isTrue);
    },
  );
}

Future<int> _seedAccount(AppDatabase database) async {
  await database.setActiveAccount(
    SyncAccountsCompanion.insert(
      providerAccountId: 'account-1',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: 'oauth_desktop',
      connectedAt: DateTime(2026, 4, 1),
    ),
  );
  return (await database.getActiveAccount())!.id;
}

class _StubAuthRepository implements DriveAuthRepository {
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

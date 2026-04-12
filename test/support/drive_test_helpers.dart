import 'package:aero_stream/core/providers/drive/drive_providers.dart';
import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_artwork_service.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_discovery_service.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/drive_library_repository.dart';
import 'package:aero_stream/data/drive/drive_metadata_catch_up_planner.dart';
import 'package:aero_stream/data/drive/drive_metadata_orchestrator.dart';
import 'package:aero_stream/data/drive/drive_scan_execution_profile.dart';
import 'package:aero_stream/data/drive/drive_scan_job_enqueuer.dart';
import 'package:aero_stream/data/drive/drive_scan_job_lifecycle.dart';
import 'package:aero_stream/data/drive/drive_scan_logger.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_codec.dart';
import 'package:aero_stream/data/drive/drive_scan_phase_executor.dart';
import 'package:aero_stream/data/drive/drive_scan_progress_refresher.dart';
import 'package:aero_stream/data/drive/drive_scan_root_binder.dart';
import 'package:aero_stream/data/drive/drive_scan_root_resolver.dart';
import 'package:aero_stream/data/drive/drive_scan_runner.dart';
import 'package:aero_stream/data/drive/drive_track_cache_service.dart';
import 'package:aero_stream/data/drive/drive_track_projector.dart';
import 'package:aero_stream/data/drive/extraction/drive_artwork_extractor.dart';
import 'package:aero_stream/data/drive/extraction/drive_metadata_extractor.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:http/http.dart' as http;

AppDatabase makeTestDatabase() => AppDatabase(NativeDatabase.memory());

DriveWorkspaceState buildWorkspaceState({
  bool isConfigured = true,
  DriveAccountProfile? account = const DriveAccountProfile(
    providerAccountId: 'drive-account',
    email: 'listener@example.com',
    displayName: 'Listener',
    authKind: 'oauth_desktop',
  ),
  bool hasLinkedAccount = true,
  bool canAccessDrive = true,
  bool requiresReconnect = false,
  String? authErrorMessage,
  List<SyncRoot> roots = const <SyncRoot>[],
  int cacheSizeBytes = 0,
  DriveSyncProgress? syncProgress,
  bool isMutating = false,
  String? configurationMessage,
  String? errorMessage,
}) {
  return DriveWorkspaceState(
    isConfigured: isConfigured,
    account: account,
    hasLinkedAccount: hasLinkedAccount,
    canAccessDrive: canAccessDrive,
    requiresReconnect: requiresReconnect,
    authErrorMessage: authErrorMessage,
    roots: roots,
    cacheSizeBytes: cacheSizeBytes,
    syncProgress: syncProgress,
    isMutating: isMutating,
    configurationMessage: configurationMessage,
    errorMessage: errorMessage,
  );
}

SyncRoot buildRoot({
  int id = 1,
  int accountId = 1,
  String folderId = 'folder-1',
  String folderName = 'google_play_music',
  String syncState = 'running',
  DateTime? lastSyncedAt,
  String? lastError,
  int indexedCount = 93046,
  int metadataReadyCount = 5247,
  int artworkReadyCount = 73,
  int failedCount = 0,
}) {
  return SyncRoot(
    id: id,
    accountId: accountId,
    folderId: folderId,
    folderName: folderName,
    parentFolderId: null,
    syncState: syncState,
    lastSyncedAt: lastSyncedAt,
    lastError: lastError,
    activeJobId: null,
    indexedCount: indexedCount,
    metadataReadyCount: metadataReadyCount,
    artworkReadyCount: artworkReadyCount,
    failedCount: failedCount,
  );
}

ScanJob buildScanJob({
  int id = 42,
  int accountId = 1,
  int? rootId,
  String kind = 'baseline',
  required String state,
  required String phase,
  DateTime? startedAt,
  int indexedCount = 0,
  int metadataReadyCount = 0,
  int artworkReadyCount = 0,
  int failedCount = 0,
}) {
  return ScanJob(
    id: id,
    accountId: accountId,
    rootId: rootId,
    kind: kind,
    state: state,
    phase: phase,
    checkpointToken: null,
    startPageToken: null,
    indexedCount: indexedCount,
    metadataReadyCount: metadataReadyCount,
    artworkReadyCount: artworkReadyCount,
    failedCount: failedCount,
    lastError: null,
    createdAt: startedAt ?? DateTime(2026, 4, 4, 0, 0, 0),
    startedAt: startedAt,
    finishedAt: null,
  );
}

class FixedDriveWorkspaceNotifier extends DriveWorkspaceNotifier {
  FixedDriveWorkspaceNotifier(this.fixedState);

  final DriveWorkspaceState fixedState;
  int buildCallCount = 0;

  @override
  Future<DriveWorkspaceState> build() async {
    buildCallCount += 1;
    return fixedState;
  }
}

class NoOpDriveAuthRepository implements DriveAuthRepository {
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

class FakeDriveAuthRepository implements DriveAuthRepository {
  FakeDriveAuthRepository({required this.restoreSessionResult});

  final DriveAccountProfile? restoreSessionResult;
  int restoreCallCount = 0;

  @override
  bool get isConfigured => true;

  @override
  String? get configurationMessage => null;

  @override
  Future<DriveAccountProfile?> restoreSession() async {
    restoreCallCount += 1;
    return restoreSessionResult;
  }

  @override
  Future<DriveAccountProfile> connect() async {
    return const DriveAccountProfile(
      providerAccountId: 'drive-account',
      email: 'listener@example.com',
      displayName: 'Listener',
      authKind: 'oauth_desktop',
    );
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<T> withClient<T>(Future<T> Function(http.Client client) action) {
    throw UnimplementedError();
  }
}

class PassiveDriveAuthRepository implements DriveAuthRepository {
  @override
  bool get isConfigured => true;

  @override
  String? get configurationMessage => null;

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

class ExpiredSessionDriveHttpClient extends DriveHttpClient {
  ExpiredSessionDriveHttpClient()
    : super(authRepository: PassiveDriveAuthRepository());

  @override
  Future<List<DriveFolderEntry>> listFolders({String parentId = 'root'}) async {
    throw const DriveAuthSessionExpiredException();
  }

  @override
  Future<Map<String, dynamic>> getFolderMetadata(String folderId) async {
    throw const DriveAuthSessionExpiredException();
  }
}

class RecordingDriveScanRunner extends DriveScanRunner {
  RecordingDriveScanRunner({
    required AppDatabase database,
    required DriveAuthRepository authRepository,
  }) : this._internal(
         database: database,
         graph: _buildRunnerGraph(database, authRepository),
       );

  RecordingDriveScanRunner._internal({
    required AppDatabase database,
    required _RunnerGraph graph,
  }) : super(
         database: database,
         jobEnqueuer: graph.jobEnqueuer,
         catchUpPlanner: graph.catchUpPlanner,
         jobLifecycle: graph.jobLifecycle,
         phaseExecutor: graph.phaseExecutor,
         logger: const NoOpDriveScanLogger(),
         autoRun: false,
       );

  int bootstrapCallCount = 0;
  int enqueueCallCount = 0;
  final List<int> canceledJobIds = <int>[];

  @override
  Future<void> bootstrap() async {
    bootstrapCallCount += 1;
  }

  @override
  Future<int?> enqueueSync({int? rootId}) async {
    enqueueCallCount += 1;
    return null;
  }

  @override
  Future<void> cancelJob(int jobId) async {
    canceledJobIds.add(jobId);
  }
}

class _RunnerGraph {
  const _RunnerGraph({
    required this.jobEnqueuer,
    required this.catchUpPlanner,
    required this.jobLifecycle,
    required this.phaseExecutor,
  });

  final DriveScanJobEnqueuer jobEnqueuer;
  final DriveMetadataCatchUpPlanner catchUpPlanner;
  final DriveScanJobLifecycle jobLifecycle;
  final DriveScanPhaseExecutor phaseExecutor;
}

_RunnerGraph _buildRunnerGraph(
  AppDatabase database,
  DriveAuthRepository authRepository,
) {
  const logger = NoOpDriveScanLogger();
  const executionProfile = DriveScanExecutionProfile(
    changeWorkers: 1,
    discoveryWorkers: 1,
    metadataWorkers: 1,
    artworkWorkers: 1,
    artworkWorkersWhileMetadataPending: 0,
    metadataHighWatermark: 0,
    pageSize: 1000,
    trackProjectionBatchSize: 100,
  );
  final httpClient = DriveHttpClient(authRepository: authRepository);
  final trackCacheService = DriveTrackCacheService(
    database: database,
    driveHttpClient: httpClient,
  );
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
  final progressRefresher = DriveScanProgressRefresher(
    database: database,
    rootResolver: rootResolver,
    logger: logger,
  );
  final metadataOrchestrator = DriveMetadataOrchestrator(
    database: database,
    metadataExtractor: DriveMetadataExtractor(driveHttpClient: httpClient),
    executionProfile: executionProfile,
    progressRefresher: progressRefresher,
    logger: logger,
  );
  final artworkService = DriveArtworkService(
    database: database,
    artworkExtractor: DriveArtworkExtractor(driveHttpClient: httpClient),
    trackCacheService: trackCacheService,
    logger: logger,
  );
  final jobLifecycle = DriveScanJobLifecycle(
    database: database,
    driveHttpClient: httpClient,
    rootResolver: rootResolver,
    metadataOrchestrator: metadataOrchestrator,
    progressRefresher: progressRefresher,
    artworkService: artworkService,
    logger: logger,
  );
  final phaseExecutor = DriveScanPhaseExecutor(
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
      executionProfile: executionProfile,
      metadataCatchUpPlanner: catchUpPlanner,
      logger: logger,
    ),
    metadataOrchestrator: metadataOrchestrator,
    artworkService: artworkService,
    jobLifecycle: jobLifecycle,
    progressRefresher: progressRefresher,
    executionProfile: executionProfile,
    logger: logger,
  );
  return _RunnerGraph(
    jobEnqueuer: jobEnqueuer,
    catchUpPlanner: catchUpPlanner,
    jobLifecycle: jobLifecycle,
    phaseExecutor: phaseExecutor,
  );
}

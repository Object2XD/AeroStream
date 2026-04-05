import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/drive_oauth_config.dart';
import '../../../core/providers/runtime_mode_provider.dart';
import '../../../data/database/app_database.dart';
import '../../../data/drive/drive_auth_repository.dart';
import '../../../data/drive/drive_entities.dart';
import '../../../data/drive/drive_scan_backlog.dart';
import '../../../data/drive/drive_artwork_service.dart';
import '../../../data/drive/drive_discovery_service.dart';
import '../../../data/drive/drive_metadata_orchestrator.dart';
import '../../../data/drive/metadata_pipeline_backlog.dart';
import '../../../data/drive/drive_http_client.dart';
import '../../../data/drive/drive_library_repository.dart';
import '../../../data/drive/drive_metadata_catch_up_planner.dart';
import '../../../data/drive/drive_scan_job_lifecycle.dart';
import '../../../data/drive/drive_scan_job_enqueuer.dart';
import '../../../data/drive/drive_scan_logger.dart';
import '../../../data/drive/drive_scan_phase_codec.dart';
import '../../../data/drive/drive_scan_phase_executor.dart';
import '../../../data/drive/drive_scan_progress_refresher.dart';
import '../../../data/drive/drive_scan_root_binder.dart';
import '../../../data/drive/drive_scan_root_resolver.dart';
import '../../../data/drive/extraction/drive_artwork_extractor.dart';
import '../../../data/drive/extraction/drive_metadata_extractor.dart';
import '../../../data/drive/drive_scan_runner.dart';
import '../../../data/drive/drive_scan_execution_profile.dart';
import '../../../data/drive/drive_scan_models.dart';
import '../../../data/drive/drive_stream_proxy.dart';
import '../../../data/drive/drive_track_cache_service.dart';
import '../../../data/drive/drive_track_projector.dart';
import '../../../data/mock_library.dart';
import '../../../data/mock_media.dart';
import '../../../data/playback/playback_repository.dart';

final driveOAuthConfigProvider = Provider<DriveOAuthConfig>((ref) {
  return DriveOAuthConfig.fromEnvironment();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final driveAuthRepositoryProvider = Provider<DriveAuthRepository>((ref) {
  return PlatformDriveAuthRepository(
    config: ref.watch(driveOAuthConfigProvider),
    secureStorage: ref.watch(secureStorageProvider),
    logger: ref.watch(driveScanLoggerProvider),
  );
});

final driveScanLoggerProvider = Provider<DriveScanLogger>((ref) {
  return const ConsoleDriveScanLogger();
});

final scanSpeedTickIntervalProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 1);
});

final scanSpeedRollingWindowProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 30);
});

final driveHttpClientProvider = Provider<DriveHttpClient>((ref) {
  return DriveHttpClient(
    authRepository: ref.watch(driveAuthRepositoryProvider),
    logger: ref.watch(driveScanLoggerProvider),
  );
});

final driveLibraryRepositoryProvider = Provider<DriveLibraryRepository>((ref) {
  return DriveLibraryRepository(ref.watch(appDatabaseProvider));
});

final driveMetadataExtractorProvider = Provider<DriveMetadataExtractor>((ref) {
  return DriveMetadataExtractor(
    driveHttpClient: ref.watch(driveHttpClientProvider),
    logger: ref.watch(driveScanLoggerProvider),
  );
});

final driveArtworkExtractorProvider = Provider<DriveArtworkExtractor>((ref) {
  return DriveArtworkExtractor(
    driveHttpClient: ref.watch(driveHttpClientProvider),
    logger: ref.watch(driveScanLoggerProvider),
  );
});

final driveTrackCacheServiceProvider = Provider<DriveTrackCacheService>((ref) {
  return DriveTrackCacheService(
    database: ref.watch(appDatabaseProvider),
    driveHttpClient: ref.watch(driveHttpClientProvider),
  );
});

final driveScanExecutionProfileProvider = Provider<DriveScanExecutionProfile>((
  ref,
) {
  final isDesktopPlatform =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  return DriveScanExecutionProfile(
    changeWorkers: isDesktopPlatform ? 2 : 1,
    discoveryWorkers: isDesktopPlatform ? 8 : 3,
    metadataWorkers: isDesktopPlatform ? 6 : 2,
    metadataFetchWorkers: isDesktopPlatform ? 80 : null,
    metadataParseWorkers: isDesktopPlatform ? 4 : null,
    artworkWorkers: isDesktopPlatform ? 2 : 1,
    artworkWorkersWhileMetadataPending: 1,
    metadataHighWatermark: isDesktopPlatform ? 8 : 3,
    pageSize: 1000,
    trackProjectionBatchSize: 500,
  );
});

final driveScanRunnerProvider = Provider<DriveScanRunner>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final driveHttpClient = ref.watch(driveHttpClientProvider);
  final metadataExtractor = ref.watch(driveMetadataExtractorProvider);
  final artworkExtractor = ref.watch(driveArtworkExtractorProvider);
  final trackCacheService = ref.watch(driveTrackCacheServiceProvider);
  final executionProfile = ref.watch(driveScanExecutionProfileProvider);
  final logger = ref.watch(driveScanLoggerProvider);

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
  final discoveryService = DriveDiscoveryService(
    database: database,
    driveHttpClient: driveHttpClient,
    trackProjector: DriveTrackProjector(
      database: database,
      trackCacheService: trackCacheService,
    ),
    trackCacheService: trackCacheService,
    executionProfile: executionProfile,
    metadataCatchUpPlanner: catchUpPlanner,
    logger: logger,
  );
  final artworkService = DriveArtworkService(
    database: database,
    artworkExtractor: artworkExtractor,
    trackCacheService: trackCacheService,
    logger: logger,
  );
  final progressRefresher = DriveScanProgressRefresher(
    database: database,
    rootResolver: rootResolver,
    logger: logger,
  );
  final metadataOrchestrator = DriveMetadataOrchestrator(
    database: database,
    metadataExtractor: metadataExtractor,
    executionProfile: executionProfile,
    progressRefresher: progressRefresher,
    logger: logger,
  );
  final jobLifecycle = DriveScanJobLifecycle(
    database: database,
    driveHttpClient: driveHttpClient,
    rootResolver: rootResolver,
    metadataOrchestrator: metadataOrchestrator,
    progressRefresher: progressRefresher,
    artworkService: artworkService,
    logger: logger,
  );
  final phaseExecutor = DriveScanPhaseExecutor(
    database: database,
    phaseCodec: phaseCodec,
    discoveryService: discoveryService,
    metadataOrchestrator: metadataOrchestrator,
    artworkService: artworkService,
    jobLifecycle: jobLifecycle,
    progressRefresher: progressRefresher,
    executionProfile: executionProfile,
    logger: logger,
  );
  return DriveScanRunner(
    database: database,
    jobEnqueuer: jobEnqueuer,
    catchUpPlanner: catchUpPlanner,
    jobLifecycle: jobLifecycle,
    phaseExecutor: phaseExecutor,
    logger: logger,
  );
});

final metadataPipelineBacklogProvider = StreamProvider.autoDispose
    .family<MetadataPipelineBacklog, int>((ref, jobId) async* {
      final hub = MetadataPipelineTelemetryHub.instance;
      yield hub.snapshotForJob(jobId);
      yield* hub.watchJob(jobId);
    });

final driveStreamProxyProvider = Provider<DriveStreamProxy>((ref) {
  final proxy = DriveStreamProxy(
    database: ref.watch(appDatabaseProvider),
    driveHttpClient: ref.watch(driveHttpClientProvider),
  );
  ref.onDispose(() => unawaited(proxy.stop()));
  return proxy;
});

final playbackRepositoryProvider = Provider<PlaybackRepository>((ref) {
  final repository = PlaybackRepository(
    database: ref.watch(appDatabaseProvider),
    libraryRepository: ref.watch(driveLibraryRepositoryProvider),
    driveStreamProxy: ref.watch(driveStreamProxyProvider),
    trackCacheService: ref.watch(driveTrackCacheServiceProvider),
  );
  ref.onDispose(() => unawaited(repository.dispose()));
  return repository;
});

final libraryHasTracksProvider = StreamProvider<bool>((ref) {
  if (ref.watch(useMockAppDataProvider)) {
    return Stream.value(true);
  }
  return ref.watch(driveLibraryRepositoryProvider).watchHasTracks();
});

final recentTracksProvider = StreamProvider.autoDispose((ref) {
  if (ref.watch(useMockAppDataProvider)) {
    return Stream.value(recentTracks);
  }
  return ref.watch(driveLibraryRepositoryProvider).watchRecentTracks();
});

final librarySongsProvider = StreamProvider.autoDispose((ref) {
  if (ref.watch(useMockAppDataProvider)) {
    return Stream.value(librarySongs);
  }
  return ref.watch(driveLibraryRepositoryProvider).watchSongs();
});

final libraryAlbumsProvider = StreamProvider.autoDispose((ref) {
  if (ref.watch(useMockAppDataProvider)) {
    return Stream.value(libraryAlbums);
  }
  return ref.watch(driveLibraryRepositoryProvider).watchAlbums();
});

final libraryArtistsProvider = StreamProvider.autoDispose((ref) {
  if (ref.watch(useMockAppDataProvider)) {
    return Stream.value(libraryArtists);
  }
  return ref.watch(driveLibraryRepositoryProvider).watchArtists();
});

final libraryAlbumArtistsProvider = StreamProvider.autoDispose((ref) {
  if (ref.watch(useMockAppDataProvider)) {
    return Stream.value(libraryAlbumArtists);
  }
  return ref.watch(driveLibraryRepositoryProvider).watchAlbumArtists();
});

final libraryGenresProvider = StreamProvider.autoDispose((ref) {
  if (ref.watch(useMockAppDataProvider)) {
    return Stream.value(libraryGenres);
  }
  return ref.watch(driveLibraryRepositoryProvider).watchGenres();
});

final libraryInfoStatsProvider = StreamProvider.autoDispose((ref) {
  if (ref.watch(useMockAppDataProvider)) {
    final totalListeningMinutes = librarySongs.fold<int>(
      0,
      (sum, track) => sum + (track.durationSeconds ~/ 60),
    );
    return Stream.value(
      LibraryInfoStats(
        trackCount: librarySongs.length,
        favoriteCount: 1,
        totalListeningMinutes: totalListeningMinutes,
        connectedRoots: 1,
      ),
    );
  }
  return ref.watch(driveLibraryRepositoryProvider).watchInfoStats();
});

final albumDetailProvider = FutureProvider.autoDispose
    .family<LibraryAlbumDetail?, String>((ref, key) {
      if (ref.watch(useMockAppDataProvider)) {
        final album = libraryAlbumById(key);
        final tracks = libraryAlbumTracksById(key);
        if (album == null || tracks == null) {
          return Future.value(null);
        }
        return Future.value(LibraryAlbumDetail(album: album, tracks: tracks));
      }
      return ref.watch(driveLibraryRepositoryProvider).getAlbumDetail(key);
    });

class ScanProgress {
  const ScanProgress({
    required this.jobId,
    required this.phase,
    required this.state,
    required this.indexedCount,
    required this.metadataReadyCount,
    required this.artworkReadyCount,
    required this.failedCount,
    this.itemsPerSecond,
    this.pipelineBacklog,
    this.metadataPipelineBacklog,
  });

  final int jobId;
  final String phase;
  final String state;
  final int indexedCount;
  final int metadataReadyCount;
  final int artworkReadyCount;
  final int failedCount;
  final double? itemsPerSecond;
  final ScanPipelineBacklog? pipelineBacklog;
  final MetadataPipelineBacklog? metadataPipelineBacklog;

  bool get isRunning => state == DriveScanJobState.running.value;
  bool get isPaused => state == DriveScanJobState.paused.value;
  bool get canPause =>
      state == DriveScanJobState.running.value ||
      state == DriveScanJobState.queued.value;
  bool get canResume => state == DriveScanJobState.paused.value;
  bool get canCancel =>
      state == DriveScanJobState.queued.value ||
      state == DriveScanJobState.running.value ||
      state == DriveScanJobState.paused.value ||
      state == DriveScanJobState.cancelRequested.value;

  ScanProgress copyWith({
    int? jobId,
    String? phase,
    String? state,
    int? indexedCount,
    int? metadataReadyCount,
    int? artworkReadyCount,
    int? failedCount,
    Value<double?>? itemsPerSecond,
    Value<ScanPipelineBacklog?>? pipelineBacklog,
    Value<MetadataPipelineBacklog?>? metadataPipelineBacklog,
  }) {
    return ScanProgress(
      jobId: jobId ?? this.jobId,
      phase: phase ?? this.phase,
      state: state ?? this.state,
      indexedCount: indexedCount ?? this.indexedCount,
      metadataReadyCount: metadataReadyCount ?? this.metadataReadyCount,
      artworkReadyCount: artworkReadyCount ?? this.artworkReadyCount,
      failedCount: failedCount ?? this.failedCount,
      itemsPerSecond: itemsPerSecond == null
          ? this.itemsPerSecond
          : itemsPerSecond.value,
      pipelineBacklog: pipelineBacklog == null
          ? this.pipelineBacklog
          : pipelineBacklog.value,
      metadataPipelineBacklog: metadataPipelineBacklog == null
          ? this.metadataPipelineBacklog
          : metadataPipelineBacklog.value,
    );
  }
}

class ScanSpeedTracker {
  ScanSpeedTracker({DateTime Function()? now, Duration? rollingWindow})
    : _now = now ?? DateTime.now,
      _rollingWindow = rollingWindow ?? const Duration(seconds: 30);

  final DateTime Function() _now;
  final Duration _rollingWindow;
  _ScanSpeedJobRecord? _record;

  void observe(ScanJob? job) {
    if (job == null) {
      clear();
      return;
    }

    final trackedCount = _trackedCount(job);
    final previous = _record;
    final isRunning =
        job.state == DriveScanJobState.running.value && trackedCount != null;
    if (!isRunning) {
      _record = _ScanSpeedJobRecord(
        jobId: job.id,
        phase: job.phase,
        state: job.state,
        trackedCount: trackedCount,
        samples: ListQueue<_ScanSpeedSample>(),
      );
      return;
    }

    final shouldResetForJobChange =
        previous == null || previous.jobId != job.id;
    final shouldResetForPhaseChange =
        previous != null && previous.phase != job.phase;
    final shouldResetForResume =
        previous != null && previous.state != DriveScanJobState.running.value;
    final shouldResetForCountDecrease =
        previous != null &&
        previous.trackedCount != null &&
        trackedCount < previous.trackedCount!;

    if (shouldResetForJobChange ||
        shouldResetForPhaseChange ||
        shouldResetForResume ||
        shouldResetForCountDecrease) {
      _record = _ScanSpeedJobRecord(
        jobId: job.id,
        phase: job.phase,
        state: job.state,
        trackedCount: trackedCount,
        samples: ListQueue<_ScanSpeedSample>(),
      );
      return;
    }

    _record = previous.copyWith(state: job.state, trackedCount: trackedCount);
  }

  void sampleNow() {
    final record = _record;
    if (record == null ||
        record.state != DriveScanJobState.running.value ||
        record.trackedCount == null) {
      return;
    }

    final now = _now();
    final samples = ListQueue<_ScanSpeedSample>.from(record.samples)
      ..addLast(
        _ScanSpeedSample(trackedCount: record.trackedCount!, observedAt: now),
      );
    final windowStart = now.subtract(_rollingWindow);
    while (samples.length > 1 &&
        samples.first.observedAt.isBefore(windowStart)) {
      samples.removeFirst();
    }

    _record = record.copyWith(samples: samples);
  }

  double? currentRate() {
    final record = _record;
    if (record == null ||
        record.state != DriveScanJobState.running.value ||
        record.trackedCount == null) {
      return null;
    }

    if (record.samples.length < 2) {
      return 0.0;
    }

    final first = record.samples.first;
    final last = record.samples.last;
    final elapsedMs = last.observedAt
        .difference(first.observedAt)
        .inMilliseconds;
    if (elapsedMs <= 0) {
      return 0.0;
    }
    final countDelta = last.trackedCount - first.trackedCount;
    if (countDelta <= 0) {
      return 0.0;
    }
    return countDelta * 1000 / elapsedMs;
  }

  void clear() => _record = null;

  int? _trackedCount(ScanJob job) {
    return switch (job.phase) {
      'baseline_discovery' || 'incremental_changes' => job.indexedCount,
      'metadata_enrichment' => job.metadataReadyCount,
      'artwork_enrichment' => job.artworkReadyCount,
      _ => null,
    };
  }
}

class _ScanSpeedJobRecord {
  const _ScanSpeedJobRecord({
    required this.jobId,
    required this.phase,
    required this.state,
    required this.trackedCount,
    required this.samples,
  });

  final int jobId;
  final String phase;
  final String state;
  final int? trackedCount;
  final ListQueue<_ScanSpeedSample> samples;

  _ScanSpeedJobRecord copyWith({
    String? phase,
    String? state,
    int? trackedCount,
    ListQueue<_ScanSpeedSample>? samples,
  }) {
    return _ScanSpeedJobRecord(
      jobId: jobId,
      phase: phase ?? this.phase,
      state: state ?? this.state,
      trackedCount: trackedCount ?? this.trackedCount,
      samples: samples ?? ListQueue<_ScanSpeedSample>.from(this.samples),
    );
  }
}

class _ScanSpeedSample {
  const _ScanSpeedSample({
    required this.trackedCount,
    required this.observedAt,
  });

  final int trackedCount;
  final DateTime observedAt;
}

class GoogleDriveState {
  const GoogleDriveState({
    required this.isConfigured,
    required this.account,
    required this.hasLinkedAccount,
    required this.canAccessDrive,
    required this.requiresReconnect,
    required this.authErrorMessage,
    required this.roots,
    required this.cacheSizeBytes,
    required this.scanProgress,
    required this.isMutating,
    required this.configurationMessage,
    required this.errorMessage,
  });

  final bool isConfigured;
  final DriveAccountProfile? account;
  final bool hasLinkedAccount;
  final bool canAccessDrive;
  final bool requiresReconnect;
  final String? authErrorMessage;
  final List<SyncRoot> roots;
  final int cacheSizeBytes;
  final ScanProgress? scanProgress;
  final bool isMutating;
  final String? configurationMessage;
  final String? errorMessage;

  bool get isConnected => canAccessDrive;
  bool get isBusy =>
      isMutating || (scanProgress != null && !scanProgress!.isPaused);

  GoogleDriveState copyWith({
    Value<DriveAccountProfile?>? account,
    bool? hasLinkedAccount,
    bool? canAccessDrive,
    bool? requiresReconnect,
    Value<String?>? authErrorMessage,
    List<SyncRoot>? roots,
    int? cacheSizeBytes,
    Value<ScanProgress?>? scanProgress,
    bool? isMutating,
    String? configurationMessage,
    Value<String?>? errorMessage,
  }) {
    return GoogleDriveState(
      isConfigured: isConfigured,
      account: account == null ? this.account : account.value,
      hasLinkedAccount: hasLinkedAccount ?? this.hasLinkedAccount,
      canAccessDrive: canAccessDrive ?? this.canAccessDrive,
      requiresReconnect: requiresReconnect ?? this.requiresReconnect,
      authErrorMessage: authErrorMessage == null
          ? this.authErrorMessage
          : authErrorMessage.value,
      roots: roots ?? this.roots,
      cacheSizeBytes: cacheSizeBytes ?? this.cacheSizeBytes,
      scanProgress: scanProgress == null
          ? this.scanProgress
          : scanProgress.value,
      isMutating: isMutating ?? this.isMutating,
      configurationMessage: configurationMessage ?? this.configurationMessage,
      errorMessage: errorMessage == null
          ? this.errorMessage
          : errorMessage.value,
    );
  }
}

class GoogleDriveController extends AsyncNotifier<GoogleDriveState> {
  StreamSubscription<SyncAccount?>? _accountSubscription;
  StreamSubscription<List<SyncRoot>>? _rootsSubscription;
  StreamSubscription<int>? _cacheSubscription;
  StreamSubscription<ScanJob?>? _jobSubscription;
  StreamSubscription<ScanPipelineBacklog>? _taskBacklogSubscription;
  StreamSubscription<MetadataPipelineBacklog>? _metadataPipelineSubscription;
  Timer? _scanSpeedTimer;
  ScanSpeedTracker? _scanSpeedTracker;
  int? _taskBacklogJobId;
  int? _metadataPipelineJobId;

  DriveAuthRepository get _authRepository =>
      ref.read(driveAuthRepositoryProvider);
  AppDatabase get _database => ref.read(appDatabaseProvider);
  DriveHttpClient get _httpClient => ref.read(driveHttpClientProvider);
  DriveLibraryRepository get _libraryRepository =>
      ref.read(driveLibraryRepositoryProvider);
  DriveScanRunner get _runner => ref.read(driveScanRunnerProvider);
  ScanSpeedTracker get _speedTracker => _scanSpeedTracker ??= ScanSpeedTracker(
    rollingWindow: ref.read(scanSpeedRollingWindowProvider),
  );
  Duration get _scanSpeedTickInterval =>
      ref.read(scanSpeedTickIntervalProvider);

  @override
  Future<GoogleDriveState> build() async {
    if (ref.watch(useMockAppDataProvider)) {
      return const GoogleDriveState(
        isConfigured: true,
        account: DriveAccountProfile(
          providerAccountId: 'mock-account',
          email: 'demo@example.com',
          displayName: 'Demo User',
          authKind: 'mock',
        ),
        hasLinkedAccount: true,
        canAccessDrive: true,
        requiresReconnect: false,
        authErrorMessage: null,
        roots: <SyncRoot>[],
        cacheSizeBytes: 0,
        scanProgress: null,
        isMutating: false,
        configurationMessage: null,
        errorMessage: null,
      );
    }

    ref.onDispose(() async {
      _stopScanSpeedTimer();
      await _accountSubscription?.cancel();
      await _rootsSubscription?.cancel();
      await _cacheSubscription?.cancel();
      await _jobSubscription?.cancel();
      await _taskBacklogSubscription?.cancel();
      await _metadataPipelineSubscription?.cancel();
    });

    final accountRow = await _database.getActiveAccount();
    if (accountRow == null) {
      final restoredProfile = await _authRepository.restoreSession();
      if (restoredProfile != null) {
        await _database.setActiveAccount(
          SyncAccountsCompanion.insert(
            providerAccountId: restoredProfile.providerAccountId,
            email: restoredProfile.email,
            displayName: restoredProfile.displayName,
            authKind: restoredProfile.authKind,
            connectedAt: DateTime.now(),
            isActive: const Value(true),
            authSessionState: Value(DriveAuthSessionState.ready.value),
            authSessionError: const Value(null),
          ),
        );
      }
    } else if (accountRow.authKind == 'oauth_desktop') {
      final restoredProfile = await _authRepository.restoreSession();
      if (restoredProfile == null) {
        await _database.markAccountReauthRequired(accountRow.id);
      } else {
        await _database.setActiveAccount(
          SyncAccountsCompanion.insert(
            providerAccountId: restoredProfile.providerAccountId,
            email: restoredProfile.email,
            displayName: restoredProfile.displayName,
            authKind: restoredProfile.authKind,
            connectedAt: accountRow.connectedAt,
            isActive: const Value(true),
            authSessionState: Value(DriveAuthSessionState.ready.value),
            authSessionError: const Value(null),
          ),
        );
      }
    }

    final initialState = await _loadState();
    _wireSubscriptions();
    _syncTaskBacklogSubscription(initialState.scanProgress);
    _syncMetadataPipelineSubscription(initialState.scanProgress);
    _syncScanSpeedTimer(initialState.scanProgress);
    if (initialState.canAccessDrive) {
      unawaited(_runner.bootstrap());
    }
    return initialState;
  }

  Future<void> connect() async {
    final currentState = state.asData?.value ?? await _loadState();
    state = AsyncData(
      currentState.copyWith(isMutating: true, errorMessage: const Value(null)),
    );

    try {
      final profile = await _authRepository.connect();
      await _database.setActiveAccount(
        SyncAccountsCompanion.insert(
          providerAccountId: profile.providerAccountId,
          email: profile.email,
          displayName: profile.displayName,
          authKind: profile.authKind,
          connectedAt: DateTime.now(),
          isActive: const Value(true),
          authSessionState: Value(DriveAuthSessionState.ready.value),
          authSessionError: const Value(null),
        ),
      );
      final nextState = (await _loadState()).copyWith(
        isMutating: false,
        errorMessage: const Value(null),
      );
      _syncTaskBacklogSubscription(nextState.scanProgress);
      _syncMetadataPipelineSubscription(nextState.scanProgress);
      _syncScanSpeedTimer(nextState.scanProgress);
      state = AsyncData(nextState);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(
        currentState.copyWith(
          isMutating: false,
          errorMessage: Value(_errorMessage(error)),
        ),
      );
    }
  }

  Future<void> disconnect() async {
    final currentState = state.asData?.value ?? await _loadState();
    state = AsyncData(
      currentState.copyWith(isMutating: true, errorMessage: const Value(null)),
    );

    try {
      final jobId = currentState.scanProgress?.jobId;
      if (jobId != null) {
        await _runner.cancelJob(jobId);
      }
      await _authRepository.disconnect();
      await _libraryRepository.clearCachedFiles();
      await _database.clearActiveAccount();
      final nextState = await _loadState();
      _syncTaskBacklogSubscription(nextState.scanProgress);
      _syncMetadataPipelineSubscription(nextState.scanProgress);
      _syncScanSpeedTimer(nextState.scanProgress);
      state = AsyncData(nextState);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(
        currentState.copyWith(
          isMutating: false,
          errorMessage: Value(_errorMessage(error)),
        ),
      );
    }
  }

  Future<void> addRoot(DriveFolderEntry folder) async {
    final account = await _requireDriveAccess();

    await _assertRootDoesNotOverlap(folder);
    await _database.upsertRoot(
      SyncRootsCompanion.insert(
        accountId: account.id,
        folderId: folder.id,
        folderName: folder.name,
        parentFolderId: Value(folder.parentId),
        syncState: Value(DriveScanJobState.completed.value),
      ),
    );
    final root = await _database.getRootByFolderId(folder.id);
    if (root != null) {
      await _runner.enqueueSync(rootId: root.id);
    }
  }

  Future<void> removeRoot(int rootId) async {
    final root = await _database.getRootById(rootId);
    if (root?.activeJobId != null) {
      await _runner.cancelJob(root!.activeJobId!);
    }
    await _database.deleteRoot(rootId);
  }

  Future<void> enqueueSync() async {
    try {
      await _requireDriveAccess();
      await _runner.enqueueSync();
    } catch (error, stackTrace) {
      final currentState = state.asData?.value ?? await _loadState();
      state = AsyncError(error, stackTrace);
      state = AsyncData(
        currentState.copyWith(errorMessage: Value(_errorMessage(error))),
      );
    }
  }

  Future<void> pauseSync(int jobId) => _runner.pauseJob(jobId);

  Future<void> resumeSync(int jobId) => _runner.resumeJob(jobId);

  Future<void> cancelSync(int jobId) => _runner.cancelJob(jobId);

  Future<void> syncNow() => enqueueSync();

  Future<void> clearCache() async {
    await _libraryRepository.clearCachedFiles();
  }

  Future<List<DriveFolderEntry>> listFolders({String parentId = 'root'}) async {
    await _requireDriveAccess();
    return _httpClient.listFolders(parentId: parentId);
  }

  Future<DriveFolderEntry> getFolder(String folderId) async {
    await _requireDriveAccess();
    final metadata = await _httpClient.getFolderMetadata(folderId);
    final parents = metadata['parents'] as List<dynamic>?;
    final parentIds = parents?.cast<String>() ?? const <String>[];
    return DriveFolderEntry(
      id: metadata['id'] as String,
      name: metadata['name'] as String? ?? 'Folder',
      parentId: parentIds.isEmpty ? null : parentIds.first,
    );
  }

  void _wireSubscriptions() {
    _accountSubscription ??= _database.watchActiveAccount().listen((_) async {
      await _reloadStatePreservingUiFlags();
    });
    _rootsSubscription ??= _database.watchRoots().listen((_) async {
      await _reloadStatePreservingUiFlags();
    });
    _cacheSubscription ??= _database.watchCacheSizeBytes().listen((_) async {
      await _reloadStatePreservingUiFlags();
    });
    _jobSubscription ??= _database.watchLatestActiveScanJob().listen((_) async {
      await _reloadStatePreservingUiFlags();
    });
  }

  Future<void> _reloadStatePreservingUiFlags() async {
    final currentState = state.asData?.value;
    final nextState = await _loadState(
      isMutating: currentState?.isMutating ?? false,
      errorMessage: currentState?.errorMessage,
    );
    if (!ref.mounted) {
      return;
    }
    _syncTaskBacklogSubscription(nextState.scanProgress);
    _syncMetadataPipelineSubscription(nextState.scanProgress);
    _syncScanSpeedTimer(nextState.scanProgress);
    state = AsyncData(nextState);
  }

  void _syncTaskBacklogSubscription(ScanProgress? progress) {
    final nextJobId = progress?.jobId;
    if (nextJobId == null) {
      unawaited(_taskBacklogSubscription?.cancel());
      _taskBacklogSubscription = null;
      _taskBacklogJobId = null;
      return;
    }
    if (_taskBacklogJobId == nextJobId && _taskBacklogSubscription != null) {
      return;
    }
    unawaited(_taskBacklogSubscription?.cancel());
    _taskBacklogJobId = nextJobId;
    _taskBacklogSubscription = _database
        .watchScanPipelineBacklog(nextJobId)
        .listen(_applyPipelineBacklogUpdate);
  }

  void _syncMetadataPipelineSubscription(ScanProgress? progress) {
    final shouldWatch =
        progress != null &&
        progress.phase == DriveScanPhase.metadataEnrichment.value;
    final nextJobId = shouldWatch ? progress.jobId : null;
    if (nextJobId == null) {
      unawaited(_metadataPipelineSubscription?.cancel());
      _metadataPipelineSubscription = null;
      _metadataPipelineJobId = null;
      return;
    }
    if (_metadataPipelineJobId == nextJobId &&
        _metadataPipelineSubscription != null) {
      return;
    }
    unawaited(_metadataPipelineSubscription?.cancel());
    _metadataPipelineJobId = nextJobId;
    _metadataPipelineSubscription = MetadataPipelineTelemetryHub.instance
        .watchJob(nextJobId)
        .distinct()
        .listen(_applyMetadataPipelineBacklogUpdate);
  }

  void _applyPipelineBacklogUpdate(ScanPipelineBacklog backlog) {
    _updateScanProgress((progress) {
      if (progress.jobId != _taskBacklogJobId) {
        return progress;
      }
      if (progress.pipelineBacklog == backlog) {
        return progress;
      }
      return progress.copyWith(pipelineBacklog: Value(backlog));
    });
  }

  void _applyMetadataPipelineBacklogUpdate(MetadataPipelineBacklog backlog) {
    _updateScanProgress((progress) {
      if (progress.jobId != _metadataPipelineJobId ||
          progress.phase != DriveScanPhase.metadataEnrichment.value ||
          progress.metadataPipelineBacklog == backlog) {
        return progress;
      }
      return progress.copyWith(metadataPipelineBacklog: Value(backlog));
    });
  }

  void _updateScanProgress(
    ScanProgress Function(ScanProgress progress) update,
  ) {
    if (!ref.mounted) {
      return;
    }
    final currentState = state.asData?.value;
    final progress = currentState?.scanProgress;
    if (currentState == null || progress == null) {
      return;
    }

    final nextProgress = update(progress);
    if (identical(nextProgress, progress)) {
      return;
    }

    state = AsyncData(currentState.copyWith(scanProgress: Value(nextProgress)));
  }

  void _syncScanSpeedTimer(ScanProgress? progress) {
    if (progress?.isRunning == true) {
      _scanSpeedTimer ??= Timer.periodic(_scanSpeedTickInterval, (_) {
        _refreshScanSpeed();
      });
      return;
    }
    _stopScanSpeedTimer();
  }

  void _stopScanSpeedTimer() {
    _scanSpeedTimer?.cancel();
    _scanSpeedTimer = null;
  }

  void _refreshScanSpeed() {
    if (!ref.mounted) {
      _stopScanSpeedTimer();
      return;
    }
    final currentState = state.asData?.value;
    final progress = currentState?.scanProgress;
    if (currentState == null || progress == null || !progress.isRunning) {
      _stopScanSpeedTimer();
      return;
    }

    _speedTracker.sampleNow();
    final nextRate = _speedTracker.currentRate();
    if (_ratesEqual(progress.itemsPerSecond, nextRate)) {
      return;
    }

    state = AsyncData(
      currentState.copyWith(
        scanProgress: Value(progress.copyWith(itemsPerSecond: Value(nextRate))),
      ),
    );
  }

  bool _ratesEqual(double? left, double? right) {
    if (left == null || right == null) {
      return left == right;
    }
    return (left - right).abs() < 0.0001;
  }

  Future<GoogleDriveState> _loadState({
    bool isMutating = false,
    String? errorMessage,
  }) async {
    final accountRow = await _database.getActiveAccount();
    final account = _mapAccount(accountRow);
    final roots = await _database.getRoots();
    final cacheSizeBytes = await _database.watchCacheSizeBytes().first;
    final requiresReconnect =
        accountRow?.authSessionState ==
        DriveAuthSessionState.reauthRequired.value;
    final hasLinkedAccount = account != null;
    final canAccessDrive =
        _authRepository.isConfigured && hasLinkedAccount && !requiresReconnect;
    final scanJob = accountRow == null || !canAccessDrive
        ? null
        : await _database.getLatestActiveScanJob(accountId: accountRow.id);
    final pipelineBacklog = scanJob == null
        ? null
        : await _database.getScanPipelineBacklog(scanJob.id);
    final metadataPipelineBacklog =
        scanJob == null ||
            scanJob.phase != DriveScanPhase.metadataEnrichment.value
        ? null
        : MetadataPipelineTelemetryHub.instance.snapshotForJob(scanJob.id);

    return GoogleDriveState(
      isConfigured: _authRepository.isConfigured,
      account: account,
      hasLinkedAccount: hasLinkedAccount,
      canAccessDrive: canAccessDrive,
      requiresReconnect: requiresReconnect,
      authErrorMessage: requiresReconnect
          ? accountRow?.authSessionError ?? driveAuthReconnectRequiredMessage
          : null,
      roots: roots,
      cacheSizeBytes: cacheSizeBytes,
      scanProgress: _mapScanProgress(
        scanJob,
        pipelineBacklog: pipelineBacklog,
        metadataPipelineBacklog: metadataPipelineBacklog,
      ),
      isMutating: isMutating,
      configurationMessage: _authRepository.configurationMessage,
      errorMessage: errorMessage,
    );
  }

  Future<SyncAccount> _requireDriveAccess() async {
    final account = await _database.getActiveAccount();
    if (account == null) {
      throw const DriveAuthException('Connect Google Drive first.');
    }
    if (account.authSessionState ==
        DriveAuthSessionState.reauthRequired.value) {
      throw const DriveAuthException(driveAuthReconnectRequiredMessage);
    }
    return account;
  }

  String _errorMessage(Object error) {
    if (error is DriveAuthException) {
      return error.message;
    }
    return error.toString();
  }

  Future<void> _assertRootDoesNotOverlap(DriveFolderEntry folder) async {
    final roots = await _database.getRoots();
    if (roots.any((root) => root.folderId == folder.id)) {
      throw const DriveAuthException('This folder is already added.');
    }

    final newAncestors = await _ancestorFolderIds(folder);
    for (final root in roots) {
      if (newAncestors.contains(root.folderId)) {
        throw const DriveAuthException(
          'This folder is nested inside an existing sync root.',
        );
      }

      final rootFolder = await getFolder(root.folderId);
      final existingAncestors = await _ancestorFolderIds(rootFolder);
      if (existingAncestors.contains(folder.id)) {
        throw const DriveAuthException(
          'An existing sync root is nested inside this folder.',
        );
      }
    }
  }

  Future<Set<String>> _ancestorFolderIds(DriveFolderEntry folder) async {
    final ancestors = <String>{};
    var currentParentId = folder.parentId;
    while (currentParentId != null &&
        currentParentId.isNotEmpty &&
        currentParentId != 'root') {
      ancestors.add(currentParentId);
      currentParentId = (await getFolder(currentParentId)).parentId;
    }
    return ancestors;
  }

  DriveAccountProfile? _mapAccount(SyncAccount? account) {
    if (account == null) {
      return null;
    }
    return DriveAccountProfile(
      providerAccountId: account.providerAccountId,
      email: account.email,
      displayName: account.displayName,
      authKind: account.authKind,
    );
  }

  ScanProgress? _mapScanProgress(
    ScanJob? job, {
    ScanPipelineBacklog? pipelineBacklog,
    MetadataPipelineBacklog? metadataPipelineBacklog,
  }) {
    if (job == null) {
      _speedTracker.clear();
      return null;
    }
    _speedTracker.observe(job);
    return ScanProgress(
      jobId: job.id,
      phase: job.phase,
      state: job.state,
      indexedCount: job.indexedCount,
      metadataReadyCount: job.metadataReadyCount,
      artworkReadyCount: job.artworkReadyCount,
      failedCount: job.failedCount,
      itemsPerSecond: _speedTracker.currentRate(),
      pipelineBacklog: pipelineBacklog,
      metadataPipelineBacklog: metadataPipelineBacklog,
    );
  }
}

final googleDriveControllerProvider =
    AsyncNotifierProvider<GoogleDriveController, GoogleDriveState>(
      GoogleDriveController.new,
    );

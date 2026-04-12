import 'dart:async';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/drive_oauth_config.dart';
import '../../../core/providers/runtime_mode_provider.dart';
import '../../../data/database/app_database.dart';
import '../../../data/drive/drive_artwork_service.dart';
import '../../../data/drive/drive_auth_repository.dart';
import '../../../data/drive/drive_discovery_service.dart';
import '../../../data/drive/drive_entities.dart';
import '../../../data/drive/drive_http_client.dart';
import '../../../data/drive/drive_library_repository.dart';
import '../../../data/drive/drive_metadata_catch_up_planner.dart';
import '../../../data/drive/drive_metadata_orchestrator.dart';
import '../../../data/drive/drive_scan_execution_profile.dart';
import '../../../data/drive/drive_scan_job_enqueuer.dart';
import '../../../data/drive/drive_scan_job_lifecycle.dart';
import '../../../data/drive/drive_scan_logger.dart';
import '../../../data/drive/drive_scan_phase_codec.dart';
import '../../../data/drive/drive_scan_phase_executor.dart';
import '../../../data/drive/drive_scan_progress_refresher.dart';
import '../../../data/drive/drive_scan_root_binder.dart';
import '../../../data/drive/drive_scan_root_resolver.dart';
import '../../../data/drive/drive_scan_runner.dart';
import '../../../data/drive/drive_stream_proxy.dart';
import '../../../data/drive/drive_track_cache_service.dart';
import '../../../data/drive/drive_track_projector.dart';
import '../../../data/drive/extraction/drive_artwork_extractor.dart';
import '../../../data/drive/extraction/drive_metadata_extractor.dart';
import '../../../data/drive/metadata_pipeline_backlog.dart';
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

final driveScanLoggerProvider = Provider<DriveScanLogger>((ref) {
  return const ConsoleDriveScanLogger();
});

final driveAuthRepositoryProvider = Provider<DriveAuthRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return PlatformDriveAuthRepository(
    config: ref.watch(driveOAuthConfigProvider),
    secureStorage: ref.watch(secureStorageProvider),
    logger: ref.watch(driveScanLoggerProvider),
    onDesktopSessionInvalidated: () async {
      final account = await database.getActiveAccount();
      if (account == null ||
          account.authKind != 'oauth_desktop' ||
          account.authSessionState ==
              DriveAuthSessionState.reauthRequired.value) {
        return;
      }
      await database.markAccountReauthRequired(account.id);
    },
  );
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

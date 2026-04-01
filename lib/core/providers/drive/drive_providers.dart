import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/drive_oauth_config.dart';
import '../../../core/providers/runtime_mode_provider.dart';
import '../../../data/database/app_database.dart';
import '../../../data/drive/drive_artwork_extractor.dart';
import '../../../data/drive/drive_auth_repository.dart';
import '../../../data/drive/drive_entities.dart';
import '../../../data/drive/drive_http_client.dart';
import '../../../data/drive/drive_library_repository.dart';
import '../../../data/drive/drive_scan_logger.dart';
import '../../../data/drive/drive_metadata_extractor.dart';
import '../../../data/drive/drive_scan_coordinator.dart';
import '../../../data/drive/drive_scan_execution_profile.dart';
import '../../../data/drive/drive_scan_models.dart';
import '../../../data/drive/drive_stream_proxy.dart';
import '../../../data/drive/drive_track_cache_service.dart';
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
    artworkWorkers: isDesktopPlatform ? 2 : 1,
    artworkWorkersWhileMetadataPending: 1,
    metadataHighWatermark: isDesktopPlatform ? 8 : 3,
    pageSize: 1000,
    trackProjectionBatchSize: 500,
  );
});

final driveScanCoordinatorProvider = Provider<DriveScanCoordinator>((ref) {
  return DriveScanCoordinator(
    database: ref.watch(appDatabaseProvider),
    driveHttpClient: ref.watch(driveHttpClientProvider),
    metadataExtractor: ref.watch(driveMetadataExtractorProvider),
    artworkExtractor: ref.watch(driveArtworkExtractorProvider),
    trackCacheService: ref.watch(driveTrackCacheServiceProvider),
    executionProfile: ref.watch(driveScanExecutionProfileProvider),
    logger: ref.watch(driveScanLoggerProvider),
  );
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
  });

  final int jobId;
  final String phase;
  final String state;
  final int indexedCount;
  final int metadataReadyCount;
  final int artworkReadyCount;
  final int failedCount;

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

  DriveAuthRepository get _authRepository =>
      ref.read(driveAuthRepositoryProvider);
  AppDatabase get _database => ref.read(appDatabaseProvider);
  DriveHttpClient get _httpClient => ref.read(driveHttpClientProvider);
  DriveLibraryRepository get _libraryRepository =>
      ref.read(driveLibraryRepositoryProvider);
  DriveScanCoordinator get _coordinator =>
      ref.read(driveScanCoordinatorProvider);

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
      await _accountSubscription?.cancel();
      await _rootsSubscription?.cancel();
      await _cacheSubscription?.cancel();
      await _jobSubscription?.cancel();
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
    if (initialState.canAccessDrive) {
      unawaited(_coordinator.bootstrap());
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
      state = AsyncData(
        (await _loadState()).copyWith(
          isMutating: false,
          errorMessage: const Value(null),
        ),
      );
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
        await _coordinator.cancelJob(jobId);
      }
      await _authRepository.disconnect();
      await _libraryRepository.clearCachedFiles();
      await _database.clearActiveAccount();
      state = AsyncData(await _loadState());
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
      await _coordinator.enqueueSync(rootId: root.id);
    }
  }

  Future<void> removeRoot(int rootId) async {
    final root = await _database.getRootById(rootId);
    if (root?.activeJobId != null) {
      await _coordinator.cancelJob(root!.activeJobId!);
    }
    await _database.deleteRoot(rootId);
  }

  Future<void> enqueueSync() async {
    try {
      await _requireDriveAccess();
      await _coordinator.enqueueSync();
    } catch (error, stackTrace) {
      final currentState = state.asData?.value ?? await _loadState();
      state = AsyncError(error, stackTrace);
      state = AsyncData(
        currentState.copyWith(errorMessage: Value(_errorMessage(error))),
      );
    }
  }

  Future<void> pauseSync(int jobId) => _coordinator.pauseJob(jobId);

  Future<void> resumeSync(int jobId) => _coordinator.resumeJob(jobId);

  Future<void> cancelSync(int jobId) => _coordinator.cancelJob(jobId);

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
      final currentState = state.asData?.value;
      state = AsyncData(
        await _loadState(
          isMutating: currentState?.isMutating ?? false,
          errorMessage: currentState?.errorMessage,
        ),
      );
    });
    _rootsSubscription ??= _database.watchRoots().listen((_) async {
      final currentState = state.asData?.value;
      state = AsyncData(
        await _loadState(
          isMutating: currentState?.isMutating ?? false,
          errorMessage: currentState?.errorMessage,
        ),
      );
    });
    _cacheSubscription ??= _database.watchCacheSizeBytes().listen((_) async {
      final currentState = state.asData?.value;
      state = AsyncData(
        await _loadState(
          isMutating: currentState?.isMutating ?? false,
          errorMessage: currentState?.errorMessage,
        ),
      );
    });
    _jobSubscription ??= _database.watchLatestActiveScanJob().listen((_) async {
      final currentState = state.asData?.value;
      state = AsyncData(
        await _loadState(
          isMutating: currentState?.isMutating ?? false,
          errorMessage: currentState?.errorMessage,
        ),
      );
    });
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
      scanProgress: _mapScanProgress(scanJob),
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

  ScanProgress? _mapScanProgress(ScanJob? job) {
    if (job == null) {
      return null;
    }
    return ScanProgress(
      jobId: job.id,
      phase: job.phase,
      state: job.state,
      indexedCount: job.indexedCount,
      metadataReadyCount: job.metadataReadyCount,
      artworkReadyCount: job.artworkReadyCount,
      failedCount: job.failedCount,
    );
  }
}

final googleDriveControllerProvider =
    AsyncNotifierProvider<GoogleDriveController, GoogleDriveState>(
      GoogleDriveController.new,
    );

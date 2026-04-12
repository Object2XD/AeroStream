import 'dart:async';

import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../../../data/drive/drive_auth_repository.dart';
import '../../../data/drive/drive_entities.dart';
import '../../../data/drive/drive_http_client.dart';
import '../../../data/drive/drive_library_repository.dart';
import '../../../data/drive/drive_scan_models.dart';
import '../../../data/drive/drive_scan_runner.dart';
import 'drive_workspace_provider.dart';

class DriveCommands {
  DriveCommands({
    required AppDatabase database,
    required DriveAuthRepository authRepository,
    required DriveHttpClient httpClient,
    required DriveLibraryRepository libraryRepository,
    required DriveScanRunner runner,
    required DriveWorkspaceNotifier workspace,
  }) : _database = database,
       _authRepository = authRepository,
       _httpClient = httpClient,
       _libraryRepository = libraryRepository,
       _runner = runner,
       _workspace = workspace;

  final AppDatabase _database;
  final DriveAuthRepository _authRepository;
  final DriveHttpClient _httpClient;
  final DriveLibraryRepository _libraryRepository;
  final DriveScanRunner _runner;
  final DriveWorkspaceNotifier _workspace;

  Future<void> connect() async {
    final currentState =
        _workspace.currentValue ?? await _workspace.loadState();
    _workspace.writeState(
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
      final nextState = (await _workspace.loadState()).copyWith(
        isMutating: false,
        errorMessage: const Value(null),
      );
      await _workspace.replaceState(nextState);
    } catch (error, stackTrace) {
      _workspace.writeErrorState(
        error,
        stackTrace,
        fallbackState: currentState.copyWith(
          isMutating: false,
          errorMessage: Value(_errorMessage(error)),
        ),
      );
    }
  }

  Future<void> disconnect() async {
    final currentState =
        _workspace.currentValue ?? await _workspace.loadState();
    _workspace.writeState(
      currentState.copyWith(isMutating: true, errorMessage: const Value(null)),
    );

    try {
      final jobId = currentState.syncProgress?.jobId;
      if (jobId != null) {
        await _runner.cancelJob(jobId);
      }
      await _authRepository.disconnect();
      await _libraryRepository.clearCachedFiles();
      await _database.clearActiveAccount();
      final nextState = await _workspace.loadState();
      await _workspace.replaceState(nextState);
    } catch (error, stackTrace) {
      _workspace.writeErrorState(
        error,
        stackTrace,
        fallbackState: currentState.copyWith(
          isMutating: false,
          errorMessage: Value(_errorMessage(error)),
        ),
      );
    }
  }

  Future<void> addRoot(DriveFolderEntry folder) async {
    await _runGuardedDriveCall(() async {
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
    });
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
      await _runGuardedDriveCall(() async {
        await _requireDriveAccess();
        await _runner.enqueueSync();
      });
    } catch (error, stackTrace) {
      final effectiveError = await _normalizeRuntimeDriveError(error);
      final currentState =
          _workspace.currentValue ?? await _workspace.loadState();
      _workspace.writeErrorState(
        effectiveError,
        stackTrace,
        fallbackState: currentState.copyWith(
          errorMessage: Value(_errorMessage(effectiveError)),
        ),
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
    return _runGuardedDriveCall(() async {
      await _requireDriveAccess();
      return _httpClient.listFolders(parentId: parentId);
    });
  }

  Future<DriveFolderEntry> getFolder(String folderId) async {
    return _runGuardedDriveCall(() async {
      await _requireDriveAccess();
      final metadata = await _httpClient.getFolderMetadata(folderId);
      final parents = metadata['parents'] as List<dynamic>?;
      final parentIds = parents?.cast<String>() ?? const <String>[];
      return DriveFolderEntry(
        id: metadata['id'] as String,
        name: metadata['name'] as String? ?? 'Folder',
        parentId: parentIds.isEmpty ? null : parentIds.first,
      );
    });
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

  Future<T> _runGuardedDriveCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      final effectiveError = await _normalizeRuntimeDriveError(error);
      throw effectiveError;
    }
  }

  Future<Object> _normalizeRuntimeDriveError(Object error) async {
    if (!_isReconnectRequiredError(error)) {
      return error;
    }

    await _markDesktopReconnectRequiredIfNeeded();
    var nextState = await _workspace.loadState(
      isMutating: _workspace.currentValue?.isMutating ?? false,
      errorMessage: driveAuthReconnectRequiredMessage,
    );
    nextState = nextState.copyWith(
      canAccessDrive: false,
      requiresReconnect: true,
      authErrorMessage: Value(
        nextState.authErrorMessage ?? driveAuthReconnectRequiredMessage,
      ),
      syncProgress: const Value(null),
      errorMessage: const Value(driveAuthReconnectRequiredMessage),
    );
    await _workspace.replaceState(nextState);
    return const DriveAuthException(driveAuthReconnectRequiredMessage);
  }

  bool _isReconnectRequiredError(Object error) {
    if (error is DriveAuthSessionExpiredException) {
      return true;
    }
    return error is DriveAuthException &&
        error.message == driveAuthReconnectRequiredMessage;
  }

  Future<void> _markDesktopReconnectRequiredIfNeeded() async {
    final account = await _database.getActiveAccount();
    if (account == null ||
        account.authKind != 'oauth_desktop' ||
        account.authSessionState ==
            DriveAuthSessionState.reauthRequired.value) {
      return;
    }
    await _database.markAccountReauthRequired(account.id);
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
}

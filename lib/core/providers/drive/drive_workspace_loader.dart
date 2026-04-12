import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../../../data/drive/drive_auth_repository.dart';
import '../../../data/drive/drive_entities.dart';
import '../../../data/drive/drive_scan_backlog.dart';
import '../../../data/drive/drive_scan_models.dart';
import '../../../data/drive/metadata_pipeline_backlog.dart';
import 'drive_sync_progress.dart';
import 'drive_workspace_state.dart';
import 'scan_speed_tracker.dart';

class DriveWorkspaceLoader {
  DriveWorkspaceLoader({
    required AppDatabase database,
    required DriveAuthRepository authRepository,
    required ScanSpeedTracker speedTracker,
  }) : _database = database,
       _authRepository = authRepository,
       _speedTracker = speedTracker;

  final AppDatabase _database;
  final DriveAuthRepository _authRepository;
  final ScanSpeedTracker _speedTracker;

  Future<void> restoreAccountSession() async {
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
      return;
    }

    if (accountRow.authKind != 'oauth_desktop') {
      return;
    }

    final restoredProfile = await _authRepository.restoreSession();
    if (restoredProfile == null) {
      await _database.markAccountReauthRequired(accountRow.id);
      return;
    }

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

  Future<DriveWorkspaceState> loadState({
    bool isMutating = false,
    String? errorMessage,
  }) async {
    final accountRow = await _database.getActiveAccount();
    final account = _mapAccount(accountRow);
    final roots = await _database.getRoots();
    final cacheSizeBytes = await _database.getCacheSizeBytes();
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

    return DriveWorkspaceState(
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
      syncProgress: _mapSyncProgress(
        scanJob,
        pipelineBacklog: pipelineBacklog,
        metadataPipelineBacklog: metadataPipelineBacklog,
      ),
      isMutating: isMutating,
      configurationMessage: _authRepository.configurationMessage,
      errorMessage: errorMessage,
    );
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

  DriveSyncProgress? _mapSyncProgress(
    ScanJob? job, {
    ScanPipelineBacklog? pipelineBacklog,
    MetadataPipelineBacklog? metadataPipelineBacklog,
  }) {
    if (job == null) {
      _speedTracker.clear();
      return null;
    }
    _speedTracker.observe(job);
    return DriveSyncProgress(
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

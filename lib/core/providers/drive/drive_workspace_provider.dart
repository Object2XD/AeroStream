import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../runtime_mode_provider.dart';
import '../../../data/drive/drive_entities.dart';
import 'drive_dependency_providers.dart';
import 'drive_workspace_loader.dart';
import 'drive_workspace_runtime_binder.dart';
import 'drive_workspace_state.dart';
import 'scan_speed_tracker.dart';

class DriveWorkspaceNotifier extends AsyncNotifier<DriveWorkspaceState> {
  DriveWorkspaceLoader? _loader;
  DriveWorkspaceRuntimeBinder? _runtimeBinder;
  ScanSpeedTracker? _speedTracker;

  DriveWorkspaceLoader get _workspaceLoader {
    final cached = _loader;
    if (cached != null) {
      return cached;
    }
    final resolved = DriveWorkspaceLoader(
      database: ref.read(appDatabaseProvider),
      authRepository: ref.read(driveAuthRepositoryProvider),
      speedTracker: _resolvedSpeedTracker,
    );
    _loader = resolved;
    return resolved;
  }

  DriveWorkspaceRuntimeBinder get _workspaceRuntimeBinder {
    final cached = _runtimeBinder;
    if (cached != null) {
      return cached;
    }
    final resolved = DriveWorkspaceRuntimeBinder(
      ref: ref,
      database: ref.read(appDatabaseProvider),
      speedTracker: _resolvedSpeedTracker,
      scanSpeedTickInterval: ref.read(scanSpeedTickIntervalProvider),
      loadState: loadState,
      readState: () => state,
      writeState: writeState,
    );
    _runtimeBinder = resolved;
    return resolved;
  }

  ScanSpeedTracker get _resolvedSpeedTracker {
    final cached = _speedTracker;
    if (cached != null) {
      return cached;
    }
    final resolved = ScanSpeedTracker(
      rollingWindow: ref.read(scanSpeedRollingWindowProvider),
    );
    _speedTracker = resolved;
    return resolved;
  }

  DriveWorkspaceState? get currentValue => state.asData?.value;

  @override
  Future<DriveWorkspaceState> build() async {
    if (ref.watch(useMockAppDataProvider)) {
      return const DriveWorkspaceState(
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
        roots: const [],
        cacheSizeBytes: 0,
        syncProgress: null,
        isMutating: false,
        configurationMessage: null,
        errorMessage: null,
      );
    }

    ref.onDispose(() => unawaited(_runtimeBinder?.dispose()));

    await _workspaceLoader.restoreAccountSession();
    final initialState = await loadState();
    _workspaceRuntimeBinder.startWatchers();
    _workspaceRuntimeBinder.attach(initialState.syncProgress);
    if (initialState.canAccessDrive) {
      unawaited(ref.read(driveScanRunnerProvider).bootstrap());
    }
    return initialState;
  }

  Future<DriveWorkspaceState> loadState({
    bool isMutating = false,
    String? errorMessage,
  }) {
    return _workspaceLoader.loadState(
      isMutating: isMutating,
      errorMessage: errorMessage,
    );
  }

  void writeState(DriveWorkspaceState nextState) {
    if (!ref.mounted) {
      return;
    }
    state = AsyncData(nextState);
  }

  Future<void> replaceState(DriveWorkspaceState nextState) async {
    _workspaceRuntimeBinder.attach(nextState.syncProgress);
    writeState(nextState);
  }

  Future<void> refreshPreservingUiFlags() async {
    if (!ref.mounted) {
      return;
    }
    final currentState = state.asData?.value;
    final nextState = await loadState(
      isMutating: currentState?.isMutating ?? false,
      errorMessage: currentState?.errorMessage,
    );
    if (!ref.mounted) {
      return;
    }
    await replaceState(nextState);
  }

  void writeErrorState(
    Object error,
    StackTrace stackTrace, {
    required DriveWorkspaceState fallbackState,
  }) {
    if (!ref.mounted) {
      return;
    }
    state = AsyncError(error, stackTrace);
    state = AsyncData(fallbackState);
  }
}

final driveWorkspaceProvider =
    AsyncNotifierProvider<DriveWorkspaceNotifier, DriveWorkspaceState>(
      DriveWorkspaceNotifier.new,
    );

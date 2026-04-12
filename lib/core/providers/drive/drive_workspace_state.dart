import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../../../data/drive/drive_entities.dart';
import 'drive_sync_progress.dart';

class DriveWorkspaceState {
  const DriveWorkspaceState({
    required this.isConfigured,
    required this.account,
    required this.hasLinkedAccount,
    required this.canAccessDrive,
    required this.requiresReconnect,
    required this.authErrorMessage,
    required this.roots,
    required this.cacheSizeBytes,
    required this.syncProgress,
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
  final DriveSyncProgress? syncProgress;
  final bool isMutating;
  final String? configurationMessage;
  final String? errorMessage;

  bool get isConnected => canAccessDrive;
  bool get isBusy =>
      isMutating || (syncProgress != null && !syncProgress!.isPaused);

  DriveWorkspaceState copyWith({
    Value<DriveAccountProfile?>? account,
    bool? hasLinkedAccount,
    bool? canAccessDrive,
    bool? requiresReconnect,
    Value<String?>? authErrorMessage,
    List<SyncRoot>? roots,
    int? cacheSizeBytes,
    Value<DriveSyncProgress?>? syncProgress,
    bool? isMutating,
    String? configurationMessage,
    Value<String?>? errorMessage,
  }) {
    return DriveWorkspaceState(
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
      syncProgress: syncProgress == null
          ? this.syncProgress
          : syncProgress.value,
      isMutating: isMutating ?? this.isMutating,
      configurationMessage: configurationMessage ?? this.configurationMessage,
      errorMessage: errorMessage == null
          ? this.errorMessage
          : errorMessage.value,
    );
  }
}

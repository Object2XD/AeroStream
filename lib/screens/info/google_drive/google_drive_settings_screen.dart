import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/drive/drive_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/drive/drive_entities.dart';
import '../../../widgets/aero_page_scaffold.dart';

class GoogleDriveSettingsScreen extends HookConsumerWidget {
  const GoogleDriveSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final driveState = ref.watch(googleDriveControllerProvider);
    final controller = ref.read(googleDriveControllerProvider.notifier);

    return AeroPageScaffold(
      title: 'Google Drive',
      showBackButton: true,
      bodyTopPadding: 20,
      body: driveState.when(
        data: (state) {
          final errorBanner = state.errorMessage == null
              ? null
              : _InlineMessageBanner(
                  message: state.errorMessage!,
                  icon: Icons.error_outline_rounded,
                  isError: true,
                );

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;
              final liveSyncPanel = _LiveSyncPanel(state: state);
              final controlDock = _ControlDock(
                state: state,
                onConnect: controller.connect,
                onDisconnect: controller.disconnect,
                onSync: controller.enqueueSync,
                onAddFolder: () => _openFolderPicker(context, ref),
                onClearCache: controller.clearCache,
                onPause: state.scanProgress?.canPause == true
                    ? () => controller.pauseSync(state.scanProgress!.jobId)
                    : null,
                onResume: state.scanProgress?.canResume == true
                    ? () => controller.resumeSync(state.scanProgress!.jobId)
                    : null,
                onCancel: state.scanProgress?.canCancel == true
                    ? () => controller.cancelSync(state.scanProgress!.jobId)
                    : null,
              );
              final foldersSection = _FoldersSection(
                state: state,
                onRemove: controller.removeRoot,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EntranceReveal(child: _DriveHero(state: state)),
                  const SizedBox(height: 20),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: liveSyncPanel),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              controlDock,
                              if (errorBanner != null) ...[
                                const SizedBox(height: 16),
                                errorBanner,
                              ],
                              const SizedBox(height: 20),
                              foldersSection,
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    liveSyncPanel,
                    const SizedBox(height: 16),
                    controlDock,
                    if (errorBanner != null) ...[
                      const SizedBox(height: 16),
                      errorBanner,
                    ],
                    const SizedBox(height: 20),
                    foldersSection,
                  ],
                ],
              );
            },
          );
        },
        error: (error, stackTrace) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        loading: () => const SizedBox(
          height: 420,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Future<void> _openFolderPicker(BuildContext context, WidgetRef ref) async {
    final selectedFolder = await showModalBottomSheet<DriveFolderEntry>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DriveFolderPickerSheet(
        onLoadFolders: (parentId) => ref
            .read(googleDriveControllerProvider.notifier)
            .listFolders(parentId: parentId),
      ),
    );

    if (selectedFolder == null || !context.mounted) {
      return;
    }

    await ref
        .read(googleDriveControllerProvider.notifier)
        .addRoot(selectedFolder);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Added "${selectedFolder.name}" to sync roots.'),
        ),
      );
  }
}

class _EntranceReveal extends StatelessWidget {
  const _EntranceReveal({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _DriveHero extends StatelessWidget {
  const _DriveHero({required this.state});

  final GoogleDriveState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _heroTitle(state);
    final email = state.account?.email;
    final supportText = _heroSupportText(state);
    final bannerMessage = _heroBannerMessage(state);
    final statusLabel = _heroStatusLabel(state);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.28),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.82),
            theme.colorScheme.surfaceContainerHigh,
            theme.colorScheme.surfaceContainer,
          ],
          stops: const [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: -12,
            child: Icon(
              Icons.cloud_sync_rounded,
              size: 160,
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.08,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'GOOGLE DRIVE',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.96,
                        ),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _StatusBadge(
                    label: statusLabel,
                    icon: _heroStatusIcon(state),
                    highlight:
                        state.requiresReconnect || state.scanProgress != null,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                  height: 1.06,
                ),
              ),
              if (email != null) ...[
                const SizedBox(height: 10),
                Text(
                  email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.84,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  supportText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.9,
                    ),
                    height: 1.4,
                  ),
                ),
              ),
              if (bannerMessage != null) ...[
                const SizedBox(height: 18),
                _InlineMessageBanner(
                  message: bannerMessage,
                  icon: state.requiresReconnect
                      ? Icons.info_outline_rounded
                      : Icons.tune_rounded,
                  isError: state.requiresReconnect,
                  usePrimaryContainerTone: true,
                ),
              ],
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _HeroStatChip(
                    label: 'Folders',
                    value: state.roots.length.toString(),
                  ),
                  _HeroStatChip(
                    label: 'Cache',
                    value: formatBytes(state.cacheSizeBytes),
                  ),
                  _HeroStatChip(label: 'Status', value: statusLabel),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _heroTitle(GoogleDriveState state) {
    if (state.hasLinkedAccount) {
      return state.account!.displayName;
    }
    if (!state.isConfigured) {
      return 'Google Drive unavailable';
    }
    return 'Connect your library';
  }

  String _heroSupportText(GoogleDriveState state) {
    if (!state.isConfigured) {
      return state.configurationMessage ??
          'Google Drive is not configured for this build yet.';
    }
    if (!state.hasLinkedAccount) {
      return 'Connect your Google account to bring folders into Aero Stream and keep your library in step.';
    }
    if (state.requiresReconnect) {
      return 'Your saved session needs attention before Aero Stream can continue syncing the folders already selected.';
    }
    if (state.scanProgress != null) {
      return _phaseSubtitle(state.scanProgress!);
    }
    if (state.roots.isEmpty) {
      return 'Choose the folders you want Aero Stream to keep nearby, then start the first sync whenever you are ready.';
    }
    return 'Connected and ready to pull the next round of Drive changes into your local library.';
  }

  String? _heroBannerMessage(GoogleDriveState state) {
    if (state.requiresReconnect) {
      return state.authErrorMessage ?? driveSyncReconnectRequiredMessage;
    }
    return null;
  }
}

class _LiveSyncPanel extends StatelessWidget {
  const _LiveSyncPanel({required this.state});

  final GoogleDriveState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = state.scanProgress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'LIVE SYNC',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _StatusBadge(
                label: progress == null
                    ? _idleStatusLabel(state)
                    : progress.isPaused
                    ? 'Paused'
                    : 'Active',
                icon: progress == null
                    ? _idleStatusIcon(state)
                    : progress.isPaused
                    ? Icons.pause_circle_outline_rounded
                    : Icons.sync_rounded,
                highlight: progress != null || state.requiresReconnect,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: progress == null
                ? _IdleSyncContent(
                    key: const ValueKey('idle-sync'),
                    state: state,
                  )
                : _ActiveSyncContent(
                    key: ValueKey<String>(
                      '${progress.phase}:${progress.state}:${progress.failedCount}:${progress.indexedCount}:${progress.metadataReadyCount}:${progress.artworkReadyCount}',
                    ),
                    progress: progress,
                  ),
          ),
        ],
      ),
    );
  }

  String _idleStatusLabel(GoogleDriveState state) {
    if (!state.isConfigured) {
      return 'Unavailable';
    }
    if (!state.hasLinkedAccount) {
      return 'Offline';
    }
    if (state.requiresReconnect) {
      return 'Blocked';
    }
    if (state.roots.isEmpty) {
      return 'Waiting';
    }
    return 'Ready';
  }

  IconData _idleStatusIcon(GoogleDriveState state) {
    if (!state.isConfigured) {
      return Icons.cloud_off_rounded;
    }
    if (!state.hasLinkedAccount) {
      return Icons.account_circle_outlined;
    }
    if (state.requiresReconnect) {
      return Icons.warning_amber_rounded;
    }
    if (state.roots.isEmpty) {
      return Icons.folder_open_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }
}

class _IdleSyncContent extends StatelessWidget {
  const _IdleSyncContent({super.key, required this.state});

  final GoogleDriveState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _idleTitle(state),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _idleSubtitle(state),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.42,
          ),
        ),
      ],
    );
  }

  String _idleTitle(GoogleDriveState state) {
    if (!state.isConfigured) {
      return 'Configuration needed';
    }
    if (!state.hasLinkedAccount) {
      return 'Connection required';
    }
    if (state.requiresReconnect) {
      return 'Reconnect required';
    }
    if (state.roots.isEmpty) {
      return 'Choose a folder to sync';
    }
    return 'Ready for your next sync';
  }

  String _idleSubtitle(GoogleDriveState state) {
    if (!state.isConfigured) {
      return state.configurationMessage ??
          'This desktop build is missing the Google Drive configuration needed to connect.';
    }
    if (!state.hasLinkedAccount) {
      return 'Connect your account, then pick one or more folders to start building the library.';
    }
    if (state.requiresReconnect) {
      return 'Resume access to the saved session before Aero Stream can continue scanning or reading tags.';
    }
    if (state.roots.isEmpty) {
      return 'Your account is connected. Add a folder when you want Aero Stream to begin the first pass.';
    }
    return 'Everything is in place. Start a sync whenever you want the latest Drive changes reflected locally.';
  }
}

class _ActiveSyncContent extends StatelessWidget {
  const _ActiveSyncContent({super.key, required this.progress});

  final ScanProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailLine =
        progress.failedCount > 0 && progress.artworkReadyCount > 0
        ? 'Artwork ${formatCompactCount(progress.artworkReadyCount)} ready so far.'
        : null;
    final summaryMetrics = <_SyncMetric>[
      _SyncMetric(label: 'Indexed', exactValue: progress.indexedCount),
      _SyncMetric(label: 'Tags', exactValue: progress.metadataReadyCount),
      _SyncMetric(
        label: progress.failedCount > 0 ? 'Failed' : 'Artwork',
        exactValue: progress.failedCount > 0
            ? progress.failedCount
            : progress.artworkReadyCount,
        emphasize: progress.failedCount > 0,
        compact: progress.failedCount == 0,
      ),
    ];

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _phaseTitle(progress.phase),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.06,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _phaseSubtitle(progress),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.42,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: summaryMetrics
              .map((metric) => _SyncMetricPill(metric: metric))
              .toList(growable: false),
        ),
        if (detailLine != null) ...[
          const SizedBox(height: 14),
          Text(
            detailLine,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _ControlDock extends StatelessWidget {
  const _ControlDock({
    required this.state,
    required this.onConnect,
    required this.onDisconnect,
    required this.onSync,
    required this.onAddFolder,
    required this.onClearCache,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
  });

  final GoogleDriveState state;
  final Future<void> Function() onConnect;
  final Future<void> Function() onDisconnect;
  final Future<void> Function() onSync;
  final VoidCallback onAddFolder;
  final Future<void> Function() onClearCache;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryAction = _primaryLibraryAction();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTROLS',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (state.scanProgress != null) ...[
            const SizedBox(height: 14),
            Text(
              'Sync controls',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _DockActionButton(
                  tooltip: 'Pause sync',
                  icon: Icons.pause_circle_outline_rounded,
                  onPressed: onPause,
                  tone: _DockActionTone.tonal,
                ),
                _DockActionButton(
                  tooltip: 'Resume sync',
                  icon: Icons.play_circle_outline_rounded,
                  onPressed: onResume,
                  tone: _DockActionTone.tonal,
                ),
                _DockActionButton(
                  tooltip: 'Cancel sync',
                  icon: Icons.close_rounded,
                  onPressed: onCancel,
                  tone: _DockActionTone.dangerOutline,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: theme.colorScheme.outlineVariant),
          ],
          const SizedBox(height: 18),
          Text(
            'Library actions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DockActionButton(
                tooltip: primaryAction.tooltip,
                icon: primaryAction.icon,
                onPressed: primaryAction.onPressed,
                tone: _DockActionTone.filled,
              ),
              _DockActionButton(
                tooltip: 'Add folder',
                icon: Icons.create_new_folder_rounded,
                onPressed: state.isBusy || !state.canAccessDrive
                    ? null
                    : onAddFolder,
                tone: _DockActionTone.tonal,
              ),
              _DockActionButton(
                tooltip: 'Clear cache',
                icon: Icons.delete_sweep_rounded,
                onPressed: state.isBusy || state.cacheSizeBytes == 0
                    ? null
                    : () => onClearCache(),
                tone: _DockActionTone.tonal,
              ),
              _DockActionButton(
                tooltip: 'Disconnect',
                icon: Icons.link_off_rounded,
                onPressed: state.isBusy || !state.hasLinkedAccount
                    ? null
                    : () => onDisconnect(),
                tone: _DockActionTone.outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _PrimaryAction _primaryLibraryAction() {
    if (state.requiresReconnect) {
      return _PrimaryAction(
        tooltip: 'Reconnect',
        icon: Icons.sync_problem_rounded,
        onPressed: state.isBusy || !state.isConfigured
            ? null
            : () => onConnect(),
      );
    }
    if (state.canAccessDrive) {
      return _PrimaryAction(
        tooltip: 'Enqueue sync',
        icon: Icons.sync_rounded,
        onPressed: state.isBusy || !state.isConfigured ? null : () => onSync(),
      );
    }
    return _PrimaryAction(
      tooltip: 'Connect account',
      icon: Icons.account_circle_rounded,
      onPressed: state.isBusy || !state.isConfigured ? null : () => onConnect(),
    );
  }
}

class _FoldersSection extends StatelessWidget {
  const _FoldersSection({required this.state, required this.onRemove});

  final GoogleDriveState state;
  final Future<void> Function(int rootId) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Synced folders',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  state.roots.length == 1
                      ? '1 folder'
                      : '${state.roots.length} folders',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (state.roots.isEmpty)
            const _EmptyFoldersState()
          else
            Column(
              children: [
                for (var index = 0; index < state.roots.length; index++) ...[
                  _FolderRow(
                    root: state.roots[index],
                    onRemove: state.requiresReconnect || state.isBusy
                        ? null
                        : () => onRemove(state.roots[index].id),
                  ),
                  if (index < state.roots.length - 1)
                    Divider(
                      height: 24,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _FolderRow extends StatelessWidget {
  const _FolderRow({required this.root, required this.onRemove});

  final SyncRoot root;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counters = _rootCounters(root);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.folder_copy_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                root.folderName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _rootStatus(root),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              if (counters != null) ...[
                const SizedBox(height: 6),
                Text(
                  counters,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.88,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        _DockActionButton(
          tooltip: 'Remove folder',
          icon: Icons.close_rounded,
          onPressed: onRemove,
          tone: _DockActionTone.outline,
          compact: true,
        ),
      ],
    );
  }

  String _rootStatus(SyncRoot root) {
    return switch (root.syncState) {
      'queued' => 'Queued for sync',
      'running' => 'Sync in progress',
      'paused' => 'Sync paused',
      'failed' => _friendlyRootError(root.lastError) ?? 'Sync failed',
      'canceled' => 'Sync canceled',
      _ =>
        root.lastSyncedAt == null
            ? 'Waiting for first sync'
            : 'Last synced ${root.lastSyncedAt}',
    };
  }

  String? _rootCounters(SyncRoot root) {
    if (root.indexedCount == 0 &&
        root.metadataReadyCount == 0 &&
        root.artworkReadyCount == 0) {
      return null;
    }
    return '${formatCompactCount(root.indexedCount)} indexed · ${formatCompactCount(root.metadataReadyCount)} tags · ${formatCompactCount(root.artworkReadyCount)} artwork';
  }
}

class _EmptyFoldersState extends StatelessWidget {
  const _EmptyFoldersState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.create_new_folder_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'No folders are selected yet. Use the add-folder action above to choose the first Drive folder you want to keep in sync.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.highlight,
  });

  final String label;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = highlight
        ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.14)
        : theme.colorScheme.surface.withValues(alpha: 0.16);
    final foreground = highlight
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.78,
              ),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessageBanner extends StatelessWidget {
  const _InlineMessageBanner({
    required this.message,
    required this.icon,
    this.isError = false,
    this.usePrimaryContainerTone = false,
  });

  final String message;
  final IconData icon;
  final bool isError;
  final bool usePrimaryContainerTone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = usePrimaryContainerTone
        ? isError
              ? theme.colorScheme.errorContainer.withValues(alpha: 0.9)
              : theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.12)
        : isError
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.secondaryContainer;
    final foreground = usePrimaryContainerTone
        ? isError
              ? theme.colorScheme.onErrorContainer
              : theme.colorScheme.onPrimaryContainer
        : isError
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSecondaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: foreground, height: 1.38),
            ),
          ),
        ],
      ),
    );
  }
}

enum _DockActionTone { filled, tonal, outline, dangerOutline }

class _DockActionButton extends StatelessWidget {
  const _DockActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.tone,
    this.compact = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final _DockActionTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = compact ? 48.0 : 56.0;

    return Semantics(
      label: tooltip,
      button: true,
      enabled: onPressed != null,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: compact ? 20 : 22),
        style: ButtonStyle(
          fixedSize: WidgetStatePropertyAll<Size>(Size.square(size)),
          minimumSize: WidgetStatePropertyAll<Size>(Size.square(size)),
          padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            final disabled = states.contains(WidgetState.disabled);
            return switch (tone) {
              _DockActionTone.outline => BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(
                  alpha: disabled ? 0.35 : 0.9,
                ),
              ),
              _DockActionTone.dangerOutline => BorderSide(
                color: theme.colorScheme.error.withValues(
                  alpha: disabled ? 0.24 : 0.72,
                ),
              ),
              _ => null,
            };
          }),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            final disabled = states.contains(WidgetState.disabled);
            return switch (tone) {
              _DockActionTone.filled =>
                disabled
                    ? theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      )
                    : theme.colorScheme.primary,
              _DockActionTone.tonal =>
                disabled
                    ? theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      )
                    : theme.colorScheme.surfaceContainerHighest,
              _DockActionTone.outline => Colors.transparent,
              _DockActionTone.dangerOutline =>
                disabled
                    ? Colors.transparent
                    : theme.colorScheme.errorContainer.withValues(alpha: 0.18),
            };
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            final disabled = states.contains(WidgetState.disabled);
            return switch (tone) {
              _DockActionTone.filled =>
                disabled
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                    : theme.colorScheme.onPrimary,
              _DockActionTone.tonal =>
                disabled
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                    : theme.colorScheme.onSurface,
              _DockActionTone.outline =>
                disabled
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                    : theme.colorScheme.onSurface,
              _DockActionTone.dangerOutline =>
                disabled
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                    : theme.colorScheme.error,
            };
          }),
        ),
      ),
    );
  }
}

class _SyncMetricPill extends StatelessWidget {
  const _SyncMetricPill({required this.metric});

  final _SyncMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = metric.emphasize
        ? theme.colorScheme.errorContainer.withValues(alpha: 0.26)
        : theme.colorScheme.surfaceContainerHigh;
    final foreground = metric.emphasize
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    final displayValue = metric.compact
        ? formatCompactCount(metric.exactValue)
        : metric.exactValue.toString();

    return Tooltip(
      message: '${metric.label} ${formatExactCount(metric.exactValue)}',
      child: Semantics(
        label: '${metric.label} ${formatExactCount(metric.exactValue)}',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: metric.emphasize
                  ? theme.colorScheme.error.withValues(alpha: 0.34)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: metric.emphasize
                      ? theme.colorScheme.error.withValues(alpha: 0.9)
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                displayValue,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryAction {
  const _PrimaryAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
}

class _SyncMetric {
  const _SyncMetric({
    required this.label,
    required this.exactValue,
    this.emphasize = false,
    this.compact = true,
  });

  final String label;
  final int exactValue;
  final bool emphasize;
  final bool compact;
}

class _DriveFolderPickerSheet extends StatefulWidget {
  const _DriveFolderPickerSheet({required this.onLoadFolders});

  final Future<List<DriveFolderEntry>> Function(String parentId) onLoadFolders;

  @override
  State<_DriveFolderPickerSheet> createState() =>
      _DriveFolderPickerSheetState();
}

class _DriveFolderPickerSheetState extends State<_DriveFolderPickerSheet> {
  final List<DriveFolderEntry> _breadcrumbs = <DriveFolderEntry>[
    const DriveFolderEntry(id: 'root', name: 'My Drive', parentId: null),
  ];

  late Future<List<DriveFolderEntry>> _foldersFuture = _loadCurrentLevel();

  @override
  Widget build(BuildContext context) {
    final currentFolder = _breadcrumbs.last;
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose a sync folder',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Navigate your Drive folders, then confirm the one you want Aero Stream to keep in sync.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _DockActionButton(
                  tooltip: 'Use current folder',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () => Navigator.of(context).pop(currentFolder),
                  tone: _DockActionTone.filled,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.folder_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current folder',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentFolder.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_breadcrumbs.length > 1) ...[
                          const SizedBox(height: 4),
                          Text(
                            _breadcrumbs
                                .map((folder) => folder.name)
                                .join(' / '),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _breadcrumbs.length,
                separatorBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),
                itemBuilder: (context, index) {
                  final breadcrumb = _breadcrumbs[index];
                  final isCurrent = index == _breadcrumbs.length - 1;
                  return FilledButton.tonal(
                    onPressed: isCurrent
                        ? null
                        : () => _jumpToBreadcrumb(index),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: isCurrent
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.surfaceContainerLow,
                      foregroundColor: isCurrent
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                    child: Text(breadcrumb.name),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Container(
                  key: ValueKey<String>(currentFolder.id),
                  constraints: const BoxConstraints(minHeight: 200),
                  child: FutureBuilder<List<DriveFolderEntry>>(
                    future: _foldersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            snapshot.error.toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        );
                      }

                      final folders =
                          snapshot.data ?? const <DriveFolderEntry>[];
                      if (folders.isEmpty) {
                        return Center(
                          child: Text(
                            'No subfolders found here.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: folders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            tileColor: theme.colorScheme.surfaceContainerLow,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.folder_copy_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            title: Text(
                              folder.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              'Open folder',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _openFolder(folder),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<DriveFolderEntry>> _loadCurrentLevel() {
    return widget.onLoadFolders(_breadcrumbs.last.id);
  }

  Future<void> _openFolder(DriveFolderEntry folder) async {
    setState(() {
      _breadcrumbs.add(folder);
      _foldersFuture = _loadCurrentLevel();
    });
  }

  void _jumpToBreadcrumb(int index) {
    setState(() {
      _breadcrumbs.removeRange(index + 1, _breadcrumbs.length);
      _foldersFuture = _loadCurrentLevel();
    });
  }
}

String _heroStatusLabel(GoogleDriveState state) {
  if (!state.isConfigured) {
    return 'Unavailable';
  }
  if (!state.hasLinkedAccount) {
    return 'Not connected';
  }
  if (state.requiresReconnect) {
    return 'Reconnect required';
  }
  if (state.scanProgress != null) {
    return _jobStateLabel(state.scanProgress!);
  }
  return state.roots.isEmpty ? 'Choose folders' : 'Ready';
}

IconData _heroStatusIcon(GoogleDriveState state) {
  if (!state.isConfigured) {
    return Icons.cloud_off_rounded;
  }
  if (!state.hasLinkedAccount) {
    return Icons.account_circle_outlined;
  }
  if (state.requiresReconnect) {
    return Icons.sync_problem_rounded;
  }
  if (state.scanProgress != null) {
    return state.scanProgress!.isPaused
        ? Icons.pause_circle_outline_rounded
        : Icons.sync_rounded;
  }
  return state.roots.isEmpty
      ? Icons.folder_open_rounded
      : Icons.check_circle_outline_rounded;
}

String _jobStateLabel(ScanProgress progress) {
  if (progress.isPaused) {
    return 'Paused';
  }
  return switch (progress.phase) {
    'baseline_discovery' => 'Discovering',
    'incremental_changes' => 'Applying changes',
    'metadata_enrichment' => 'Reading tags',
    'artwork_enrichment' => 'Fetching artwork',
    'finalize' => 'Finalizing',
    _ => 'Queued',
  };
}

String _phaseTitle(String phase) {
  return switch (phase) {
    'baseline_discovery' => 'Discovering files',
    'incremental_changes' => 'Applying Drive changes',
    'metadata_enrichment' => 'Extracting metadata',
    'artwork_enrichment' => 'Collecting artwork',
    'finalize' => 'Finalizing library',
    _ => 'Queued',
  };
}

String _phaseSubtitle(ScanProgress progress) {
  if (progress.isPaused) {
    return 'The current sync is paused. Resume when you want Aero Stream to continue the next phase.';
  }
  return switch (progress.phase) {
    'baseline_discovery' =>
      'Scanning the selected folders and indexing newly discovered files.',
    'incremental_changes' =>
      'Applying the latest Google Drive changes to the local library state.',
    'metadata_enrichment' =>
      'Reading tags across your selected folders and tightening up the library metadata.',
    'artwork_enrichment' =>
      'Collecting artwork for the tracks that already have their tags in place.',
    'finalize' =>
      'Wrapping up the current pass and saving the final library state locally.',
    _ => 'Preparing the next sync pass.',
  };
}

String? _friendlyRootError(String? rawError) {
  if (rawError == null || rawError.isEmpty) {
    return null;
  }
  final normalized = rawError.toLowerCase();
  if (normalized.contains('pathaccessexception') ||
      normalized.contains('flutter_secure_storage.dat') ||
      normalized.contains('cryptunprotectdata')) {
    return driveSyncReconnectRequiredMessage;
  }
  return rawError;
}

@visibleForTesting
String formatCompactCount(int count) {
  if (count < 1000) {
    return '$count';
  }
  if (count < 10000) {
    return '${_formatCompactDecimal(count / 1000)}K';
  }
  if (count < 1000000) {
    return '${(count / 1000).round()}K';
  }
  return '${_formatCompactDecimal(count / 1000000)}M';
}

String _formatCompactDecimal(double value) {
  final fixed = ((value * 10).floor() / 10).toStringAsFixed(1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}

String formatExactCount(int count) {
  final digits = count.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

String formatBytes(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }

  const units = <String>['B', 'KB', 'MB', 'GB'];
  double value = bytes.toDouble();
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  return '${value.toStringAsFixed(value >= 10 || unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
}

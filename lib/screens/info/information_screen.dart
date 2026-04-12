import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_routes.dart';
import '../../core/permissions/notification_permission_state.dart';
import '../../core/providers/app_settings_controller.dart';
import '../../core/providers/drive/drive_providers.dart';
import '../../data/mock_info.dart';
import '../../models/info_models.dart';
import '../../widgets/aero_page_scaffold.dart';
import '../../widgets/info_panels.dart';
import '../../widgets/info_stats_grid.dart';
import '../../widgets/list_row.dart';

class InformationScreen extends HookConsumerWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final driveState = ref.watch(driveWorkspaceProvider);
    final infoStatsValue = ref.watch(libraryInfoStatsProvider);

    final dynamicStats = infoStatsValue.asData?.value;
    final statsItems = <InfoStatItem>[
      InfoStatItem(
        label: 'Total Listening Time',
        value: _formatListeningHours(dynamicStats?.totalListeningMinutes ?? 0),
        icon: Icons.history_rounded,
        routeName: AppRoutes.infoListeningTime,
      ),
      InfoStatItem(
        label: 'Songs Played',
        value: '${dynamicStats?.trackCount ?? 0}',
        icon: Icons.music_note_rounded,
        routeName: AppRoutes.infoSongsPlayed,
      ),
      InfoStatItem(
        label: 'Synced Folders',
        value: '${dynamicStats?.connectedRoots ?? 0}',
        icon: Icons.folder_copy_rounded,
      ),
      InfoStatItem(
        label: 'Favorite Songs',
        value: '${dynamicStats?.favoriteCount ?? 0}',
        icon: Icons.favorite_rounded,
      ),
    ];

    Future<void> handleNotificationToggle(bool value) async {
      final message = await ref
          .read(appSettingsProvider.notifier)
          .setNotificationsEnabled(value);
      if (!context.mounted) {
        return;
      }

      final updatedState = ref.read(appSettingsProvider);
      final action =
          updatedState.notificationPermissionState ==
              NotificationPermissionState.permanentlyDenied
          ? SnackBarAction(
              label: 'Settings',
              onPressed: () {
                unawaited(
                  ref.read(appSettingsProvider.notifier).openSystemSettings(),
                );
              },
            )
          : null;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message), action: action));
    }

    return AeroPageScaffold(
      title: 'Information',
      bodyTopPadding: 24,
      scrollViewKey: const ValueKey('information-scroll-view'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          InfoStatsGrid(
            items: statsItems,
            onItemTap: (item) {
              if (item.routeName == null) {
                return;
              }
              context.push(item.routeName!);
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Google Drive',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          InfoSectionCard(
            children: [
              ListRow(
                title: 'Drive Connection',
                subtitle: _driveSubtitle(driveState),
                leading: Icon(
                  Icons.cloud_sync_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onTap: () => context.push(AppRoutes.infoGoogleDrive),
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          InfoSectionCard(
            children: infoSettings.map((item) {
              return _buildSettingRow(
                context,
                settings,
                item,
                onNotificationToggle: handleNotificationToggle,
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          InfoSectionCard(
            children: infoOptions.map((item) {
              return ListRow(
                title: item.title,
                leading: Icon(
                  item.icon,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                onTap: () => debugPrint('Option tapped: ${item.id}'),
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context,
    AppSettingsState settings,
    InfoSettingItem item, {
    required ValueChanged<bool> onNotificationToggle,
  }) {
    final theme = Theme.of(context);

    if (item.hasSwitch) {
      return ListRow(
        title: item.title,
        subtitle: _notificationSubtitle(settings.notificationPermissionState),
        leading: Icon(
          item.icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 24,
        ),
        trailing: SizedBox(
          width: 52,
          child: Switch(
            value: settings.notificationsEnabled,
            onChanged: settings.isUpdatingNotifications
                ? null
                : (value) => onNotificationToggle(value),
          ),
        ),
        onTap: settings.isUpdatingNotifications
            ? null
            : () => onNotificationToggle(!settings.notificationsEnabled),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      );
    }

    return ListRow(
      title: item.title,
      subtitle: item.subtitle,
      leading: Icon(
        item.icon,
        color: theme.colorScheme.onSurfaceVariant,
        size: 24,
      ),
      onTap: () => debugPrint('Setting tapped: ${item.id}'),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    );
  }

  String _notificationSubtitle(NotificationPermissionState state) {
    return switch (state) {
      NotificationPermissionState.granted => 'Enabled',
      NotificationPermissionState.notRequired =>
        'Available without a runtime permission prompt',
      NotificationPermissionState.permanentlyDenied =>
        'Blocked in system settings',
      NotificationPermissionState.unsupported => 'Unavailable on this platform',
      NotificationPermissionState.denied => 'Off',
    };
  }

  String _driveSubtitle(AsyncValue<DriveWorkspaceState> state) {
    return state.when(
      data: (value) {
        if (!value.isConfigured && value.configurationMessage != null) {
          return value.configurationMessage!;
        }
        if (!value.hasLinkedAccount) {
          return 'Not connected';
        }
        if (value.requiresReconnect) {
          return '${value.account!.email} • reconnect required';
        }
        final progress = value.syncProgress;
        if (progress != null) {
          final phase = switch (progress.phase) {
            'baseline_discovery' => 'discovering files',
            'incremental_changes' => 'applying changes',
            'metadata_enrichment' => 'reading tags',
            'artwork_enrichment' => 'fetching artwork',
            'finalize' => 'finalizing',
            _ => 'working',
          };
          return '${value.account!.email} • $phase • ${progress.indexedCount} indexed';
        }
        final rootLabel = value.roots.isEmpty
            ? 'No folders selected'
            : '${value.roots.length} synced folder(s)';
        return '${value.account!.email} • $rootLabel';
      },
      error: (error, stackTrace) => error.toString(),
      loading: () => 'Checking connection…',
    );
  }

  String _formatListeningHours(int totalMinutes) {
    if (totalMinutes <= 0) {
      return '0 hours';
    }

    final hours = totalMinutes / 60;
    return '${hours.toStringAsFixed(hours >= 10 ? 0 : 1)} hours';
  }
}

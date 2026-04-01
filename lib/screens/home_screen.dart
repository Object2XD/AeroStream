import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app_routes.dart';
import '../core/providers/mini_player_controller.dart';
import '../core/providers/drive/drive_providers.dart';
import '../data/mock_media.dart';
import '../widgets/aero_page_scaffold.dart';
import '../widgets/feature_placeholder_view.dart';
import '../widgets/now_playing_panel.dart';
import '../widgets/playlist_grid.dart';
import '../widgets/quick_action_chips.dart';
import '../widgets/recent_track_list.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final miniPlayer = ref.watch(miniPlayerControllerProvider);
    final recentTracksValue = ref.watch(recentTracksProvider);

    return AeroPageScaffold(
      title: 'Music',
      scrollViewKey: const ValueKey('home-scroll-view'),
      actions: [
        IconButton(
          onPressed: () => debugPrint('Search tapped'),
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          onPressed: () => debugPrint('Notifications tapped'),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 8),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (miniPlayer.currentTrack != null)
            NowPlayingPanel(track: miniPlayer.currentTrack!)
          else
            _EmptyNowPlayingCard(
              onOpenInfo: () => context.go(AppRoutes.info),
            ),
          const SizedBox(height: 24),
          const QuickActionChips(actions: quickActions),
          const SizedBox(height: 32),
          Text(
            'Recently Played',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          recentTracksValue.when(
            data: (tracks) {
              if (tracks.isEmpty) {
                return const FeaturePlaceholderView(
                  icon: Icons.cloud_off_rounded,
                  eyebrow: 'GOOGLE DRIVE',
                  title: 'Connect your library',
                  description:
                      'Use the Info tab to connect Google Drive and sync your music collection.',
                );
              }

              final activeIndex = miniPlayer.currentTrack == null
                  ? 0
                  : tracks.indexWhere(
                      (track) => track.id == miniPlayer.currentTrack!.id,
                    );
              return RecentTrackList(
                tracks: tracks,
                activeIndex: activeIndex < 0 ? 0 : activeIndex,
                onTrackTap: (track) {
                  ref
                      .read(miniPlayerControllerProvider.notifier)
                      .playTrack(track, queue: tracks);
                },
              );
            },
            error: (error, stackTrace) {
              return FeaturePlaceholderView(
                icon: Icons.error_outline_rounded,
                eyebrow: 'RECENT TRACKS',
                title: 'Could not load your library',
                description: error.toString(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 32),
          Text(
            'Your Playlists',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          const PlaylistGrid(playlists: playlists),
        ],
      ),
    );
  }
}

class _EmptyNowPlayingCard extends StatelessWidget {
  const _EmptyNowPlayingCard({
    required this.onOpenInfo,
  });

  final VoidCallback onOpenInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.cloud_sync_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GOOGLE DRIVE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.84,
                    ),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect your music library',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Open Info to sign in and choose the folders you want to sync.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.82,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: onOpenInfo,
                  child: const Text('Open Info'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

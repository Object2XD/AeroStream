import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_routes.dart';
import '../../core/providers/mini_player_controller.dart';
import '../../widgets/feature_placeholder_view.dart';
import '../../models/track_item.dart';
import 'playback_overlay_scaffold.dart';
import 'player_screen_content.dart';

class PlayerScreen extends HookConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(miniPlayerControllerProvider);
    final controller = ref.read(miniPlayerControllerProvider.notifier);
    final dragValue = useState<double?>(null);
    final displayedPosition = dragValue.value ?? playback.positionSeconds;
    final currentTrack = playback.currentTrack;

    return PlaybackOverlayScaffold(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4B386B), Color(0xFF1B1C22), Color(0xFF111318)],
          stops: [0, 0.45, 1],
        ),
      ),
      specBuilder: PlaybackOverlayLayoutSpec.player,
      childBuilder: (context, layoutSpec) {
        if (currentTrack == null) {
          return const Center(
            child: FeaturePlaceholderView(
              icon: Icons.music_off_rounded,
              eyebrow: 'PLAYER',
              title: 'Nothing is playing',
              description:
                  'Choose a track from your synced library to start playback.',
            ),
          );
        }

        return PlayerScreenContent(
          layoutSpec: layoutSpec,
          track: currentTrack,
          isFavorite: playback.isFavorite,
          isPlaying: playback.isPlaying,
          displayedPosition: displayedPosition,
          maxPosition: playback.currentDurationSeconds,
          elapsedLabel: formatTrackTimestamp(displayedPosition),
          durationLabel: playback.durationLabel,
          upNextCount: playback.upNextCount,
          onClose: () =>
              closePlaybackOverlay(context, fallbackRoute: AppRoutes.home),
          onMore: () => showPlaybackOverlayPlaceholder(
            context,
            'Player actions are coming soon.',
          ),
          onFavoriteToggle: controller.toggleFavorite,
          onSeekChanged: (value) => dragValue.value = value,
          onSeekChangeEnd: (value) {
            controller.seekTo(value);
            dragValue.value = null;
          },
          onShuffle: () => showPlaybackOverlayPlaceholder(
            context,
            'Shuffle controls are coming soon.',
          ),
          onPrevious: controller.playPrevious,
          onPlayPause: controller.togglePlayPause,
          onNext: controller.playNext,
          onRepeat: () => showPlaybackOverlayPlaceholder(
            context,
            'Repeat controls are coming soon.',
          ),
          onUpNextTap: () => context.push(AppRoutes.queue),
        );
      },
    );
  }
}

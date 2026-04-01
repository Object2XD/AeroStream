import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_routes.dart';
import '../../core/providers/mini_player_controller.dart';
import '../../models/track_item.dart';
import '../../widgets/feature_placeholder_view.dart';
import 'playback_overlay_scaffold.dart';
import 'queue_screen_content.dart';

class QueueScreen extends HookConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playback = ref.watch(miniPlayerControllerProvider);
    final controller = ref.read(miniPlayerControllerProvider.notifier);

    return PlaybackOverlayScaffold(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surfaceContainerLow,
            theme.colorScheme.surface,
          ],
        ),
      ),
      specBuilder: PlaybackOverlayLayoutSpec.queue,
      childBuilder: (context, layoutSpec) {
        if (playback.queue.isEmpty) {
          return const Center(
            child: FeaturePlaceholderView(
              icon: Icons.queue_music_rounded,
              eyebrow: 'QUEUE',
              title: 'Your queue is empty',
              description:
                  'Start playback from the Library or Home tab to build a queue.',
            ),
          );
        }

        return QueueScreenContent(
          layoutSpec: layoutSpec,
          queue: playback.queue,
          currentIndex: playback.currentIndex,
          totalDurationLabel: formatQueueDuration(playback.queue),
          onClose: () =>
              closePlaybackOverlay(context, fallbackRoute: AppRoutes.player),
          onSave: () => showPlaybackOverlayPlaceholder(
            context,
            'Saving queues as playlists is coming soon.',
          ),
          onTrackTap: (index) {
            controller.playFromQueueIndex(index);
            closePlaybackOverlay(context, fallbackRoute: AppRoutes.player);
          },
          onReorderTap: () => showPlaybackOverlayPlaceholder(
            context,
            'Queue reordering is coming soon.',
          ),
        );
      },
    );
  }
}

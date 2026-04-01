import 'package:flutter/material.dart';

import '../../models/track_item.dart';
import '../../widgets/network_cover_image.dart';
import 'playback_overlay_scaffold.dart';

class QueueScreenContent extends StatelessWidget {
  const QueueScreenContent({
    super.key,
    required this.layoutSpec,
    required this.queue,
    required this.currentIndex,
    required this.totalDurationLabel,
    required this.onClose,
    required this.onSave,
    required this.onTrackTap,
    required this.onReorderTap,
  });

  final PlaybackOverlayLayoutSpec layoutSpec;
  final List<TrackItem> queue;
  final int currentIndex;
  final String totalDurationLabel;
  final VoidCallback onClose;
  final VoidCallback onSave;
  final ValueChanged<int> onTrackTap;
  final VoidCallback onReorderTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QueueHeader(onClose: onClose, onSave: onSave),
        const SizedBox(height: 16),
        QueueSummaryRow(
          queueCount: queue.length,
          totalDurationLabel: totalDurationLabel,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: QueueListPanel(
            queue: queue,
            currentIndex: currentIndex,
            dividerColor: theme.colorScheme.outlineVariant.withValues(
              alpha: 0.32,
            ),
            onTrackTap: onTrackTap,
            onReorderTap: onReorderTap,
          ),
        ),
      ],
    );
  }
}

class QueueHeader extends StatelessWidget {
  const QueueHeader({super.key, required this.onClose, required this.onSave});

  final VoidCallback onClose;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          color: theme.colorScheme.onSurface,
        ),
        Expanded(
          child: Center(
            child: Text(
              'Queue',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onSave,
          icon: const Icon(Icons.playlist_add_rounded),
          color: theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}

class QueueSummaryRow extends StatelessWidget {
  const QueueSummaryRow({
    super.key,
    required this.queueCount,
    required this.totalDurationLabel,
  });

  final int queueCount;
  final String totalDurationLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'QUEUE ($queueCount)',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          totalDurationLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class QueueListPanel extends StatelessWidget {
  const QueueListPanel({
    super.key,
    required this.queue,
    required this.currentIndex,
    required this.dividerColor,
    required this.onTrackTap,
    required this.onReorderTap,
  });

  final List<TrackItem> queue;
  final int currentIndex;
  final Color dividerColor;
  final ValueChanged<int> onTrackTap;
  final VoidCallback onReorderTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: queue.length,
        separatorBuilder: (context, index) {
          return Divider(
            height: 1,
            indent: 88,
            endIndent: 16,
            color: dividerColor,
          );
        },
        itemBuilder: (context, index) {
          final track = queue[index];

          return QueueRow(
            track: track,
            isCurrent: index == currentIndex,
            onTap: () => onTrackTap(index),
            onReorderTap: onReorderTap,
          );
        },
      ),
    );
  }
}

class QueueRow extends StatelessWidget {
  const QueueRow({
    super.key,
    required this.track,
    required this.isCurrent,
    required this.onTap,
    required this.onReorderTap,
  });

  final TrackItem track;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onReorderTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isCurrent
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NetworkCoverImage(
                  imageUrl: track.imageUrl,
                  width: 48,
                  height: 48,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isCurrent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isCurrent
                            ? theme.colorScheme.primary.withValues(alpha: 0.82)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent) ...[
                Icon(
                  Icons.graphic_eq_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                track.durationLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                onPressed: onReorderTap,
                icon: Icon(
                  Icons.drag_handle_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

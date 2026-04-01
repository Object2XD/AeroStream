import 'package:flutter/material.dart';

import '../models/track_item.dart';
import 'network_cover_image.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    required this.track,
    required this.progress,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onOpen,
    required this.onNext,
  });

  final TrackItem track;
  final double progress;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onOpen;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    const miniPlayerRadius = 16.0;
    const progressHeight = 2.0;
    const progressHorizontalInset = miniPlayerRadius;
    const contentHorizontalPadding = 16.0;
    const contentTopPadding = 12.0;
    const contentBottomPadding = 12.0;

    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(miniPlayerRadius),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(miniPlayerRadius),
        onTap: onOpen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: progressHorizontalInset,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0).toDouble(),
                    minHeight: progressHeight,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.72),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                contentHorizontalPadding,
                contentTopPadding,
                contentHorizontalPadding,
                contentBottomPadding,
              ),
              child: Row(
                children: [
                  NetworkCoverImage(
                    imageUrl: track.imageUrl,
                    width: 48,
                    height: 48,
                    borderRadius: 16,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _MiniPlayerIconButton(
                    icon: isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onTap: onPlayPause,
                    selected: isPlaying,
                  ),
                  const SizedBox(width: 4),
                  _MiniPlayerIconButton(
                    icon: Icons.skip_next_rounded,
                    onTap: onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayerIconButton extends StatelessWidget {
  const _MiniPlayerIconButton({
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkResponse(
      onTap: onTap,
      radius: 22,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.secondaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 22,
          color: selected
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

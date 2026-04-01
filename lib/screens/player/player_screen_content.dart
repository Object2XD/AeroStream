import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/track_item.dart';
import '../../widgets/network_cover_image.dart';
import 'playback_overlay_scaffold.dart';

class PlayerScreenContent extends StatelessWidget {
  const PlayerScreenContent({
    super.key,
    required this.layoutSpec,
    required this.track,
    required this.isFavorite,
    required this.isPlaying,
    required this.displayedPosition,
    required this.maxPosition,
    required this.elapsedLabel,
    required this.durationLabel,
    required this.upNextCount,
    required this.onClose,
    required this.onMore,
    required this.onFavoriteToggle,
    required this.onSeekChanged,
    required this.onSeekChangeEnd,
    required this.onShuffle,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onRepeat,
    required this.onUpNextTap,
  });

  final PlaybackOverlayLayoutSpec layoutSpec;
  final TrackItem track;
  final bool isFavorite;
  final bool isPlaying;
  final double displayedPosition;
  final double maxPosition;
  final String elapsedLabel;
  final String durationLabel;
  final int upNextCount;
  final VoidCallback onClose;
  final VoidCallback onMore;
  final VoidCallback onFavoriteToggle;
  final ValueChanged<double> onSeekChanged;
  final ValueChanged<double> onSeekChangeEnd;
  final VoidCallback onShuffle;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onRepeat;
  final VoidCallback onUpNextTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlayerHeader(onClose: onClose, onMore: onMore),
        SizedBox(height: layoutSpec.verticalSpacing),
        Expanded(
          child: Center(
            child: PlayerArtwork(
              imageUrl: track.imageUrl,
              artworkSize: layoutSpec.artworkSize,
            ),
          ),
        ),
        SizedBox(height: layoutSpec.verticalSpacing),
        PlayerTrackInfoRow(
          track: track,
          isFavorite: isFavorite,
          onFavoriteToggle: onFavoriteToggle,
        ),
        SizedBox(height: layoutSpec.verticalSpacing),
        PlayerPlaybackSlider(
          value: displayedPosition,
          max: maxPosition,
          elapsedLabel: elapsedLabel,
          durationLabel: durationLabel,
          onChanged: onSeekChanged,
          onChangeEnd: onSeekChangeEnd,
        ),
        SizedBox(height: layoutSpec.verticalSpacing - 4),
        PlayerTransportControls(
          isPlaying: isPlaying,
          onShuffle: onShuffle,
          onPrevious: onPrevious,
          onPlayPause: onPlayPause,
          onNext: onNext,
          onRepeat: onRepeat,
        ),
        SizedBox(height: layoutSpec.verticalSpacing),
        PlayerUpNextButton(upNextCount: upNextCount, onTap: onUpNextTap),
      ],
    );
  }
}

class PlayerHeader extends StatelessWidget {
  const PlayerHeader({super.key, required this.onClose, required this.onMore});

  final VoidCallback onClose;
  final VoidCallback onMore;

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
              'NOW PLAYING',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onMore,
          icon: const Icon(Icons.more_vert_rounded),
          color: theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}

class PlayerArtwork extends StatelessWidget {
  const PlayerArtwork({
    super.key,
    required this.imageUrl,
    required this.artworkSize,
  });

  final String imageUrl;
  final double artworkSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: artworkSize,
        height: artworkSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: NetworkCoverImage(
            imageUrl: imageUrl,
            width: artworkSize,
            height: artworkSize,
            borderRadius: 28,
          ),
        ),
      ),
    );
  }
}

class PlayerTrackInfoRow extends StatelessWidget {
  const PlayerTrackInfoRow({
    super.key,
    required this.track,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final TrackItem track;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: onFavoriteToggle,
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          ),
          color: isFavorite
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}

class PlayerPlaybackSlider extends StatelessWidget {
  const PlayerPlaybackSlider({
    super.key,
    required this.value,
    required this.max,
    required this.elapsedLabel,
    required this.durationLabel,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double value;
  final double max;
  final String elapsedLabel;
  final String durationLabel;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.onSurfaceVariant.withValues(
              alpha: 0.28,
            ),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.18),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value.clamp(0, max).toDouble(),
            max: math.max(max, 1),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                elapsedLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                durationLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PlayerTransportControls extends StatelessWidget {
  const PlayerTransportControls({
    super.key,
    required this.isPlaying,
    required this.onShuffle,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onRepeat,
  });

  final bool isPlaying;
  final VoidCallback onShuffle;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onShuffle,
          icon: const Icon(Icons.shuffle_rounded),
          color: theme.colorScheme.onSurfaceVariant,
        ),
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.skip_previous_rounded),
          iconSize: 34,
          color: theme.colorScheme.onSurface,
        ),
        SizedBox(
          width: 72,
          height: 72,
          child: FilledButton(
            onPressed: onPlayPause,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 36,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.skip_next_rounded),
          iconSize: 34,
          color: theme.colorScheme.onSurface,
        ),
        IconButton(
          onPressed: onRepeat,
          icon: const Icon(Icons.repeat_rounded),
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class PlayerUpNextButton extends StatelessWidget {
  const PlayerUpNextButton({
    super.key,
    required this.upNextCount,
    required this.onTap,
  });

  final int upNextCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = upNextCount == 1
        ? '1 song in queue'
        : '$upNextCount songs in queue';

    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.queue_music_rounded,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Up Next',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.82,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_up_rounded,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_routes.dart';
import '../../core/providers/drive/drive_providers.dart';
import '../../core/providers/mini_player_controller.dart';
import '../../models/track_item.dart';
import '../../widgets/feature_placeholder_view.dart';
import '../../widgets/media_list_row.dart';
import '../../widgets/network_cover_image.dart';

const double _kAlbumDetailBottomSpacing = 32.0;
const double _kAlbumDetailNotFoundBottomSpacing = 16.0;

class AlbumDetailScreen extends HookConsumerWidget {
  const AlbumDetailScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumDetailValue = ref.watch(albumDetailProvider(albumId));
    final albumDetail = albumDetailValue.asData?.value;

    if (albumDetailValue.hasError) {
      return const _AlbumDetailNotFoundView();
    }

    if (albumDetailValue.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (albumDetail == null) {
      return const _AlbumDetailNotFoundView();
    }

    final theme = Theme.of(context);
    final album = albumDetail.album;
    final albumTracks = albumDetail.tracks;

    void showPlaceholder(String message) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    void playAlbumQueue(List<TrackItem> queue) {
      if (queue.isEmpty) {
        return;
      }

      ref
          .read(miniPlayerControllerProvider.notifier)
          .playTrack(queue.first, queue: queue);
      context.push(AppRoutes.player);
    }

    void playTrack(TrackItem track) {
      ref
          .read(miniPlayerControllerProvider.notifier)
          .playTrack(track, queue: albumTracks);
      context.push(AppRoutes.player);
    }

    void shuffleAlbum() {
      final shuffledQueue = [...albumTracks]..shuffle();
      playAlbumQueue(shuffledQueue);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(
          color: theme.colorScheme.onSurface,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            onPressed: () => showPlaceholder('Album actions are coming soon.'),
            icon: const Icon(Icons.more_vert_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 840 ? 32.0 : 16.0;
          final contentMaxWidth = constraints.maxWidth >= 840
              ? 640.0
              : double.infinity;

          return SingleChildScrollView(
            key: const ValueKey('album-detail-scroll-view'),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              _kAlbumDetailBottomSpacing,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AlbumHero(
                      title: album.title,
                      artist: album.artist,
                      year: album.year,
                      imageUrl: album.imageUrl,
                      songCount: albumTracks.length,
                      onArtistTap: () =>
                          showPlaceholder('Artist details are coming soon.'),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: albumTracks.isEmpty
                                ? null
                                : () => playAlbumQueue(albumTracks),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Play'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: albumTracks.isEmpty
                                ? null
                                : shuffleAlbum,
                            icon: const Icon(Icons.shuffle_rounded),
                            label: const Text('Shuffle'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        for (
                          var index = 0;
                          index < albumTracks.length;
                          index++
                        ) ...[
                          MediaListRow(
                            title: albumTracks[index].title,
                            subtitle: albumTracks[index].artist,
                            imageUrl: albumTracks[index].imageUrl,
                            itemKey: ValueKey(
                              'album-detail-track-${albumTracks[index].id}',
                            ),
                            onTap: () => playTrack(albumTracks[index]),
                            trailing: TrackRowTrailing(
                              durationLabel: albumTracks[index].durationLabel,
                              buttonKey: ValueKey(
                                'album-detail-track-menu-${albumTracks[index].id}',
                              ),
                              onMenuTap: () => showPlaceholder(
                                'Song actions are coming soon.',
                              ),
                            ),
                          ),
                          if (index < albumTracks.length - 1)
                            const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AlbumHero extends StatelessWidget {
  const _AlbumHero({
    required this.title,
    required this.artist,
    required this.year,
    required this.imageUrl,
    required this.songCount,
    required this.onArtistTap,
  });

  final String title;
  final String artist;
  final int year;
  final String imageUrl;
  final int songCount;
  final VoidCallback onArtistTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: NetworkCoverImage(
              imageUrl: imageUrl,
              width: 240,
              height: 240,
              borderRadius: 20,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onArtistTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              artist,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Album • $year • $songCount songs',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumDetailNotFoundView extends StatelessWidget {
  const _AlbumDetailNotFoundView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(
          color: theme.colorScheme.onSurface,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          _kAlbumDetailNotFoundBottomSpacing,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: const FeaturePlaceholderView(
              icon: Icons.album_outlined,
              eyebrow: 'ALBUM',
              title: 'Album not found',
              description:
                  'This album could not be loaded. Try returning to your library and opening another album.',
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/playlist_item.dart';
import 'network_cover_image.dart';

class PlaylistGrid extends StatelessWidget {
  const PlaylistGrid({super.key, required this.playlists});

  final List<PlaylistItem> playlists;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 720 ? 3 : 2;
        final crossAxisSpacing = width >= 720 ? 16.0 : 12.0;
        final mainAxisSpacing = width >= 720 ? 24.0 : 16.0;
        final childAspectRatio = width >= 720 ? 0.96 : 0.87;

        return GridView.builder(
          itemCount: playlists.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return InkWell(
              onTap: () => debugPrint('Playlist tapped: ${playlist.name}'),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: NetworkCoverImage(
                      imageUrl: playlist.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.songCount} songs',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

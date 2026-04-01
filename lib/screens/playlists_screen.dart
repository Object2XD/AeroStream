import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../widgets/aero_page_scaffold.dart';
import '../widgets/feature_placeholder_view.dart';

class PlaylistsScreen extends HookConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AeroPageScaffold(
      title: 'Playlists',
      scrollViewKey: ValueKey('playlists-scroll-view'),
      actions: [SizedBox(width: 8)],
      body: FeaturePlaceholderView(
        icon: Icons.featured_play_list_rounded,
        eyebrow: 'NEXT SURFACE',
        title: 'Playlist management is queued up for the next pass.',
        description:
            'This branch is already wired into the router so custom playlist flows can be layered in without replacing the app frame again.',
      ),
    );
  }
}

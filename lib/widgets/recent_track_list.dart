import 'package:flutter/material.dart';

import '../models/track_item.dart';
import 'media_list_row.dart';

class RecentTrackList extends StatelessWidget {
  const RecentTrackList({
    super.key,
    required this.tracks,
    this.activeIndex = 0,
    this.itemSpacing = 8,
    this.onTrackTap,
    this.onMenuTap,
  });

  final List<TrackItem> tracks;
  final int activeIndex;
  final double itemSpacing;
  final ValueChanged<TrackItem>? onTrackTap;
  final ValueChanged<TrackItem>? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(tracks.length, (index) {
        final track = tracks[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == tracks.length - 1 ? 0 : itemSpacing,
          ),
          child: MediaListRow(
            title: track.title,
            subtitle: track.artist,
            imageUrl: track.imageUrl,
            trailing: TrackRowTrailing(
              durationLabel: track.durationLabel,
              onMenuTap: () {
                if (onMenuTap != null) {
                  onMenuTap!(track);
                  return;
                }
                debugPrint('Song menu: ${track.title}');
              },
            ),
            isActive: index == activeIndex,
            onTap: () {
              if (onTrackTap != null) {
                onTrackTap!(track);
                return;
              }
              debugPrint('Track tapped: ${track.title}');
            },
          ),
        );
      }),
    );
  }
}

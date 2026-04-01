import 'package:flutter/material.dart';

import 'list_row.dart';
import 'network_cover_image.dart';

class MediaListRow extends StatelessWidget {
  const MediaListRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.itemKey,
    this.onTap,
    this.trailing,
    this.isActive = false,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final Key? itemKey;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return ListRow(
      title: title,
      subtitle: subtitle,
      leading: NetworkCoverImage(
        imageUrl: imageUrl,
        width: 56,
        height: 56,
        borderRadius: 12,
      ),
      trailing: trailing,
      itemKey: itemKey,
      isActive: isActive,
      onTap: onTap,
    );
  }
}

class TrackRowTrailing extends StatelessWidget {
  const TrackRowTrailing({
    super.key,
    required this.durationLabel,
    required this.onMenuTap,
    this.buttonKey,
  });

  final String durationLabel;
  final VoidCallback onMenuTap;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 88,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              durationLabel,
              textAlign: TextAlign.right,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              key: buttonKey,
              onPressed: onMenuTap,
              padding: EdgeInsets.zero,
              iconSize: 20,
              splashRadius: 24,
              color: theme.colorScheme.onSurfaceVariant,
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/info_models.dart';

class InfoStatsGrid extends StatelessWidget {
  const InfoStatsGrid({super.key, required this.items, this.onItemTap});

  static const double tileWidth = 160;
  static const double tileHeight = 134;
  static const double horizontalGap = 12;
  static const double verticalGap = 12;

  final List<InfoStatItem> items;
  final ValueChanged<InfoStatItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final maxFitColumnCount =
            ((availableWidth + horizontalGap) / (tileWidth + horizontalGap))
                .floor();
        final columnCount = maxFitColumnCount <= 0
            ? 1
            : maxFitColumnCount > items.length
            ? items.length
            : maxFitColumnCount;
        final gridWidth =
            columnCount * tileWidth + (columnCount - 1) * horizontalGap;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: gridWidth,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: horizontalGap,
              runSpacing: verticalGap,
              children: items.map((item) {
                return SizedBox(
                  key: ValueKey('info-stat-tile-${item.label}'),
                  width: tileWidth,
                  height: tileHeight,
                  child: _InfoStatCard(
                    item: item,
                    onTap: onItemTap == null ? null : () => onItemTap!(item),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _InfoStatCard extends StatelessWidget {
  const _InfoStatCard({required this.item, this.onTap});

  final InfoStatItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: theme.colorScheme.primary, size: 24),
              const Spacer(),
              Text(
                item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

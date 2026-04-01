import 'package:flutter/material.dart';

import 'media_list_row.dart';
import 'network_cover_image.dart';

const double _kLibraryGridCrossAxisSpacing = 12.0;
const double _kLibraryGridMainAxisSpacing = 20.0;
const double _kLibraryGridChildAspectRatio = 0.68;
const double _kLibraryGridTrailingGapBudget = 40.0;
const double _kLibraryListRowHeight = 72.0;
const double _kLibraryListRowSpacing = 12.0;

class LibraryMediaItemData {
  const LibraryMediaItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
    this.trailing,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onTap;
  final Widget? trailing;
}

class LibraryMediaGrid extends StatelessWidget {
  const LibraryMediaGrid({super.key, required this.items});

  final List<LibraryMediaItemData> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: _kLibraryGridCrossAxisSpacing,
        mainAxisSpacing: _kLibraryGridMainAxisSpacing,
        childAspectRatio: _kLibraryGridChildAspectRatio,
      ),
      itemBuilder: (context, index) {
        return _LibraryMediaGridItem(item: items[index]);
      },
    );
  }
}

class LibraryMediaList extends StatelessWidget {
  const LibraryMediaList({super.key, required this.items});

  final List<LibraryMediaItemData> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _LibraryMediaListItem(item: items[index]);
      },
    );
  }
}

class SliverLibraryMediaGrid extends StatelessWidget {
  const SliverLibraryMediaGrid({
    super.key,
    required this.itemCount,
    required this.itemAt,
    this.onItemBuilt,
  });

  final int itemCount;
  final LibraryMediaItemData? Function(int index) itemAt;
  final ValueChanged<int>? onItemBuilt;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        final rowCount = (itemCount / crossAxisCount).ceil();
        final tileWidth =
            (constraints.crossAxisExtent -
                (_kLibraryGridCrossAxisSpacing * (crossAxisCount - 1))) /
            crossAxisCount;
        final baseMainAxisExtent = tileWidth / _kLibraryGridChildAspectRatio;
        final fillViewportMainAxisExtent = rowCount == 0
            ? baseMainAxisExtent
            : (constraints.remainingPaintExtent -
                      (_kLibraryGridMainAxisSpacing * (rowCount - 1)) -
                      _kLibraryGridTrailingGapBudget) /
                  rowCount;
        final mainAxisExtent = rowCount <= 2 &&
                fillViewportMainAxisExtent > baseMainAxisExtent
            ? fillViewportMainAxisExtent
            : baseMainAxisExtent;

        return SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            onItemBuilt?.call(index);
            final item = itemAt(index);
            if (item == null) {
              return const _LibraryMediaGridPlaceholderItem();
            }
            return _LibraryMediaGridItem(item: item);
          }, childCount: itemCount),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: _kLibraryGridCrossAxisSpacing,
            mainAxisSpacing: _kLibraryGridMainAxisSpacing,
            mainAxisExtent: mainAxisExtent,
          ),
        );
      },
    );
  }
}

class SliverLibraryMediaList extends StatelessWidget {
  const SliverLibraryMediaList({
    super.key,
    required this.itemCount,
    required this.itemAt,
    this.onItemBuilt,
  });

  final int itemCount;
  final LibraryMediaItemData? Function(int index) itemAt;
  final ValueChanged<int>? onItemBuilt;

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _kLibraryListRowHeight + _kLibraryListRowSpacing,
      delegate: SliverChildBuilderDelegate((context, index) {
        onItemBuilt?.call(index);
        final item = itemAt(index);
        return Padding(
          padding: const EdgeInsets.only(bottom: _kLibraryListRowSpacing),
          child: item == null
              ? const _LibraryMediaListPlaceholderItem()
              : _LibraryMediaListItem(item: item),
        );
      }, childCount: itemCount),
    );
  }
}

class _LibraryMediaGridItem extends StatelessWidget {
  const _LibraryMediaGridItem({required this.item});

  final LibraryMediaItemData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('library-media-item-${item.id}'),
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: NetworkCoverImage(
                imageUrl: item.imageUrl,
                width: double.infinity,
                height: double.infinity,
                borderRadius: 24,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.trailing != null) ...[
                  const SizedBox(width: 8),
                  item.trailing!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryMediaListItem extends StatelessWidget {
  const _LibraryMediaListItem({required this.item});

  final LibraryMediaItemData item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kLibraryListRowHeight,
      child: MediaListRow(
        title: item.title,
        subtitle: item.subtitle,
        imageUrl: item.imageUrl,
        itemKey: ValueKey('library-media-item-${item.id}'),
        onTap: item.onTap,
        trailing: item.trailing,
      ),
    );
  }
}

class _LibraryMediaGridPlaceholderItem extends StatelessWidget {
  const _LibraryMediaGridPlaceholderItem();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 18,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        FractionallySizedBox(
          widthFactor: 0.66,
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _LibraryMediaListPlaceholderItem extends StatelessWidget {
  const _LibraryMediaListPlaceholderItem();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.surfaceContainerHighest;

    return SizedBox(
      height: _kLibraryListRowHeight,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(width: 56, height: 56),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.58,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

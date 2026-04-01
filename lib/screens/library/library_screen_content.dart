import 'package:flutter/material.dart';

import '../../models/library_models.dart';
import 'library_screen_types.dart';

class LibraryUtilityRow extends StatelessWidget {
  const LibraryUtilityRow({
    super.key,
    required this.sortOptions,
    required this.currentSortKey,
    required this.showViewToggle,
    required this.viewMode,
    required this.onSortSelected,
    required this.onViewModeChanged,
  });

  final List<LibrarySortKey> sortOptions;
  final LibrarySortKey currentSortKey;
  final bool showViewToggle;
  final LibraryViewMode viewMode;
  final ValueChanged<LibrarySortKey> onSortSelected;
  final ValueChanged<LibraryViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        PopupMenuButton<LibrarySortKey>(
          key: const ValueKey('library-sort-button'),
          tooltip: 'Sort by ${currentSortKey.label}',
          onSelected: onSortSelected,
          color: theme.colorScheme.surfaceContainer,
          icon: Icon(
            Icons.sort_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          itemBuilder: (context) {
            return sortOptions.map((sortKey) {
              final isSelected = sortKey == currentSortKey;
              return PopupMenuItem<LibrarySortKey>(
                value: sortKey,
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(sortKey.label),
                  ],
                ),
              );
            }).toList(growable: false);
          },
        ),
        const Spacer(),
        if (showViewToggle)
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LibraryViewModeButton(
                    buttonKey: const ValueKey('library-view-grid'),
                    icon: Icons.grid_view_rounded,
                    isSelected: viewMode == LibraryViewMode.grid,
                    onTap: () => onViewModeChanged(LibraryViewMode.grid),
                  ),
                  const SizedBox(width: 4),
                  LibraryViewModeButton(
                    buttonKey: const ValueKey('library-view-list'),
                    icon: Icons.view_list_rounded,
                    isSelected: viewMode == LibraryViewMode.list,
                    onTap: () => onViewModeChanged(LibraryViewMode.list),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LibraryViewModeButton extends StatelessWidget {
  const LibraryViewModeButton({
    super.key,
    required this.buttonKey,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final Key buttonKey;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.secondaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: buttonKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class LibraryOverflowButton extends StatelessWidget {
  const LibraryOverflowButton({
    super.key,
    required this.buttonKey,
    required this.onTap,
  });

  final Key buttonKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      key: buttonKey,
      onPressed: onTap,
      icon: Icon(
        Icons.more_vert_rounded,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

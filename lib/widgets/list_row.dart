import 'package:flutter/material.dart';

class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.itemKey,
    this.isActive = false,
    this.onTap,
    this.contentPadding = const EdgeInsets.fromLTRB(8, 8, 8, 8),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Key? itemKey;
  final bool isActive;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isActive
        ? theme.colorScheme.surfaceContainerHigh
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: itemKey,
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: contentPadding,
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 16)],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 12), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

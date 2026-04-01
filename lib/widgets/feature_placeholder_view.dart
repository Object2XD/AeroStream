import 'package:flutter/material.dart';

class FeaturePlaceholderView extends StatelessWidget {
  const FeaturePlaceholderView({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSecondaryContainer,
              size: 30,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            eyebrow,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

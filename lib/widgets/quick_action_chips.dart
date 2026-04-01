import 'package:flutter/material.dart';

class QuickActionChips extends StatelessWidget {
  const QuickActionChips({super.key, required this.actions});

  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isPrimary = index == 0;
          return _QuickActionChip(label: actions[index], selected: isPrimary);
        },
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => debugPrint('Quick action: $label'),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 48,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

ThemeData buildAeroTheme() {
  const background = Color(0xFF111318);
  const surfaceContainerLow = Color(0xFF17191F);
  const surfaceContainer = Color(0xFF1E1F25);
  const surfaceContainerHigh = Color(0xFF272932);
  const surfaceContainerHighest = Color(0xFF414751);
  const primary = Color(0xFFA8C7FA);
  const primaryContainer = Color(0xFF0842A0);
  const onPrimaryContainer = Color(0xFFD3E3FD);
  const secondary = Color(0xFFC2C7CF);
  const secondaryContainer = Color(0xFF414751);
  const onSecondaryContainer = Color(0xFFDEE3EB);
  const onSurface = Color(0xFFE2E2E9);
  const onSurfaceVariant = Color(0xFFC4C6D0);
  const outlineVariant = Color(0xFF3C404A);

  final colorScheme =
      const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: background,
        onPrimary: Color(0xFF062E6F),
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      ).copyWith(
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        outlineVariant: outlineVariant,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
    ),
    textTheme: ThemeData.dark(useMaterial3: true).textTheme.copyWith(
      headlineSmall: const TextStyle(
        fontSize: 34,
        height: 1.12,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleLarge: const TextStyle(
        fontSize: 28,
        height: 1.14,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        height: 1.22,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.29,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        height: 1.14,
        fontWeight: FontWeight.w600,
        color: onSurfaceVariant,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainer,
      indicatorColor: colorScheme.secondaryContainer,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          height: 1.33,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: isSelected
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurfaceVariant,
        );
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      selectedColor: colorScheme.secondaryContainer,
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: const TextStyle(
        color: onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

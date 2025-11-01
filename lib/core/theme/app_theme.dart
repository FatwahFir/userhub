import 'package:flutter/material.dart';

ThemeData appTheme(BuildContext context) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2563EB),
    brightness: Brightness.light,
  );

  final base = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      actionsIconTheme: IconThemeData(color: colorScheme.primary, size: 22),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: const Color(0xFF1F2937),
      displayColor: const Color(0xFF111827),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
      ),
      prefixIconColor: colorScheme.primary.withOpacity(.8),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withOpacity(0.3),
      space: 24,
      thickness: 1,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      shadowColor: const Color(0x11000000),
      surfaceTintColor: Colors.transparent,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: colorScheme.primary.withOpacity(.12),
      labelStyle: base.textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      iconColor: colorScheme.primary,
    ),
    iconTheme: const IconThemeData(size: 22),
    snackBarTheme: base.snackBarTheme.copyWith(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );
}

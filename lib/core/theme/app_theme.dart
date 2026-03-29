import 'package:flutter/material.dart';

import 'app_theme_config.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light(AppThemeConfig config) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: config.primarySeedColor,
      brightness: Brightness.light,
      surface: config.lightSurface,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData dark(AppThemeConfig config) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: config.primarySeedColor,
      brightness: Brightness.dark,
      surface: config.darkSurface,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

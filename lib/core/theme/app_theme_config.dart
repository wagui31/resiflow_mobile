import 'package:flutter/material.dart';

class AppThemeConfig {
  const AppThemeConfig({
    required this.primarySeedColor,
    required this.lightSurface,
    required this.darkSurface,
  });

  final Color primarySeedColor;
  final Color lightSurface;
  final Color darkSurface;
}

/// Build-level branding for the current residence application.
class ResidenceTheme {
  const ResidenceTheme._();

  static const AppThemeConfig current = AppThemeConfig(
    primarySeedColor: Color(0xFF0E7490),
    lightSurface: Color(0xFFF7FAFC),
    darkSurface: Color(0xFF0F172A),
  );
}

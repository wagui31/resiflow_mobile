import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AppDashboardTheme extends ThemeExtension<AppDashboardTheme> {
  const AppDashboardTheme({
    required this.successColor,
    required this.warningColor,
    required this.heroStartColor,
    required this.heroEndColor,
    required this.heroGlowColor,
    required this.chartFillColor,
    required this.heroRadius,
    required this.sectionRadius,
  });

  final Color successColor;
  final Color warningColor;
  final Color heroStartColor;
  final Color heroEndColor;
  final Color heroGlowColor;
  final Color chartFillColor;
  final double heroRadius;
  final double sectionRadius;

  @override
  AppDashboardTheme copyWith({
    Color? successColor,
    Color? warningColor,
    Color? heroStartColor,
    Color? heroEndColor,
    Color? heroGlowColor,
    Color? chartFillColor,
    double? heroRadius,
    double? sectionRadius,
  }) {
    return AppDashboardTheme(
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      heroStartColor: heroStartColor ?? this.heroStartColor,
      heroEndColor: heroEndColor ?? this.heroEndColor,
      heroGlowColor: heroGlowColor ?? this.heroGlowColor,
      chartFillColor: chartFillColor ?? this.chartFillColor,
      heroRadius: heroRadius ?? this.heroRadius,
      sectionRadius: sectionRadius ?? this.sectionRadius,
    );
  }

  @override
  AppDashboardTheme lerp(
    covariant ThemeExtension<AppDashboardTheme>? other,
    double t,
  ) {
    if (other is! AppDashboardTheme) {
      return this;
    }

    return AppDashboardTheme(
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      heroStartColor: Color.lerp(heroStartColor, other.heroStartColor, t)!,
      heroEndColor: Color.lerp(heroEndColor, other.heroEndColor, t)!,
      heroGlowColor: Color.lerp(heroGlowColor, other.heroGlowColor, t)!,
      chartFillColor: Color.lerp(chartFillColor, other.chartFillColor, t)!,
      heroRadius: lerpDouble(heroRadius, other.heroRadius, t)!,
      sectionRadius: lerpDouble(sectionRadius, other.sectionRadius, t)!,
    );
  }

  static AppDashboardTheme light(ColorScheme colorScheme) {
    return AppDashboardTheme(
      successColor: const Color(0xFF1D8348),
      warningColor: const Color(0xFFC26B00),
      heroStartColor: colorScheme.primary.withValues(alpha: 0.18),
      heroEndColor: colorScheme.tertiary.withValues(alpha: 0.16),
      heroGlowColor: colorScheme.primary.withValues(alpha: 0.12),
      chartFillColor: colorScheme.primary.withValues(alpha: 0.14),
      heroRadius: 30,
      sectionRadius: 26,
    );
  }

  static AppDashboardTheme dark(ColorScheme colorScheme) {
    return AppDashboardTheme(
      successColor: const Color(0xFF56D68A),
      warningColor: const Color(0xFFF2B14A),
      heroStartColor: colorScheme.primary.withValues(alpha: 0.24),
      heroEndColor: colorScheme.tertiary.withValues(alpha: 0.2),
      heroGlowColor: colorScheme.primary.withValues(alpha: 0.18),
      chartFillColor: colorScheme.primary.withValues(alpha: 0.18),
      heroRadius: 30,
      sectionRadius: 26,
    );
  }
}

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AppLayoutTheme extends ThemeExtension<AppLayoutTheme> {
  const AppLayoutTheme({
    required this.mobileHorizontalPadding,
    required this.tabletHorizontalPadding,
    required this.desktopHorizontalPadding,
    required this.mobileVerticalPadding,
    required this.tabletVerticalPadding,
    required this.desktopVerticalPadding,
    required this.mobileMaxContentWidth,
    required this.tabletMaxContentWidth,
    required this.desktopMaxContentWidth,
    required this.sectionSpacing,
    required this.itemSpacing,
  });

  final double mobileHorizontalPadding;
  final double tabletHorizontalPadding;
  final double desktopHorizontalPadding;
  final double mobileVerticalPadding;
  final double tabletVerticalPadding;
  final double desktopVerticalPadding;
  final double mobileMaxContentWidth;
  final double tabletMaxContentWidth;
  final double desktopMaxContentWidth;
  final double sectionSpacing;
  final double itemSpacing;

  @override
  AppLayoutTheme copyWith({
    double? mobileHorizontalPadding,
    double? tabletHorizontalPadding,
    double? desktopHorizontalPadding,
    double? mobileVerticalPadding,
    double? tabletVerticalPadding,
    double? desktopVerticalPadding,
    double? mobileMaxContentWidth,
    double? tabletMaxContentWidth,
    double? desktopMaxContentWidth,
    double? sectionSpacing,
    double? itemSpacing,
  }) {
    return AppLayoutTheme(
      mobileHorizontalPadding:
          mobileHorizontalPadding ?? this.mobileHorizontalPadding,
      tabletHorizontalPadding:
          tabletHorizontalPadding ?? this.tabletHorizontalPadding,
      desktopHorizontalPadding:
          desktopHorizontalPadding ?? this.desktopHorizontalPadding,
      mobileVerticalPadding: mobileVerticalPadding ?? this.mobileVerticalPadding,
      tabletVerticalPadding: tabletVerticalPadding ?? this.tabletVerticalPadding,
      desktopVerticalPadding:
          desktopVerticalPadding ?? this.desktopVerticalPadding,
      mobileMaxContentWidth:
          mobileMaxContentWidth ?? this.mobileMaxContentWidth,
      tabletMaxContentWidth:
          tabletMaxContentWidth ?? this.tabletMaxContentWidth,
      desktopMaxContentWidth:
          desktopMaxContentWidth ?? this.desktopMaxContentWidth,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      itemSpacing: itemSpacing ?? this.itemSpacing,
    );
  }

  @override
  AppLayoutTheme lerp(
    covariant ThemeExtension<AppLayoutTheme>? other,
    double t,
  ) {
    if (other is! AppLayoutTheme) {
      return this;
    }

    return AppLayoutTheme(
      mobileHorizontalPadding: lerpDouble(
        mobileHorizontalPadding,
        other.mobileHorizontalPadding,
        t,
      )!,
      tabletHorizontalPadding: lerpDouble(
        tabletHorizontalPadding,
        other.tabletHorizontalPadding,
        t,
      )!,
      desktopHorizontalPadding: lerpDouble(
        desktopHorizontalPadding,
        other.desktopHorizontalPadding,
        t,
      )!,
      mobileVerticalPadding: lerpDouble(
        mobileVerticalPadding,
        other.mobileVerticalPadding,
        t,
      )!,
      tabletVerticalPadding: lerpDouble(
        tabletVerticalPadding,
        other.tabletVerticalPadding,
        t,
      )!,
      desktopVerticalPadding: lerpDouble(
        desktopVerticalPadding,
        other.desktopVerticalPadding,
        t,
      )!,
      mobileMaxContentWidth: lerpDouble(
        mobileMaxContentWidth,
        other.mobileMaxContentWidth,
        t,
      )!,
      tabletMaxContentWidth: lerpDouble(
        tabletMaxContentWidth,
        other.tabletMaxContentWidth,
        t,
      )!,
      desktopMaxContentWidth: lerpDouble(
        desktopMaxContentWidth,
        other.desktopMaxContentWidth,
        t,
      )!,
      sectionSpacing: lerpDouble(sectionSpacing, other.sectionSpacing, t)!,
      itemSpacing: lerpDouble(itemSpacing, other.itemSpacing, t)!,
    );
  }

  static const AppLayoutTheme standard = AppLayoutTheme(
    mobileHorizontalPadding: 16,
    tabletHorizontalPadding: 24,
    desktopHorizontalPadding: 32,
    mobileVerticalPadding: 16,
    tabletVerticalPadding: 24,
    desktopVerticalPadding: 32,
    mobileMaxContentWidth: 600,
    tabletMaxContentWidth: 840,
    desktopMaxContentWidth: 1200,
    sectionSpacing: 24,
    itemSpacing: 12,
  );
}

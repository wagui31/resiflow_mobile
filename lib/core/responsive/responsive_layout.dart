import 'package:flutter/material.dart';

import '../theme/app_layout_theme.dart';
import 'app_breakpoints.dart';

enum ResponsiveSize { mobile, tablet, desktop }

@immutable
class ResponsiveLayout {
  const ResponsiveLayout({
    required this.size,
    required this.width,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.maxContentWidth,
    required this.sectionSpacing,
    required this.itemSpacing,
  });

  final ResponsiveSize size;
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  final double maxContentWidth;
  final double sectionSpacing;
  final double itemSpacing;

  bool get isMobile => size == ResponsiveSize.mobile;
  bool get isTablet => size == ResponsiveSize.tablet;
  bool get isDesktop => size == ResponsiveSize.desktop;

  int get dashboardColumns {
    if (isDesktop) {
      return 3;
    }
    if (isTablet) {
      return 2;
    }
    return 1;
  }

  static ResponsiveLayout fromWidth(double width, AppLayoutTheme layoutTheme) {
    if (width >= AppBreakpoints.desktop) {
      return ResponsiveLayout(
        size: ResponsiveSize.desktop,
        width: width,
        horizontalPadding: layoutTheme.desktopHorizontalPadding,
        verticalPadding: layoutTheme.desktopVerticalPadding,
        maxContentWidth: layoutTheme.desktopMaxContentWidth,
        sectionSpacing: layoutTheme.sectionSpacing,
        itemSpacing: layoutTheme.itemSpacing,
      );
    }

    if (width >= AppBreakpoints.tablet) {
      return ResponsiveLayout(
        size: ResponsiveSize.tablet,
        width: width,
        horizontalPadding: layoutTheme.tabletHorizontalPadding,
        verticalPadding: layoutTheme.tabletVerticalPadding,
        maxContentWidth: layoutTheme.tabletMaxContentWidth,
        sectionSpacing: layoutTheme.sectionSpacing,
        itemSpacing: layoutTheme.itemSpacing,
      );
    }

    return ResponsiveLayout(
      size: ResponsiveSize.mobile,
      width: width,
      horizontalPadding: layoutTheme.mobileHorizontalPadding,
      verticalPadding: layoutTheme.mobileVerticalPadding,
      maxContentWidth: layoutTheme.mobileMaxContentWidth,
      sectionSpacing: layoutTheme.sectionSpacing,
      itemSpacing: layoutTheme.itemSpacing,
    );
  }
}

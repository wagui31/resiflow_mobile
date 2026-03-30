import 'package:flutter/material.dart';

import '../theme/app_layout_theme.dart';
import 'responsive_layout.dart';

typedef ResponsiveWidgetBuilder =
    Widget Function(BuildContext context, ResponsiveLayout layout);

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.builder,
    super.key,
  });

  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final layoutTheme =
        Theme.of(context).extension<AppLayoutTheme>() ??
        AppLayoutTheme.standard;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final layout = ResponsiveLayout.fromWidth(width, layoutTheme);

        return builder(context, layout);
      },
    );
  }
}

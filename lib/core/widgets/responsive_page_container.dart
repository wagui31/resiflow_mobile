import 'package:flutter/material.dart';

import '../responsive/responsive_builder.dart';

class ResponsivePageContainer extends StatelessWidget {
  const ResponsivePageContainer({
    required this.child,
    this.alignment = Alignment.topCenter,
    this.useTopSafeArea = true,
    super.key,
  });

  final Widget child;
  final Alignment alignment;
  final bool useTopSafeArea;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layout) {
        final topSpacing = useTopSafeArea
            ? 0.0
            : (layout.isMobile ? 4.0 : 6.0);
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: SafeArea(
            top: useTopSafeArea,
            child: Align(
              alignment: alignment,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: layout.horizontalPadding,
                  ).copyWith(
                    top: topSpacing,
                    bottom: layout.verticalPadding,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

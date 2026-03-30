import 'package:flutter/material.dart';

import '../responsive/responsive_builder.dart';

class ResponsivePageContainer extends StatelessWidget {
  const ResponsivePageContainer({
    required this.child,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layout) {
        return SafeArea(
          child: Align(
            alignment: alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: layout.horizontalPadding,
                  vertical: layout.verticalPadding,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

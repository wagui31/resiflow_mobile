import 'package:flutter/material.dart';

import '../responsive/responsive_builder.dart';
import 'global_page_header.dart';
import 'responsive_page_container.dart';

class ModuleScaffold extends StatelessWidget {
  const ModuleScaffold({
    required this.title,
    required this.description,
    this.child,
    super.key,
  });

  final String title;
  final String description;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: ResponsivePageContainer(
        child: ResponsiveBuilder(
          builder: (context, layout) {
            return ListView(
              children: <Widget>[
                GlobalPageHeader(title: title, layout: layout),
                SizedBox(height: layout.isMobile ? 8 : 10),
                Text(
                  description,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (child != null) ...<Widget>[
                  SizedBox(height: layout.isMobile ? 12 : 14),
                  child!,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

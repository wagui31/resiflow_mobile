import 'package:flutter/material.dart';

import '../branding/app_branding.dart';
import '../responsive/responsive_builder.dart';
import 'app_logo.dart';
import 'language_switcher.dart';
import 'responsive_page_container.dart';

class ModuleScaffold extends StatelessWidget {
  const ModuleScaffold({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const branding = AppBranding.current;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const <Widget>[
          LanguageSwitcher(),
        ],
      ),
      body: ResponsivePageContainer(
        child: ResponsiveBuilder(
          builder: (context, layout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppLogo(
                  logoAssetPath: branding.logoAssetPath,
                ),
                SizedBox(height: layout.sectionSpacing - 4),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: layout.itemSpacing),
                Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../branding/app_branding.dart';
import 'app_logo.dart';
import 'language_switcher.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppLogo(
              logoAssetPath: branding.logoAssetPath,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

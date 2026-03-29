import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/i18n/app_locale_controller.dart';
import 'core/i18n/l10n.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_config.dart';

class ResiflowApp extends ConsumerWidget {
  const ResiflowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleControllerProvider);
    final router = ref.watch(appRouterProvider);
    const themeConfig = ResidenceTheme.current;

    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) => 'ResiFlow',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: AppL10n.localizationsDelegates,
      theme: AppTheme.light(themeConfig),
      darkTheme: AppTheme.dark(themeConfig),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

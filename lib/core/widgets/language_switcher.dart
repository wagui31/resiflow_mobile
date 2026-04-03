import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/app_locale.dart';
import '../i18n/app_locale_controller.dart';
import '../i18n/extensions/app_localizations_x.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(appLocaleControllerProvider);

    return PopupMenuButton<Locale>(
      tooltip: context.l10n.languageSwitcherTooltip,
      icon: const Icon(Icons.language),
      initialValue: currentLocale,
      onSelected: (Locale locale) {
        ref.read(appLocaleControllerProvider.notifier).setLocale(locale);
      },
      itemBuilder: (BuildContext context) {
        return AppLocale.supportedLocales
            .map((Locale locale) {
              return PopupMenuItem<Locale>(
                value: locale,
                child: Text(_labelFor(context, locale.languageCode)),
              );
            })
            .toList(growable: false);
      },
    );
  }

  String _labelFor(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'en':
        return context.l10n.languageEnglish;
      case 'fr':
        return context.l10n.languageFrench;
      default:
        return languageCode;
    }
  }
}

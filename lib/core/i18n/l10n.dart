import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:resiflow_mobile/l10n/app_localizations.dart';

import 'app_locale.dart';

abstract final class AppL10n {
  static const Locale fallbackLocale = AppLocale.fallback;

  static const List<Locale> supportedLocales = AppLocale.supportedLocales;

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

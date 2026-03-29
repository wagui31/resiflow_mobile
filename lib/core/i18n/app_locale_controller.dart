import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_locale.dart';

class AppLocaleController extends Notifier<Locale> {
  @override
  Locale build() => AppLocale.fallback;

  void setLocale(Locale locale) {
    if (AppLocale.supportedLocales.contains(locale)) {
      state = locale;
    }
  }
}

final appLocaleControllerProvider =
    NotifierProvider<AppLocaleController, Locale>(AppLocaleController.new);

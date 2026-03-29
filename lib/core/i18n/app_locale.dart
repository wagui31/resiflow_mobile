import 'package:flutter/material.dart';

abstract final class AppLocale {
  static const Locale fallback = Locale('fr');

  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
  ];
}

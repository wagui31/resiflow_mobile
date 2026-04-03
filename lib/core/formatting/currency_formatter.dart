import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static String format(
    BuildContext context,
    double value, {
    required String? currencyCode,
    bool compact = false,
    int? decimalDigits,
  }) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final digits = decimalDigits ?? _defaultDecimalDigits(value);
    final number = compact
        ? _buildCompactFormat(locale, digits).format(value)
        : _buildDecimalFormat(locale, digits).format(value);
    final normalizedCurrency = _normalizeCurrency(currencyCode);

    if (normalizedCurrency == null) {
      return number;
    }

    return '$number $normalizedCurrency';
  }

  static int _defaultDecimalDigits(double value) {
    return value.abs() >= 100 ? 0 : 2;
  }

  static NumberFormat _buildDecimalFormat(String locale, int decimalDigits) {
    final format = NumberFormat.decimalPattern(locale);
    format.minimumFractionDigits = decimalDigits;
    format.maximumFractionDigits = decimalDigits;
    return format;
  }

  static NumberFormat _buildCompactFormat(String locale, int decimalDigits) {
    final format = NumberFormat.compact(locale: locale);
    format.minimumFractionDigits = decimalDigits;
    format.maximumFractionDigits = decimalDigits;
    return format;
  }

  static String? _normalizeCurrency(String? currencyCode) {
    final trimmed = currencyCode?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed.toUpperCase();
  }
}

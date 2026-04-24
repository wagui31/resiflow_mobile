import 'package:flutter/material.dart';

import '../formatting/currency_formatter.dart';

class FormattedAmountText extends StatelessWidget {
  const FormattedAmountText(
    this.amount, {
    required this.currencyCode,
    super.key,
    this.style,
    this.currencyStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.compact = false,
    this.decimalDigits,
    this.currencyScale = 0.58,
  });

  final double amount;
  final String? currencyCode;
  final TextStyle? style;
  final TextStyle? currencyStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool compact;
  final int? decimalDigits;
  final double currencyScale;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final number = CurrencyFormatter.formatNumber(
      context,
      amount,
      compact: compact,
      decimalDigits: decimalDigits,
    );
    final normalizedCurrency = CurrencyFormatter.normalizeCurrency(
      currencyCode,
    );

    if (normalizedCurrency == null) {
      return Text(
        number,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final resolvedCurrencyStyle =
        currencyStyle ??
        baseStyle.copyWith(
          fontSize: (baseStyle.fontSize ?? 14) * currencyScale,
          height: 1,
        );

    return Text.rich(
      TextSpan(
        text: number,
        style: baseStyle,
        children: <InlineSpan>[
          TextSpan(text: ' $normalizedCurrency', style: resolvedCurrencyStyle),
        ],
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

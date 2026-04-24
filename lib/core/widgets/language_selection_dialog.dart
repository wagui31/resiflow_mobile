import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/app_locale.dart';
import '../i18n/app_locale_controller.dart';
import '../i18n/extensions/app_localizations_x.dart';
import '../responsive/responsive_builder.dart';

Future<void> showLanguageSelectionDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const _LanguageSelectionDialog(),
  );
}

class _LanguageSelectionDialog extends ConsumerWidget {
  const _LanguageSelectionDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLocale = ref.watch(appLocaleControllerProvider);

    return ResponsiveBuilder(
      builder: (context, layout) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: layout.isMobile ? 16 : 24,
            vertical: 24,
          ),
          title: Text(
            context.l10n.accountLanguageTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.isMobile ? 360 : 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.accountLanguageSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                RadioGroup<Locale>(
                  groupValue: currentLocale,
                  onChanged: (selectedLocale) {
                    if (selectedLocale == null) {
                      return;
                    }
                    ref
                        .read(appLocaleControllerProvider.notifier)
                        .setLocale(selectedLocale);
                    Navigator.of(context).pop();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: AppLocale.supportedLocales
                        .map(
                          (locale) => RadioListTile<Locale>(
                            value: locale,
                            contentPadding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              _labelFor(context, locale.languageCode),
                            ),
                            subtitle: Text(locale.languageCode.toUpperCase()),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.paymentDialogCancel),
            ),
          ],
        );
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

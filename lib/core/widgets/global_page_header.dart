import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../branding/app_branding.dart';
import '../formatting/currency_formatter.dart';
import '../i18n/extensions/app_localizations_x.dart';
import '../responsive/responsive_layout.dart';
import '../router/app_router.dart';
import 'app_logo.dart';
import 'language_switcher.dart';

class GlobalPageHeader extends ConsumerWidget {
  const GlobalPageHeader({
    required this.title,
    required this.layout,
    this.actions = const <Widget>[],
    this.residenceBalance,
    this.currencyCode,
    super.key,
  });

  final String title;
  final ResponsiveLayout layout;
  final List<Widget> actions;
  final double? residenceBalance;
  final String? currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const branding = AppBranding.current;
    final hasResidenceBalance = residenceBalance != null;
    final logoSize = layout.isMobile ? 40.0 : 46.0;
    final actionButtonSize = layout.isMobile ? 38.0 : 40.0;
    final actionSpacing = layout.isMobile ? 2.0 : 4.0;
    final headerSpacing = layout.isMobile ? 10.0 : 14.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.isMobile ? 12 : 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: layout.isMobile ? 60 : 66,
            child: Theme(
              data: theme.copyWith(
                iconButtonTheme: IconButtonThemeData(
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.all(layout.isMobile ? 6 : 8),
                    minimumSize: Size(actionButtonSize, actionButtonSize),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  AppLogo(
                    logoAssetPath: branding.logoAssetPath,
                    size: logoSize,
                  ),
                  SizedBox(width: headerSpacing),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        fontSize: layout.isMobile ? 22 : 24,
                      ),
                    ),
                  ),
                  SizedBox(width: headerSpacing),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ..._withSpacing(actions, actionSpacing),
                        if (actions.isNotEmpty) SizedBox(width: actionSpacing),
                        const LanguageSwitcher(),
                        SizedBox(width: actionSpacing),
                        IconButton(
                          onPressed: () {
                            ref
                                .read(authSessionControllerProvider.notifier)
                                .clearSession();
                            context.goNamed(landingRouteName);
                          },
                          tooltip: context.l10n.authLogoutButton,
                          icon: const Icon(Icons.logout_rounded),
                          color: colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasResidenceBalance) ...<Widget>[
            SizedBox(height: layout.isMobile ? 8 : 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: layout.isMobile ? 14 : 18,
                vertical: layout.isMobile ? 12 : 14,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(layout.isMobile ? 18 : 22),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.16),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    context.l10n.headerResidenceBalanceLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.84,
                      ),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(
                      context,
                      residenceBalance!,
                      currencyCode: currencyCode,
                    ),
                    textAlign: TextAlign.center,
                    style: (layout.isMobile
                            ? theme.textTheme.titleLarge
                            : theme.textTheme.headlineSmall)
                        ?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) {
      return const <Widget>[];
    }

    return <Widget>[
      for (var index = 0; index < children.length; index++) ...<Widget>[
        if (index > 0) SizedBox(width: spacing),
        children[index],
      ],
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../branding/app_branding.dart';
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
    super.key,
  });

  final String title;
  final ResponsiveLayout layout;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const branding = AppBranding.current;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.isMobile ? 12 : 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AppLogo(
                logoAssetPath: branding.logoAssetPath,
                size: layout.isMobile ? 44 : 50,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ...actions,
                  if (actions.isNotEmpty) const SizedBox(width: 4),
                  const LanguageSwitcher(),
                  const SizedBox(width: 4),
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
            ],
          ),
        ],
      ),
    );
  }
}

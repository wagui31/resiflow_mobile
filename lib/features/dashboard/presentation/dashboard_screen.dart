import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/app_branding.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/language_switcher.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const branding = AppBranding.current;
    final modules = <_DashboardModule>[
      _DashboardModule(
        title: context.l10n.moduleAuthTitle,
        description: context.l10n.moduleAuthDescription,
        routeName: 'auth',
        icon: Icons.lock_outline,
      ),
      _DashboardModule(
        title: context.l10n.modulePaymentTitle,
        description: context.l10n.modulePaymentDescription,
        routeName: 'paiement',
        icon: Icons.payments_outlined,
      ),
      _DashboardModule(
        title: context.l10n.moduleExpenseTitle,
        description: context.l10n.moduleExpenseDescription,
        routeName: 'depense',
        icon: Icons.receipt_long_outlined,
      ),
      _DashboardModule(
        title: context.l10n.moduleVoteTitle,
        description: context.l10n.moduleVoteDescription,
        routeName: 'vote',
        icon: Icons.how_to_vote_outlined,
      ),
      _DashboardModule(
        title: context.l10n.moduleResidenceTitle,
        description: context.l10n.moduleResidenceDescription,
        routeName: 'residence',
        icon: Icons.apartment_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
        actions: const <Widget>[
          LanguageSwitcher(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          AppLogo(
            logoAssetPath: branding.logoAssetPath,
            size: 72,
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.dashboardTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.dashboardSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          for (final module in modules) ...<Widget>[
            Card(
              child: ListTile(
                leading: Icon(module.icon),
                title: Text(module.title),
                subtitle: Text(module.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.goNamed(module.routeName),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DashboardModule {
  const _DashboardModule({
    required this.title,
    required this.description,
    required this.routeName,
    required this.icon,
  });

  final String title;
  final String description;
  final String routeName;
  final IconData icon;
}

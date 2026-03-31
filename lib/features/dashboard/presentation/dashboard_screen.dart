import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_session_controller.dart';
import '../../../core/branding/app_branding.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/widgets/responsive_page_container.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const branding = AppBranding.current;
    final modules = <_DashboardModule>[
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
        actions: <Widget>[
          IconButton(
            onPressed: () {
              ref.read(authSessionControllerProvider.notifier).clearSession();
              context.goNamed(landingRouteName);
            },
            tooltip: context.l10n.authLogoutButton,
            icon: const Icon(Icons.logout_rounded),
          ),
          const LanguageSwitcher(),
        ],
      ),
      body: ResponsivePageContainer(
        child: ResponsiveBuilder(
          builder: (context, layout) {
            return ListView(
              children: <Widget>[
                AppLogo(
                  logoAssetPath: branding.logoAssetPath,
                  size: layout.isMobile ? 72 : 88,
                ),
                SizedBox(height: layout.sectionSpacing - 4),
                Text(
                  context.l10n.dashboardTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: layout.itemSpacing),
                Text(
                  context.l10n.dashboardSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: layout.sectionSpacing),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: modules.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: layout.dashboardColumns,
                    crossAxisSpacing: layout.itemSpacing,
                    mainAxisSpacing: layout.itemSpacing,
                    childAspectRatio: layout.isMobile ? 2.9 : 2.2,
                  ),
                  itemBuilder: (context, index) {
                    final module = modules[index];

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => context.goNamed(module.routeName),
                        child: Padding(
                          padding: EdgeInsets.all(layout.horizontalPadding),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(module.icon),
                              SizedBox(width: layout.itemSpacing),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      module.title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    SizedBox(height: layout.itemSpacing / 2),
                                    Text(
                                      module.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: layout.itemSpacing),
                              const Align(
                                alignment: Alignment.topCenter,
                                child: Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
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

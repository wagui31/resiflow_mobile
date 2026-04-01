import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/branding/app_branding.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_dashboard_theme.dart';
import '../../../core/widgets/responsive_page_container.dart';
import '../../auth/application/auth_session_controller.dart';
import '../application/dashboard_providers.dart';
import 'widgets/dashboard_line_chart.dart';
import 'widgets/dashboard_panels.dart';
import 'widgets/dashboard_sections.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    const branding = AppBranding.current;

    final actions = <DashboardAction>[
      DashboardAction(
        title: context.l10n.modulePaymentTitle,
        description: context.l10n.modulePaymentDescription,
        routeName: 'paiement',
        icon: Icons.payments_outlined,
      ),
      DashboardAction(
        title: context.l10n.moduleExpenseTitle,
        description: context.l10n.moduleExpenseDescription,
        routeName: 'depense',
        icon: Icons.receipt_long_outlined,
      ),
      DashboardAction(
        title: context.l10n.moduleVoteTitle,
        description: context.l10n.moduleVoteDescription,
        routeName: 'vote',
        icon: Icons.how_to_vote_outlined,
      ),
      DashboardAction(
        title: context.l10n.moduleResidenceTitle,
        description: context.l10n.moduleResidenceDescription,
        routeName: 'residence',
        icon: Icons.apartment_outlined,
      ),
    ];

    return Scaffold(
      body: ResponsivePageContainer(
        child: ResponsiveBuilder(
          builder: (context, layout) {
            final user = ref.watch(currentUserProvider);
            final snapshotAsync = ref.watch(dashboardSnapshotProvider);

            return snapshotAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => DashboardErrorState(
                onRetry: () => ref.invalidate(dashboardSnapshotProvider),
              ),
              data: (snapshot) {
                final metrics = <DashboardMetric>[
                  DashboardMetric(
                    title: context.l10n.dashboardCardBalance,
                    value: _formatCurrency(context, snapshot.stats.currentBalance),
                    icon: Icons.account_balance_wallet_rounded,
                    toneColor: colorScheme.primary,
                  ),
                  DashboardMetric(
                    title: context.l10n.dashboardCardContributions,
                    value: _formatCurrency(
                      context,
                      snapshot.stats.totalContributions,
                    ),
                    icon: Icons.south_west_rounded,
                    toneColor: dashboardTheme.successColor,
                  ),
                  DashboardMetric(
                    title: context.l10n.dashboardCardExpenses,
                    value: _formatCurrency(context, snapshot.stats.totalExpenses),
                    icon: Icons.north_east_rounded,
                    toneColor: colorScheme.tertiary,
                  ),
                  DashboardMetric(
                    title: context.l10n.dashboardCardLateResidents,
                    value: snapshot.overview.lateResidentCount.toString(),
                    icon: Icons.schedule_rounded,
                    toneColor: dashboardTheme.warningColor,
                  ),
                ];

                return ListView(
                  children: <Widget>[
                    DashboardTopBar(
                      layout: layout,
                      logoAssetPath: branding.logoAssetPath,
                      onLogout: () {
                        ref
                            .read(authSessionControllerProvider.notifier)
                            .clearSession();
                        context.goNamed(landingRouteName);
                      },
                    ),
                    SizedBox(height: layout.itemSpacing),
                    DashboardHero(
                      layout: layout,
                      user: user,
                    ),
                    SizedBox(height: layout.sectionSpacing),
                    DashboardSectionCard(
                      layout: layout,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            context.l10n.dashboardChartTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: layout.itemSpacing / 2),
                          Text(
                            context.l10n.dashboardChartSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: layout.sectionSpacing),
                          if (snapshot.stats.balanceEvolution.length >= 2) ...<Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.l10n.dashboardChartLegendCurrent,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            DashboardLineChart(
                              points: snapshot.stats.balanceEvolution,
                            ),
                          ] else if (snapshot.stats.balanceEvolution.isEmpty)
                            DashboardEmptyState(
                              title: context.l10n.dashboardChartEmptyNoData,
                            )
                          else
                            DashboardEmptyState(
                              title: context.l10n.dashboardChartSinglePointTitle,
                              subtitle: context.l10n.dashboardChartSinglePointBody(
                                _formatMonthLabel(
                                  context,
                                  snapshot.stats.balanceEvolution.single.month,
                                ),
                                _formatCurrency(
                                  context,
                                  snapshot.stats.balanceEvolution.single.balance,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: layout.sectionSpacing),
                    Wrap(
                      spacing: layout.itemSpacing,
                      runSpacing: layout.itemSpacing,
                      children: metrics
                          .map(
                            (metric) => SizedBox(
                              width: _metricWidth(layout),
                              child: DashboardMetricCard(
                                metric: metric,
                                layout: layout,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: layout.sectionSpacing),
                    if (layout.isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: DashboardActionsSection(
                              layout: layout,
                              actions: actions,
                            ),
                          ),
                          SizedBox(width: layout.itemSpacing),
                          Expanded(
                            child: DashboardRecentVotesSection(
                              layout: layout,
                              votes: snapshot.overview.recentVotes,
                              formatCurrency: (value) =>
                                  _formatCurrency(context, value),
                              voteStatusLabel: (status) =>
                                  _voteStatusLabel(context, status),
                              voteStatusColor: (status) =>
                                  _voteStatusColor(context, status),
                            ),
                          ),
                        ],
                      )
                    else ...<Widget>[
                      DashboardActionsSection(
                        layout: layout,
                        actions: actions,
                      ),
                      SizedBox(height: layout.sectionSpacing),
                      DashboardRecentVotesSection(
                        layout: layout,
                        votes: snapshot.overview.recentVotes,
                        formatCurrency: (value) => _formatCurrency(context, value),
                        voteStatusLabel: (status) =>
                            _voteStatusLabel(context, status),
                        voteStatusColor: (status) =>
                            _voteStatusColor(context, status),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

double _metricWidth(ResponsiveLayout layout) {
  if (layout.isDesktop) {
    return (layout.maxContentWidth - (layout.itemSpacing * 3)) / 4;
  }
  if (layout.isTablet) {
    return (layout.maxContentWidth - layout.itemSpacing) / 2;
  }
  return layout.maxContentWidth;
}

String _formatCurrency(BuildContext context, double value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final format = NumberFormat.currency(
    locale: locale,
    symbol: 'EUR ',
    decimalDigits: value.abs() >= 100 ? 0 : 2,
  );
  return format.format(value);
}

String _formatMonthLabel(BuildContext context, String rawValue) {
  final parsed = DateTime.tryParse('$rawValue-01');
  if (parsed == null) {
    return rawValue;
  }

  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMM(locale).format(parsed);
}

String _voteStatusLabel(BuildContext context, String status) {
  return switch (status) {
    'OUVERT' => context.l10n.dashboardVoteStatusOpen,
    'VALIDE' => context.l10n.dashboardVoteStatusValidated,
    'REJETE' => context.l10n.dashboardVoteStatusRejected,
    _ => status,
  };
}

Color _voteStatusColor(BuildContext context, String status) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final dashboardTheme =
      theme.extension<AppDashboardTheme>() ??
      AppDashboardTheme.light(colorScheme);

  return switch (status) {
    'VALIDE' => dashboardTheme.successColor,
    'REJETE' => dashboardTheme.warningColor,
    _ => colorScheme.primary,
  };
}

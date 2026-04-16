import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/theme/app_dashboard_theme.dart';
import '../../../core/widgets/responsive_page_container.dart';
import '../../auth/application/auth_session_controller.dart';
import '../application/dashboard_providers.dart';
import '../../paiement/application/paiement_providers.dart';
import 'widgets/dashboard_line_chart.dart';
import 'widgets/dashboard_panels.dart';
import 'widgets/dashboard_pie_charts.dart';
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

    return Scaffold(
      body: ResponsivePageContainer(
        child: ResponsiveBuilder(
          builder: (context, layout) {
            final user = ref.watch(currentUserProvider);
            final currencyCode = ref.watch(currentCurrencyCodeProvider);
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
                    value: _formatCurrency(
                      context,
                      snapshot.stats.currentBalance,
                      currencyCode,
                    ),
                    icon: Icons.account_balance_wallet_rounded,
                    toneColor: colorScheme.primary,
                  ),
                  DashboardMetric(
                    title: context.l10n.dashboardCardLateResidents,
                    value: snapshot.stats.paymentHousingStats.lateHousing
                        .toString(),
                    icon: Icons.schedule_rounded,
                    toneColor: const Color(0xFFC62828),
                  ),
                  DashboardMetric(
                    title: context.l10n.dashboardCardContributions,
                    value: _formatCurrency(
                      context,
                      snapshot.stats.totalContributions,
                      currencyCode,
                    ),
                    icon: Icons.south_west_rounded,
                    toneColor: dashboardTheme.successColor,
                  ),
                  DashboardMetric(
                    title: context.l10n.dashboardCardExpenses,
                    value: _formatCurrency(
                      context,
                      snapshot.stats.totalExpenses,
                      currencyCode,
                    ),
                    icon: Icons.north_east_rounded,
                    toneColor: colorScheme.tertiary,
                  ),
                ];

                return ListView(
                  children: <Widget>[
                    DashboardTopBar(
                      title: context.l10n.dashboardTitle,
                      layout: layout,
                      residenceBalance: snapshot.overview.balance,
                      currencyCode: currencyCode,
                      actions: <Widget>[
                        IconButton(
                          onPressed: () {
                            ref.invalidate(dashboardSnapshotProvider);
                            ref.invalidate(residentPaymentControllerProvider);
                            ref
                                .read(authSessionControllerProvider.notifier)
                                .refreshCurrentUser();
                          },
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).refreshIndicatorSemanticLabel,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    SizedBox(height: layout.itemSpacing),
                    DashboardHero(
                      layout: layout,
                      user: user,
                      paymentHousingStats: snapshot.stats.paymentHousingStats,
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
                          if (snapshot.stats.balanceEvolution.length >=
                              2) ...<Widget>[
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
                              currencyCode: currencyCode,
                            ),
                          ] else if (snapshot.stats.balanceEvolution.isEmpty)
                            DashboardEmptyState(
                              title: context.l10n.dashboardChartEmptyNoData,
                            )
                          else
                            DashboardEmptyState(
                              title:
                                  context.l10n.dashboardChartSinglePointTitle,
                              subtitle: context.l10n
                                  .dashboardChartSinglePointBody(
                                    _formatMonthLabel(
                                      context,
                                      snapshot
                                          .stats
                                          .balanceEvolution
                                          .single
                                          .month,
                                    ),
                                    _formatCurrency(
                                      context,
                                      snapshot
                                          .stats
                                          .balanceEvolution
                                          .single
                                          .balance,
                                      currencyCode,
                                    ),
                                  ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: layout.sectionSpacing),
                    DashboardPieChartsSection(
                      layout: layout,
                      paymentHousingStats: snapshot.stats.paymentHousingStats,
                      expenseCategoryStats: snapshot.stats.expenseCategoryStats,
                    ),
                    SizedBox(height: layout.sectionSpacing),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: metrics.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: layout.isMobile ? 1 : 2,
                        crossAxisSpacing: layout.itemSpacing,
                        mainAxisSpacing: layout.itemSpacing,
                        mainAxisExtent: layout.isMobile ? 156 : 172,
                      ),
                      itemBuilder: (context, index) {
                        return DashboardMetricCard(
                          metric: metrics[index],
                          layout: layout,
                        );
                      },
                    ),
                    SizedBox(height: layout.sectionSpacing),
                    DashboardRecentVotesSection(
                      layout: layout,
                      votes: snapshot.overview.recentVotes,
                      formatCurrency: (value) =>
                          _formatCurrency(context, value, currencyCode),
                      voteStatusLabel: (status) =>
                          _voteStatusLabel(context, status),
                      voteStatusColor: (status) =>
                          _voteStatusColor(context, status),
                    ),
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

String _formatCurrency(
  BuildContext context,
  double value,
  String? currencyCode,
) {
  return CurrencyFormatter.format(context, value, currencyCode: currencyCode);
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

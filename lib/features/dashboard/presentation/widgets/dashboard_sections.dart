import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../domain/dashboard_models.dart';
import 'dashboard_panels.dart';

class DashboardActionsSection extends StatelessWidget {
  const DashboardActionsSection({
    required this.layout,
    required this.actions,
    super.key,
  });

  final ResponsiveLayout layout;
  final List<DashboardAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DashboardSectionCard(
      layout: layout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.dashboardActionsTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: layout.itemSpacing / 2),
          Text(
            context.l10n.dashboardActionsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          SizedBox(height: layout.sectionSpacing),
          ...actions.map(
            (action) => Padding(
              padding: EdgeInsets.only(bottom: layout.itemSpacing),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => context.goNamed(action.routeName),
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.26,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          action.icon,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              action.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              action.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardRecentVotesSection extends StatelessWidget {
  const DashboardRecentVotesSection({
    required this.layout,
    required this.votes,
    required this.formatCurrency,
    required this.voteStatusLabel,
    required this.voteStatusColor,
    super.key,
  });

  final ResponsiveLayout layout;
  final List<DashboardVote> votes;
  final String Function(double value) formatCurrency;
  final String Function(String status) voteStatusLabel;
  final Color Function(String status) voteStatusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DashboardSectionCard(
      layout: layout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.dashboardActivityTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: layout.itemSpacing / 2),
          Text(
            context.l10n.dashboardActivitySubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          SizedBox(height: layout.sectionSpacing),
          if (votes.isEmpty)
            DashboardEmptyState(title: context.l10n.dashboardActivityEmpty)
          else
            ...votes.map(
              (vote) => Container(
                margin: EdgeInsets.only(bottom: layout.itemSpacing),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.22,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            vote.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DashboardStatusBadge(
                          label: voteStatusLabel(vote.status),
                          color: voteStatusColor(vote.status),
                        ),
                      ],
                    ),
                    if (vote.description.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      Text(
                        vote.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      '${context.l10n.dashboardEstimatedAmount} - ${formatCurrency(vote.estimatedAmount)}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

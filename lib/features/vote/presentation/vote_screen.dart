import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_dashboard_theme.dart';
import '../../../core/widgets/global_page_header.dart';
import '../../../core/widgets/responsive_page_container.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../application/vote_providers.dart';
import '../domain/vote_models.dart';

class VoteScreen extends ConsumerWidget {
  const VoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsivePageContainer(
        child: ResponsiveBuilder(
          builder: (context, layout) => _VotePage(layout: layout),
        ),
      ),
    );
  }
}

class _VotePage extends ConsumerWidget {
  const _VotePage({required this.layout});

  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
    final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;
    final currencyCode = ref.watch(currentCurrencyCodeProvider);
    final dashboardSnapshot = ref.watch(dashboardSnapshotProvider).valueOrNull;
    final votesAsync = ref.watch(voteOverviewControllerProvider);

    return ListView(
      children: <Widget>[
        GlobalPageHeader(
          title: context.l10n.moduleVoteTitle,
          layout: layout,
          residenceBalance: dashboardSnapshot?.overview.balance,
          currencyCode: currencyCode,
          actions: <Widget>[
            IconButton(
              onPressed: () =>
                  ref.read(voteOverviewControllerProvider.notifier).refresh(),
              tooltip: context.l10n.voteRefreshTooltip,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        SizedBox(height: layout.sectionSpacing),
        _VoteIntroCard(layout: layout, isAdmin: isAdmin),
        SizedBox(height: layout.sectionSpacing),
        votesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => _VoteErrorState(
            message: _resolveVoteErrorMessage(context, error),
            onRetry: () =>
                ref.read(voteOverviewControllerProvider.notifier).refresh(),
          ),
          data: (votes) {
            if (votes.isEmpty) {
              return _VoteEmptyState(layout: layout);
            }
            final openVotes =
                votes
                    .where(
                      (vote) => vote.displayStatus == VoteDisplayStatus.enCours,
                    )
                    .toList()
                  ..sort(_compareOpenVotesByEndDate);
            final closedVotes =
                votes
                    .where(
                      (vote) => vote.displayStatus == VoteDisplayStatus.termine,
                    )
                    .toList()
                  ..sort(_compareClosedVotesByEndDate);
            final otherVotes =
                votes
                    .where(
                      (vote) =>
                          vote.displayStatus != VoteDisplayStatus.enCours &&
                          vote.displayStatus != VoteDisplayStatus.termine,
                    )
                    .toList()
                  ..sort(_compareOpenVotesByEndDate);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _VoteCollectionHero(layout: layout, votes: votes),
                SizedBox(height: layout.sectionSpacing),
                if (openVotes.isNotEmpty)
                  _VoteSection(
                    title: context.l10n.voteStatusOpen,
                    votes: openVotes,
                    layout: layout,
                    currencyCode: currencyCode,
                    isAdmin: isAdmin,
                  ),
                if (closedVotes.isNotEmpty) ...<Widget>[
                  if (openVotes.isNotEmpty)
                    SizedBox(height: layout.sectionSpacing),
                  _VoteSection(
                    title: context.l10n.voteStatusClosed,
                    votes: closedVotes,
                    layout: layout,
                    currencyCode: currencyCode,
                    isAdmin: isAdmin,
                  ),
                ],
                if (otherVotes.isNotEmpty) ...<Widget>[
                  if (openVotes.isNotEmpty || closedVotes.isNotEmpty)
                    SizedBox(height: layout.sectionSpacing),
                  _VoteSection(
                    title: context.l10n.voteInfoTitle,
                    votes: otherVotes,
                    layout: layout,
                    currencyCode: currencyCode,
                    isAdmin: isAdmin,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _VoteSection extends StatelessWidget {
  const _VoteSection({
    required this.title,
    required this.votes,
    required this.layout,
    required this.currencyCode,
    required this.isAdmin,
  });

  final String title;
  final List<VoteOverview> votes;
  final ResponsiveLayout layout;
  final String? currencyCode;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.42,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${votes.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: layout.itemSpacing),
        ...votes.map(
          (vote) => Padding(
            padding: EdgeInsets.only(bottom: layout.itemSpacing + 4),
            child: _VoteCard(
              vote: vote,
              layout: layout,
              currencyCode: currencyCode,
              isAdmin: isAdmin,
            ),
          ),
        ),
      ],
    );
  }
}

class _VoteCollectionHero extends StatelessWidget {
  const _VoteCollectionHero({required this.layout, required this.votes});

  final ResponsiveLayout layout;
  final List<VoteOverview> votes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final openCount = votes
        .where((vote) => vote.displayStatus == VoteDisplayStatus.enCours)
        .length;
    final closedCount = votes.length - openCount;
    final totalVoters = votes.fold<int>(
      0,
      (sum, vote) => sum + vote.totalVoters,
    );
    final totalEligible = votes.fold<int>(
      0,
      (sum, vote) => sum + vote.totalEligibleVoters,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.42),
        ),
      ),
      child: Wrap(
        spacing: layout.isMobile ? 14 : 22,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          _VoteHeroInlineStat(
            icon: Icons.timelapse_rounded,
            label: context.l10n.voteStatusOpen,
            value: '$openCount',
            tint: colorScheme.primary,
          ),
          _VoteHeroInlineStat(
            icon: Icons.check_circle_outline_rounded,
            label: context.l10n.voteStatusClosed,
            value: '$closedCount',
            tint: colorScheme.tertiary,
          ),
          _VoteHeroInlineStat(
            icon: Icons.pie_chart_rounded,
            label: context.l10n.voteResultsSectionTitle,
            value: '$totalVoters/$totalEligible',
            tint: colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _VoteHeroInlineStat extends StatelessWidget {
  const _VoteHeroInlineStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: tint),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            children: <InlineSpan>[
              TextSpan(
                text: '$value ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: tint,
                ),
              ),
              TextSpan(
                text: label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VoteIntroCard extends ConsumerWidget {
  const _VoteIntroCard({required this.layout, required this.isAdmin});

  final ResponsiveLayout layout;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    final residenceId = ref.watch(currentUserProvider)?.residenceId;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            dashboardTheme.heroStartColor,
            dashboardTheme.heroEndColor,
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.62),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dashboardTheme.heroGlowColor,
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      context.l10n.moduleVoteDescription,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              if (isAdmin) ...<Widget>[
                const SizedBox(width: 12),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surface.withValues(
                        alpha: 0.82,
                      ),
                      foregroundColor: colorScheme.primary,
                    ),
                    onPressed: residenceId == null
                        ? null
                        : () => _showCreateVoteDialog(context, residenceId),
                    tooltip: context.l10n.voteCreateAction,
                    icon: const Icon(Icons.add_rounded, size: 18),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  context.l10n.voteInfoTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.voteInfoBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _VoteInlineInfo(
                  icon: Icons.admin_panel_settings_rounded,
                  label: context.l10n.voteInfoAdminCreated,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VoteInlineInfo(
                  icon: Icons.how_to_vote_rounded,
                  label: context.l10n.voteInfoResidentVotes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VoteInlineInfo(
                  icon: Icons.bar_chart_rounded,
                  label: context.l10n.voteInfoVisibleResults,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoteInlineInfo extends StatelessWidget {
  const _VoteInlineInfo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _VoteCard extends ConsumerStatefulWidget {
  const _VoteCard({
    required this.vote,
    required this.layout,
    required this.currencyCode,
    required this.isAdmin,
  });

  final VoteOverview vote;
  final ResponsiveLayout layout;
  final String? currencyCode;
  final bool isAdmin;

  @override
  ConsumerState<_VoteCard> createState() => _VoteCardState();
}

class _VoteCardState extends ConsumerState<_VoteCard> {
  VoteChoice? _submittingChoice;
  bool _closingVote = false;
  bool _creatingExpense = false;

  @override
  Widget build(BuildContext context) {
    final vote = widget.vote;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    final adminDetailsAsync = widget.isAdmin
        ? ref.watch(voteDetailsProvider(vote.id))
        : null;
    final commentsByLogement = _commentsByLogement(
      adminDetailsAsync?.valueOrNull?.comments ?? const <VoteCommentDetail>[],
    );
    final canCreateExpense =
        widget.isAdmin &&
        vote.displayStatus == VoteDisplayStatus.termine &&
        vote.businessStatus == VoteBusinessStatus.valide &&
        vote.expenseId == null;
    final expenseAlreadyCreated =
        widget.isAdmin &&
        vote.displayStatus == VoteDisplayStatus.termine &&
        vote.businessStatus == VoteBusinessStatus.valide &&
        vote.expenseId != null;
    final statusColor = switch (vote.displayStatus) {
      VoteDisplayStatus.enCours => dashboardTheme.successColor,
      VoteDisplayStatus.termine => colorScheme.primary,
      VoteDisplayStatus.unknown => colorScheme.onSurfaceVariant,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.layout.isMobile ? 18 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.surface,
            colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    _VoteLiveMarker(
                      color: statusColor,
                      label: vote.displayStatus == VoteDisplayStatus.enCours
                          ? context.l10n.voteStatusOpen
                          : context.l10n.voteStatusClosed,
                    ),
                    _VoteBusinessBadge(vote: vote),
                  ],
                ),
              ),
              if (widget.isAdmin &&
                  vote.displayStatus == VoteDisplayStatus.enCours) ...<Widget>[
                const SizedBox(width: 12),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: context.l10n.voteStatusClosed,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                      foregroundColor: colorScheme.error,
                    ),
                    onPressed: _closingVote ? null : _handleCloseVote,
                    icon: _closingVote
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.gavel_rounded, size: 18),
                  ),
                ),
              ] else if (canCreateExpense || expenseAlreadyCreated) ...<Widget>[
                const SizedBox(width: 12),
                _VoteExpenseAction(
                  enabled: canCreateExpense && !_creatingExpense,
                  loading: _creatingExpense,
                  created: expenseAlreadyCreated,
                  onPressed: _handleCreateExpenseFromVote,
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      vote.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vote.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              _VoteAmountHighlight(
                amount: vote.estimatedAmount,
                currencyCode: widget.currencyCode,
              ),
            ],
          ),
          if (vote.nearEnd) ...<Widget>[
            const SizedBox(height: 14),
            _VoteAlertBanner(daysRemaining: vote.daysRemaining),
          ],
          const SizedBox(height: 18),
          _VoteResultPanel(
            vote: vote,
            layout: widget.layout,
            currencyCode: widget.currencyCode,
          ),
          const SizedBox(height: 18),
          if (vote.currentUserCanVote)
            _VoteActionPanel(
              submittingChoice: _submittingChoice,
              onVote: _handleVote,
            )
          else if (vote.currentUserHasVoted)
            _VoteCurrentChoiceBanner(
              choice: vote.currentUserChoice,
              comment: vote.currentUserComment,
            )
          else if (vote.displayStatus == VoteDisplayStatus.termine)
            _VoteClosedBanner(),
          const SizedBox(height: 18),
          _VoteHousingSection(
            vote: vote,
            isAdmin: widget.isAdmin,
            adminCommentsByLogement: commentsByLogement,
            commentsLoading: adminDetailsAsync?.isLoading ?? false,
          ),
          const SizedBox(height: 16),
          _VoteMetaFooter(vote: vote),
        ],
      ),
    );
  }

  Future<void> _handleVote(VoteChoice choice) async {
    final comment = await _showVoteCommentDialog(context);
    if (!mounted || comment == null) {
      return;
    }
    setState(() => _submittingChoice = choice);
    try {
      await ref
          .read(voteOverviewControllerProvider.notifier)
          .submitVote(voteId: widget.vote.id, choice: choice, comment: comment);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.voteSubmitSuccess)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveVoteErrorMessage(context, error))),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingChoice = null);
      }
    }
  }

  Future<void> _handleCloseVote() async {
    setState(() => _closingVote = true);
    try {
      await ref
          .read(voteOverviewControllerProvider.notifier)
          .closeVote(widget.vote.id);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveVoteErrorMessage(context, error))),
      );
    } finally {
      if (mounted) {
        setState(() => _closingVote = false);
      }
    }
  }

  Future<void> _handleCreateExpenseFromVote() async {
    if (_creatingExpense) {
      return;
    }
    final confirmed = await _showCreateExpenseConfirmationDialog(context);
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _creatingExpense = true);
    try {
      await ref
          .read(voteOverviewControllerProvider.notifier)
          .createExpenseFromVote(widget.vote.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.voteExpenseCreateSuccess)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveVoteErrorMessage(context, error))),
      );
    } finally {
      if (mounted) {
        setState(() => _creatingExpense = false);
      }
    }
  }
}

class _VoteExpenseAction extends StatelessWidget {
  const _VoteExpenseAction({
    required this.enabled,
    required this.loading,
    required this.created,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final bool created;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = created
        ? colorScheme.onSurfaceVariant
        : const Color(0xFF1D8348);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            tooltip: created
                ? context.l10n.voteExpenseAlreadyCreated
                : context.l10n.voteCreateExpenseAction,
            style: IconButton.styleFrom(
              backgroundColor: accent.withValues(alpha: created ? 0.08 : 0.12),
              foregroundColor: accent,
            ),
            onPressed: enabled ? onPressed : null,
            icon: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    created
                        ? Icons.receipt_long_outlined
                        : Icons.receipt_long_rounded,
                    size: 18,
                  ),
          ),
        ),
        if (created) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            context.l10n.voteExpenseAlreadyCreated,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF5E8E67),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _VoteLiveMarker extends StatelessWidget {
  const _VoteLiveMarker({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteBusinessBadge extends StatelessWidget {
  const _VoteBusinessBadge({required this.vote});

  final VoteOverview vote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (label, color) = switch (vote.businessStatus) {
      VoteBusinessStatus.valide => ('VALIDE', const Color(0xFF1D8348)),
      VoteBusinessStatus.rejete => ('REJETE', colorScheme.error),
      VoteBusinessStatus.ouvert => ('OUVERT', colorScheme.secondary),
      VoteBusinessStatus.cloture => ('CLOTURE', colorScheme.tertiary),
      VoteBusinessStatus.unknown => ('INCONNU', colorScheme.outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _VoteAmountHighlight extends StatelessWidget {
  const _VoteAmountHighlight({
    required this.amount,
    required this.currencyCode,
  });

  final double amount;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.16),
            colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            context.l10n.voteEstimatedAmountLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(
              context,
              amount,
              currencyCode: currencyCode,
            ),
            textAlign: TextAlign.right,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteMetaFooter extends StatelessWidget {
  const _VoteMetaFooter({required this.vote});

  final VoteOverview vote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final items = <Widget>[
      _VoteMetaItem(
        label: context.l10n.voteStartDateLabel,
        value: _formatDate(context, vote.startDate),
      ),
      _VoteMetaItem(
        label: context.l10n.voteEndDateLabel,
        value: _formatDate(context, vote.endDate),
      ),
    ];

    if (vote.createdByName.trim().isNotEmpty) {
      items.add(
        _VoteMetaItem(
          label: context.l10n.voteCreatedByLabel,
          value: vote.createdByName,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
      ),
      child: Wrap(spacing: 16, runSpacing: 8, children: items),
    );
  }
}

class _VoteAlertBanner extends StatelessWidget {
  const _VoteAlertBanner({required this.daysRemaining});

  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Icon(Icons.schedule_rounded, size: 18, color: colorScheme.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.l10n.voteEndingSoon(daysRemaining),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}

class _VoteMetaItem extends StatelessWidget {
  const _VoteMetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
        ),
        children: <InlineSpan>[
          TextSpan(
            text: '$label ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteResultPanel extends StatelessWidget {
  const _VoteResultPanel({
    required this.vote,
    required this.layout,
    required this.currencyCode,
  });

  final VoteOverview vote;
  final ResponsiveLayout layout;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 18 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.56),
            colorScheme.surfaceContainer.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                context.l10n.voteResultsSectionTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.76),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.l10n.voteParticipantsSummary(
                    vote.totalVoters,
                    vote.totalEligibleVoters,
                  ),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _leadingLabel(context, vote),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 16,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: vote.totalPour == 0 ? 1 : vote.totalPour,
                    child: Container(color: dashboardTheme.successColor),
                  ),
                  Expanded(
                    flex: vote.totalContre == 0 ? 1 : vote.totalContre,
                    child: Container(color: colorScheme.error),
                  ),
                  Expanded(
                    flex: vote.totalNeutre == 0 ? 1 : vote.totalNeutre,
                    child: Container(color: colorScheme.tertiary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _VoteCounterChip(
                color: dashboardTheme.successColor,
                label: context.l10n.voteChoicePour,
                value: vote.totalPour,
              ),
              _VoteCounterChip(
                color: colorScheme.error,
                label: context.l10n.voteChoiceContre,
                value: vote.totalContre,
              ),
              _VoteCounterChip(
                color: colorScheme.tertiary,
                label: context.l10n.voteChoiceNeutre,
                value: vote.totalNeutre,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: vote.turnoutProgress,
            minHeight: 12,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.voteTurnoutLabel(
              vote.totalVoters,
              vote.totalEligibleVoters,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _leadingLabel(BuildContext context, VoteOverview vote) {
    return switch (vote.leadingChoice) {
      VoteChoice.pour => context.l10n.voteLeadingPour(vote.leadingVotes),
      VoteChoice.contre => context.l10n.voteLeadingContre(vote.leadingVotes),
      VoteChoice.neutre => context.l10n.voteLeadingNeutre(vote.leadingVotes),
      VoteChoice.egalite => context.l10n.voteLeadingTie,
      VoteChoice.aucun || VoteChoice.unknown => context.l10n.voteLeadingNone,
    };
  }
}

class _VoteCounterChip extends StatelessWidget {
  const _VoteCounterChip({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label - $value',
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _VoteActionPanel extends StatelessWidget {
  const _VoteActionPanel({
    required this.submittingChoice,
    required this.onVote,
  });

  final VoteChoice? submittingChoice;
  final Future<void> Function(VoteChoice choice) onVote;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _VoteChoiceButton(
              choice: VoteChoice.pour,
              icon: Icons.thumb_up_alt_rounded,
              label: context.l10n.voteChoicePour,
              submittingChoice: submittingChoice,
              onVote: onVote,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _VoteChoiceButton(
              choice: VoteChoice.contre,
              icon: Icons.thumb_down_alt_rounded,
              label: context.l10n.voteChoiceContre,
              submittingChoice: submittingChoice,
              onVote: onVote,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _VoteChoiceButton(
              choice: VoteChoice.neutre,
              icon: Icons.horizontal_rule_rounded,
              label: context.l10n.voteChoiceNeutre,
              submittingChoice: submittingChoice,
              onVote: onVote,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteChoiceButton extends StatelessWidget {
  const _VoteChoiceButton({
    required this.choice,
    required this.icon,
    required this.label,
    required this.submittingChoice,
    required this.onVote,
  });

  final VoteChoice choice;
  final IconData icon;
  final String label;
  final VoteChoice? submittingChoice;
  final Future<void> Function(VoteChoice choice) onVote;

  @override
  Widget build(BuildContext context) {
    final isLoading = submittingChoice == choice;
    final colorScheme = Theme.of(context).colorScheme;
    final background = switch (choice) {
      VoteChoice.pour => const Color(0xFF1D8348).withValues(alpha: 0.12),
      VoteChoice.contre => colorScheme.error.withValues(alpha: 0.1),
      VoteChoice.neutre => colorScheme.tertiary.withValues(alpha: 0.14),
      _ => colorScheme.surfaceContainerHighest,
    };

    return FilledButton.tonalIcon(
      style: FilledButton.styleFrom(
        backgroundColor: background,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        textStyle: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: submittingChoice != null ? null : () => onVote(choice),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
    );
  }
}

class _VoteCurrentChoiceBanner extends StatelessWidget {
  const _VoteCurrentChoiceBanner({required this.choice, this.comment});

  final VoteChoice choice;
  final String? comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primaryContainer.withValues(alpha: 0.72),
            colorScheme.secondaryContainer.withValues(alpha: 0.34),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.voteAlreadyVoted(_choiceLabel(context, choice)),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          if ((comment ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              context.l10n.voteCurrentUserCommentLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              comment!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.88),
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _choiceLabel(BuildContext context, VoteChoice choice) {
    return switch (choice) {
      VoteChoice.pour => context.l10n.voteChoicePour,
      VoteChoice.contre => context.l10n.voteChoiceContre,
      VoteChoice.neutre => context.l10n.voteChoiceNeutre,
      _ => context.l10n.voteChoiceUnknown,
    };
  }
}

class _VoteClosedBanner extends StatelessWidget {
  const _VoteClosedBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        context.l10n.voteClosedMessage,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _VoteHousingSection extends StatelessWidget {
  const _VoteHousingSection({
    required this.vote,
    required this.isAdmin,
    required this.adminCommentsByLogement,
    required this.commentsLoading,
  });

  final VoteOverview vote;
  final bool isAdmin;
  final Map<int, List<VoteCommentDetail>> adminCommentsByLogement;
  final bool commentsLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
            colorScheme.surface.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          title: Text(
            context.l10n.voteHousingSectionTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            _buildSubtitle(context),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          children: vote.housingParticipations
              .map(
                (participation) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _VoteHousingTile(
                    participation: participation,
                    comments:
                        adminCommentsByLogement[participation.logementId] ??
                        const <VoteCommentDetail>[],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _buildSubtitle(BuildContext context) {
    final base = context.l10n.voteHousingSectionSubtitle(
      vote.housingParticipations.length,
    );
    if (!isAdmin) {
      return base;
    }
    if (commentsLoading) {
      return '$base • ${context.l10n.voteAdminCommentsLoading}';
    }
    return '$base • ${context.l10n.voteAdminCommentsVisible}';
  }
}

class _VoteHousingTile extends StatelessWidget {
  const _VoteHousingTile({required this.participation, required this.comments});

  final VoteHousingParticipation participation;
  final List<VoteCommentDetail> comments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    final accent = participation.hasVoted
        ? dashboardTheme.successColor
        : colorScheme.outline;
    final progress = participation.totalEligibleVoters <= 0
        ? 0.0
        : (participation.totalVoters / participation.totalEligibleVoters)
              .clamp(0, 1)
              .toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      participation.codeInterne,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      participation.hasVoted
                          ? context.l10n.voteHousingVoted
                          : context.l10n.voteHousingNotVoted,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: participation.hasVoted
                            ? dashboardTheme.successColor
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.l10n.voteHousingParticipationValue(
                    participation.totalVoters,
                    participation.totalEligibleVoters,
                  ),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (comments.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.38,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.voteAdminCommentsSectionTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...comments.map(
                    (comment) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _VoteHousingCommentTile(comment: comment),
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
}

class _VoteHousingCommentTile extends StatelessWidget {
  const _VoteHousingCommentTile({required this.comment});

  final VoteCommentDetail comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            comment.userEmail,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comment.comment,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteEmptyState extends StatelessWidget {
  const _VoteEmptyState({required this.layout});

  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: <Widget>[
          Icon(Icons.how_to_vote_rounded, size: 38, color: colorScheme.primary),
          const SizedBox(height: 14),
          Text(
            context.l10n.voteEmptyTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.voteEmptyBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteErrorState extends StatelessWidget {
  const _VoteErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 34),
          const SizedBox(height: 12),
          Text(
            context.l10n.voteErrorTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.voteRetryAction),
          ),
        ],
      ),
    );
  }
}

class _VoteCommentDialog extends StatefulWidget {
  const _VoteCommentDialog();

  @override
  State<_VoteCommentDialog> createState() => _VoteCommentDialogState();
}

class _VoteCommentDialogState extends State<_VoteCommentDialog> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.voteCommentDialogTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.l10n.voteCommentDialogBody,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              maxLength: voteCommentMaxLength,
              maxLines: 2,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              buildCounter:
                  (
                    BuildContext context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    final remaining = (maxLength ?? 0) - currentLength;
                    return Text(
                      context.l10n.voteCommentRemainingCharacters(remaining),
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
              decoration: InputDecoration(
                labelText: context.l10n.voteCommentFieldLabel,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop<String?>(null),
          child: Text(context.l10n.voteCancelAction),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop<String>(_commentController.text.trim()),
          child: Text(context.l10n.voteCommentSubmitAction),
        ),
      ],
    );
  }
}

class _CreateVoteDialog extends ConsumerStatefulWidget {
  const _CreateVoteDialog({required this.residenceId});

  final int residenceId;

  @override
  ConsumerState<_CreateVoteDialog> createState() => _CreateVoteDialogState();
}

class _CreateVoteDialogState extends ConsumerState<_CreateVoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day, 8);
    _endDate = _startDate.add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AlertDialog(
      title: Text(context.l10n.voteCreateDialogTitle),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460,
          maxHeight: mediaQuery.size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    context.l10n.voteCreateDialogBody,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: context.l10n.voteFieldTitle,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? context.l10n.voteFieldTitleError
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: context.l10n.voteFieldDescription,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? context.l10n.voteFieldDescriptionError
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.voteFieldEstimatedAmount,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _DateField(
                  label: context.l10n.voteFieldStartDate,
                  value: _formatDate(context, _startDate),
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: 16),
                _DateField(
                  label: context.l10n.voteFieldEndDate,
                  value: _formatDate(context, _endDate),
                  onTap: _pickEndDate,
                ),
                if (_errorText != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(context.l10n.voteCancelAction),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(
            _submitting
                ? context.l10n.authSubmittingLabel
                : context.l10n.voteCreateAction,
          ),
        ),
      ],
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _startDate = DateTime(picked.year, picked.month, picked.day, 8);
      if (!_endDate.isAfter(_startDate)) {
        _endDate = _startDate.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _endDate = DateTime(picked.year, picked.month, picked.day, 20);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_endDate.isAfter(_startDate)) {
      setState(() => _errorText = context.l10n.voteDateRangeError);
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await ref
          .read(voteOverviewControllerProvider.notifier)
          .createVote(
            CreateVotePayload(
              residenceId: widget.residenceId,
              title: _titleController.text,
              description: _descriptionController.text,
              estimatedAmount: _parseAmount(_amountController.text),
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _errorText = _resolveVoteErrorMessage(context, error));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(value)),
            const Icon(Icons.calendar_month_rounded),
          ],
        ),
      ),
    );
  }
}

Future<void> _showCreateVoteDialog(
  BuildContext context,
  int residenceId,
) async {
  final created = await showDialog<bool>(
    context: context,
    builder: (context) => _CreateVoteDialog(residenceId: residenceId),
  );

  if (created == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.voteCreateSuccess)));
  }
}

Future<String?> _showVoteCommentDialog(BuildContext context) {
  return showDialog<String?>(
    context: context,
    builder: (context) => const _VoteCommentDialog(),
  );
}

Future<bool?> _showCreateExpenseConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.voteExpenseConfirmDialogTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Text(
          context.l10n.voteExpenseConfirmDialogBody,
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(context.l10n.voteCancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(context.l10n.voteCreateExpenseAction),
        ),
      ],
    ),
  );
}

Map<int, List<VoteCommentDetail>> _commentsByLogement(
  List<VoteCommentDetail> comments,
) {
  final map = <int, List<VoteCommentDetail>>{};
  for (final comment in comments) {
    final logementId = comment.logementId;
    if (logementId == null) {
      continue;
    }
    map.putIfAbsent(logementId, () => <VoteCommentDetail>[]).add(comment);
  }
  return map;
}

String _formatDate(BuildContext context, DateTime? date) {
  if (date == null) {
    return context.l10n.paymentDateUnavailable;
  }
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}

double? _parseAmount(String raw) {
  final normalized = raw.trim().replaceAll(',', '.');
  if (normalized.isEmpty) {
    return null;
  }
  final value = double.tryParse(normalized);
  if (value == null || value <= 0) {
    return null;
  }
  return value;
}

String _resolveVoteErrorMessage(BuildContext context, Object error) {
  final exception = ApiException.fromError(error);
  return switch (exception.kind) {
    ApiExceptionKind.timeout => context.l10n.authErrorTimeout,
    ApiExceptionKind.network => context.l10n.authErrorNetwork,
    ApiExceptionKind.unauthorized => context.l10n.authErrorUnauthorized,
    ApiExceptionKind.forbidden =>
      exception.message.isEmpty
          ? context.l10n.voteForbiddenError
          : exception.message,
    ApiExceptionKind.notFound =>
      exception.message.isEmpty
          ? context.l10n.voteNotFoundError
          : exception.message,
    ApiExceptionKind.badRequest => exception.message,
    ApiExceptionKind.unknown => exception.message,
  };
}

int _compareOpenVotesByEndDate(VoteOverview a, VoteOverview b) {
  return _voteSortKey(a.endDate).compareTo(_voteSortKey(b.endDate));
}

int _compareClosedVotesByEndDate(VoteOverview a, VoteOverview b) {
  return _voteSortKey(b.endDate).compareTo(_voteSortKey(a.endDate));
}

int _voteSortKey(DateTime? value) {
  return value?.millisecondsSinceEpoch ?? 0;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_dashboard_theme.dart';
import '../../../core/widgets/formatted_amount_text.dart';
import '../../../core/widgets/responsive_page_container.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../application/paiement_providers.dart';
import '../data/paiement_repository.dart';
import '../domain/paiement_models.dart';

class PaiementScreen extends ConsumerWidget {
  const PaiementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsivePageContainer(
        useTopSafeArea: false,
        child: ResponsiveBuilder(
          builder: (context, layout) => _PaymentPage(
            layout: layout,
            onModeChanged: (mode) {
              ref.read(paymentViewModeProvider.notifier).state = mode;
              ref.read(selectedPaymentLogementProvider.notifier).state = null;
            },
          ),
        ),
      ),
    );
  }
}

class _PaymentPage extends ConsumerWidget {
  const _PaymentPage({required this.layout, required this.onModeChanged});

  final ResponsiveLayout layout;
  final ValueChanged<PaymentViewMode> onModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
    final isAdmin = _isAdminRole(userRole);
    final pendingPaymentsCount = isAdmin
        ? ref.watch(pendingPaymentsCountProvider).valueOrNull
        : null;
    final canManageOwnPayments =
        userRole == UserRole.user || _isAdminRole(userRole);
    final mode = isAdmin
        ? ref.watch(paymentViewModeProvider)
        : PaymentViewMode.mine;
    final selectedLogement = isAdmin
        ? ref.watch(selectedPaymentLogementProvider)
        : null;
    final overviewAsync = _resolveAsync(ref, mode, selectedLogement);

    return ListView(
      children: <Widget>[
        if (isAdmin) ...<Widget>[
          _PaymentModeCard(
            layout: layout,
            mode: mode,
            pendingCount: pendingPaymentsCount,
            onModeChanged: onModeChanged,
          ),
          SizedBox(height: layout.itemSpacing),
        ],
        if (isAdmin && mode == PaymentViewMode.resident) ...<Widget>[
          _ResidentHousingCard(
            layout: layout,
            selectedLogement: selectedLogement,
          ),
          SizedBox(height: layout.sectionSpacing),
        ],
        if (mode == PaymentViewMode.resident && selectedLogement == null)
          _InlineStateCard(
            icon: Icons.manage_search_rounded,
            title: context.l10n.paymentResidentEmptyTitle,
            body: context.l10n.paymentResidentEmptyBody,
          )
        else if (mode == PaymentViewMode.pending)
          _AdminPendingPaymentsBody(layout: layout)
        else
          _PaymentBody(
            layout: layout,
            overviewAsync: overviewAsync,
            targetLogement: mode == PaymentViewMode.resident
                ? selectedLogement
                : null,
            canCreatePayment:
                (mode == PaymentViewMode.mine && canManageOwnPayments) ||
                (isAdmin &&
                    mode == PaymentViewMode.resident &&
                    selectedLogement != null),
            canDeletePendingPayment: mode == PaymentViewMode.mine,
            onRetry: () => _refresh(ref, mode, selectedLogement),
          ),
      ],
    );
  }

  AsyncValue<ResidentPaymentOverview> _resolveAsync(
    WidgetRef ref,
    PaymentViewMode mode,
    PaymentLogementOption? selectedLogement,
  ) {
    switch (mode) {
      case PaymentViewMode.mine:
        return ref.watch(residentPaymentControllerProvider);
      case PaymentViewMode.resident:
        if (selectedLogement == null) {
          return const AsyncLoading();
        }
        return ref.watch(adminResidentPaymentProvider(selectedLogement.id));
      case PaymentViewMode.pending:
        return const AsyncLoading();
    }
  }

  void _refresh(
    WidgetRef ref,
    PaymentViewMode mode,
    PaymentLogementOption? selectedLogement,
  ) {
    ref.read(authSessionControllerProvider.notifier).refreshCurrentUser();
    if (mode == PaymentViewMode.mine) {
      ref.read(residentPaymentControllerProvider.notifier).refresh();
      return;
    }
    if (mode == PaymentViewMode.pending) {
      ref.invalidate(adminPendingPaymentsProvider);
      return;
    }
    if (selectedLogement == null) {
      return;
    }
    ref.invalidate(adminResidentPaymentProvider(selectedLogement.id));
  }
}

class _PaymentBody extends StatelessWidget {
  const _PaymentBody({
    required this.layout,
    required this.overviewAsync,
    required this.canCreatePayment,
    required this.canDeletePendingPayment,
    required this.onRetry,
    this.targetLogement,
  });

  final ResponsiveLayout layout;
  final AsyncValue<ResidentPaymentOverview> overviewAsync;
  final bool canCreatePayment;
  final bool canDeletePendingPayment;
  final VoidCallback onRetry;
  final PaymentLogementOption? targetLogement;

  @override
  Widget build(BuildContext context) {
    return overviewAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _PaymentErrorState(
        message: _resolvePaymentErrorMessage(context, error),
        onRetry: onRetry,
      ),
      data: (overview) => _PaymentOverviewSections(
        layout: layout,
        overview: overview,
        targetLogement: targetLogement,
        canCreatePayment: canCreatePayment,
        canDeletePendingPayment: canDeletePendingPayment,
      ),
    );
  }
}

class _PaymentOverviewSections extends ConsumerStatefulWidget {
  const _PaymentOverviewSections({
    required this.layout,
    required this.overview,
    required this.canCreatePayment,
    required this.canDeletePendingPayment,
    this.targetLogement,
  });

  final ResponsiveLayout layout;
  final ResidentPaymentOverview overview;
  final bool canCreatePayment;
  final bool canDeletePendingPayment;
  final PaymentLogementOption? targetLogement;

  @override
  ConsumerState<_PaymentOverviewSections> createState() =>
      _PaymentOverviewSectionsState();
}

class _PaymentOverviewSectionsState
    extends ConsumerState<_PaymentOverviewSections> {
  bool _showAllMonths = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    final currencyCode = ref.watch(currentCurrencyCodeProvider);
    final pending = widget.overview.pendingPayment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildHero(
          context,
          dashboardTheme,
          widget.canCreatePayment && pending == null,
        ),
        if (widget.canCreatePayment && pending != null) ...<Widget>[
          SizedBox(height: widget.layout.itemSpacing),
          Text(
            context.l10n.paymentPendingLocksCreation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        SizedBox(height: widget.layout.sectionSpacing),
        Wrap(
          spacing: widget.layout.itemSpacing,
          runSpacing: widget.layout.itemSpacing,
          children: <Widget>[
            SizedBox(
              width: _cardWidth(widget.layout),
              child: _buildPendingSection(context, currencyCode, pending),
            ),
            SizedBox(
              width: _cardWidth(widget.layout),
              child: _InfoCard(
                icon: Icons.view_timeline_rounded,
                title: context.l10n.paymentTimelineTitle,
                subtitle: context.l10n.paymentTimelineBody,
                child: _buildMonthSection(context, dashboardTheme),
              ),
            ),
            SizedBox(
              width: widget.layout.maxContentWidth,
              child: _InfoCard(
                icon: Icons.receipt_long_rounded,
                title: context.l10n.paymentHistoryTitle,
                subtitle: context.l10n.paymentHistoryBody,
                child: _buildHistorySection(context, currencyCode),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHero(
    BuildContext context,
    AppDashboardTheme dashboardTheme,
    bool canCreate,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final overview = widget.overview;
    final isLate = overview.status == ResidentPaymentStatus.overdue;
    final tone = isLate ? colorScheme.error : dashboardTheme.successColor;
    final badge = switch (overview.status) {
      ResidentPaymentStatus.overdue => context.l10n.paymentStatusOverdue,
      ResidentPaymentStatus.upToDate => context.l10n.paymentStatusUpToDate,
      ResidentPaymentStatus.unknown => context.l10n.paymentStatusUnknown,
    };
    final title = isLate
        ? context.l10n.paymentHeroLateTitle
        : context.l10n.paymentHeroHealthyTitle;
    final body = switch (overview.status) {
      ResidentPaymentStatus.overdue => context.l10n.paymentHeroLateBody(
        _formatDate(context, overview.dateFin),
      ),
      ResidentPaymentStatus.upToDate => context.l10n.paymentHeroHealthyBody(
        _formatDate(context, overview.dateFin),
      ),
      ResidentPaymentStatus.unknown => context.l10n.paymentHeroFallbackBody,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.layout.isMobile ? 20 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dashboardTheme.heroRadius),
        gradient: LinearGradient(
          colors: <Color>[
            tone.withValues(alpha: 0.18),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          ],
        ),
        border: Border.all(color: tone.withValues(alpha: 0.24)),
      ),
      child: Wrap(
        spacing: widget.layout.itemSpacing,
        runSpacing: widget.layout.itemSpacing,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.layout.isDesktop
                  ? 580
                  : widget.layout.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.targetLogement != null) ...<Widget>[
                  Text(
                    context.l10n.paymentResidentViewing(
                      widget.targetLogement!.consultationLabel,
                    ),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.paymentResidentViewingDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: tone,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                if (overview.nextDueWarning) ...<Widget>[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: dashboardTheme.warningColor,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          context.l10n.paymentDueSoon,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (canCreate)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
              child: FilledButton.icon(
                onPressed: () => _showCreateDialog(
                  context,
                  widget.overview,
                  widget.targetLogement,
                  ref.read(currentUserProvider)?.residenceId,
                ),
                icon: const Icon(Icons.add_card_rounded),
                label: Text(context.l10n.paymentPrimaryAction),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(
    BuildContext context,
    AppDashboardTheme dashboardTheme,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final months = _visibleMonths(widget.overview.months);
    final unpaidMonths = months.where((month) => !month.paid).toList();
    final visibleCount = _resolvedVisibleMonthCount(context, months.length);
    final displayedMonths = months.take(visibleCount).toList();

    if (months.isEmpty) {
      return _EmptyState(
        title: context.l10n.paymentTimelineEmptyTitle,
        body: context.l10n.paymentTimelineEmptyBody,
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        ...displayedMonths.map(
          (month) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: month.paid
                  ? dashboardTheme.successColor.withValues(alpha: 0.12)
                  : colorScheme.errorContainer.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: month.paid
                    ? dashboardTheme.successColor.withValues(alpha: 0.22)
                    : colorScheme.error.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _formatMonth(context, month.month),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  month.paid
                      ? context.l10n.paymentMonthPaid
                      : context.l10n.paymentMonthUnpaid,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: month.paid ? null : colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (months.length > visibleCount)
          TextButton(
            onPressed: () => setState(() => _showAllMonths = true),
            child: Text(context.l10n.paymentTimelineShowMore),
          ),
        if (unpaidMonths.length > 15)
          Text(
            context.l10n.paymentTimelineTooManyUnpaid(unpaidMonths.length),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context, String? currencyCode) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final overview = widget.overview;

    if (overview.history.isEmpty) {
      return _EmptyState(
        title: context.l10n.paymentHistoryEmptyTitle,
        body: context.l10n.paymentHistoryEmptyBody,
      );
    }

    return Column(
      children: overview.history
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.32,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.period,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(context, item.date),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Align(
                    alignment: Alignment.topRight,
                    child: FormattedAmountText(
                      item.amount,
                      currencyCode: currencyCode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPendingSection(
    BuildContext context,
    String? currencyCode,
    PendingPayment? pending,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final overview = widget.overview;
    final overdueMonths = overview.months.where((month) => !month.paid).toList()
      ..sort(
        (left, right) =>
            _monthFromApi(right.month).compareTo(_monthFromApi(left.month)),
      );
    final recentOverdueMonths = overdueMonths.take(3).toList();
    final isOverdue = overview.status == ResidentPaymentStatus.overdue;
    final currentUserRole =
        ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
    final pendingHint = _isAdminRole(currentUserRole)
        ? context.l10n.paymentPendingSelfHint
        : context.l10n.paymentPendingHint;

    if (pending == null && !isOverdue) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _EmptyState(
            title: context.l10n.paymentPendingEmptyTitle,
            body: context.l10n.paymentPendingEmptyBody,
          ),
        ),
      );
    }

    return _InfoCard(
      icon: Icons.pending_actions_rounded,
      iconColor: isOverdue ? colorScheme.error : null,
      titleColor: isOverdue ? colorScheme.error : null,
      subtitleColor: isOverdue ? colorScheme.error : null,
      title: isOverdue
          ? context.l10n.paymentOverdueCardTitle
          : context.l10n.paymentPendingTitle,
      subtitle: isOverdue
          ? null
          : context.l10n.paymentPendingBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isOverdue) ...<Widget>[
            Text(
              context.l10n.paymentOverdueMonthsLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: recentOverdueMonths
                  .map(
                    (month) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.82,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        _formatMonth(context, month.month),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (overdueMonths.length > 3) ...<Widget>[
              const SizedBox(height: 14),
              Text(
                context.l10n.paymentOverdueManyMonthsMessage(
                  overdueMonths.length,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ],
            if (pending != null) const SizedBox(height: 20),
          ],
          if (pending != null) ...<Widget>[
            _MetricLine(
              label: context.l10n.paymentPendingAmount,
              value: FormattedAmountText(
                pending.amount,
                currencyCode: currencyCode,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            _MetricLine(
              label: context.l10n.paymentPendingMonths,
              value: Text(
                context.l10n.paymentPendingMonthsValue(pending.months),
              ),
            ),
            if (pending.startDate != null ||
                pending.endDate != null) ...<Widget>[
              const SizedBox(height: 12),
              _MetricLine(
                label: context.l10n.paymentPendingPeriod,
                value: Text(
                  '${_formatDate(context, pending.startDate)} - ${_formatDate(context, pending.endDate)}',
                ),
              ),
            ],
            if (widget.canDeletePendingPayment) ...<Widget>[
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: () => _confirmDelete(context, ref, pending),
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(context.l10n.paymentDeletePending),
              ),
              const SizedBox(height: 12),
              Text(
                pendingHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
          if (pending == null && isOverdue && overdueMonths.length <= 3)
            Text(
              context.l10n.paymentOverdueRegularizeSoon,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
        ],
      ),
    );
  }

  int _resolvedVisibleMonthCount(BuildContext context, int totalMonths) {
    if (totalMonths <= 0) {
      return 0;
    }

    if (_showAllMonths) {
      return totalMonths > 15 ? 15 : totalMonths;
    }

    final cardsPerRow = widget.layout.isMobile
        ? 2
        : widget.layout.isDesktop
        ? 5
        : 4;
    final defaultCount = cardsPerRow * 2;
    return totalMonths > defaultCount ? defaultCount : totalMonths;
  }
}

class _PaymentModeCard extends StatelessWidget {
  const _PaymentModeCard({
    required this.layout,
    required this.mode,
    required this.pendingCount,
    required this.onModeChanged,
  });

  final ResponsiveLayout layout;
  final PaymentViewMode mode;
  final int? pendingCount;
  final ValueChanged<PaymentViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: layout.isDesktop ? 360 : layout.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.paymentModeSelectorLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.paymentModeSelectorDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: layout.isMobile ? layout.maxContentWidth : 420,
            child: SegmentedButton<PaymentViewMode>(
              segments: <ButtonSegment<PaymentViewMode>>[
                ButtonSegment<PaymentViewMode>(
                  value: PaymentViewMode.mine,
                  icon: const Icon(Icons.payments_rounded),
                  label: _SegmentLabel(context.l10n.paymentModeMine),
                ),
                ButtonSegment<PaymentViewMode>(
                  value: PaymentViewMode.resident,
                  icon: const Icon(Icons.people_alt_rounded),
                  label: _SegmentLabel(context.l10n.paymentModeResident),
                ),
                ButtonSegment<PaymentViewMode>(
                  value: PaymentViewMode.pending,
                  icon: const Icon(Icons.pending_actions_rounded),
                  label: _PendingPaymentSegmentLabel(
                    label: context.l10n.paymentModePending,
                    pendingCount: pendingCount,
                  ),
                ),
              ],
              selected: <PaymentViewMode>{mode},
              onSelectionChanged: (selection) => onModeChanged(selection.first),
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResidentHousingCard extends ConsumerWidget {
  const _ResidentHousingCard({
    required this.layout,
    required this.selectedLogement,
  });

  final ResponsiveLayout layout;
  final PaymentLogementOption? selectedLogement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    final logementsAsync = ref.watch(paymentResidenceLogementsProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.paymentResidentSearchTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.paymentResidentSearchBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          logementsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => _InlineStateCard(
              icon: Icons.sync_problem_rounded,
              title: context.l10n.paymentHousingLoadErrorTitle,
              body: _resolvePaymentErrorMessage(context, error),
            ),
            data: (logements) {
              if (logements.isEmpty) {
                return _InlineStateCard(
                  icon: Icons.home_work_outlined,
                  title: context.l10n.paymentHousingEmptyTitle,
                  body: context.l10n.paymentHousingEmptyBody,
                );
              }

              PaymentLogementOption? resolvedSelection = selectedLogement;
              final selectedLogementId = resolvedSelection?.id;
              if (selectedLogementId != null &&
                  !logements.any(
                    (logement) => logement.id == selectedLogementId,
                  )) {
                resolvedSelection = null;
              }

              final dropdownWidth = layout.isDesktop
                  ? layout.maxContentWidth * 0.48
                  : layout.maxContentWidth;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: dropdownWidth),
                    child: DropdownButtonFormField<int>(
                      initialValue: resolvedSelection?.id,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.paymentResidentEmailLabel,
                        prefixIcon: const Icon(Icons.home_work_rounded),
                      ),
                      items: logements
                          .map(
                            (logement) => DropdownMenuItem<int>(
                              value: logement.id,
                              child: Text(
                                logement.selectorLabel,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        PaymentLogementOption? nextSelection;
                        for (final logement in logements) {
                          if (logement.id == value) {
                            nextSelection = logement;
                            break;
                          }
                        }
                        ref
                                .read(selectedPaymentLogementProvider.notifier)
                                .state =
                            nextSelection;
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: EdgeInsets.all(layout.isMobile ? 16 : 18),
                    decoration: BoxDecoration(
                      color: resolvedSelection == null
                          ? colorScheme.surface
                          : dashboardTheme.heroGlowColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(
                        dashboardTheme.sectionRadius,
                      ),
                      border: Border.all(
                        color: resolvedSelection == null
                            ? colorScheme.outlineVariant.withValues(alpha: 0.45)
                            : colorScheme.primary.withValues(alpha: 0.24),
                      ),
                    ),
                    child: switch (resolvedSelection) {
                      null => Text(
                        context.l10n.paymentResidentSearchHint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      final selection => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            context.l10n.paymentResidentViewing(
                              selection.consultationLabel,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  selection.codeInterne.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _HousingPill(
                                label: selection.active
                                    ? context.l10n.paymentHousingStatusActive
                                    : context.l10n.paymentHousingStatusInactive,
                                color: selection.active
                                    ? dashboardTheme.successColor
                                    : dashboardTheme.warningColor,
                              ),
                            ],
                          ),
                          if (selection.housingDescriptionLabel.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                selection.housingDescriptionLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.paymentResidentViewingDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HousingPill extends StatelessWidget {
  const _HousingPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InlineStateCard extends StatelessWidget {
  const _InlineStateCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 32),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final Color? iconColor;
  final Color? titleColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: iconColor ?? colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: subtitleColor ?? colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: 16),
        Flexible(child: value),
      ],
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }
}

class _PendingPaymentSegmentLabel extends StatelessWidget {
  const _PendingPaymentSegmentLabel({
    required this.label,
    required this.pendingCount,
  });

  final String label;
  final int? pendingCount;

  @override
  Widget build(BuildContext context) {
    final count = pendingCount ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
        if (count > 0) ...<Widget>[
          const SizedBox(width: 4),
          Badge(
            backgroundColor: colorScheme.primary,
            textColor: colorScheme.onPrimary,
            label: Text('$count'),
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PaymentErrorState extends StatelessWidget {
  const _PaymentErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.wifi_tethering_error_rounded, size: 36),
                const SizedBox(height: 16),
                Text(
                  context.l10n.paymentErrorTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.authRetryButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminPendingPaymentsBody extends ConsumerWidget {
  const _AdminPendingPaymentsBody({required this.layout});

  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(adminPendingPaymentsProvider);

    return paymentsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _PaymentErrorState(
        message: _resolvePaymentErrorMessage(context, error),
        onRetry: () => ref.invalidate(adminPendingPaymentsProvider),
      ),
      data: (payments) =>
          _AdminPendingPaymentsSection(layout: layout, payments: payments),
    );
  }
}

class _AdminPendingPaymentsSection extends ConsumerWidget {
  const _AdminPendingPaymentsSection({
    required this.layout,
    required this.payments,
  });

  final ResponsiveLayout layout;
  final List<PaymentRecord> payments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyCode = ref.watch(currentCurrencyCodeProvider);

    return _InfoCard(
      icon: Icons.pending_actions_rounded,
      title: context.l10n.paymentAdminPendingTitle,
      subtitle: context.l10n.paymentAdminPendingBody,
      child: payments.isEmpty
          ? _EmptyState(
              title: context.l10n.paymentAdminPendingEmptyTitle,
              body: context.l10n.paymentAdminPendingEmptyBody,
            )
          : Column(
              children: payments
                  .map(
                    (payment) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(layout.isMobile ? 16 : 18),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  payment.adminLogementLabel,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  context.l10n.paymentAdminStatusPending,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          FormattedAmountText(
                            payment.totalAmount,
                            currencyCode: currencyCode,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            children: <Widget>[
                              _AdminPaymentMeta(
                                label: context.l10n.paymentAdminResidentEmail,
                                value: payment.logementLabel,
                              ),
                              _AdminPaymentMeta(
                                label: context.l10n.paymentPendingMonths,
                                value: context.l10n.paymentPendingMonthsValue(
                                  payment.monthCount,
                                ),
                              ),
                              _AdminPaymentMeta(
                                label: context.l10n.paymentAdminPeriod,
                                value:
                                    '${_formatDate(context, payment.startDate)} - ${_formatDate(context, payment.endDate)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              payment.createdByName.trim().isNotEmpty
                                  ? 'Demand\u00E9 par : ${payment.createdByName.trim()}'
                                  : 'Demand\u00E9 par :',
                              textAlign: TextAlign.right,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: <Widget>[
                              FilledButton.tonalIcon(
                                onPressed: () => _handleAdminPaymentAction(
                                  context,
                                  ref,
                                  payment,
                                  PaymentAdminAction.validate,
                                ),
                                icon: const Icon(Icons.check_rounded),
                                label: Text(context.l10n.paymentAdminValidate),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _handleAdminPaymentAction(
                                  context,
                                  ref,
                                  payment,
                                  PaymentAdminAction.reject,
                                ),
                                icon: const Icon(Icons.close_rounded),
                                label: Text(context.l10n.paymentAdminReject),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _AdminPaymentMeta extends StatelessWidget {
  const _AdminPaymentMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CreatePaymentDialog extends ConsumerStatefulWidget {
  const _CreatePaymentDialog({
    required this.overview,
    this.targetLogement,
    this.residenceId,
  });

  final ResidentPaymentOverview overview;
  final PaymentLogementOption? targetLogement;
  final int? residenceId;

  @override
  ConsumerState<_CreatePaymentDialog> createState() =>
      _CreatePaymentDialogState();
}

class _CreatePaymentDialogState extends ConsumerState<_CreatePaymentDialog> {
  late DateTime _selectedMonth;
  int _monthCount = 1;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedMonth = _initialMonth(widget.overview);
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.yMMMM(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(_selectedMonth);
    final targetLogement = widget.targetLogement;

    return AlertDialog(
      title: Text(context.l10n.paymentDialogTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(switch (targetLogement) {
              final logement? => context.l10n.paymentDialogBodyForResident(
                logement.consultationLabel,
              ),
              null => context.l10n.paymentDialogBody,
            }),
            const SizedBox(height: 18),
            Text(context.l10n.paymentDialogStartMonth),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _submitting ? null : _pickMonth,
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text(monthLabel),
            ),
            const SizedBox(height: 18),
            Text(context.l10n.paymentDialogMonthCount),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                IconButton.filledTonal(
                  onPressed: _submitting || _monthCount <= 1
                      ? null
                      : () => setState(() => _monthCount -= 1),
                  icon: const Icon(Icons.remove_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Center(
                    child: Text(
                      context.l10n.paymentDialogMonthCountValue(_monthCount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: _submitting
                      ? null
                      : () => setState(() => _monthCount += 1),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            if (_errorText != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                _errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.paymentDialogCancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(
            _submitting
                ? context.l10n.authSubmittingLabel
                : context.l10n.paymentDialogSubmit,
          ),
        ),
      ],
    );
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final firstMonth = widget.overview.months.isNotEmpty
        ? _monthFromApi(widget.overview.months.first.month)
        : DateTime(now.year, now.month, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: firstMonth,
      lastDate: DateTime(now.year + 2, 12, 1),
      selectableDayPredicate: (date) => date.day == 1,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedMonth = DateTime(picked.year, picked.month, 1);
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      final payload = CreateMyPaymentPayload(
        startMonth: _selectedMonth,
        monthCount: _monthCount,
      );

      if (widget.targetLogement != null && widget.residenceId != null) {
        final targetLogement = widget.targetLogement!;
        await ref
            .read(paiementRepositoryProvider)
            .createAdminLogementPayment(
              residenceId: widget.residenceId!,
              logementId: targetLogement.id,
              payload: payload,
            );
        _refreshAfterAdminPaymentCreation(ref, targetLogement.id);
      } else {
        await ref
            .read(residentPaymentControllerProvider.notifier)
            .createMyPayment(payload);
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorText = _resolvePaymentErrorMessage(context, error);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

Future<void> _showCreateDialog(
  BuildContext context,
  ResidentPaymentOverview overview,
  PaymentLogementOption? targetLogement,
  int? residenceId,
) async {
  final created = await showDialog<bool>(
    context: context,
    builder: (context) => _CreatePaymentDialog(
      overview: overview,
      targetLogement: targetLogement,
      residenceId: residenceId,
    ),
  );

  if (created == true && context.mounted) {
    final logementLabel = targetLogement?.consultationLabel;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          logementLabel != null && logementLabel.isNotEmpty
              ? context.l10n.paymentCreateSuccessForResident(logementLabel)
              : context.l10n.paymentCreateSuccess,
        ),
      ),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PendingPayment payment,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.paymentDeleteConfirmTitle),
      content: Text(context.l10n.paymentDeleteConfirmBody),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.paymentDialogCancel),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.paymentDeletePending),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  try {
    await ref
        .read(residentPaymentControllerProvider.notifier)
        .deletePendingPayment(payment.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.paymentDeleteSuccess)),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolvePaymentErrorMessage(context, error))),
      );
    }
  }
}

Future<void> _handleAdminPaymentAction(
  BuildContext context,
  WidgetRef ref,
  PaymentRecord payment,
  PaymentAdminAction action,
) async {
  if (action == PaymentAdminAction.validate) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.paymentAdminValidateConfirmTitle),
        content: Text(context.l10n.paymentAdminValidateConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.paymentDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.paymentAdminValidate),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }
  }

  try {
    final repository = ref.read(paiementRepositoryProvider);
    if (action == PaymentAdminAction.validate) {
      await repository.validatePayment(payment.id);
    } else {
      await repository.rejectPayment(payment.id);
    }

    _refreshAfterAdminPaymentAction(ref, payment.logementId);

    if (context.mounted) {
      final successMessage = action == PaymentAdminAction.validate
          ? context.l10n.paymentAdminValidateSuccess
          : context.l10n.paymentAdminRejectSuccess;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolvePaymentErrorMessage(context, error))),
      );
    }
  }
}

void _refreshAfterAdminPaymentAction(WidgetRef ref, int logementId) {
  ref.read(authSessionControllerProvider.notifier).refreshCurrentUser();
  ref.invalidate(adminPendingPaymentsProvider);
  ref.invalidate(dashboardSnapshotProvider);
  final currentLogementId = ref.read(currentUserProvider)?.logement?.logementId;
  if (currentLogementId != null && currentLogementId == logementId) {
    ref.invalidate(residentPaymentControllerProvider);
  }
  if (logementId > 0) {
    ref.invalidate(adminResidentPaymentProvider(logementId));
  }
}

void _refreshAfterAdminPaymentCreation(WidgetRef ref, int logementId) {
  ref.read(authSessionControllerProvider.notifier).refreshCurrentUser();
  ref.invalidate(adminPendingPaymentsProvider);
  ref.invalidate(dashboardSnapshotProvider);
  final currentLogementId = ref.read(currentUserProvider)?.logement?.logementId;
  if (currentLogementId != null && currentLogementId == logementId) {
    ref.invalidate(residentPaymentControllerProvider);
  }
  if (logementId > 0) {
    ref.invalidate(adminResidentPaymentProvider(logementId));
  }
}

double _cardWidth(ResponsiveLayout layout) {
  if (layout.isDesktop) {
    return (layout.maxContentWidth - layout.itemSpacing) / 2;
  }
  return layout.maxContentWidth;
}

List<PaymentMonthItem> _visibleMonths(List<PaymentMonthItem> months) {
  final unpaidMonths = months.where((month) => !month.paid).toList();
  if (unpaidMonths.isNotEmpty) {
    return unpaidMonths;
  }
  return months.reversed.take(3).toList().reversed.toList();
}

String _formatDate(BuildContext context, DateTime? date) {
  if (date == null) {
    return context.l10n.paymentDateUnavailable;
  }
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}

String _formatMonth(BuildContext context, String month) {
  return DateFormat.yMMMM(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(_monthFromApi(month));
}

DateTime _monthFromApi(String month) {
  final parts = month.split('-');
  final now = DateTime.now();
  if (parts.length != 2) {
    return DateTime(now.year, now.month, 1);
  }
  return DateTime(
    int.tryParse(parts[0]) ?? now.year,
    int.tryParse(parts[1]) ?? now.month,
    1,
  );
}

DateTime _initialMonth(ResidentPaymentOverview overview) {
  final unpaid = overview.months.where((month) => !month.paid);
  if (unpaid.isNotEmpty) {
    return _monthFromApi(unpaid.first.month);
  }
  if (overview.months.isNotEmpty) {
    return _monthFromApi(overview.months.last.month);
  }
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
}

String _resolvePaymentErrorMessage(BuildContext context, Object error) {
  final exception = ApiException.fromError(error);
  return switch (exception.kind) {
    ApiExceptionKind.timeout => context.l10n.authErrorTimeout,
    ApiExceptionKind.network => context.l10n.authErrorNetwork,
    ApiExceptionKind.unauthorized => context.l10n.authErrorUnauthorized,
    ApiExceptionKind.forbidden =>
      _hasExplicitApiMessage(exception.message)
          ? exception.message
          : context.l10n.paymentResidentForbiddenError,
    ApiExceptionKind.notFound =>
      exception.message.isEmpty
          ? context.l10n.paymentNotFoundError
          : exception.message,
    ApiExceptionKind.badRequest => exception.message,
    ApiExceptionKind.unknown => exception.message,
  };
}

bool _isAdminRole(UserRole role) {
  return role == UserRole.admin || role == UserRole.superAdmin;
}

bool _hasExplicitApiMessage(String message) {
  final trimmed = message.trim();
  return trimmed.isNotEmpty &&
      trimmed != 'You are not allowed to perform this action.';
}

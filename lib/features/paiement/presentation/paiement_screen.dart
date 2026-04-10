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
import '../application/paiement_providers.dart';
import '../data/paiement_repository.dart';
import '../domain/paiement_models.dart';

class PaiementScreen extends ConsumerStatefulWidget {
  const PaiementScreen({super.key});

  @override
  ConsumerState<PaiementScreen> createState() => _PaiementScreenState();
}

class _PaiementScreenState extends ConsumerState<PaiementScreen> {
  late final TextEditingController _residentEmailController;
  String? _residentSearchErrorText;

  @override
  void initState() {
    super.initState();
    _residentEmailController = TextEditingController();
  }

  @override
  void dispose() {
    _residentEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsivePageContainer(
        child: ResponsiveBuilder(
          builder: (context, layout) => _PaymentPage(
            layout: layout,
            residentEmailController: _residentEmailController,
            residentSearchErrorText: _residentSearchErrorText,
            onSearch: _searchResident,
            onModeChanged: _changeMode,
            onClearSearchError: _clearSearchError,
          ),
        ),
      ),
    );
  }

  void _changeMode(PaymentViewMode mode) {
    ref.read(paymentViewModeProvider.notifier).state = mode;
    ref.read(selectedResidentEmailProvider.notifier).state = null;
    _residentEmailController.clear();
    _clearSearchError();
  }

  void _searchResident() {
    final email = _residentEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _residentSearchErrorText = context.l10n.authInvalidEmailMessage;
      });
      return;
    }

    ref.read(selectedResidentEmailProvider.notifier).state = email;
    _clearSearchError();
  }

  void _clearSearchError() {
    if (_residentSearchErrorText == null) {
      return;
    }
    setState(() {
      _residentSearchErrorText = null;
    });
  }
}

class _PaymentPage extends ConsumerWidget {
  const _PaymentPage({
    required this.layout,
    required this.residentEmailController,
    required this.residentSearchErrorText,
    required this.onSearch,
    required this.onModeChanged,
    required this.onClearSearchError,
  });

  final ResponsiveLayout layout;
  final TextEditingController residentEmailController;
  final String? residentSearchErrorText;
  final VoidCallback onSearch;
  final ValueChanged<PaymentViewMode> onModeChanged;
  final VoidCallback onClearSearchError;

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
    final searchedEmail = isAdmin
        ? ref.watch(selectedResidentEmailProvider)
        : null;
    final overviewAsync = _resolveAsync(ref, mode, searchedEmail);
    final dashboardSnapshot = ref.watch(dashboardSnapshotProvider).valueOrNull;
    final currencyCode = ref.watch(currentCurrencyCodeProvider);
    final canRefresh = switch (mode) {
      PaymentViewMode.mine => true,
      PaymentViewMode.resident => searchedEmail?.isNotEmpty == true,
      PaymentViewMode.pending => true,
    };

    return ListView(
      children: <Widget>[
        GlobalPageHeader(
          title: context.l10n.modulePaymentTitle,
          layout: layout,
          residenceBalance: dashboardSnapshot?.overview.balance,
          currencyCode: currencyCode,
          actions: <Widget>[
            IconButton(
              onPressed: canRefresh
                  ? () => _refresh(ref, mode, searchedEmail)
                  : null,
              tooltip: context.l10n.paymentRefreshTooltip,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        SizedBox(height: layout.sectionSpacing),
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
          _ResidentSearchCard(
            controller: residentEmailController,
            layout: layout,
            errorText: residentSearchErrorText,
            searchedEmail: searchedEmail,
            onSearch: onSearch,
            onChanged: onClearSearchError,
          ),
          SizedBox(height: layout.sectionSpacing),
        ],
        if (mode == PaymentViewMode.resident && searchedEmail == null)
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
            targetResidentEmail: mode == PaymentViewMode.resident
                ? searchedEmail
                : null,
            canCreatePayment:
                (mode == PaymentViewMode.mine && canManageOwnPayments) ||
                (isAdmin &&
                    mode == PaymentViewMode.resident &&
                    searchedEmail?.isNotEmpty == true),
            canDeletePendingPayment: mode == PaymentViewMode.mine,
            onRetry: () => _refresh(ref, mode, searchedEmail),
          ),
      ],
    );
  }

  AsyncValue<ResidentPaymentOverview> _resolveAsync(
    WidgetRef ref,
    PaymentViewMode mode,
    String? searchedEmail,
  ) {
    switch (mode) {
      case PaymentViewMode.mine:
        return ref.watch(residentPaymentControllerProvider);
      case PaymentViewMode.resident:
        if (searchedEmail == null) {
          return const AsyncLoading();
        }
        return ref.watch(adminResidentPaymentProvider(searchedEmail));
      case PaymentViewMode.pending:
        return const AsyncLoading();
    }
  }

  void _refresh(
    WidgetRef ref,
    PaymentViewMode mode,
    String? searchedEmail,
  ) {
    if (mode == PaymentViewMode.mine) {
      ref.read(residentPaymentControllerProvider.notifier).refresh();
      return;
    }
    if (mode == PaymentViewMode.pending) {
      ref.invalidate(adminPendingPaymentsProvider);
      return;
    }
    if (searchedEmail == null || searchedEmail.isEmpty) {
      return;
    }
    ref.invalidate(adminResidentPaymentProvider(searchedEmail));
  }
}

class _PaymentBody extends StatelessWidget {
  const _PaymentBody({
    required this.layout,
    required this.overviewAsync,
    required this.canCreatePayment,
    required this.canDeletePendingPayment,
    required this.onRetry,
    this.targetResidentEmail,
  });

  final ResponsiveLayout layout;
  final AsyncValue<ResidentPaymentOverview> overviewAsync;
  final bool canCreatePayment;
  final bool canDeletePendingPayment;
  final VoidCallback onRetry;
  final String? targetResidentEmail;

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
        targetResidentEmail: targetResidentEmail,
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
    this.targetResidentEmail,
  });

  final ResponsiveLayout layout;
  final ResidentPaymentOverview overview;
  final bool canCreatePayment;
  final bool canDeletePendingPayment;
  final String? targetResidentEmail;

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
    final tone = isLate
        ? dashboardTheme.warningColor
        : dashboardTheme.successColor;
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
                if (widget.targetResidentEmail != null) ...<Widget>[
                  Text(
                    context.l10n.paymentResidentViewing(
                      widget.targetResidentEmail!,
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
                  widget.targetResidentEmail,
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
    final visibleCount = _resolvedVisibleMonthCount(
      context,
      months.length,
    );
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
        ...displayedMonths
          .map(
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
                      color: month.paid
                          ? null
                          : colorScheme.onErrorContainer,
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
                    child: Text(
                      CurrencyFormatter.format(
                        context,
                        item.amount,
                        currencyCode: currencyCode,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
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
    final currentUserRole =
        ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
    final pendingHint = _isAdminRole(currentUserRole)
        ? context.l10n.paymentPendingSelfHint
        : context.l10n.paymentPendingHint;

    if (pending == null) {
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
      title: context.l10n.paymentPendingTitle,
      subtitle: context.l10n.paymentPendingBody,
      child: Column(
        children: <Widget>[
          _MetricLine(
            label: context.l10n.paymentPendingAmount,
            value: CurrencyFormatter.format(
              context,
              pending.amount,
              currencyCode: currencyCode,
            ),
          ),
          const SizedBox(height: 12),
          _MetricLine(
            label: context.l10n.paymentPendingMonths,
            value: context.l10n.paymentPendingMonthsValue(
              pending.months,
            ),
          ),
          if (pending.startDate != null || pending.endDate != null) ...<Widget>[
            const SizedBox(height: 12),
            _MetricLine(
              label: context.l10n.paymentPendingPeriod,
              value:
                  '${_formatDate(context, pending.startDate)} - ${_formatDate(context, pending.endDate)}',
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
              onSelectionChanged: (selection) =>
                  onModeChanged(selection.first),
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

class _ResidentSearchCard extends StatelessWidget {
  const _ResidentSearchCard({
    required this.controller,
    required this.layout,
    required this.errorText,
    required this.searchedEmail,
    required this.onSearch,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ResponsiveLayout layout;
  final String? errorText;
  final String? searchedEmail;
  final VoidCallback onSearch;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: layout.isDesktop ? 420 : layout.maxContentWidth,
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => onChanged(),
                  onSubmitted: (_) => onSearch(),
                  decoration: InputDecoration(
                    labelText: context.l10n.paymentResidentEmailLabel,
                    hintText: 'resident@email.com',
                    errorText: errorText,
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search_rounded),
                label: Text(context.l10n.paymentResidentSearchButton),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            searchedEmail == null
                ? context.l10n.paymentResidentSearchHint
                : context.l10n.paymentResidentViewing(searchedEmail!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

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
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
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
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: 16),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
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
      data: (payments) => _AdminPendingPaymentsSection(
        layout: layout,
        payments: payments,
      ),
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
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: layout.isDesktop
                                      ? layout.maxContentWidth * 0.5
                                      : layout.maxContentWidth,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      payment.userEmail,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.tertiaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        context.l10n.paymentAdminStatusPending,
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onTertiaryContainer,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(
                                  context,
                                  payment.totalAmount,
                                  currencyCode: currencyCode,
                                ),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            children: <Widget>[
                              _AdminPaymentMeta(
                                label: context.l10n.paymentAdminResidentEmail,
                                value: payment.userEmail,
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
    this.targetResidentEmail,
  });

  final ResidentPaymentOverview overview;
  final String? targetResidentEmail;

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
    final targetResidentEmail = widget.targetResidentEmail?.trim();
    final isResidentPayment =
        targetResidentEmail != null && targetResidentEmail.isNotEmpty;

    return AlertDialog(
      title: Text(context.l10n.paymentDialogTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              isResidentPayment
                  ? context.l10n.paymentDialogBodyForResident(
                      targetResidentEmail,
                    )
                  : context.l10n.paymentDialogBody,
            ),
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

      if (widget.targetResidentEmail != null &&
          widget.targetResidentEmail!.trim().isNotEmpty) {
        final targetEmail = widget.targetResidentEmail!.trim();
        await ref.read(paiementRepositoryProvider).createAdminUserPayment(
          targetEmail,
          payload,
        );
        _refreshAfterAdminPaymentCreation(ref, targetEmail);
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
  String? targetResidentEmail,
) async {
  final created = await showDialog<bool>(
    context: context,
    builder: (context) => _CreatePaymentDialog(
      overview: overview,
      targetResidentEmail: targetResidentEmail,
    ),
  );

  if (created == true && context.mounted) {
    final normalizedEmail = targetResidentEmail?.trim();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          normalizedEmail != null && normalizedEmail.isNotEmpty
              ? context.l10n.paymentCreateSuccessForResident(normalizedEmail)
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

    _refreshAfterAdminPaymentAction(ref, payment.userEmail);

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

void _refreshAfterAdminPaymentAction(WidgetRef ref, String userEmail) {
  ref.invalidate(adminPendingPaymentsProvider);
  ref.invalidate(dashboardSnapshotProvider);
  final currentUserEmail = ref.read(currentUserProvider)?.email.trim().toLowerCase();
  if (currentUserEmail != null &&
      currentUserEmail.isNotEmpty &&
      currentUserEmail == userEmail.trim().toLowerCase()) {
    ref.invalidate(residentPaymentControllerProvider);
  }
  if (userEmail.trim().isNotEmpty) {
    ref.invalidate(adminResidentPaymentProvider(userEmail.trim()));
  }
}

void _refreshAfterAdminPaymentCreation(WidgetRef ref, String userEmail) {
  ref.invalidate(adminPendingPaymentsProvider);
  ref.invalidate(dashboardSnapshotProvider);
  final currentUserEmail =
      ref.read(currentUserProvider)?.email.trim().toLowerCase();
  if (currentUserEmail != null &&
      currentUserEmail.isNotEmpty &&
      currentUserEmail == userEmail.trim().toLowerCase()) {
    ref.invalidate(residentPaymentControllerProvider);
  }
  if (userEmail.trim().isNotEmpty) {
    ref.invalidate(adminResidentPaymentProvider(userEmail.trim()));
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
    ApiExceptionKind.forbidden => _hasExplicitApiMessage(exception.message)
        ? exception.message
        : context.l10n.paymentResidentForbiddenError,
    ApiExceptionKind.notFound => exception.message.isEmpty
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

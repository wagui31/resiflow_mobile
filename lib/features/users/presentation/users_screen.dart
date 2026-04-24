import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/account_settings_dialog.dart';
import '../../../core/widgets/formatted_amount_text.dart';
import '../../../core/widgets/responsive_page_container.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../application/users_providers.dart';
import '../data/users_repository.dart';
import '../domain/users_models.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsivePageContainer(
        useTopSafeArea: false,
        child: ResponsiveBuilder(
          builder: (context, layout) {
            return _ResidencePage(
              layout: layout,
              searchController: _searchController,
              onSearchChanged: _handleSearchChanged,
              onClearSearch: _clearSearch,
            );
          },
        ),
      ),
    );
  }

  void _handleSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) {
        return;
      }
      ref.read(usersSearchQueryProvider.notifier).state = value;
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(usersSearchQueryProvider.notifier).state = '';
  }
}

class _ResidencePage extends ConsumerWidget {
  const _ResidencePage({
    required this.layout,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final ResponsiveLayout layout;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
    final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;
    final tab = isAdmin ? ref.watch(usersTabProvider) : UsersTab.residents;
    final residenceViewAsync = ref.watch(residenceViewProvider);
    final currencyCode = ref.watch(currentCurrencyCodeProvider);
    final pendingResidentsCount =
        residenceViewAsync.valueOrNull?.overview.pendingResidents;

    return ListView(
      children: <Widget>[
        _ResidenceHero(
          layout: layout,
          isAdmin: isAdmin,
          onEditCurrentUser: currentUser == null
              ? null
              : () => _showEditCurrentUserDialog(context, ref, currentUser),
        ),
        SizedBox(height: layout.itemSpacing),
        residenceViewAsync.when(
          loading: () => const _OverviewSkeleton(),
          error: (error, _) => _InlineStateCard(
            icon: Icons.error_outline_rounded,
            title: context.l10n.usersLoadErrorTitle,
            body: _resolveUsersErrorMessage(context, error),
          ),
          data: (view) => _ResidenceOverviewPanel(
            layout: layout,
            overview: view.overview,
            currencyCode: currencyCode,
          ),
        ),
        SizedBox(height: layout.sectionSpacing),
        if (isAdmin) ...<Widget>[
          _UsersTabSelector(
            selectedTab: tab,
            pendingCount: pendingResidentsCount,
            onChanged: (value) =>
                ref.read(usersTabProvider.notifier).state = value,
          ),
          SizedBox(height: layout.itemSpacing),
        ],
        _ResidenceSearchBar(
          controller: searchController,
          onChanged: onSearchChanged,
          onClear: onClearSearch,
        ),
        SizedBox(height: layout.sectionSpacing),
        if (tab == UsersTab.residents)
          _ResidenceHousingBody(layout: layout, isAdmin: isAdmin)
        else
          _ResidencePendingBody(layout: layout),
      ],
    );
  }
}

class _ResidenceHero extends StatelessWidget {
  const _ResidenceHero({
    required this.layout,
    required this.isAdmin,
    required this.onEditCurrentUser,
  });

  final ResponsiveLayout layout;
  final bool isAdmin;
  final VoidCallback? onEditCurrentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.14),
            colorScheme.tertiary.withValues(alpha: 0.10),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.60),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Wrap(
        spacing: layout.itemSpacing,
        runSpacing: layout.itemSpacing,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: layout.isDesktop ? 700 : layout.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isAdmin
                      ? context.l10n.moduleUsersAdminTitle
                      : context.l10n.moduleUsersUserTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isAdmin
                      ? context.l10n.moduleUsersAdminBody
                      : context.l10n.moduleUsersUserBody,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (onEditCurrentUser != null)
            FilledButton.tonalIcon(
              onPressed: onEditCurrentUser,
              icon: const Icon(Icons.edit_rounded),
              label: Text(context.l10n.usersEditProfileAction),
            ),
        ],
      ),
    );
  }
}

class _ResidenceOverviewPanel extends StatelessWidget {
  const _ResidenceOverviewPanel({
    required this.layout,
    required this.overview,
    required this.currencyCode,
  });

  final ResponsiveLayout layout;
  final ResidenceOverview overview;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionTitle(title: context.l10n.usersOverviewTitle),
        SizedBox(height: layout.itemSpacing),
        _OverviewSummaryCard(
          layout: layout,
          overview: overview,
          currencyCode: currencyCode,
        ),
      ],
    );
  }
}

class _OverviewSkeleton extends StatelessWidget {
  const _OverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _OverviewSummaryCard extends StatelessWidget {
  const _OverviewSummaryCard({
    required this.layout,
    required this.overview,
    required this.currencyCode,
  });

  final ResponsiveLayout layout;
  final ResidenceOverview overview;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const balanceColor = Color(0xFF123A7A);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.88),
            colorScheme.tertiary.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _InfoChip(
            icon: Icons.account_balance_wallet_rounded,
            label: _cagnotteStatusLabel(context, overview.cagnotteStatus),
            color: balanceColor,
          ),
          const SizedBox(height: 12),
          FormattedAmountText(
            overview.cagnotteSolde,
            currencyCode: currencyCode,
            decimalDigits: 2,
            textAlign: TextAlign.center,
            style:
                (layout.isMobile
                        ? theme.textTheme.headlineSmall
                        : theme.textTheme.headlineMedium)
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: balanceColor,
                      letterSpacing: -0.8,
                    ),
          ),
          const SizedBox(height: 18),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 18),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _OverviewCompactMetricCard(
                      title: context.l10n.usersSummaryTotalHousing,
                      value: '${overview.totalLogements}',
                      subtitle:
                          '${overview.activeLogements} ${context.l10n.usersSummaryActiveHousing} / ${overview.inactiveLogements} ${context.l10n.usersSummaryInactiveHousing}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OverviewCompactMetricCard(
                      title: context.l10n.usersSummaryResidents,
                      value: '${overview.activeResidents}',
                      subtitle:
                          '${overview.pendingResidents} ${context.l10n.usersPendingTab}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _OverviewCompactMetricCard(
                      title: context.l10n.usersSummaryPaymentStatus,
                      value: '${overview.logementsAJour}',
                      subtitle:
                          '${overview.logementsEnRetard} ${context.l10n.usersSummaryLateHousing}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OverviewCompactMetricCard(
                      title: context.l10n.dashboardCardResidents,
                      value: '${overview.totalResidents}',
                      subtitle:
                          '${overview.adminResidents} ${context.l10n.usersSummaryAdminSplit}',
                    ),
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

class _OverviewCompactMetricCard extends StatelessWidget {
  const _OverviewCompactMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersTabSelector extends StatelessWidget {
  const _UsersTabSelector({
    required this.selectedTab,
    required this.pendingCount,
    required this.onChanged,
  });

  final UsersTab selectedTab;
  final int? pendingCount;
  final ValueChanged<UsersTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.l10n.usersAdminViewLabel,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        SegmentedButton<UsersTab>(
          showSelectedIcon: false,
          segments: <ButtonSegment<UsersTab>>[
            ButtonSegment<UsersTab>(
              value: UsersTab.residents,
              label: Text(context.l10n.usersResidentsTab),
              icon: const Icon(Icons.apartment_rounded),
            ),
            ButtonSegment<UsersTab>(
              value: UsersTab.pending,
              label: _PendingTabLabel(
                label: context.l10n.usersPendingTab,
                pendingCount: pendingCount,
              ),
              icon: const Icon(Icons.pending_actions_rounded),
            ),
          ],
          selected: <UsersTab>{selectedTab},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              onChanged(selection.first);
            }
          },
        ),
      ],
    );
  }
}

class _PendingTabLabel extends StatelessWidget {
  const _PendingTabLabel({required this.label, required this.pendingCount});

  final String label;
  final int? pendingCount;

  @override
  Widget build(BuildContext context) {
    final count = pendingCount ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label),
        if (count > 0) ...<Widget>[
          const SizedBox(width: 8),
          Badge(
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.onError,
            label: Text('$count'),
          ),
        ],
      ],
    );
  }
}

class _ResidenceSearchBar extends ConsumerWidget {
  const _ResidenceSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(usersSearchQueryProvider);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: context.l10n.usersSearchLabel,
        hintText: context.l10n.usersSearchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.trim().isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

class _ResidenceHousingBody extends ConsumerWidget {
  const _ResidenceHousingBody({required this.layout, required this.isAdmin});

  final ResponsiveLayout layout;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residenceViewAsync = ref.watch(residenceViewProvider);
    final currentLogementId = ref
        .watch(currentUserProvider)
        ?.logement
        ?.logementId;
    final currentUserId = ref.watch(currentUserProvider)?.id;

    return residenceViewAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _InlineStateCard(
        icon: Icons.error_outline_rounded,
        title: context.l10n.usersLoadErrorTitle,
        body: _resolveUsersErrorMessage(context, error),
        actionLabel: context.l10n.authRetryButton,
        onAction: () => ref.invalidate(residenceViewProvider),
      ),
      data: (view) {
        if (view.logements.isEmpty) {
          return _InlineStateCard(
            icon: Icons.apartment_rounded,
            title: context.l10n.usersResidentsEmptyTitle,
            body: context.l10n.usersResidentsEmptyBody,
          );
        }

        final currentCards = view.logements
            .where((card) => card.logement.id == currentLogementId)
            .toList();
        final adminCards = view.logements
            .where(
              (card) =>
                  card.logement.id != currentLogementId &&
                  card.hasAdminResident,
            )
            .toList();
        final lateCards = view.logements
            .where(
              (card) =>
                  card.logement.id != currentLogementId &&
                  !card.hasAdminResident &&
                  card.payment.status == ResidencePaymentStatus.late,
            )
            .toList();
        final otherCards = view.logements
            .where(
              (card) =>
                  card.logement.id != currentLogementId &&
                  !card.hasAdminResident &&
                  card.payment.status != ResidencePaymentStatus.late,
            )
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (currentCards.isNotEmpty) ...<Widget>[
              _SectionTitle(title: context.l10n.usersCurrentSectionTitle),
              SizedBox(height: layout.itemSpacing),
              _HousingGrid(
                layout: layout,
                cards: currentCards,
                isAdmin: isAdmin,
                currentUserId: currentUserId,
              ),
              SizedBox(height: layout.sectionSpacing),
            ],
            if (adminCards.isNotEmpty) ...<Widget>[
              _SectionTitle(title: context.l10n.usersAdminsSectionTitle),
              SizedBox(height: layout.itemSpacing),
              _HousingGrid(
                layout: layout,
                cards: adminCards,
                isAdmin: isAdmin,
                currentUserId: currentUserId,
              ),
              SizedBox(height: layout.sectionSpacing),
            ],
            if (lateCards.isNotEmpty) ...<Widget>[
              _SectionTitle(title: context.l10n.usersLateSectionTitle),
              SizedBox(height: layout.itemSpacing),
              _HousingGrid(
                layout: layout,
                cards: lateCards,
                isAdmin: isAdmin,
                currentUserId: currentUserId,
              ),
              SizedBox(height: layout.sectionSpacing),
            ],
            if (otherCards.isNotEmpty) ...<Widget>[
              _SectionTitle(title: context.l10n.usersOthersSectionTitle),
              SizedBox(height: layout.itemSpacing),
              _HousingGrid(
                layout: layout,
                cards: otherCards,
                isAdmin: isAdmin,
                currentUserId: currentUserId,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ResidencePendingBody extends ConsumerWidget {
  const _ResidencePendingBody({required this.layout});

  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residenceViewAsync = ref.watch(residenceViewProvider);

    return residenceViewAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _InlineStateCard(
        icon: Icons.error_outline_rounded,
        title: context.l10n.usersLoadErrorTitle,
        body: _resolveUsersErrorMessage(context, error),
        actionLabel: context.l10n.authRetryButton,
        onAction: () => ref.invalidate(residenceViewProvider),
      ),
      data: (view) {
        if (view.pendingLogements.isEmpty) {
          return _InlineStateCard(
            icon: Icons.mark_email_read_rounded,
            title: context.l10n.usersPendingEmptyTitle,
            body: context.l10n.usersPendingEmptyBody,
          );
        }

        return Wrap(
          spacing: layout.itemSpacing,
          runSpacing: layout.itemSpacing,
          children: view.pendingLogements
              .map(
                (card) => SizedBox(
                  width: _cardWidth(layout),
                  child: _PendingHousingCard(card: card),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _HousingGrid extends StatelessWidget {
  const _HousingGrid({
    required this.layout,
    required this.cards,
    required this.isAdmin,
    required this.currentUserId,
  });

  final ResponsiveLayout layout;
  final List<ResidenceHousingCard> cards;
  final bool isAdmin;
  final int? currentUserId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: layout.itemSpacing,
      runSpacing: layout.itemSpacing,
      children: cards
          .map(
            (card) => SizedBox(
              width: _cardWidth(layout),
              child: _HousingCard(
                card: card,
                isAdmin: isAdmin,
                currentUserId: currentUserId,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HousingCard extends StatefulWidget {
  const _HousingCard({
    required this.card,
    required this.isAdmin,
    required this.currentUserId,
  });

  final ResidenceHousingCard card;
  final bool isAdmin;
  final int? currentUserId;

  @override
  State<_HousingCard> createState() => _HousingCardState();
}

class _HousingCardState extends State<_HousingCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final paymentTone = _paymentColor(context, widget.card.payment.status);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: ExpansionTile(
          onExpansionChanged: (isExpanded) {
            setState(() {
              _isExpanded = isExpanded;
            });
          },
          tilePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: const Border(),
          collapsedShape: const Border(),
          trailing: const SizedBox.shrink(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.card.logement.displayLabel,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.card.logement.codeInterne,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.card.hasAdminResident)
                    _InfoChip(
                      icon: Icons.shield_rounded,
                      label: context.l10n.authRoleAdmin,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _InfoChip(
                    icon: widget.card.logement.active
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    label: widget.card.logement.active
                        ? context.l10n.paymentHousingStatusActive
                        : context.l10n.paymentHousingStatusInactive,
                    color: widget.card.logement.active
                        ? Colors.green.shade700
                        : colorScheme.onSurfaceVariant,
                  ),
                  _InfoChip(
                    icon: Icons.payments_rounded,
                    label: _paymentStatusLabel(
                      context,
                      widget.card.payment.status,
                    ),
                    color: paymentTone,
                  ),
                  _InfoChip(
                    icon: Icons.groups_rounded,
                    label: context.l10n.usersHousingOccupancyValue(
                      widget.card.occupancy.occupiedCount,
                      widget.card.occupancy.maxOccupants,
                    ),
                  ),
                  if (widget.card.payment.pendingPayment != null)
                    _InfoChip(
                      icon: Icons.schedule_rounded,
                      label: context.l10n.usersPendingPaymentLabel,
                      color: Colors.orange.shade700,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: <Widget>[
                  _MetaRow(
                    label: context.l10n.usersHousingTypeLabel,
                    value:
                        widget.card.logement.typeLogement ??
                        context.l10n.dashboardPaymentStatusUnknown,
                  ),
                  if ((widget.card.logement.etage ?? '')
                      .trim()
                      .isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    _MetaRow(
                      label: context.l10n.usersHousingFloorLabel,
                      value: widget.card.logement.etage!.trim(),
                    ),
                  ],
                  if (widget.card.payment.dateFin != null) ...<Widget>[
                    const SizedBox(height: 10),
                    _MetaRow(
                      label: context.l10n.usersHousingPaymentUntilLabel,
                      value: _formatDate(context, widget.card.payment.dateFin),
                    ),
                  ],
                  if (widget.card.payment.status ==
                          ResidencePaymentStatus.late &&
                      widget.card.payment.overdueMonths.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    _OverdueMonthsSection(
                      label: context.l10n.usersHousingOverdueMonthsLabel,
                      months: widget.card.payment.overdueMonths,
                      monthFormatter: (month) => _formatMonth(context, month),
                    ),
                  ],
                ],
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.l10n.usersHousingResidentsSubtitle(
                      widget.card.residents.length,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          children: <Widget>[
            const SizedBox(height: 8),
            _SectionTitle(title: context.l10n.usersHousingResidentsSection),
            const SizedBox(height: 12),
            if (widget.card.residents.isEmpty)
              _InlineStateCard(
                icon: Icons.person_off_rounded,
                title: context.l10n.usersHousingNoResidentsTitle,
                body: context.l10n.usersHousingNoResidentsBody,
              )
            else
              Column(
                children: widget.card.residents
                    .map(
                      (resident) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ResidentRow(
                          resident: resident,
                          isAdmin: widget.isAdmin,
                          isCurrentUser: resident.id == widget.currentUserId,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResidentRow extends ConsumerWidget {
  const _ResidentRow({
    required this.resident,
    required this.isAdmin,
    required this.isCurrentUser,
  });

  final ResidencePerson resident;
  final bool isAdmin;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            child: Text(
              _initials(resident),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      resident.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (resident.isAdmin)
                      _RolePill(
                        label: context.l10n.authRoleAdmin,
                        color: colorScheme.primary,
                      ),
                    if (isCurrentUser)
                      _RolePill(
                        label: context.l10n.usersCurrentResidentTag,
                        color: colorScheme.tertiary,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  resident.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (resident.residenceEntryDate != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    '${context.l10n.usersResidenceEntryDateLabel}: ${_formatDate(context, resident.residenceEntryDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isAdmin)
            PopupMenuButton<_ResidentAction>(
              tooltip: context.l10n.usersActionsTooltip,
              onSelected: (action) => _handleResidentAction(
                context,
                ref,
                resident,
                action,
                isCurrentUser,
              ),
              itemBuilder: (context) => <PopupMenuEntry<_ResidentAction>>[
                PopupMenuItem<_ResidentAction>(
                  value: _ResidentAction.editDate,
                  child: Text(context.l10n.usersEditDateAction),
                ),
                if (!isCurrentUser && _canChangeRole(resident))
                  PopupMenuItem<_ResidentAction>(
                    value: _ResidentAction.changeRole,
                    child: Text(
                      resident.role == UserRole.user
                          ? context.l10n.usersPromoteToAdminAction
                          : context.l10n.usersDemoteToUserAction,
                    ),
                  ),
                if (!isCurrentUser)
                  PopupMenuItem<_ResidentAction>(
                    value: _ResidentAction.delete,
                    child: Text(context.l10n.usersDeleteAction),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PendingHousingCard extends StatelessWidget {
  const _PendingHousingCard({required this.card});

  final ResidencePendingHousingCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      card.logement.displayLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      card.logement.codeInterne,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Badge(
                backgroundColor: colorScheme.error,
                textColor: colorScheme.onError,
                label: Text('${card.pendingResidents.length}'),
                child: const Icon(Icons.pending_actions_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _InfoChip(
                icon: card.logement.active
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                label: card.logement.active
                    ? context.l10n.paymentHousingStatusActive
                    : context.l10n.paymentHousingStatusInactive,
                color: card.logement.active
                    ? Colors.green.shade700
                    : colorScheme.onSurfaceVariant,
              ),
              _InfoChip(
                icon: Icons.groups_rounded,
                label: context.l10n.usersHousingOccupancyValue(
                  card.occupancy.occupiedCount,
                  card.occupancy.maxOccupants,
                ),
              ),
            ],
          ),
          if (card.existingResidents.isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            _SectionTitle(
              title: context.l10n.usersHousingExistingResidentsSection,
            ),
            const SizedBox(height: 10),
            Column(
              children: card.existingResidents
                  .map(
                    (resident) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SimpleResidentRow(resident: resident),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 18),
          _SectionTitle(
            title: context.l10n.usersHousingPendingResidentsSection,
          ),
          const SizedBox(height: 10),
          Column(
            children: card.pendingResidents
                .map(
                  (resident) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PendingResidentRow(resident: resident),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SimpleResidentRow extends StatelessWidget {
  const _SimpleResidentRow({required this.resident});

  final ResidencePerson resident;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            child: Text(
              _initials(resident),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              resident.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (resident.isAdmin)
            _RolePill(
              label: context.l10n.authRoleAdmin,
              color: colorScheme.primary,
            ),
        ],
      ),
    );
  }
}

class _PendingResidentRow extends ConsumerWidget {
  const _PendingResidentRow({required this.resident});

  final ResidencePerson resident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.onErrorContainer,
                child: Text(
                  _initials(resident),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      resident.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resident.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (resident.residenceEntryDate != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        '${context.l10n.usersCreatedAtLabel}: ${_formatDate(context, resident.residenceEntryDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: () => _confirmApproveUser(context, ref, resident),
                icon: const Icon(Icons.check_rounded),
                label: Text(context.l10n.usersApproveAction),
              ),
              OutlinedButton.icon(
                onPressed: () => _rejectUser(context, ref, resident),
                icon: const Icon(Icons.close_rounded),
                label: Text(context.l10n.usersRejectAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: tone),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: tone,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _OverdueMonthsSection extends StatelessWidget {
  const _OverdueMonthsSection({
    required this.label,
    required this.months,
    required this.monthFormatter,
  });

  final String label;
  final List<String> months;
  final String Function(String month) monthFormatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tone = colorScheme.error;
    final visibleMonths = months.take(3).toList();
    final overflowCount = months.length - visibleMonths.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tone.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.event_busy_rounded, size: 18, color: tone),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final month in visibleMonths)
                _MonthPill(label: monthFormatter(month), color: tone),
              if (overflowCount > 0)
                _MonthPill(
                  label:
                      '... ${context.l10n.paymentPendingMonthsValue(months.length)}',
                  color: tone.withValues(alpha: 0.9),
                  filled: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthPill extends StatelessWidget {
  const _MonthPill({
    required this.label,
    required this.color,
    this.filled = false,
  });

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: filled ? 0 : 0.24)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: filled ? Colors.white : color,
          fontWeight: FontWeight.w700,
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
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 28, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: 18),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _EditCurrentUserDialog extends ConsumerStatefulWidget {
  const _EditCurrentUserDialog({required this.currentUser});

  final UserProfile currentUser;

  @override
  ConsumerState<_EditCurrentUserDialog> createState() =>
      _EditCurrentUserDialogState();
}

class _EditCurrentUserDialogState
    extends ConsumerState<_EditCurrentUserDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  DateTime? _residenceEntryDate;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.currentUser.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.currentUser.lastName ?? '',
    );
    _residenceEntryDate = widget.currentUser.residenceEntryDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        widget.currentUser.role == UserRole.admin ||
        widget.currentUser.role == UserRole.superAdmin;

    return AlertDialog(
      title: Text(context.l10n.usersEditProfileDialogTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.usersFirstNameLabel,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.usersLastNameLabel,
                ),
              ),
              if (isAdmin) ...<Widget>[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.l10n.usersResidenceEntryDateLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _pickDate,
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(_formatDate(context, _residenceEntryDate)),
                ),
              ],
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
                : context.l10n.usersSaveAction,
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _residenceEntryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _residenceEntryDate = picked;
    });
  }

  Future<void> _submit() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() {
        _errorText = context.l10n.authRequiredFieldsMessage;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      final repository = ref.read(usersRepositoryProvider);
      final updatedProfile = await repository.updateCurrentUser(
        UpdateCurrentUserPayload(firstName: firstName, lastName: lastName),
      );

      final isAdmin =
          widget.currentUser.role == UserRole.admin ||
          widget.currentUser.role == UserRole.superAdmin;
      if (isAdmin &&
          _residenceEntryDate != null &&
          !_isSameDay(
            widget.currentUser.residenceEntryDate,
            _residenceEntryDate,
          )) {
        await repository.updateResidenceEntryDate(
          widget.currentUser.id,
          UpdateResidenceEntryDatePayload(date: _residenceEntryDate!),
        );
        await ref
            .read(authSessionControllerProvider.notifier)
            .refreshCurrentUser();
      } else {
        ref
            .read(authSessionControllerProvider.notifier)
            .setCurrentUser(updatedProfile);
      }

      if (!mounted) {
        return;
      }
      ref.invalidate(residenceViewProvider);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = _resolveUsersErrorMessage(context, error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

enum _ResidentAction { editDate, changeRole, delete }

Future<void> _showEditCurrentUserDialog(
  BuildContext context,
  WidgetRef ref,
  UserProfile currentUser,
) async {
  final updated = await showAccountSettingsDialog(
    context,
    currentUser: currentUser,
  );
  if (updated == true && context.mounted) {
    ref.invalidate(residenceViewProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.usersProfileUpdatedSuccess)),
    );
  }
}

Future<void> _handleResidentAction(
  BuildContext context,
  WidgetRef ref,
  ResidencePerson resident,
  _ResidentAction action,
  bool isCurrentUser,
) async {
  switch (action) {
    case _ResidentAction.editDate:
      await _showEditResidenceEntryDateDialog(
        context,
        ref,
        resident,
        isCurrentUser: isCurrentUser,
      );
      return;
    case _ResidentAction.changeRole:
      await _confirmChangeUserRole(context, ref, resident);
      return;
    case _ResidentAction.delete:
      await _confirmDeleteUser(context, ref, resident);
      return;
  }
}

Future<void> _showEditResidenceEntryDateDialog(
  BuildContext context,
  WidgetRef ref,
  ResidencePerson resident, {
  required bool isCurrentUser,
}) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: resident.residenceEntryDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  if (picked == null || !context.mounted) {
    return;
  }

  try {
    await ref
        .read(usersRepositoryProvider)
        .updateResidenceEntryDate(
          resident.id,
          UpdateResidenceEntryDatePayload(date: picked),
        );
    ref.invalidate(residenceViewProvider);
    if (isCurrentUser) {
      await ref
          .read(authSessionControllerProvider.notifier)
          .refreshCurrentUser();
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.usersDateUpdatedSuccess)),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveUsersErrorMessage(context, error))),
      );
    }
  }
}

Future<void> _confirmApproveUser(
  BuildContext context,
  WidgetRef ref,
  ResidencePerson resident,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.usersApproveConfirmTitle),
      content: Text(context.l10n.usersApproveConfirmBody),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.paymentDialogCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.usersApproveAction),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  try {
    await ref.read(usersRepositoryProvider).approveUser(resident.id);
    ref.invalidate(residenceViewProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.usersApproveSuccess)));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveUsersErrorMessage(context, error))),
      );
    }
  }
}

Future<void> _rejectUser(
  BuildContext context,
  WidgetRef ref,
  ResidencePerson resident,
) async {
  try {
    await ref.read(usersRepositoryProvider).rejectUser(resident.id);
    ref.invalidate(residenceViewProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.usersRejectSuccess)));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveUsersErrorMessage(context, error))),
      );
    }
  }
}

Future<void> _confirmDeleteUser(
  BuildContext context,
  WidgetRef ref,
  ResidencePerson resident,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.usersDeleteConfirmTitle),
      content: Text(context.l10n.usersDeleteConfirmBody(resident.email)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.paymentDialogCancel),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.usersDeleteAction),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  try {
    await ref.read(usersRepositoryProvider).deleteUser(resident.id);
    ref.invalidate(residenceViewProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.usersDeleteSuccess)));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveUsersErrorMessage(context, error))),
      );
    }
  }
}

Future<void> _confirmChangeUserRole(
  BuildContext context,
  WidgetRef ref,
  ResidencePerson resident,
) async {
  if (!_canChangeRole(resident)) {
    return;
  }

  final nextRole = resident.role == UserRole.user
      ? UserRole.admin
      : UserRole.user;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.usersRoleChangeConfirmTitle),
      content: Text(
        context.l10n.usersRoleChangeConfirmBody(
          resident.email,
          _userRoleLabel(context, nextRole),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.paymentDialogCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            nextRole == UserRole.admin
                ? context.l10n.usersPromoteToAdminAction
                : context.l10n.usersDemoteToUserAction,
          ),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  try {
    await ref
        .read(usersRepositoryProvider)
        .updateUserRole(resident.id, UpdateUserRolePayload(role: nextRole));
    ref.invalidate(residenceViewProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.usersRoleUpdatedSuccess)),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveUsersErrorMessage(context, error))),
      );
    }
  }
}

double _cardWidth(ResponsiveLayout layout) {
  if (layout.isDesktop) {
    return (layout.maxContentWidth - layout.itemSpacing) / 2;
  }
  return layout.maxContentWidth;
}

String _initials(ResidencePerson resident) {
  final first = (resident.firstName ?? '').trim();
  final last = (resident.lastName ?? '').trim();
  final value =
      '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}';
  if (value.isNotEmpty) {
    return value.toUpperCase();
  }
  return resident.email.trim().isNotEmpty
      ? resident.email.trim()[0].toUpperCase()
      : '?';
}

Color _paymentColor(BuildContext context, ResidencePaymentStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (status) {
    ResidencePaymentStatus.upToDate => Colors.green.shade700,
    ResidencePaymentStatus.late => colorScheme.error,
    ResidencePaymentStatus.inactive => Colors.orange.shade700,
    ResidencePaymentStatus.unknown => colorScheme.onSurfaceVariant,
  };
}

String _paymentStatusLabel(
  BuildContext context,
  ResidencePaymentStatus status,
) {
  return switch (status) {
    ResidencePaymentStatus.upToDate =>
      context.l10n.dashboardPaymentStatusUpToDate,
    ResidencePaymentStatus.late => context.l10n.dashboardPaymentStatusLate,
    ResidencePaymentStatus.inactive => context.l10n.usersPaymentStatusInactive,
    ResidencePaymentStatus.unknown =>
      context.l10n.dashboardPaymentStatusUnknown,
  };
}

String _cagnotteStatusLabel(
  BuildContext context,
  ResidenceCagnotteStatus status,
) {
  return switch (status) {
    ResidenceCagnotteStatus.positive => context.l10n.usersFundPositive,
    ResidenceCagnotteStatus.negative => context.l10n.usersFundNegative,
    ResidenceCagnotteStatus.neutral => context.l10n.usersFundNeutral,
  };
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

bool _isSameDay(DateTime? left, DateTime? right) {
  if (left == null || right == null) {
    return left == right;
  }
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

bool _canChangeRole(ResidencePerson resident) {
  return resident.role == UserRole.user || resident.role == UserRole.admin;
}

String _userRoleLabel(BuildContext context, UserRole role) {
  return switch (role) {
    UserRole.superAdmin => context.l10n.authRoleSuperAdmin,
    UserRole.admin => context.l10n.authRoleAdmin,
    UserRole.user || UserRole.unknown => context.l10n.authRoleUser,
  };
}

String _resolveUsersErrorMessage(BuildContext context, Object error) {
  final exception = ApiException.fromError(error);
  return switch (exception.kind) {
    ApiExceptionKind.timeout => context.l10n.authErrorTimeout,
    ApiExceptionKind.network => context.l10n.authErrorNetwork,
    ApiExceptionKind.unauthorized => context.l10n.authErrorUnauthorized,
    ApiExceptionKind.badRequest => exception.message,
    ApiExceptionKind.forbidden => exception.message,
    ApiExceptionKind.notFound => exception.message,
    ApiExceptionKind.unknown => exception.message,
  };
}

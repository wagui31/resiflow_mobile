import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/global_page_header.dart';
import '../../../core/widgets/responsive_page_container.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../../dashboard/application/dashboard_providers.dart';
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
        child: ResponsiveBuilder(
          builder: (context, layout) {
            return _UsersPage(
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

class _UsersPage extends ConsumerWidget {
  const _UsersPage({
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
    final pendingUsersCount = ref.watch(pendingUsersCountProvider).valueOrNull;
    final dashboardSnapshot = ref.watch(dashboardSnapshotProvider).valueOrNull;
    final currencyCode = ref.watch(currentCurrencyCodeProvider);

    return ListView(
      children: <Widget>[
        GlobalPageHeader(
          title: context.l10n.moduleSettingsTitle,
          layout: layout,
          residenceBalance: dashboardSnapshot?.overview.balance,
          currencyCode: currencyCode,
          actions: <Widget>[
            IconButton(
              onPressed: () => _refresh(ref),
              tooltip: context.l10n.usersRefreshTooltip,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        SizedBox(height: layout.sectionSpacing),
        _UsersHero(
          layout: layout,
          isAdmin: isAdmin,
          onEditCurrentUser: currentUser == null
              ? null
              : () => _showEditCurrentUserDialog(context, ref, currentUser),
        ),
        SizedBox(height: layout.itemSpacing),
        if (isAdmin) ...<Widget>[
          _UsersTabSelector(
            selectedTab: tab,
            pendingCount: pendingUsersCount,
            onChanged: (value) =>
                ref.read(usersTabProvider.notifier).state = value,
          ),
          SizedBox(height: layout.itemSpacing),
        ],
        if (tab == UsersTab.residents) ...<Widget>[
          _UsersSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
            onClear: onClearSearch,
          ),
          SizedBox(height: layout.sectionSpacing),
          _ResidentsBody(layout: layout, isAdmin: isAdmin),
        ] else
          _PendingUsersBody(layout: layout),
      ],
    );
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(residenceUsersProvider);
    ref.invalidate(pendingUsersProvider);
  }
}

class _UsersHero extends StatelessWidget {
  const _UsersHero({
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
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.14),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
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
              maxWidth: layout.isDesktop ? 640 : layout.maxContentWidth,
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<UsersTab>(
          showSelectedIcon: false,
          segments: <ButtonSegment<UsersTab>>[
            ButtonSegment<UsersTab>(
              value: UsersTab.residents,
              label: Text(context.l10n.usersResidentsTab),
              icon: const Icon(Icons.groups_rounded),
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
  const _PendingTabLabel({
    required this.label,
    required this.pendingCount,
  });

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

class _UsersSearchBar extends ConsumerWidget {
  const _UsersSearchBar({
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
      keyboardType: TextInputType.emailAddress,
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

class _ResidentsBody extends ConsumerWidget {
  const _ResidentsBody({
    required this.layout,
    required this.isAdmin,
  });

  final ResponsiveLayout layout;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(filteredResidenceUsersProvider);
    final currentUserId = ref.watch(currentUserProvider)?.id;

    return usersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _InlineStateCard(
        icon: Icons.error_outline_rounded,
        title: context.l10n.usersLoadErrorTitle,
        body: _resolveUsersErrorMessage(context, error),
        actionLabel: context.l10n.authRetryButton,
        onAction: () => ref.invalidate(residenceUsersProvider),
      ),
      data: (users) {
        final visibleUsers = users
            .where((user) => user.role != UserRole.superAdmin)
            .toList();

        if (visibleUsers.isEmpty) {
          return _InlineStateCard(
            icon: Icons.groups_2_rounded,
            title: context.l10n.usersResidentsEmptyTitle,
            body: context.l10n.usersResidentsEmptyBody,
          );
        }

        final current = visibleUsers
            .where((user) => user.id == currentUserId)
            .toList();
        final admins = visibleUsers
            .where((user) => user.id != currentUserId && user.isAdmin)
            .toList();
        final late = visibleUsers
            .where(
              (user) =>
                  user.id != currentUserId &&
                  !user.isAdmin &&
                  user.paymentStatus == PaymentStatus.late,
            )
            .toList();
        final others = visibleUsers
            .where(
              (user) =>
                  user.id != currentUserId &&
                  !user.isAdmin &&
                  user.paymentStatus != PaymentStatus.late,
            )
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (current.isNotEmpty) ...<Widget>[
              _SectionTitle(title: context.l10n.usersCurrentSectionTitle),
              SizedBox(height: layout.itemSpacing),
              _UserGrid(
                layout: layout,
                users: current,
                isAdmin: isAdmin,
                highlightCurrentUser: true,
              ),
              SizedBox(height: layout.sectionSpacing),
            ],
            if (admins.isNotEmpty) ...<Widget>[
              _SectionTitle(title: context.l10n.usersAdminsSectionTitle),
              SizedBox(height: layout.itemSpacing),
              _UserGrid(layout: layout, users: admins, isAdmin: isAdmin),
              SizedBox(height: layout.sectionSpacing),
            ],
            if (late.isNotEmpty) ...<Widget>[
              _SectionTitle(title: context.l10n.usersLateSectionTitle),
              SizedBox(height: layout.itemSpacing),
              _UserGrid(layout: layout, users: late, isAdmin: isAdmin),
              SizedBox(height: layout.sectionSpacing),
            ],
            if (others.isNotEmpty) ...<Widget>[
              _SectionTitle(title: context.l10n.usersOthersSectionTitle),
              SizedBox(height: layout.itemSpacing),
              _UserGrid(layout: layout, users: others, isAdmin: isAdmin),
            ],
          ],
        );
      },
    );
  }
}

class _PendingUsersBody extends ConsumerWidget {
  const _PendingUsersBody({required this.layout});

  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingUsersProvider);

    return pendingAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _InlineStateCard(
        icon: Icons.error_outline_rounded,
        title: context.l10n.usersLoadErrorTitle,
        body: _resolveUsersErrorMessage(context, error),
        actionLabel: context.l10n.authRetryButton,
        onAction: () => ref.invalidate(pendingUsersProvider),
      ),
      data: (users) {
        final visibleUsers = users
            .where((user) => user.role != UserRole.superAdmin)
            .toList();

        if (visibleUsers.isEmpty) {
          return _InlineStateCard(
            icon: Icons.mark_email_read_rounded,
            title: context.l10n.usersPendingEmptyTitle,
            body: context.l10n.usersPendingEmptyBody,
          );
        }

        return Wrap(
          spacing: layout.itemSpacing,
          runSpacing: layout.itemSpacing,
          children: visibleUsers
              .map(
                (user) => SizedBox(
                  width: _cardWidth(layout),
                  child: _PendingUserCard(user: user),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _UserGrid extends StatelessWidget {
  const _UserGrid({
    required this.layout,
    required this.users,
    required this.isAdmin,
    this.highlightCurrentUser = false,
  });

  final ResponsiveLayout layout;
  final List<ResidenceUser> users;
  final bool isAdmin;
  final bool highlightCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: layout.itemSpacing,
      runSpacing: layout.itemSpacing,
      children: users
          .map(
            (user) => SizedBox(
              width: _cardWidth(layout),
              child: _ResidentContactCard(
                user: user,
                isAdmin: isAdmin,
                highlightCurrentUser: highlightCurrentUser,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ResidentContactCard extends ConsumerWidget {
  const _ResidentContactCard({
    required this.user,
    required this.isAdmin,
    required this.highlightCurrentUser,
  });

  final ResidenceUser user;
  final bool isAdmin;
  final bool highlightCurrentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = ref.watch(currentUserProvider);
    final isCurrentUser = currentUser?.id == user.id;
    final paymentColor = _paymentColor(context, user.paymentStatus);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlightCurrentUser
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlightCurrentUser
              ? colorScheme.primary.withValues(alpha: 0.28)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                child: Text(
                  _initials(user),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton<_ResidentAction>(
                  tooltip: context.l10n.usersActionsTooltip,
                  onSelected: (action) => _handleResidentAction(
                    context,
                    ref,
                    user,
                    action,
                    isCurrentUser,
                  ),
                  itemBuilder: (context) => <PopupMenuEntry<_ResidentAction>>[
                    PopupMenuItem<_ResidentAction>(
                      value: _ResidentAction.editDate,
                      child: Text(context.l10n.usersEditDateAction),
                    ),
                    if (!isCurrentUser && _canChangeRole(user))
                      PopupMenuItem<_ResidentAction>(
                        value: _ResidentAction.changeRole,
                        child: Text(
                          user.role == UserRole.user
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _InfoChip(
                icon: switch (user.role) {
                  UserRole.superAdmin => Icons.workspace_premium_rounded,
                  UserRole.admin => Icons.verified_user_rounded,
                  UserRole.user || UserRole.unknown => Icons.person_rounded,
                },
                label: _userRoleLabel(context, user.role),
              ),
              _InfoChip(
                icon: Icons.payments_rounded,
                label: user.paymentStatus == PaymentStatus.late
                    ? context.l10n.dashboardPaymentStatusLate
                    : user.paymentStatus == PaymentStatus.upToDate
                    ? context.l10n.dashboardPaymentStatusUpToDate
                    : context.l10n.dashboardPaymentStatusUnknown,
                color: paymentColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetaRow(
            label: context.l10n.usersResidenceEntryDateLabel,
            value: _formatDate(context, user.residenceEntryDate),
          ),
          if ((user.numeroImmeuble ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            _MetaRow(
              label: context.l10n.authBuildingLabel,
              value: user.numeroImmeuble!.trim(),
            ),
          ],
          if ((user.codeLogement ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            _MetaRow(
              label: context.l10n.authHousingLabel,
              value: user.codeLogement!.trim(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleResidentAction(
    BuildContext context,
    WidgetRef ref,
    ResidenceUser user,
    _ResidentAction action,
    bool isCurrentUser,
  ) async {
    if (action == _ResidentAction.editDate) {
      await _showEditResidenceEntryDateDialog(
        context,
        ref,
        user,
        isCurrentUser: isCurrentUser,
      );
      return;
    }
    if (action == _ResidentAction.changeRole) {
      await _confirmChangeUserRole(context, ref, user);
      return;
    }
    await _confirmDeleteUser(context, ref, user);
  }
}

class _PendingUserCard extends ConsumerWidget {
  const _PendingUserCard({required this.user});

  final ResidenceUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            user.email,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.usersPendingCardBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (user.createdAt != null) ...<Widget>[
            const SizedBox(height: 14),
            _MetaRow(
              label: context.l10n.usersCreatedAtLabel,
              value: _formatDateTime(context, user.createdAt),
            ),
          ],
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: () => _confirmApproveUser(context, ref, user),
                icon: const Icon(Icons.check_rounded),
                label: Text(context.l10n.usersApproveAction),
              ),
              OutlinedButton.icon(
                onPressed: () => _rejectUser(context, ref, user),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

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
            FilledButton.tonal(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
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
  late final TextEditingController _buildingController;
  late final TextEditingController _housingController;
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
    _buildingController = TextEditingController(
      text: widget.currentUser.numeroImmeuble ?? '',
    );
    _housingController = TextEditingController(
      text: widget.currentUser.codeLogement ?? '',
    );
    _residenceEntryDate = widget.currentUser.residenceEntryDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _buildingController.dispose();
    _housingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUser.role == UserRole.admin ||
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
              const SizedBox(height: 14),
              TextField(
                controller: _buildingController,
                decoration: InputDecoration(
                  labelText: context.l10n.authBuildingLabel,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _housingController,
                decoration: InputDecoration(
                  labelText: context.l10n.authHousingLabel,
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
        UpdateCurrentUserPayload(
          firstName: firstName,
          lastName: lastName,
          numeroImmeuble: _buildingController.text,
          codeLogement: _housingController.text,
        ),
      );

      final isAdmin = widget.currentUser.role == UserRole.admin ||
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
        ref.read(authSessionControllerProvider.notifier).setCurrentUser(
              updatedProfile,
            );
      }

      if (!mounted) {
        return;
      }
      ref.invalidate(residenceUsersProvider);
      ref.invalidate(pendingUsersProvider);
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
  final updated = await showDialog<bool>(
    context: context,
    builder: (context) => _EditCurrentUserDialog(currentUser: currentUser),
  );
  if (updated == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.usersProfileUpdatedSuccess)),
    );
  }
}

Future<void> _showEditResidenceEntryDateDialog(
  BuildContext context,
  WidgetRef ref,
  ResidenceUser user, {
  required bool isCurrentUser,
}) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: user.residenceEntryDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  if (picked == null || !context.mounted) {
    return;
  }

  try {
    await ref.read(usersRepositoryProvider).updateResidenceEntryDate(
          user.id,
          UpdateResidenceEntryDatePayload(date: picked),
        );
    ref.invalidate(residenceUsersProvider);
    ref.invalidate(pendingUsersProvider);
    if (isCurrentUser) {
      await ref.read(authSessionControllerProvider.notifier).refreshCurrentUser();
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
  ResidenceUser user,
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
    await ref.read(usersRepositoryProvider).approveUser(user.id);
    ref.invalidate(pendingUsersProvider);
    ref.invalidate(residenceUsersProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.usersApproveSuccess)),
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

Future<void> _rejectUser(
  BuildContext context,
  WidgetRef ref,
  ResidenceUser user,
) async {
  try {
    await ref.read(usersRepositoryProvider).rejectUser(user.id);
    ref.invalidate(pendingUsersProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.usersRejectSuccess)),
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

Future<void> _confirmDeleteUser(
  BuildContext context,
  WidgetRef ref,
  ResidenceUser user,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.usersDeleteConfirmTitle),
      content: Text(context.l10n.usersDeleteConfirmBody(user.email)),
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
    await ref.read(usersRepositoryProvider).deleteUser(user.id);
    ref.invalidate(residenceUsersProvider);
    ref.invalidate(pendingUsersProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.usersDeleteSuccess)),
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

Future<void> _confirmChangeUserRole(
  BuildContext context,
  WidgetRef ref,
  ResidenceUser user,
) async {
  if (!_canChangeRole(user)) {
    return;
  }

  final nextRole = user.role == UserRole.user ? UserRole.admin : UserRole.user;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.usersRoleChangeConfirmTitle),
      content: Text(
        context.l10n.usersRoleChangeConfirmBody(
          user.email,
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
    await ref.read(usersRepositoryProvider).updateUserRole(
          user.id,
          UpdateUserRolePayload(role: nextRole),
        );
    ref.invalidate(residenceUsersProvider);
    ref.invalidate(pendingUsersProvider);
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

String _initials(ResidenceUser user) {
  final first = (user.firstName ?? '').trim();
  final last = (user.lastName ?? '').trim();
  final value =
      '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}';
  if (value.isNotEmpty) {
    return value.toUpperCase();
  }
  return user.email.trim().isNotEmpty
      ? user.email.trim()[0].toUpperCase()
      : '?';
}

Color _paymentColor(BuildContext context, PaymentStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (status) {
    PaymentStatus.upToDate => Colors.green.shade700,
    PaymentStatus.late => colorScheme.error,
    PaymentStatus.unknown => colorScheme.onSurfaceVariant,
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

String _formatDateTime(BuildContext context, DateTime? date) {
  if (date == null) {
    return context.l10n.paymentDateUnavailable;
  }
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).add_Hm().format(date);
}

bool _isSameDay(DateTime? left, DateTime? right) {
  if (left == null || right == null) {
    return left == right;
  }
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

bool _canChangeRole(ResidenceUser user) {
  return user.role == UserRole.user || user.role == UserRole.admin;
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

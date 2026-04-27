import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../auth/domain/auth_models.dart';
import '../application/users_providers.dart';
import '../data/users_repository.dart';

Future<void> showAdminUserReactivationDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const _AdminUserReactivationDialog(),
  );
}

class _AdminUserReactivationDialog extends ConsumerStatefulWidget {
  const _AdminUserReactivationDialog();

  @override
  ConsumerState<_AdminUserReactivationDialog> createState() =>
      _AdminUserReactivationDialogState();
}

class _AdminUserReactivationDialogState
    extends ConsumerState<_AdminUserReactivationDialog> {
  int? _reactivatingUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoverableUsersAsync = ref.watch(recoverableUsersProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 940, maxHeight: 760),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.16),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 20, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer.withValues(alpha: 0.92),
                        colorScheme.surfaceContainerHigh,
                      ],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              context.l10n.accountMenuManageUsers,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.userRecoveryDialogSubtitle,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.86),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonLabel,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: recoverableUsersAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => _RecoverableUsersErrorState(
                        message: _resolveUsersErrorMessage(context, error),
                        onRetry: () => ref.invalidate(recoverableUsersProvider),
                      ),
                      data: (users) => DefaultTabController(
                        length: 2,
                        child: ResponsiveBuilder(
                          builder: (context, layout) {
                            final rejectedCount = users.rejected.length;
                            final archivedCount = users.archived.length;

                            return Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: TabBar(
                                    dividerColor: Colors.transparent,
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: colorScheme.surface,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: colorScheme.shadow.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    labelColor: colorScheme.onSurface,
                                    unselectedLabelColor:
                                        colorScheme.onSurfaceVariant,
                                    tabs: <Widget>[
                                      _RecoveryTab(
                                        label: context
                                            .l10n
                                            .userRecoveryRejectedTab,
                                        count: rejectedCount,
                                      ),
                                      _RecoveryTab(
                                        label: context
                                            .l10n
                                            .userRecoveryArchivedTab,
                                        count: archivedCount,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Expanded(
                                  child: TabBarView(
                                    children: <Widget>[
                                      _RecoverableUsersList(
                                        users: users.rejected,
                                        status: UserStatus.rejected,
                                        busyUserId: _reactivatingUserId,
                                        onReactivate: _reactivateUser,
                                        compact: layout.isMobile,
                                      ),
                                      _RecoverableUsersList(
                                        users: users.archived,
                                        status: UserStatus.archived,
                                        busyUserId: _reactivatingUserId,
                                        onReactivate: _reactivateUser,
                                        compact: layout.isMobile,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reactivateUser(UserProfile user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.userRecoveryReactivateConfirmTitle),
        content: Text(
          context.l10n.userRecoveryReactivateConfirmBody(user.email),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.voteCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.userRecoveryReactivateAction),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _reactivatingUserId = user.id;
    });

    try {
      await ref.read(usersRepositoryProvider).reactivateUser(user.id);
      ref.invalidate(recoverableUsersProvider);
      ref.invalidate(residenceViewProvider);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.userRecoveryReactivateSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_resolveUsersErrorMessage(context, error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _reactivatingUserId = null;
        });
      }
    }
  }
}

class _RecoveryTab extends StatelessWidget {
  const _RecoveryTab({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tab(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoverableUsersList extends StatelessWidget {
  const _RecoverableUsersList({
    required this.users,
    required this.status,
    required this.busyUserId,
    required this.onReactivate,
    required this.compact,
  });

  final List<UserProfile> users;
  final UserStatus status;
  final int? busyUserId;
  final Future<void> Function(UserProfile user) onReactivate;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return _RecoverableUsersEmptyState(status: status);
    }

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        return _RecoverableUserCard(
          user: user,
          status: status,
          busy: busyUserId == user.id,
          onReactivate: () => onReactivate(user),
          compact: compact,
        );
      },
    );
  }
}

class _RecoverableUserCard extends StatelessWidget {
  const _RecoverableUserCard({
    required this.user,
    required this.status,
    required this.busy,
    required this.onReactivate,
    required this.compact,
  });

  final UserProfile user;
  final UserStatus status;
  final bool busy;
  final VoidCallback onReactivate;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final logementLabel = user.logement?.displayLabel.trim().isNotEmpty == true
        ? user.logement!.displayLabel
        : _fallbackHousingLabel(user);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _RecoverableUserHeader(
                  user: user,
                  status: status,
                  logementLabel: logementLabel,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: busy ? null : onReactivate,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(context.l10n.userRecoveryReactivateAction),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _RecoverableUserHeader(
                    user: user,
                    status: status,
                    logementLabel: logementLabel,
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: busy ? null : onReactivate,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(context.l10n.userRecoveryReactivateAction),
                ),
              ],
            ),
    );
  }

  String _fallbackHousingLabel(UserProfile user) {
    final pieces = <String>[
      if ((user.numeroImmeuble ?? '').trim().isNotEmpty)
        user.numeroImmeuble!.trim(),
      if ((user.codeLogement ?? '').trim().isNotEmpty)
        user.codeLogement!.trim(),
    ];
    return pieces.join(' - ');
  }
}

class _RecoverableUserHeader extends StatelessWidget {
  const _RecoverableUserHeader({
    required this.user,
    required this.status,
    required this.logementLabel,
  });

  final UserProfile user;
  final UserStatus status;
  final String logementLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
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
                    user.displayName.isNotEmpty ? user.displayName : user.email,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _StatusBadge(status: status),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _DetailPill(
              icon: Icons.apartment_rounded,
              label: logementLabel.isNotEmpty
                  ? logementLabel
                  : context.l10n.userRecoveryHousingUnknown,
            ),
            _DetailPill(
              icon: Icons.admin_panel_settings_rounded,
              label: _roleLabel(context, user.role),
            ),
            if ((user.residenceName ?? '').trim().isNotEmpty)
              _DetailPill(
                icon: Icons.home_work_rounded,
                label: user.residenceName!.trim(),
              ),
          ],
        ),
      ],
    );
  }

  String _roleLabel(BuildContext context, UserRole role) {
    return switch (role) {
      UserRole.superAdmin => context.l10n.authRoleSuperAdmin,
      UserRole.admin => context.l10n.authRoleAdmin,
      UserRole.user => context.l10n.authRoleUser,
      UserRole.unknown => context.l10n.authRoleLabel,
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final UserStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tone = switch (status) {
      UserStatus.rejected => colorScheme.error,
      UserStatus.archived => colorScheme.secondary,
      _ => colorScheme.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        switch (status) {
          UserStatus.rejected => context.l10n.userRecoveryRejectedTab,
          UserStatus.archived => context.l10n.userRecoveryArchivedTab,
          _ => context.l10n.authStatusLabel,
        },
        style: theme.textTheme.labelLarge?.copyWith(
          color: tone,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoverableUsersEmptyState extends StatelessWidget {
  const _RecoverableUsersEmptyState({required this.status});

  final UserStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                status == UserStatus.archived
                    ? Icons.archive_outlined
                    : Icons.person_off_outlined,
                color: colorScheme.onPrimaryContainer,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              status == UserStatus.archived
                  ? context.l10n.userRecoveryArchivedEmptyTitle
                  : context.l10n.userRecoveryRejectedEmptyTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status == UserStatus.archived
                  ? context.l10n.userRecoveryArchivedEmptyBody
                  : context.l10n.userRecoveryRejectedEmptyBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoverableUsersErrorState extends StatelessWidget {
  const _RecoverableUsersErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.cloud_off_rounded, size: 40, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              context.l10n.userRecoveryLoadErrorTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.authRetryButton),
            ),
          ],
        ),
      ),
    );
  }
}

String _resolveUsersErrorMessage(BuildContext context, Object error) {
  final exception = ApiException.fromError(error);

  return switch (exception.kind) {
    ApiExceptionKind.timeout => context.l10n.authErrorTimeout,
    ApiExceptionKind.network => context.l10n.authErrorNetwork,
    _ =>
      exception.message.trim().isNotEmpty
          ? exception.message.trim()
          : context.l10n.authErrorTechnical,
  };
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../../features/dashboard/application/dashboard_providers.dart';
import '../../features/depense/application/depense_providers.dart';
import '../../features/paiement/application/paiement_providers.dart';
import '../../features/users/application/users_providers.dart';
import '../i18n/extensions/app_localizations_x.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingUsersCount = ref.watch(pendingUsersCountProvider).valueOrNull;
    final pendingPaymentsCount = ref
        .watch(pendingPaymentsCountProvider)
        .valueOrNull;
    final pendingExpenseAdminItemsCount = ref
        .watch(pendingExpenseAdminItemsCountProvider)
        .valueOrNull;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onDestinationSelected(ref, index),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: _PaymentsNavigationIcon(
              icon: Icons.payments_outlined,
              pendingCount: pendingPaymentsCount,
            ),
            selectedIcon: _PaymentsNavigationIcon(
              icon: Icons.payments_rounded,
              pendingCount: pendingPaymentsCount,
            ),
            label: context.l10n.modulePaymentTitle,
          ),
          NavigationDestination(
            icon: _ExpensesNavigationIcon(
              icon: Icons.receipt_long_outlined,
              pendingCount: pendingExpenseAdminItemsCount,
            ),
            selectedIcon: _ExpensesNavigationIcon(
              icon: Icons.receipt_long_rounded,
              pendingCount: pendingExpenseAdminItemsCount,
            ),
            label: context.l10n.moduleExpenseTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: context.l10n.dashboardTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.how_to_vote_outlined),
            selectedIcon: const Icon(Icons.how_to_vote_rounded),
            label: context.l10n.moduleVoteTitle,
          ),
          NavigationDestination(
            icon: _UsersNavigationIcon(
              icon: Icons.people_outline_rounded,
              pendingCount: pendingUsersCount,
            ),
            selectedIcon: _UsersNavigationIcon(
              icon: Icons.people_rounded,
              pendingCount: pendingUsersCount,
            ),
            label: context.l10n.moduleSettingsTitle,
          ),
        ],
      ),
    );
  }

  void _onDestinationSelected(WidgetRef ref, int index) {
    if (index == navigationShell.currentIndex) {
      _refreshCurrentBranch(ref, index);
      return;
    }

    navigationShell.goBranch(index);
  }

  void _refreshCurrentBranch(WidgetRef ref, int index) {
    switch (index) {
      case 0:
        final mode = ref.read(paymentViewModeProvider);
        final selectedLogement = ref.read(selectedPaymentLogementProvider);
        if (mode == PaymentViewMode.mine) {
          ref.read(residentPaymentControllerProvider.notifier).refresh();
          return;
        }
        if (mode == PaymentViewMode.pending) {
          ref.invalidate(adminPendingPaymentsProvider);
          return;
        }
        if (selectedLogement != null) {
          ref.invalidate(adminResidentPaymentProvider(selectedLogement.id));
        }
        return;
      case 1:
        final expenseTab = ref.read(expenseViewTabProvider);
        if (expenseTab == ExpenseViewTab.pending) {
          ref.invalidate(adminPendingSharedExpensePaymentsProvider);
          ref.invalidate(adminPendingExpensesProvider);
        }
        ref.invalidate(expenseOverviewProvider);
        return;
      case 3:
        return;
      case 2:
        ref.invalidate(dashboardSnapshotProvider);
        ref.read(authSessionControllerProvider.notifier).refreshCurrentUser();
        return;
      case 4:
        ref.invalidate(residenceViewProvider);
        return;
    }
  }
}

class _PaymentsNavigationIcon extends StatelessWidget {
  const _PaymentsNavigationIcon({
    required this.icon,
    required this.pendingCount,
  });

  final IconData icon;
  final int? pendingCount;

  @override
  Widget build(BuildContext context) {
    final count = pendingCount ?? 0;
    final iconWidget = Icon(icon);

    if (count <= 0) {
      return iconWidget;
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Badge(
      backgroundColor: colorScheme.primary,
      textColor: colorScheme.onPrimary,
      label: Text('$count'),
      child: iconWidget,
    );
  }
}

class _UsersNavigationIcon extends StatelessWidget {
  const _UsersNavigationIcon({
    required this.icon,
    required this.pendingCount,
  });

  final IconData icon;
  final int? pendingCount;

  @override
  Widget build(BuildContext context) {
    final count = pendingCount ?? 0;
    final iconWidget = Icon(icon);

    if (count <= 0) {
      return iconWidget;
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Badge(
      backgroundColor: colorScheme.error,
      textColor: colorScheme.onError,
      label: Text('$count'),
      child: iconWidget,
    );
  }
}

class _ExpensesNavigationIcon extends StatelessWidget {
  const _ExpensesNavigationIcon({
    required this.icon,
    required this.pendingCount,
  });

  final IconData icon;
  final int? pendingCount;

  @override
  Widget build(BuildContext context) {
    final count = pendingCount ?? 0;
    final iconWidget = Icon(icon);

    if (count <= 0) {
      return iconWidget;
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Badge(
      backgroundColor: colorScheme.primary,
      textColor: colorScheme.onPrimary,
      label: Text('$count'),
      child: iconWidget,
    );
  }
}

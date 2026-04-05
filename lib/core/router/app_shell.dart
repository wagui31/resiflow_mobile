import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../../features/dashboard/application/dashboard_providers.dart';
import '../../features/paiement/application/paiement_providers.dart';
import '../../features/users/application/users_providers.dart';
import '../i18n/extensions/app_localizations_x.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onDestinationSelected(ref, index),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.payments_outlined),
            selectedIcon: const Icon(Icons.payments_rounded),
            label: context.l10n.modulePaymentTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
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
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
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
        final searchedEmail = ref.read(selectedResidentEmailProvider);
        if (mode == PaymentViewMode.mine) {
          ref.read(residentPaymentControllerProvider.notifier).refresh();
          return;
        }
        if (mode == PaymentViewMode.pending) {
          ref.invalidate(adminPendingPaymentsProvider);
          return;
        }
        if (searchedEmail != null && searchedEmail.isNotEmpty) {
          ref.invalidate(adminResidentPaymentProvider(searchedEmail));
        }
        return;
      case 1:
      case 3:
        return;
      case 2:
        ref.invalidate(dashboardSnapshotProvider);
        ref.read(authSessionControllerProvider.notifier).refreshCurrentUser();
        return;
      case 4:
        final tab = ref.read(usersTabProvider);
        ref.invalidate(residenceUsersProvider);
        if (tab == UsersTab.pending) {
          ref.invalidate(pendingUsersProvider);
        }
        return;
    }
  }
}

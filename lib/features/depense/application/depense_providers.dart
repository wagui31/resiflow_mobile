import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../data/depense_repository.dart';
import '../domain/depense_models.dart';

enum ExpenseViewTab { cagnotte, shared, pending }

const Duration _pendingExpenseAdminRefreshInterval = Duration(seconds: 15);

final expenseViewTabProvider = StateProvider<ExpenseViewTab>(
  (ref) => ExpenseViewTab.cagnotte,
);

final selectedExpenseCategoryIdsProvider = StateProvider<Set<int>>(
  (ref) => <int>{},
);

final expenseOverviewProvider = FutureProvider.autoDispose<ExpenseOverview>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  final residenceId = user?.residenceId;

  if (user == null || residenceId == null) {
    throw const ExpenseDataException(
      'Authenticated residence context is missing.',
    );
  }

  final repository = ref.watch(depenseRepositoryProvider);
  final results = await Future.wait<Object>(<Future<Object>>[
    repository.fetchResidenceBalance(residenceId),
    repository.fetchExpenseCategories(),
    repository.fetchApprovedCagnotteExpensesByResidence(residenceId),
    repository.fetchApprovedSharedExpensesByResidence(residenceId),
  ]);

  return ExpenseOverview(
    balance: results[0] as ResidenceFundBalance,
    categories: results[1] as List<ExpenseCategory>,
    cagnotteExpenses: results[2] as List<ExpenseRecord>,
    sharedExpenses: results[3] as List<SharedExpenseRecord>,
  );
});

final adminPendingSharedExpensePaymentsProvider =
    FutureProvider.autoDispose<List<SharedExpensePaymentRecord>>((ref) {
      ref.watch(currentUserProvider);
      final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
      final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;

      if (!isAdmin) {
        return Future.value(const <SharedExpensePaymentRecord>[]);
      }

      final timer = Timer.periodic(_pendingExpenseAdminRefreshInterval, (_) {
        ref.invalidateSelf();
      });
      ref.onDispose(timer.cancel);

      return ref
          .read(depenseRepositoryProvider)
          .fetchAdminPendingSharedExpensePayments();
    });

final adminPendingExpensesProvider =
    FutureProvider.autoDispose<List<ExpenseRecord>>((ref) {
      final user = ref.watch(currentUserProvider);
      final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
      final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;
      final residenceId = user?.residenceId;

      if (!isAdmin || residenceId == null) {
        return Future.value(const <ExpenseRecord>[]);
      }

      final timer = Timer.periodic(_pendingExpenseAdminRefreshInterval, (_) {
        ref.invalidateSelf();
      });
      ref.onDispose(timer.cancel);

      return ref
          .read(depenseRepositoryProvider)
          .fetchPendingExpensesByResidence(residenceId);
    });

final pendingExpenseAdminItemsCountProvider =
    Provider.autoDispose<AsyncValue<int>>((ref) {
      final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
      final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;

      if (!isAdmin) {
        return const AsyncValue.data(0);
      }

      final pendingPaymentsAsync = ref.watch(
        adminPendingSharedExpensePaymentsProvider,
      );
      final pendingExpensesAsync = ref.watch(adminPendingExpensesProvider);

      if (pendingPaymentsAsync.hasError) {
        return AsyncValue.error(
          pendingPaymentsAsync.error!,
          pendingPaymentsAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (pendingExpensesAsync.hasError) {
        return AsyncValue.error(
          pendingExpensesAsync.error!,
          pendingExpensesAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (pendingPaymentsAsync.isLoading || pendingExpensesAsync.isLoading) {
        return const AsyncValue.loading();
      }

      return AsyncValue.data(
        (pendingPaymentsAsync.valueOrNull?.length ?? 0) +
            (pendingExpensesAsync.valueOrNull?.length ?? 0),
      );
    });

final pendingSharedExpensePaymentsCountProvider =
    pendingExpenseAdminItemsCountProvider;

class ExpenseDataException implements Exception {
  const ExpenseDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

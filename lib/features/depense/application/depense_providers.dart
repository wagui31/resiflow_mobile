import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../data/depense_repository.dart';
import '../domain/depense_models.dart';

enum ExpenseViewTab { cagnotte, shared, pending }

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

class ExpenseDataException implements Exception {
  const ExpenseDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

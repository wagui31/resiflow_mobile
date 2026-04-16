import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_models.dart';

final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  final residenceId = user?.residenceId;

  if (user == null || residenceId == null) {
    throw const DashboardDataException(
      'Authenticated residence context is missing.',
    );
  }

  final repository = ref.watch(dashboardRepositoryProvider);
  final results = await Future.wait<Object>(<Future<Object>>[
    repository.fetchOverview(residenceId),
    repository.fetchStats(residenceId),
    repository.fetchPaymentHousingStats(residenceId),
    repository.fetchExpenseCategoryStats(residenceId),
  ]);

  final stats = results[1] as DashboardStats;

  return DashboardSnapshot(
    overview: results[0] as DashboardOverview,
    stats: DashboardStats(
      totalContributions: stats.totalContributions,
      totalExpenses: stats.totalExpenses,
      currentBalance: stats.currentBalance,
      topPayers: stats.topPayers,
      balanceEvolution: stats.balanceEvolution,
      paymentHousingStats: results[2] as DashboardPaymentHousingStats,
      expenseCategoryStats: results[3] as DashboardExpenseCategoryStats,
    ),
  );
});

class DashboardDataException implements Exception {
  const DashboardDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

String buildDashboardDisplayName(UserProfile user) {
  final parts = <String>[
    if ((user.firstName ?? '').trim().isNotEmpty) user.firstName!.trim(),
    if ((user.lastName ?? '').trim().isNotEmpty) user.lastName!.trim(),
  ];

  return parts.join(' ').trim();
}

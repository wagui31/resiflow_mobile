import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_models.dart';

final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((ref) async {
  final user = ref.watch(currentUserProvider);
  final residenceId = user?.residenceId;

  if (user == null || residenceId == null) {
    throw const DashboardDataException('Authenticated residence context is missing.');
  }

  final repository = ref.watch(dashboardRepositoryProvider);
  final results = await Future.wait<Object>(<Future<Object>>[
    repository.fetchOverview(residenceId),
    repository.fetchStats(residenceId),
  ]);

  return DashboardSnapshot(
    overview: results[0] as DashboardOverview,
    stats: results[1] as DashboardStats,
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

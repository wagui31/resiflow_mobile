import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../data/users_repository.dart';
import '../domain/users_models.dart';

enum UsersTab { residents, pending }

const Duration _residenceViewRefreshInterval = Duration(seconds: 15);
const Duration _residenceAlertsRefreshInterval = Duration(seconds: 30);
const Duration _recoverableUsersRefreshInterval = Duration(seconds: 20);

final usersTabProvider = StateProvider<UsersTab>((ref) => UsersTab.residents);

final usersSearchQueryProvider = StateProvider<String>((ref) => '');

final residenceViewProvider = FutureProvider.autoDispose<ResidenceViewData>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  final residenceId = user?.residenceId;
  final query = ref.watch(usersSearchQueryProvider);
  final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
  final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;

  if (user == null || residenceId == null) {
    throw const UsersDataException(
      'Authenticated residence context is missing.',
    );
  }

  if (isAdmin) {
    final timer = Timer.periodic(_residenceViewRefreshInterval, (_) {
      ref.invalidateSelf();
    });
    ref.onDispose(timer.cancel);
  }

  return ref
      .read(usersRepositoryProvider)
      .fetchResidenceView(residenceId, query: query);
});

final residenceAlertsProvider =
    FutureProvider.autoDispose<ResidenceAlertViewData>((ref) async {
      final user = ref.watch(currentUserProvider);
      final residenceId = user?.residenceId;

      if (user == null || residenceId == null) {
        throw const UsersDataException(
          'Authenticated residence context is missing.',
        );
      }

      final timer = Timer.periodic(_residenceAlertsRefreshInterval, (_) {
        ref.invalidateSelf();
      });
      ref.onDispose(timer.cancel);

      return ref
          .read(usersRepositoryProvider)
          .fetchResidenceAlerts(residenceId);
    });

final pendingUsersCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
  final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;

  if (!isAdmin) {
    return const AsyncValue.data(0);
  }

  return ref
      .watch(residenceViewProvider)
      .whenData((view) => view.pendingResidentsCount);
});

final recoverableUsersProvider =
    FutureProvider.autoDispose<
      ({List<UserProfile> rejected, List<UserProfile> archived})
    >((ref) async {
      final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
      final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;

      if (!isAdmin) {
        throw const UsersDataException(
          'Admin role is required to manage archived or rejected users.',
        );
      }

      final timer = Timer.periodic(_recoverableUsersRefreshInterval, (_) {
        ref.invalidateSelf();
      });
      ref.onDispose(timer.cancel);

      final repository = ref.read(usersRepositoryProvider);
      final rejected = await repository.fetchAdminUsers(
        status: UserStatus.rejected,
      );
      final archived = await repository.fetchAdminUsers(
        status: UserStatus.archived,
      );
      return (rejected: rejected, archived: archived);
    });

class UsersDataException implements Exception {
  const UsersDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

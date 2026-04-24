import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../data/users_repository.dart';
import '../domain/users_models.dart';

enum UsersTab { residents, pending }

const Duration _residenceViewRefreshInterval = Duration(seconds: 15);

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

class UsersDataException implements Exception {
  const UsersDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

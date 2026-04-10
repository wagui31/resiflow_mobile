import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../data/users_repository.dart';
import '../domain/users_models.dart';

enum UsersTab { residents, pending }

const Duration _pendingUsersRefreshInterval = Duration(seconds: 15);

final usersTabProvider = StateProvider<UsersTab>((ref) => UsersTab.residents);

final usersSearchQueryProvider = StateProvider<String>((ref) => '');

final residenceUsersProvider = FutureProvider.autoDispose<List<ResidenceUser>>((
  ref,
) {
  ref.watch(currentUserProvider);
  return ref.read(usersRepositoryProvider).fetchResidenceUsers();
});

final pendingUsersProvider = FutureProvider.autoDispose<List<ResidenceUser>>((
  ref,
) {
  ref.watch(currentUserProvider);
  final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
  final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;

  if (isAdmin) {
    final timer = Timer.periodic(_pendingUsersRefreshInterval, (_) {
      ref.invalidateSelf();
    });
    ref.onDispose(timer.cancel);
  }

  return ref.read(usersRepositoryProvider).fetchPendingUsers();
});

final pendingUsersCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
  final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;

  if (!isAdmin) {
    return const AsyncValue.data(0);
  }

  final pendingUsersAsync = ref.watch(pendingUsersProvider);
  return pendingUsersAsync.whenData(
    (users) => users.where((user) => user.role != UserRole.superAdmin).length,
  );
});

final filteredResidenceUsersProvider =
    Provider.autoDispose<AsyncValue<List<ResidenceUser>>>((ref) {
      final query = ref.watch(usersSearchQueryProvider).trim().toLowerCase();
      final usersAsync = ref.watch(residenceUsersProvider);

      return usersAsync.whenData((users) {
        if (query.isEmpty) {
          return users;
        }
        return users
            .where((user) => user.email.trim().toLowerCase().contains(query))
            .toList();
      });
    });

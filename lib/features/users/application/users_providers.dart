import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../data/users_repository.dart';
import '../domain/users_models.dart';

enum UsersTab { residents, pending }

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
  return ref.read(usersRepositoryProvider).fetchPendingUsers();
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/auth_token_provider.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';
import '../domain/auth_session_models.dart';

final authSessionControllerProvider =
    NotifierProvider<AuthSessionController, AuthSessionState>(
      AuthSessionController.new,
    );

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authSessionControllerProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserProfile?>((ref) {
  final session = ref.watch(authSessionControllerProvider);
  return switch (session) {
    AuthenticatedSession(:final user) => user,
    _ => null,
  };
});

final currentUserRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});

final currentAccountStatusProvider = Provider<UserStatus?>((ref) {
  final session = ref.watch(authSessionControllerProvider);
  return switch (session) {
    AuthenticatedSession(:final user) => user.status,
    UnauthenticatedSession(:final accountNotice) => accountNotice?.status,
  };
});

class AuthSessionController extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() => const UnauthenticatedSession();

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);

    try {
      final loginResult = await repository.login(
        email: email,
        password: password,
      );
      ref.read(authTokenProvider.notifier).setToken(loginResult.token);

      try {
        final user = await repository.getCurrentUser();
        state = AuthenticatedSession(
          token: loginResult.token,
          user: user,
        );
        return user;
      } catch (error) {
        ref.read(authTokenProvider.notifier).clearToken();
        state = const UnauthenticatedSession();
        rethrow;
      }
    } on ApiException catch (error) {
      state = UnauthenticatedSession(
        accountNotice: _accountNoticeFromException(error),
      );
      rethrow;
    }
  }

  Future<UserProfile> register(RegisterPayload payload) async {
    final user = await ref.read(authRepositoryProvider).register(payload);

    state = switch (user.status) {
      UserStatus.pending => UnauthenticatedSession(
        accountNotice: AuthAccountNotice(
          status: user.status,
        ),
      ),
      _ => const UnauthenticatedSession(),
    };

    return user;
  }

  void clearSession() {
    ref.read(authTokenProvider.notifier).clearToken();
    state = const UnauthenticatedSession();
  }

  AuthAccountNotice? _accountNoticeFromException(ApiException error) {
    return switch (error.code) {
      ApiErrorCode.accountPending => const AuthAccountNotice(
        status: UserStatus.pending,
      ),
      ApiErrorCode.accountRejected => const AuthAccountNotice(
        status: UserStatus.rejected,
      ),
      _ => null,
    };
  }
}

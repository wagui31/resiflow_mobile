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

final currentCurrencyCodeProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.currency;
});

final currentAccountNoticeProvider = Provider<AuthAccountNotice?>((ref) {
  final session = ref.watch(authSessionControllerProvider);
  return switch (session) {
    UnauthenticatedSession(:final accountNotice) => accountNotice,
    _ => null,
  };
});

final currentAccountStatusProvider = Provider<UserStatus?>((ref) {
  final session = ref.watch(authSessionControllerProvider);
  return switch (session) {
    SessionBootstrapping() => null,
    AuthenticatedSession(:final user) => user.status,
    UnauthenticatedSession(:final accountNotice) => accountNotice?.status,
  };
});

class AuthSessionController extends Notifier<AuthSessionState> {
  bool _bootstrapStarted = false;

  @override
  AuthSessionState build() => const SessionBootstrapping();

  Future<void> bootstrap() async {
    if (_bootstrapStarted) {
      return;
    }

    _bootstrapStarted = true;

    final token = await ref
        .read(authTokenProvider.notifier)
        .readPersistedToken();
    if (token == null) {
      ref.read(authTokenProvider.notifier).restoreToken(null);
      state = const UnauthenticatedSession();
      return;
    }

    ref.read(authTokenProvider.notifier).restoreToken(token);

    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      state = AuthenticatedSession(token: token, user: user);
    } on ApiException catch (error) {
      ref.read(authTokenProvider.notifier).clearToken();
      state = UnauthenticatedSession(
        accountNotice: _accountNoticeFromException(error),
      );
    } catch (_) {
      ref.read(authTokenProvider.notifier).clearToken();
      state = const UnauthenticatedSession();
    }
  }

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
        state = AuthenticatedSession(token: loginResult.token, user: user);
        return user;
      } catch (error) {
        ref.read(authTokenProvider.notifier).clearToken();
        state = const UnauthenticatedSession();
        rethrow;
      }
    } on ApiException catch (error) {
      ref.read(authTokenProvider.notifier).clearToken();

      final accountNotice = _accountNoticeFromException(error);
      if (accountNotice != null || state is! UnauthenticatedSession) {
        state = UnauthenticatedSession(accountNotice: accountNotice);
      }

      rethrow;
    }
  }

  Future<UserProfile> register(RegisterPayload payload) async {
    final user = await ref.read(authRepositoryProvider).register(payload);

    state = switch (user.status) {
      UserStatus.pending => UnauthenticatedSession(
        accountNotice: AuthAccountNotice(status: user.status, message: null),
      ),
      _ => const UnauthenticatedSession(),
    };

    return user;
  }

  void dismissAccountNotice() {
    final session = state;
    if (session is UnauthenticatedSession && session.accountNotice != null) {
      state = const UnauthenticatedSession();
    }
  }

  void clearSession() {
    ref.read(authTokenProvider.notifier).clearToken();
    state = const UnauthenticatedSession();
  }

  Future<UserProfile?> refreshCurrentUser() async {
    final session = state;
    if (session is! AuthenticatedSession) {
      return null;
    }

    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    state = AuthenticatedSession(token: session.token, user: user);
    return user;
  }

  void setCurrentUser(UserProfile user) {
    final session = state;
    if (session is! AuthenticatedSession) {
      return;
    }
    state = AuthenticatedSession(token: session.token, user: user);
  }

  AuthAccountNotice? _accountNoticeFromException(ApiException error) {
    return switch (error.code) {
      ApiErrorCode.accountPending => AuthAccountNotice(
        status: UserStatus.pending,
        message: error.message,
      ),
      ApiErrorCode.accountRejected => AuthAccountNotice(
        status: UserStatus.rejected,
        message: error.message,
      ),
      ApiErrorCode.accountArchived => AuthAccountNotice(
        status: UserStatus.archived,
        message: error.message,
      ),
      _ => null,
    };
  }
}

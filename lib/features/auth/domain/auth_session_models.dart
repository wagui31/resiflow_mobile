import 'auth_models.dart';

sealed class AuthSessionState {
  const AuthSessionState();

  bool get isAuthenticated => this is AuthenticatedSession;
}

class UnauthenticatedSession extends AuthSessionState {
  const UnauthenticatedSession({
    this.accountNotice,
  });

  final AuthAccountNotice? accountNotice;
}

class AuthenticatedSession extends AuthSessionState {
  const AuthenticatedSession({
    required this.token,
    required this.user,
  });

  final String token;
  final UserProfile user;
}

class AuthAccountNotice {
  const AuthAccountNotice({
    required this.status,
  });

  final UserStatus status;
}

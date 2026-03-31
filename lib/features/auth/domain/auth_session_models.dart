import 'auth_models.dart';

sealed class AuthSessionState {
  const AuthSessionState();

  bool get isAuthenticated => this is AuthenticatedSession;
  bool get isBootstrapping => this is SessionBootstrapping;
}

class SessionBootstrapping extends AuthSessionState {
  const SessionBootstrapping();
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
    this.message,
  });

  final UserStatus status;
  final String? message;
}

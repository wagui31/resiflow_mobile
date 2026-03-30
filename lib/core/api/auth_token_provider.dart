import 'package:flutter_riverpod/flutter_riverpod.dart';

final authTokenProvider =
    StateNotifierProvider<AuthTokenController, String?>((ref) {
      return AuthTokenController();
    });

class AuthTokenController extends StateNotifier<String?> {
  AuthTokenController() : super(null);

  void setToken(String token) {
    final normalizedToken = token.trim();
    state = normalizedToken.isEmpty ? null : normalizedToken;
  }

  void clearToken() {
    state = null;
  }
}

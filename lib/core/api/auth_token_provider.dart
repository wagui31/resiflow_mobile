import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/auth_token_storage.dart';

final authTokenProvider = StateNotifierProvider<AuthTokenController, String?>((
  ref,
) {
  return AuthTokenController(ref.watch(authTokenStorageProvider));
});

class AuthTokenController extends StateNotifier<String?> {
  AuthTokenController(this._storage) : super(null);

  final AuthTokenStorage _storage;

  void setToken(String token) {
    state = _normalizeToken(token);
    unawaited(_storage.writeToken(state));
  }

  void restoreToken(String? token) {
    state = _normalizeToken(token);
  }

  void clearToken() {
    state = null;
    unawaited(_storage.clearToken());
  }

  Future<String?> readPersistedToken() async {
    return _normalizeToken(await _storage.readToken());
  }

  String? _normalizeToken(String? token) {
    final normalizedToken = token?.trim();
    if (normalizedToken == null || normalizedToken.isEmpty) {
      return null;
    }
    return normalizedToken;
  }
}

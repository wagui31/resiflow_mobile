import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  return const AuthTokenStorage();
});

class AuthTokenStorage {
  const AuthTokenStorage();

  static const String _authTokenKey = 'auth.token';

  Future<String?> readToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_authTokenKey);
  }

  Future<void> writeToken(String? token) async {
    final preferences = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await preferences.remove(_authTokenKey);
      return;
    }

    await preferences.setString(_authTokenKey, token);
  }

  Future<void> clearToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_authTokenKey);
  }
}

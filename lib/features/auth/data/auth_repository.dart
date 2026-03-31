import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

final publicAppConfigProvider = FutureProvider<PublicAppConfig>((ref) async {
  return ref.watch(authRepositoryProvider).fetchPublicAppConfig();
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<PublicAppConfig> fetchPublicAppConfig() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/api/public/app-config');
      return PublicAppConfig.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: <String, dynamic>{
          'email': email.trim(),
          'password': password.trim(),
        },
      );
      return LoginResult.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<UserProfile> register(RegisterPayload payload) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/register',
        data: payload.toJson(),
      );
      return UserProfile.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<UserProfile> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/users/me');
      return UserProfile.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Map<String, dynamic> _requireMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException(message: 'The server returned an empty response.');
    }
    return data;
  }
}

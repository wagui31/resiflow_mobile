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
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/public/app-config',
      );
      return PublicAppConfig.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<List<RegistrationLogementOption>> fetchRegistrationLogements(
    String residenceCode,
  ) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/public/residences/${Uri.encodeComponent(residenceCode.trim())}/logements',
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          message: 'The server returned an empty response.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(RegistrationLogementOption.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<RegistrationContext> fetchRegistrationContext(
    String residenceCode,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/public/residences/${Uri.encodeComponent(residenceCode.trim())}/registration-context',
      );
      return RegistrationContext.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<RegistrationSearchResult> searchRegistrationLogements({
    required String residenceCode,
    String? numero,
    String? immeuble,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/public/residences/${Uri.encodeComponent(residenceCode.trim())}/logements/search',
        queryParameters: <String, dynamic>{
          if ((numero ?? '').trim().isNotEmpty) 'numero': numero!.trim(),
          if ((immeuble ?? '').trim().isNotEmpty) 'immeuble': immeuble!.trim(),
        },
      );
      return RegistrationSearchResult.fromJson(_requireMap(response.data));
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

  Future<ForgotPasswordRequestCodeResult> requestPasswordResetCode({
    required String email,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/forgot-password/request-code',
        data: <String, dynamic>{'email': email.trim()},
      );
      return ForgotPasswordRequestCodeResult.fromJson(
        _requireMap(response.data),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ForgotPasswordVerifyCodeResult> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/forgot-password/verify-code',
        data: <String, dynamic>{
          'email': email.trim(),
          'code': code.trim(),
        },
      );
      return ForgotPasswordVerifyCodeResult.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> resetForgottenPassword({
    required String resetSessionToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _dio.post<void>(
        '/api/auth/forgot-password/reset-password',
        data: <String, dynamic>{
          'resetSessionToken': resetSessionToken.trim(),
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
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

  Future<void> logout({
    String? pushToken,
    String? installationId,
  }) async {
    try {
      await _dio.post<void>(
        '/api/auth/logout',
        data: <String, dynamic>{
          if (_normalizeOptional(pushToken) case final String value)
            'token': value,
          if (_normalizeOptional(installationId) case final String value)
            'installationId': value,
        },
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Map<String, dynamic> _requireMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException(
        message: 'The server returned an empty response.',
      );
    }
    return data;
  }

  String? _normalizeOptional(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}

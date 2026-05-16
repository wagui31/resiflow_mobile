import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../auth/data/auth_repository.dart';

final pushRepositoryProvider = Provider<PushRepository>((ref) {
  return PushRepository(ref.watch(dioProvider), ref.watch(authRepositoryProvider));
});

class PushRepository {
  PushRepository(this._dio, this._authRepository);

  final Dio _dio;
  final AuthRepository _authRepository;

  Future<void> upsertToken({
    required String token,
    required String platform,
    required String installationId,
    String? deviceName,
    String? appVersion,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/push-tokens',
        data: <String, dynamic>{
          'token': token.trim(),
          'platform': platform.trim(),
          'installationId': installationId.trim(),
          if (_normalizeOptional(deviceName) case final String value)
            'deviceName': value,
          if (_normalizeOptional(appVersion) case final String value)
            'appVersion': value,
        },
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> logoutCurrentDevice({
    String? token,
    String? installationId,
  }) {
    return _authRepository.logout(
      pushToken: _normalizeOptional(token),
      installationId: _normalizeOptional(installationId),
    );
  }

  String? _normalizeOptional(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}

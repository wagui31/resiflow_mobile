import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/residence_models.dart';

final residenceRepositoryProvider = Provider<ResidenceRepository>((ref) {
  return ResidenceRepository(ref.watch(dioProvider));
});

class ResidenceRepository {
  const ResidenceRepository(this._dio);

  final Dio _dio;

  Future<ResidenceAdminSettings> fetchAdminSettings(int residenceId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/residences/$residenceId',
      );
      return ResidenceAdminSettings.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ResidenceAdminSettings> updateAdminSettings(
    int residenceId,
    UpdateResidenceAdminSettingsPayload payload,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/residences/$residenceId/admin-settings',
        data: payload.toJson(),
      );
      return ResidenceAdminSettings.fromJson(_requireMap(response.data));
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
}

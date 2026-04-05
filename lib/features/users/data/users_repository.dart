import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../auth/domain/auth_models.dart';
import '../domain/users_models.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.watch(dioProvider));
});

class UsersRepository {
  const UsersRepository(this._dio);

  final Dio _dio;

  Future<List<ResidenceUser>> fetchResidenceUsers() async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/users/residence');
      return _requireList(response.data).map(ResidenceUser.fromJson).toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<List<ResidenceUser>> fetchPendingUsers() async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/admin/users/pending');
      return _requireList(response.data).map(ResidenceUser.fromJson).toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<UserProfile> updateCurrentUser(UpdateCurrentUserPayload payload) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/users/me',
        data: payload.toJson(),
      );
      return UserProfile.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ResidenceUser> updateResidenceEntryDate(
    int userId,
    UpdateResidenceEntryDatePayload payload,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/admin/users/$userId/date-entree-residence',
        data: payload.toJson(),
      );
      return ResidenceUser.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ResidenceUser> updateUserRole(
    int userId,
    UpdateUserRolePayload payload,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/admin/users/$userId/role',
        data: payload.toJson(),
      );
      return ResidenceUser.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ResidenceUser> approveUser(int userId, {String? comment}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/admin/users/$userId/approve',
        data: _buildActionBody(comment),
      );
      return ResidenceUser.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ResidenceUser> rejectUser(int userId, {String? comment}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/admin/users/$userId/reject',
        data: _buildActionBody(comment),
      );
      return ResidenceUser.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete<void>('/api/admin/users/$userId');
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Map<String, dynamic>? _buildActionBody(String? comment) {
    final normalized = comment?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return <String, dynamic>{'comment': normalized};
  }

  Map<String, dynamic> _requireMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException(
        message: 'The server returned an empty response.',
      );
    }
    return data;
  }

  List<Map<String, dynamic>> _requireList(List<dynamic>? data) {
    if (data == null) {
      throw const ApiException(
        message: 'The server returned an empty response.',
      );
    }
    return data.whereType<Map<String, dynamic>>().toList();
  }
}

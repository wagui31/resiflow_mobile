import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/notification_models.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(dioProvider));
});

class NotificationRepository {
  const NotificationRepository(this._dio);

  final Dio _dio;

  Future<List<AppNotificationItem>> fetchNotifications({
    bool unreadOnly = false,
    List<AppNotificationType> types = const <AppNotificationType>[],
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/notifications',
        queryParameters: <String, dynamic>{
          'unreadOnly': unreadOnly,
          'limit': limit,
          if (types.isNotEmpty)
            'types': types.map((type) => type.apiValue).toList(),
        },
      );
      final data = response.data ?? const <dynamic>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(AppNotificationItem.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<int> fetchUnreadCount({
    List<AppNotificationType> types = const <AppNotificationType>[],
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/notifications/unread-count',
        queryParameters: <String, dynamic>{
          if (types.isNotEmpty)
            'types': types.map((type) => type.apiValue).toList(),
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          message: 'The server returned an empty response.',
        );
      }
      return AppUnreadNotificationCount.fromJson(data).count;
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<AppNotificationItem> markAsRead(int notificationId) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/notifications/$notificationId/read',
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          message: 'The server returned an empty response.',
        );
      }
      return AppNotificationItem.fromJson(data);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> markAllAsRead({
    List<AppNotificationType> types = const <AppNotificationType>[],
  }) async {
    try {
      await _dio.put<void>(
        '/api/notifications/read-all',
        queryParameters: <String, dynamic>{
          if (types.isNotEmpty)
            'types': types.map((type) => type.apiValue).toList(),
        },
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}

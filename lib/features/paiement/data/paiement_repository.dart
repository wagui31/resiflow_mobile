import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/paiement_models.dart';

final paiementRepositoryProvider = Provider<PaiementRepository>((ref) {
  return PaiementRepository(ref.watch(dioProvider));
});

class PaiementRepository {
  const PaiementRepository(this._dio);

  final Dio _dio;

  Future<ResidentPaymentOverview> fetchMyPaymentStatus() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/paiements/me/status',
      );
      return ResidentPaymentOverview.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ResidentPaymentOverview> fetchAdminUserPaymentStatus(
    String email,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/paiements/admin/user/status',
        queryParameters: <String, dynamic>{'email': email.trim()},
      );
      return ResidentPaymentOverview.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<PaymentRecord> createMyPayment(CreateMyPaymentPayload payload) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/paiements/me',
        data: payload.toJson(),
      );
      return PaymentRecord.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<List<PaymentRecord>> fetchAdminPendingPayments() async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/paiements/admin/pending');
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          message: 'The server returned an empty response.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(PaymentRecord.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<PaymentRecord> validatePayment(int paymentId) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/paiements/$paymentId/validate',
      );
      return PaymentRecord.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<PaymentRecord> rejectPayment(int paymentId) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/paiements/$paymentId/reject',
      );
      return PaymentRecord.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> deletePendingPayment(int paymentId) async {
    try {
      await _dio.delete<void>('/api/paiements/$paymentId');
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

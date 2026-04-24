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
    int logementId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/paiements/admin/logement/$logementId/status',
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

  Future<PaymentRecord> createAdminLogementPayment({
    required int residenceId,
    required int logementId,
    required CreateMyPaymentPayload payload,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/paiements',
        data: <String, dynamic>{
          'residenceId': residenceId,
          'logementId': logementId,
          ...payload.toJson(),
        },
      );
      return PaymentRecord.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<List<PaymentLogementOption>> fetchResidenceLogements(
    int residenceId,
  ) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/logements/residence/$residenceId',
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          message: 'The server returned an empty response.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(PaymentLogementOption.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  @Deprecated('Use createAdminLogementPayment instead.')
  Future<PaymentRecord> createAdminUserPayment(
    String email,
    CreateMyPaymentPayload payload,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/paiements/admin/user',
        queryParameters: <String, dynamic>{'email': email.trim()},
        data: payload.toJson(),
      );
      return PaymentRecord.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<List<PaymentRecord>> fetchAdminPendingPayments() async {
    final candidatePaths = <String>[
      '/api/paiements/admin/pending',
      '/api/paiements/pending/admin',
      '/api/paiements/pending',
    ];

    DioException? lastRecoverableError;
    for (final path in candidatePaths) {
      try {
        final response = await _dio.get<dynamic>(path);
        final data = _extractList(response.data, const <String>[
          'paiements',
          'payments',
          'data',
          'items',
          'content',
        ]);
        if (data == null) {
          throw const ApiException(
            message: 'The server returned an empty response.',
          );
        }

        return data
            .whereType<Map<String, dynamic>>()
            .map(PaymentRecord.fromJson)
            .where(
              (payment) => payment.status.trim().toUpperCase() == 'PENDING',
            )
            .toList();
      } on DioException catch (error) {
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403 || statusCode == 404) {
          lastRecoverableError = error;
          continue;
        }
        throw ApiException.fromDioException(error);
      }
    }

    if (lastRecoverableError != null) {
      throw ApiException.fromDioException(lastRecoverableError);
    }

    throw const ApiException(message: 'Unable to load the pending payments.');
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

  List<dynamic>? _extractList(Object? data, List<String> candidateKeys) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      for (final key in candidateKeys) {
        final value = data[key];
        if (value is List) {
          return value;
        }
      }
    }

    return null;
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/depense_models.dart';

final depenseRepositoryProvider = Provider<DepenseRepository>((ref) {
  return DepenseRepository(ref.watch(dioProvider));
});

class DepenseRepository {
  const DepenseRepository(this._dio);

  final Dio _dio;

  Future<List<ExpenseRecord>> fetchApprovedCagnotteExpensesByResidence(
    int residenceId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/depenses/residence/$residenceId/cagnotte/approuvees',
      );
      final data = _extractList(response.data, <String>[
        'depenses',
        'expenses',
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
          .map(ExpenseRecord.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<List<SharedExpenseRecord>> fetchApprovedSharedExpensesByResidence(
    int residenceId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/depenses/residence/$residenceId/partagees/approuvees',
      );
      final data = _extractList(response.data, <String>[
        'depenses',
        'expenses',
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
          .map(SharedExpenseRecord.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<List<ExpenseRecord>> fetchPendingExpensesByResidence(
    int residenceId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/depenses/residence/$residenceId',
      );
      final data = _extractList(response.data, <String>[
        'depenses',
        'expenses',
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
          .map(ExpenseRecord.fromJson)
          .where((expense) => expense.status == ExpenseStatus.enAttente)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ResidenceFundBalance> fetchResidenceBalance(int residenceId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/cagnotte/$residenceId/solde',
      );
      return ResidenceFundBalance.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ResidenceParticipantsCount> fetchResidenceParticipantsCount(
    int residenceId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/residences/$residenceId/logements-participants-actifs',
      );
      return ResidenceParticipantsCount.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<List<ExpenseCategory>> fetchExpenseCategories() async {
    try {
      final response = await _dio.get<dynamic>('/api/categories-depenses');
      final data = _extractList(response.data, <String>[
        'categories',
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
          .map(ExpenseCategory.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ExpenseRecord> createCagnotteExpense({
    required int residenceId,
    required int categoryId,
    required double amount,
    required String description,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/depenses',
        data: <String, dynamic>{
          'residenceId': residenceId,
          'categorieId': categoryId,
          'montant': amount,
          'typeDepense': 'CAGNOTTE',
          'description': description.trim(),
        },
      );
      return ExpenseRecord.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<ExpenseRecord> createSharedExpense({
    required int residenceId,
    required double amount,
    required String description,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/depenses',
        data: <String, dynamic>{
          'residenceId': residenceId,
          'montant': amount,
          'typeDepense': 'PARTAGE',
          'description': description.trim(),
        },
      );
      return ExpenseRecord.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> paySharedExpense({
    required int expenseId,
    required double amount,
  }) async {
    final candidatePaths = <String>[
      '/api/depenses/$expenseId/paiements/me',
      '/api/depenses/$expenseId/payer',
      '/api/depenses/partagees/$expenseId/payer',
    ];

    DioException? lastNotFoundError;
    for (final path in candidatePaths) {
      try {
        await _dio.post<void>(path, data: <String, dynamic>{'montant': amount});
        return;
      } on DioException catch (error) {
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          lastNotFoundError = error;
          continue;
        }
        throw ApiException.fromDioException(error);
      }
    }

    if (lastNotFoundError != null) {
      throw ApiException.fromDioException(lastNotFoundError);
    }

    throw const ApiException(
      message: 'Unable to create the shared expense payment.',
    );
  }

  Future<List<SharedExpensePaymentRecord>>
  fetchAdminPendingSharedExpensePayments() async {
    final candidatePaths = <String>[
      '/api/depenses/paiements/admin/pending',
      '/api/depenses/shared-payments/admin/pending',
      '/api/depenses/admin/paiements/pending',
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
            .map(SharedExpensePaymentRecord.fromJson)
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

    throw const ApiException(
      message: 'Unable to load the pending shared expense payments.',
    );
  }

  Future<void> validateSharedExpensePayment(int paymentId) async {
    await _executeSharedExpensePaymentAdminAction(
      paymentId: paymentId,
      candidatePaths: <String>[
        '/api/depenses/paiements/$paymentId/validate',
        '/api/depenses/shared-payments/$paymentId/validate',
      ],
    );
  }

  Future<void> rejectSharedExpensePayment(int paymentId) async {
    await _executeSharedExpensePaymentAdminAction(
      paymentId: paymentId,
      candidatePaths: <String>[
        '/api/depenses/paiements/$paymentId/reject',
        '/api/depenses/shared-payments/$paymentId/reject',
      ],
    );
  }

  Future<void> approveExpense(int expenseId) async {
    await _executeExpenseAdminAction(
      path: '/api/depenses/$expenseId/approuver',
      message: 'Unable to approve the expense #$expenseId.',
    );
  }

  Future<void> rejectExpense(int expenseId) async {
    await _executeExpenseAdminAction(
      path: '/api/depenses/$expenseId/rejeter',
      message: 'Unable to reject the expense #$expenseId.',
    );
  }

  Future<void> deleteSharedExpense(int expenseId) async {
    try {
      await _dio.delete<void>('/api/depenses/$expenseId');
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    } catch (_) {
      throw ApiException(
        message: 'Unable to delete the shared expense #$expenseId.',
      );
    }
  }

  Future<void> cancelSharedExpenseHousingPayments({
    required int expenseId,
    required int logementId,
  }) async {
    try {
      await _dio.delete<void>(
        '/api/depenses/$expenseId/logements/$logementId/paiements',
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    } catch (_) {
      throw ApiException(
        message:
            'Unable to cancel the shared expense payments for housing #$logementId.',
      );
    }
  }

  Future<void> _executeExpenseAdminAction({
    required String path,
    required String message,
  }) async {
    try {
      await _dio.post<void>(path);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    } catch (_) {
      throw ApiException(message: message);
    }
  }

  Future<void> _executeSharedExpensePaymentAdminAction({
    required int paymentId,
    required List<String> candidatePaths,
  }) async {
    DioException? lastNotFoundError;
    for (final path in candidatePaths) {
      try {
        await _dio.put<void>(path);
        return;
      } on DioException catch (error) {
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          lastNotFoundError = error;
          continue;
        }
        throw ApiException.fromDioException(error);
      }
    }

    if (lastNotFoundError != null) {
      throw ApiException.fromDioException(lastNotFoundError);
    }

    throw ApiException(
      message: 'Unable to update the shared expense payment #$paymentId.',
    );
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

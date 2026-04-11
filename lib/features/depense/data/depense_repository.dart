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
        '/api/residences/$residenceId/participants-actifs',
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

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/cagnotte_models.dart';

final cagnotteRepositoryProvider = Provider<CagnotteRepository>((ref) {
  return CagnotteRepository(ref.watch(dioProvider));
});

class CagnotteRepository {
  const CagnotteRepository(this._dio);

  final Dio _dio;

  Future<CreateResidenceFundCorrectionResult> createCorrection({
    required int residenceId,
    required double nouveauSolde,
    required String motif,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/cagnotte/$residenceId/corrections',
        data: <String, dynamic>{
          'nouveauSolde': nouveauSolde,
          'motif': motif.trim(),
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          message: 'The server returned an empty response.',
        );
      }
      return CreateResidenceFundCorrectionResult.fromJson(data);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<List<ResidenceFundTransaction>> fetchTransactions(
    int residenceId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/cagnotte/$residenceId/transactions',
      );
      final data = response.data;
      if (data is! List) {
        throw const ApiException(
          message: 'The server returned an empty response.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(ResidenceFundTransaction.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}

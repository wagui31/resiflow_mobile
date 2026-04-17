import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/vote_models.dart';

final voteRepositoryProvider = Provider<VoteRepository>((ref) {
  return VoteRepository(ref.watch(dioProvider));
});

class VoteRepository {
  const VoteRepository(this._dio);

  final Dio _dio;

  Future<List<VoteOverview>> fetchResidenceVoteOverviews(
    int residenceId,
  ) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/votes/residence/$residenceId/overview',
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          message: 'The server returned an empty response.',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(VoteOverview.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<VoteOverview> createVote(CreateVotePayload payload) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/votes',
        data: payload.toJson(),
      );
      return fetchVoteOverviewFromCreatedPayload(payload.residenceId);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> submitVote({
    required int voteId,
    required VoteChoice choice,
    String? comment,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/votes/$voteId/voter',
        data: VoteActionPayload(choice: choice, comment: comment).toJson(),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> closeVote(int voteId) async {
    try {
      await _dio.post<Map<String, dynamic>>('/api/votes/$voteId/cloturer');
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> createExpenseFromVote(int voteId) async {
    try {
      await _dio.post<Map<String, dynamic>>('/api/votes/$voteId/creer-depense');
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<VoteOverview> fetchVoteOverview(int voteId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/votes/$voteId/overview',
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          message: 'The server returned an empty response.',
        );
      }
      return VoteOverview.fromJson(data);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<VoteDetails> fetchVoteDetails(int voteId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/votes/$voteId/details',
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          message: 'The server returned an empty response.',
        );
      }
      return VoteDetails.fromJson(data);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<VoteOverview> fetchVoteOverviewFromCreatedPayload(
    int residenceId,
  ) async {
    final overviews = await fetchResidenceVoteOverviews(residenceId);
    if (overviews.isEmpty) {
      throw const ApiException(
        message: 'The created vote could not be loaded from the server.',
      );
    }
    return overviews.first;
  }
}

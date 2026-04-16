import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/api_client.dart';
import '../domain/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioProvider));
});

class DashboardRepository {
  const DashboardRepository(this._dio);

  final Dio _dio;

  Future<DashboardOverview> fetchOverview(int residenceId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/residences/$residenceId/dashboard',
      );
      return DashboardOverview.fromJson(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<DashboardStats> fetchStats(int residenceId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/residences/$residenceId/stats',
      );
      return _parseStats(_requireMap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<DashboardPaymentHousingStats> fetchPaymentHousingStats(
    int residenceId,
  ) async {
    try {
      final statsResponse = await _dio.get<Map<String, dynamic>>(
        '/api/residences/$residenceId/stats/paiements-logements',
      );
      final statsJson = _requireMap(statsResponse.data);

      try {
        final logementsResponse = await _dio.get<List<dynamic>>(
          '/api/logements/residence/$residenceId',
        );
        final logements = logementsResponse.data;
        if (logements != null) {
          statsJson['totalLogementsInactifs'] = logements
              .whereType<Map<String, dynamic>>()
              .where((logement) => logement['active'] != true)
              .length;
        }
      } on DioException {
        statsJson['totalLogementsInactifs'] = 0;
      }

      return DashboardPaymentHousingStats.fromJson(statsJson);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<DashboardExpenseCategoryStats> fetchExpenseCategoryStats(
    int residenceId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/residences/$residenceId/stats/depenses-par-categorie',
      );
      return DashboardExpenseCategoryStats.fromJson(_requireMap(response.data));
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

  DashboardStats _parseStats(Map<String, dynamic> json) {
    return DashboardStats(
      totalContributions: _readDouble(json['totalContributions']),
      totalExpenses: _readDouble(json['totalDepenses']),
      currentBalance: _readDouble(json['soldeActuel']),
      topPayers: (json['topPayeurs'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DashboardTopPayer.fromJson)
          .toList(),
      balanceEvolution:
          (json['evolutionCagnotte'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(DashboardBalancePoint.fromJson)
              .toList(),
      paymentHousingStats: const DashboardPaymentHousingStats(
        residenceId: 0,
        totalActiveHousing: 0,
        totalInactiveHousing: 0,
        upToDateHousing: 0,
        lateHousing: 0,
      ),
      expenseCategoryStats: const DashboardExpenseCategoryStats(
        residenceId: 0,
        categories: <DashboardExpenseCategoryCount>[],
      ),
    );
  }

  double _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}

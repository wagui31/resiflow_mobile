class DashboardOverview {
  const DashboardOverview({
    required this.balance,
    required this.residentCount,
    required this.lateResidentCount,
    required this.monthlyExpenses,
    required this.recentVotes,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      balance: _readDouble(json['soldeCagnotte']),
      residentCount: json['nombreResidents'] as int? ?? 0,
      lateResidentCount: json['nombreEnRetard'] as int? ?? 0,
      monthlyExpenses: _readDouble(json['depensesDuMois']),
      recentVotes: (json['derniersVotes'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DashboardVote.fromJson)
          .toList(),
    );
  }

  final double balance;
  final int residentCount;
  final int lateResidentCount;
  final double monthlyExpenses;
  final List<DashboardVote> recentVotes;
}

class DashboardStats {
  const DashboardStats({
    required this.totalContributions,
    required this.totalExpenses,
    required this.currentBalance,
    required this.topPayers,
    required this.balanceEvolution,
    required this.paymentHousingStats,
    required this.expenseCategoryStats,
  });

  final double totalContributions;
  final double totalExpenses;
  final double currentBalance;
  final List<DashboardTopPayer> topPayers;
  final List<DashboardBalancePoint> balanceEvolution;
  final DashboardPaymentHousingStats paymentHousingStats;
  final DashboardExpenseCategoryStats expenseCategoryStats;
}

class DashboardPaymentHousingStats {
  const DashboardPaymentHousingStats({
    required this.residenceId,
    required this.totalActiveHousing,
    required this.totalInactiveHousing,
    required this.upToDateHousing,
    required this.lateHousing,
  });

  factory DashboardPaymentHousingStats.fromJson(Map<String, dynamic> json) {
    return DashboardPaymentHousingStats(
      residenceId: json['residenceId'] as int? ?? 0,
      totalActiveHousing: json['totalLogementsActifs'] as int? ?? 0,
      totalInactiveHousing: json['totalLogementsInactifs'] as int? ?? 0,
      upToDateHousing: json['logementsAJour'] as int? ?? 0,
      lateHousing: json['logementsEnRetard'] as int? ?? 0,
    );
  }

  final int residenceId;
  final int totalActiveHousing;
  final int totalInactiveHousing;
  final int upToDateHousing;
  final int lateHousing;
}

class DashboardExpenseCategoryStats {
  const DashboardExpenseCategoryStats({
    required this.residenceId,
    required this.categories,
  });

  factory DashboardExpenseCategoryStats.fromJson(Map<String, dynamic> json) {
    return DashboardExpenseCategoryStats(
      residenceId: json['residenceId'] as int? ?? 0,
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DashboardExpenseCategoryCount.fromJson)
          .toList(),
    );
  }

  final int residenceId;
  final List<DashboardExpenseCategoryCount> categories;
}

class DashboardExpenseCategoryCount {
  const DashboardExpenseCategoryCount({
    required this.categoryId,
    required this.categoryName,
    required this.expenseCount,
  });

  factory DashboardExpenseCategoryCount.fromJson(Map<String, dynamic> json) {
    return DashboardExpenseCategoryCount(
      categoryId: json['categorieId'] as int?,
      categoryName: (json['categorieNom'] as String?)?.trim().isNotEmpty == true
          ? (json['categorieNom'] as String).trim()
          : 'Sans categorie',
      expenseCount: json['nombreDepenses'] as int? ?? 0,
    );
  }

  final int? categoryId;
  final String categoryName;
  final int expenseCount;
}

class DashboardTopPayer {
  const DashboardTopPayer({
    required this.logementId,
    required this.label,
    required this.totalPaid,
  });

  factory DashboardTopPayer.fromJson(Map<String, dynamic> json) {
    return DashboardTopPayer(
      logementId:
          json['logementId'] as int? ?? json['userId'] as int? ?? 0,
      label:
          (json['label'] as String?)?.trim() ??
          (json['email'] as String?)?.trim() ??
          '',
      totalPaid: _readDouble(json['totalPaye']),
    );
  }

  final int logementId;
  final String label;
  final double totalPaid;
}

class DashboardBalancePoint {
  const DashboardBalancePoint({required this.month, required this.balance});

  factory DashboardBalancePoint.fromJson(Map<String, dynamic> json) {
    return DashboardBalancePoint(
      month: json['mois'] as String? ?? '',
      balance: _readDouble(json['solde']),
    );
  }

  final String month;
  final double balance;
}

class DashboardVote {
  const DashboardVote({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedAmount,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory DashboardVote.fromJson(Map<String, dynamic> json) {
    return DashboardVote(
      id: json['id'] as int? ?? 0,
      title: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      estimatedAmount: _readDouble(json['montantEstime']),
      status: json['statut'] as String? ?? '',
      startDate: DateTime.tryParse(json['dateDebut'] as String? ?? ''),
      endDate: DateTime.tryParse(json['dateFin'] as String? ?? ''),
    );
  }

  final int id;
  final String title;
  final String description;
  final double estimatedAmount;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
}

class DashboardSnapshot {
  const DashboardSnapshot({required this.overview, required this.stats});

  final DashboardOverview overview;
  final DashboardStats stats;
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

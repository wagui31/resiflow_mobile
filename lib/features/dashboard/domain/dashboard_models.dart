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
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
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
    );
  }

  final double totalContributions;
  final double totalExpenses;
  final double currentBalance;
  final List<DashboardTopPayer> topPayers;
  final List<DashboardBalancePoint> balanceEvolution;
}

class DashboardTopPayer {
  const DashboardTopPayer({
    required this.userId,
    required this.email,
    required this.totalPaid,
  });

  factory DashboardTopPayer.fromJson(Map<String, dynamic> json) {
    return DashboardTopPayer(
      userId: json['userId'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      totalPaid: _readDouble(json['totalPaye']),
    );
  }

  final int userId;
  final String email;
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

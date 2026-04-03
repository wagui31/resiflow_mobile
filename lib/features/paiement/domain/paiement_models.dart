enum ResidentPaymentStatus {
  overdue,
  upToDate,
  unknown;

  factory ResidentPaymentStatus.fromApi(String? value) {
    return switch (value) {
      'OVERDUE' => ResidentPaymentStatus.overdue,
      'UP_TO_DATE' => ResidentPaymentStatus.upToDate,
      _ => ResidentPaymentStatus.unknown,
    };
  }
}

class ResidentPaymentOverview {
  const ResidentPaymentOverview({
    required this.status,
    required this.dateFin,
    required this.nextDueWarning,
    required this.pendingPayment,
    required this.months,
    required this.history,
  });

  factory ResidentPaymentOverview.fromJson(Map<String, dynamic> json) {
    return ResidentPaymentOverview(
      status: ResidentPaymentStatus.fromApi(json['status'] as String?),
      dateFin: _parseDate(json['dateFin'] as String?),
      nextDueWarning: json['nextDueWarning'] == true,
      pendingPayment: _parseNested(
        json['pendingPayment'],
        PendingPayment.fromJson,
      ),
      months: _parseList(json['months'], PaymentMonthItem.fromJson),
      history: _parseList(json['history'], PaymentHistoryItem.fromJson),
    );
  }

  final ResidentPaymentStatus status;
  final DateTime? dateFin;
  final bool nextDueWarning;
  final PendingPayment? pendingPayment;
  final List<PaymentMonthItem> months;
  final List<PaymentHistoryItem> history;
}

class PendingPayment {
  const PendingPayment({
    required this.id,
    required this.amount,
    required this.months,
  });

  factory PendingPayment.fromJson(Map<String, dynamic> json) {
    return PendingPayment(
      id: json['id'] as int? ?? 0,
      amount: _parseAmount(json['amount']),
      months: json['months'] as int? ?? 0,
    );
  }

  final int id;
  final double amount;
  final int months;
}

class PaymentMonthItem {
  const PaymentMonthItem({required this.month, required this.paid});

  factory PaymentMonthItem.fromJson(Map<String, dynamic> json) {
    return PaymentMonthItem(
      month: json['month'] as String? ?? '',
      paid: json['paid'] == true,
    );
  }

  final String month;
  final bool paid;
}

class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.date,
    required this.amount,
    required this.period,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      date: _parseDate(json['date'] as String?),
      amount: _parseAmount(json['amount']),
      period: json['period'] as String? ?? '',
    );
  }

  final DateTime? date;
  final double amount;
  final String period;
}

class CreateMyPaymentPayload {
  const CreateMyPaymentPayload({
    required this.startMonth,
    required this.monthCount,
  });

  final DateTime startMonth;
  final int monthCount;

  Map<String, dynamic> toJson() {
    final normalizedStartMonth = DateTime(startMonth.year, startMonth.month, 1);

    return <String, dynamic>{
      'nombreMois': monthCount,
      'dateDebut': normalizedStartMonth.toIso8601String().split('T').first,
    };
  }
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.residenceId,
    required this.monthCount,
    required this.monthlyAmount,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    required this.paymentDate,
    required this.createdById,
    required this.status,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as int? ?? 0,
      userId: json['utilisateurId'] as int? ?? 0,
      userEmail: json['utilisateurEmail'] as String? ?? '',
      residenceId: json['residenceId'] as int? ?? 0,
      monthCount: json['nombreMois'] as int? ?? 0,
      monthlyAmount: _parseAmount(json['montantMensuel']),
      totalAmount: _parseAmount(json['montantTotal']),
      startDate: _parseDate(json['dateDebut'] as String?),
      endDate: _parseDate(json['dateFin'] as String?),
      paymentDate: _parseDateTime(json['datePaiement'] as String?),
      createdById: json['creeParId'] as int? ?? 0,
      status: json['status'] as String? ?? '',
    );
  }

  final int id;
  final int userId;
  final String userEmail;
  final int residenceId;
  final int monthCount;
  final double monthlyAmount;
  final double totalAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? paymentDate;
  final int createdById;
  final String status;
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}

double _parseAmount(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

T? _parseNested<T>(
  Object? value,
  T Function(Map<String, dynamic> json) parser,
) {
  if (value is Map<String, dynamic>) {
    return parser(value);
  }
  return null;
}

List<T> _parseList<T>(
  Object? value,
  T Function(Map<String, dynamic> json) parser,
) {
  if (value is! List) {
    return <T>[];
  }

  return value.whereType<Map<String, dynamic>>().map(parser).toList();
}

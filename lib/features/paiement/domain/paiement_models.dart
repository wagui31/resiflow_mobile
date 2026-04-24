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
    required this.startDate,
    required this.endDate,
  });

  factory PendingPayment.fromJson(Map<String, dynamic> json) {
    return PendingPayment(
      id: json['id'] as int? ?? 0,
      amount: _parseAmount(json['amount']),
      months: json['months'] as int? ?? 0,
      startDate: _parseDate(json['dateDebut'] as String?),
      endDate: _parseDate(json['dateFin'] as String?),
    );
  }

  final int id;
  final double amount;
  final int months;
  final DateTime? startDate;
  final DateTime? endDate;
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

class PaymentLogementOption {
  const PaymentLogementOption({
    required this.id,
    required this.residenceId,
    required this.typeLogement,
    required this.numero,
    required this.immeuble,
    required this.etage,
    required this.codeInterne,
    required this.active,
  });

  factory PaymentLogementOption.fromJson(Map<String, dynamic> json) {
    return PaymentLogementOption(
      id: _readInt(json, <String>['id', 'logementId']),
      residenceId: _readInt(json, <String>['residenceId']),
      typeLogement: (json['typeLogement'] as String?)?.trim(),
      numero: (json['numero'] as String?)?.trim(),
      immeuble: (json['immeuble'] as String?)?.trim(),
      etage: (json['etage'] as String?)?.trim(),
      codeInterne: (json['codeInterne'] as String?)?.trim() ?? '',
      active: json['active'] == true,
    );
  }

  final int id;
  final int residenceId;
  final String? typeLogement;
  final String? numero;
  final String? immeuble;
  final String? etage;
  final String codeInterne;
  final bool active;

  String get selectorLabel {
    final code = codeInterne.trim();
    if (code.isNotEmpty) {
      return code;
    }
    return displayLabel;
  }

  String get consultationLabel {
    final code = codeInterne.trim();
    if (code.isNotEmpty) {
      return code;
    }
    return displayLabel;
  }

  String get displayLabel {
    final parts = <String>[
      if ((immeuble ?? '').trim().isNotEmpty) immeuble!.trim(),
      if ((numero ?? '').trim().isNotEmpty) numero!.trim(),
    ];
    if (parts.isNotEmpty) {
      return parts.join(' - ');
    }
    return codeInterne;
  }

  String get housingDescriptionLabel {
    final normalizedType = (typeLogement ?? '').trim().toUpperCase();
    final normalizedNumero = (numero ?? '').trim();
    final normalizedImmeuble = (immeuble ?? '').trim();
    final normalizedEtage = (etage ?? '').trim();

    if (normalizedType == 'MAISON') {
      return normalizedNumero.isNotEmpty
          ? 'MAISON - $normalizedNumero'
          : 'MAISON';
    }

    if (normalizedType == 'APPARTEMENT') {
      final parts = <String>[
        'APPARTEMENT',
        if (normalizedImmeuble.isNotEmpty) normalizedImmeuble,
        if (normalizedEtage.isNotEmpty) normalizedEtage,
        if (normalizedNumero.isNotEmpty) normalizedNumero,
      ];
      return parts.join(' - ');
    }

    final parts = <String>[
      if ((typeLogement ?? '').trim().isNotEmpty) typeLogement!.trim(),
      if (normalizedImmeuble.isNotEmpty) normalizedImmeuble,
      if (normalizedEtage.isNotEmpty) normalizedEtage,
      if (normalizedNumero.isNotEmpty) normalizedNumero,
    ];
    return parts.join(' - ');
  }

  String get supportingLabel {
    final parts = <String>[
      if ((typeLogement ?? '').trim().isNotEmpty) typeLogement!.trim(),
      if ((etage ?? '').trim().isNotEmpty) etage!.trim(),
      if (codeInterne.trim().isNotEmpty) codeInterne.trim(),
    ];
    return parts.join(' • ');
  }
}

class PaymentLogementSummary {
  const PaymentLogementSummary({
    required this.logementId,
    required this.numero,
    required this.immeuble,
    required this.typeLogement,
    required this.codeInterne,
    required this.active,
  });

  factory PaymentLogementSummary.fromJson(Map<String, dynamic> json) {
    return PaymentLogementSummary(
      logementId: _readInt(json, <String>['logementId', 'id']),
      numero: (json['numero'] as String?)?.trim(),
      immeuble: (json['immeuble'] as String?)?.trim(),
      typeLogement: (json['typeLogement'] as String?)?.trim(),
      codeInterne: (json['codeInterne'] as String?)?.trim() ?? '',
      active: json['active'] == true,
    );
  }

  final int logementId;
  final String? numero;
  final String? immeuble;
  final String? typeLogement;
  final String codeInterne;
  final bool active;

  String get displayLabel {
    final parts = <String>[
      if ((immeuble ?? '').trim().isNotEmpty) immeuble!.trim(),
      if ((numero ?? '').trim().isNotEmpty) numero!.trim(),
    ];
    return parts.isEmpty ? '$logementId' : parts.join(' - ');
  }

  String get adminLabel {
    final code = codeInterne.trim();
    if (code.isNotEmpty) {
      return code;
    }
    return displayLabel;
  }
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.logementId,
    required this.logement,
    required this.residenceId,
    required this.monthCount,
    required this.monthlyAmount,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    required this.paymentDate,
    required this.createdById,
    required this.createdByName,
    required this.status,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    final logementJson = json['logement'];
    final createdByJson = _readFirst(json, <String>[
      'creePar',
      'cree_par',
      'createdBy',
      'demandePar',
      'demande_par',
      'requestedBy',
      'requested_by',
    ]);
    return PaymentRecord(
      id: json['id'] as int? ?? 0,
      logementId: _readInt(json, <String>['logementId', 'utilisateurId']),
      logement: logementJson is Map<String, dynamic>
          ? PaymentLogementSummary.fromJson(logementJson)
          : null,
      residenceId: json['residenceId'] as int? ?? 0,
      monthCount: json['nombreMois'] as int? ?? 0,
      monthlyAmount: _parseAmount(json['montantMensuel']),
      totalAmount: _parseAmount(json['montantTotal']),
      startDate: _parseDate(json['dateDebut'] as String?),
      endDate: _parseDate(json['dateFin'] as String?),
      paymentDate: _parseDateTime(json['datePaiement'] as String?),
      createdById: _readInt(json, <String>[
        'creeParId',
        'cree_par_id',
        'createdById',
        'requested_by_id',
      ]),
      createdByName: _resolvePaymentRequesterName(json, createdByJson),
      status: json['status'] as String? ?? '',
    );
  }

  final int id;
  final int logementId;
  final PaymentLogementSummary? logement;
  final int residenceId;
  final int monthCount;
  final double monthlyAmount;
  final double totalAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? paymentDate;
  final int createdById;
  final String createdByName;
  final String status;

  String get logementLabel => logement?.displayLabel ?? '$logementId';

  String get adminLogementLabel => logement?.adminLabel ?? logementLabel;
}

String _resolvePaymentRequesterName(
  Map<String, dynamic> json,
  Object? createdByJson,
) {
  final directName =
      (_readFirst(json, <String>[
                'creeParNomComplet',
                'cree_par_nom_complet',
                'createdByName',
                'created_by_name',
                'requestedByName',
                'requested_by_name',
                'fullName',
                'nomComplet',
                'nom_complet',
              ])
              as String?)
          ?.trim();
  if (directName != null && directName.isNotEmpty) {
    return directName;
  }

  if (createdByJson is Map<String, dynamic>) {
    final nestedFullName =
        (_readFirst(createdByJson, <String>[
                  'fullName',
                  'full_name',
                  'nomComplet',
                  'nom_complet',
                  'displayName',
                  'display_name',
                  'name',
                  'nom',
                ])
                as String?)
            ?.trim();
    if (nestedFullName != null && nestedFullName.isNotEmpty) {
      return nestedFullName;
    }

    final firstName =
        (_readFirst(createdByJson, <String>[
                  'firstName',
                  'first_name',
                  'prenom',
                ])
                as String?)
            ?.trim();
    final lastName =
        (_readFirst(createdByJson, <String>['lastName', 'last_name', 'nom'])
                as String?)
            ?.trim();
    final parts = <String>[
      if (firstName != null && firstName.isNotEmpty) firstName,
      if (lastName != null && lastName.isNotEmpty) lastName,
    ];
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }
  }

  return '';
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

Object? _readFirst(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (!json.containsKey(key)) {
      continue;
    }

    final value = json[key];
    if (value != null) {
      return value;
    }
  }
  return null;
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return 0;
}

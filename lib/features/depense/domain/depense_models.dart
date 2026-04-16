enum ExpenseType {
  cagnotte,
  partage,
  unknown;

  factory ExpenseType.fromApi(String? value) {
    return switch (_normalizeEnum(value)) {
      'CAGNOTTE' => ExpenseType.cagnotte,
      'CAGNOTE' => ExpenseType.cagnotte,
      'PARTAGE' => ExpenseType.partage,
      _ => ExpenseType.unknown,
    };
  }
}

enum ExpenseStatus {
  enAttente,
  approuvee,
  rejetee,
  unknown;

  factory ExpenseStatus.fromApi(String? value) {
    return switch (_normalizeEnum(value)) {
      'EN_ATTENTE' => ExpenseStatus.enAttente,
      'PENDING' => ExpenseStatus.enAttente,
      'APPROUVEE' => ExpenseStatus.approuvee,
      'APPROUVE' => ExpenseStatus.approuvee,
      'VALIDEE' => ExpenseStatus.approuvee,
      'VALIDE' => ExpenseStatus.approuvee,
      'REJETEE' => ExpenseStatus.rejetee,
      'REJECTED' => ExpenseStatus.rejetee,
      _ => ExpenseStatus.unknown,
    };
  }
}

class ExpenseCategory {
  const ExpenseCategory({required this.id, required this.name});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: _readInt(_readFirst(json, <String>['id'])) ?? 0,
      name: (_readFirst(json, <String>['nom', 'name']) as String?)?.trim() ?? '',
    );
  }

  final int id;
  final String name;
}

class ResidenceFundBalance {
  const ResidenceFundBalance({required this.residenceId, required this.balance});

  factory ResidenceFundBalance.fromJson(Map<String, dynamic> json) {
    return ResidenceFundBalance(
      residenceId:
          _readInt(_readFirst(json, <String>['residenceId', 'residence_id'])) ??
          0,
      balance: _readDouble(_readFirst(json, <String>['solde', 'balance'])),
    );
  }

  final int residenceId;
  final double balance;
}

class ResidenceParticipantsCount {
  const ResidenceParticipantsCount({
    required this.residenceId,
    required this.participantsCount,
  });

  factory ResidenceParticipantsCount.fromJson(Map<String, dynamic> json) {
    return ResidenceParticipantsCount(
      residenceId:
          _readInt(_readFirst(json, <String>['residenceId', 'residence_id'])) ??
          0,
      participantsCount:
          _readInt(
            _readFirst(
              json,
              <String>['participantsCount', 'participants_count'],
            ),
          ) ??
          0,
    );
  }

  final int residenceId;
  final int participantsCount;
}

class ExpenseRecord {
  const ExpenseRecord({
    required this.id,
    required this.residenceId,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.type,
    required this.amountPerPerson,
    required this.description,
    required this.status,
    required this.createdById,
    required this.createdAt,
    required this.validatedById,
    required this.validatedAt,
  });

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) {
    final category =
        _readFirst(
              json,
              <String>['categorie', 'category', 'categorieDepense'],
            )
            as Map<String, dynamic>?;
    final residence =
        _readFirst(json, <String>['residence']) as Map<String, dynamic>?;
    final categoryNameValue =
        _readFirst(json, <String>['categorieNom', 'categorie_nom', 'categoryName']) ??
        category?['nom'] ??
        category?['name'];

    return ExpenseRecord(
      id: _readInt(_readFirst(json, <String>['id'])) ?? 0,
      residenceId:
          _readInt(
            _readFirst(json, <String>['residenceId', 'residence_id']) ??
                residence?['id'],
          ) ??
          0,
      categoryId: _readInt(
        _readFirst(json, <String>['categorieId', 'categorie_id', 'categoryId']) ??
            category?['id'],
      ),
      categoryName: (categoryNameValue as String?)?.trim(),
      amount: _readDouble(_readFirst(json, <String>['montant', 'amount'])),
      type: ExpenseType.fromApi(
        _readFirst(
              json,
              <String>[
                'typeDepense',
                'type_depense',
                'type',
                'typeDepenseLabel',
                'expenseType',
              ],
            )
            as String?,
      ),
      amountPerPerson: _readNullableDouble(
        _readFirst(
          json,
          <String>[
            'montantParPersonne',
            'montant_par_personne',
            'amountPerPerson',
          ],
        ),
      ),
      description:
          (_readFirst(
                json,
                <String>['description', 'libelle', 'titre', 'label'],
              )
              as String?)
              ?.trim() ??
          '',
      status: ExpenseStatus.fromApi(
        _readFirst(
              json,
              <String>['statut', 'status', 'expenseStatus', 'etat'],
            )
            as String?,
      ),
      createdById: _readInt(
        _readFirst(json, <String>['creeParId', 'cree_par_id', 'createdById']),
      ),
      createdAt: _readDateTime(
        _readFirst(
          json,
          <String>['dateCreation', 'date_creation', 'createdAt'],
        ) as String?,
      ),
      validatedById: _readInt(
        _readFirst(
          json,
          <String>['valideParId', 'valide_par_id', 'validatedById'],
        ),
      ),
      validatedAt: _readDateTime(
        _readFirst(
          json,
          <String>['dateValidation', 'date_validation', 'validatedAt'],
        ) as String?,
      ),
    );
  }

  final int id;
  final int residenceId;
  final int? categoryId;
  final String? categoryName;
  final double amount;
  final ExpenseType type;
  final double? amountPerPerson;
  final String description;
  final ExpenseStatus status;
  final int? createdById;
  final DateTime? createdAt;
  final int? validatedById;
  final DateTime? validatedAt;
}

class ExpenseOverview {
  const ExpenseOverview({
    required this.balance,
    required this.categories,
    required this.cagnotteExpenses,
    required this.sharedExpenses,
  });

  final ResidenceFundBalance balance;
  final List<ExpenseCategory> categories;
  final List<ExpenseRecord> cagnotteExpenses;
  final List<SharedExpenseRecord> sharedExpenses;
}

class SharedExpenseRecord {
  const SharedExpenseRecord({
    required this.id,
    required this.residenceId,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.totalAmount,
    required this.totalPaidAmount,
    required this.amountPerPerson,
    required this.remainingParticipantsCount,
    required this.createdAt,
    required this.validatedAt,
    required this.createdBy,
    required this.participants,
  });

  factory SharedExpenseRecord.fromJson(Map<String, dynamic> json) {
    return SharedExpenseRecord(
      id: _readInt(_readFirst(json, <String>['id'])) ?? 0,
      residenceId:
          _readInt(_readFirst(json, <String>['residenceId', 'residence_id'])) ??
          0,
      categoryId: _readInt(
        _readFirst(json, <String>['categorieId', 'categorie_id', 'categoryId']),
      ),
      categoryName:
          (_readFirst(
                json,
                <String>['categorieNom', 'categorie_nom', 'categoryName'],
              )
              as String?)
              ?.trim(),
      description:
          (_readFirst(json, <String>['description']) as String?)?.trim() ?? '',
      totalAmount: _readDouble(
        _readFirst(json, <String>['montantTotal', 'montant', 'amount']),
      ),
      totalPaidAmount: _readDouble(
        _readFirst(
          json,
          <String>['montantPayeTotal', 'paidAmountTotal', 'totalPaidAmount'],
        ),
      ),
      amountPerPerson: _readNullableDouble(
        _readFirst(
          json,
          <String>[
            'montantParPersonne',
            'montant_par_personne',
            'amountPerPerson',
          ],
        ),
      ),
      remainingParticipantsCount:
          _readInt(
            _readFirst(
              json,
              <String>[
                'nombreParticipantsRestants',
                'remainingParticipantsCount',
              ],
            ),
          ) ??
          0,
      createdAt: _readDateTime(
        _readFirst(
          json,
          <String>['dateCreation', 'date_creation', 'createdAt'],
        ) as String?,
      ),
      validatedAt: _readDateTime(
        _readFirst(
          json,
          <String>['dateValidation', 'date_validation', 'validatedAt'],
        ) as String?,
      ),
      createdBy: ExpenseUserSummary.fromJson(
        (_readFirst(json, <String>['creePar', 'createdBy'])
                as Map<String, dynamic>?) ??
            const <String, dynamic>{},
      ),
      participants:
          ((_readFirst(json, <String>['participants']) as List<dynamic>?) ??
                  const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(SharedExpenseParticipantRecord.fromJson)
              .toList(),
    );
  }

  final int id;
  final int residenceId;
  final int? categoryId;
  final String? categoryName;
  final String description;
  final double totalAmount;
  final double totalPaidAmount;
  final double? amountPerPerson;
  final int remainingParticipantsCount;
  final DateTime? createdAt;
  final DateTime? validatedAt;
  final ExpenseUserSummary createdBy;
  final List<SharedExpenseParticipantRecord> participants;
}

class ExpenseUserSummary {
  const ExpenseUserSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
  });

  factory ExpenseUserSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseUserSummary(
      id: _readInt(_readFirst(json, <String>['id'])),
      firstName: (_readFirst(json, <String>['firstName']) as String?)?.trim(),
      lastName: (_readFirst(json, <String>['lastName']) as String?)?.trim(),
      fullName:
          (_readFirst(json, <String>['fullName']) as String?)?.trim() ?? '',
    );
  }

  final int? id;
  final String? firstName;
  final String? lastName;
  final String fullName;
}

enum SharedExpenseParticipantStatus {
  unpaid,
  partiallyPaid,
  paid,
  unknown;

  factory SharedExpenseParticipantStatus.fromApi(String? value) {
    return switch (_normalizeEnum(value)) {
      'NON_PAYE' => SharedExpenseParticipantStatus.unpaid,
      'PARTIELLEMENT_PAYE' => SharedExpenseParticipantStatus.partiallyPaid,
      'PAYE' => SharedExpenseParticipantStatus.paid,
      _ => SharedExpenseParticipantStatus.unknown,
    };
  }
}

class SharedExpenseParticipantRecord {
  const SharedExpenseParticipantRecord({
    required this.logementId,
    required this.logementLabel,
    required this.codeInterne,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
  });

  factory SharedExpenseParticipantRecord.fromJson(Map<String, dynamic> json) {
    return SharedExpenseParticipantRecord(
      logementId:
          _readInt(
            _readFirst(
              json,
              <String>['logementId', 'utilisateurId', 'userId', 'id'],
            ),
          ) ??
          0,
      logementLabel:
          (_readFirst(
                json,
                <String>['logementLabel', 'utilisateurEmail', 'label'],
              )
              as String?)
              ?.trim(),
      codeInterne:
          (_readFirst(json, <String>['codeInterne', 'code_interne']) as String?)
              ?.trim(),
      firstName: (_readFirst(json, <String>['firstName']) as String?)?.trim(),
      lastName: (_readFirst(json, <String>['lastName']) as String?)?.trim(),
      fullName:
          (_readFirst(json, <String>['fullName']) as String?)?.trim() ?? '',
      amountDue: _readDouble(
        _readFirst(json, <String>['montantDu', 'amountDue']),
      ),
      amountPaid: _readDouble(
        _readFirst(json, <String>['montantPaye', 'amountPaid']),
      ),
      status: SharedExpenseParticipantStatus.fromApi(
        _readFirst(json, <String>['statut', 'status']) as String?,
      ),
    );
  }

  final int logementId;
  final String? logementLabel;
  final String? codeInterne;
  final String? firstName;
  final String? lastName;
  final String fullName;
  final double amountDue;
  final double amountPaid;
  final SharedExpenseParticipantStatus status;

  String get displayLabel {
    final explicitLabel = (logementLabel ?? '').trim();
    if (explicitLabel.isNotEmpty) {
      return explicitLabel;
    }

    final fallbackName = fullName.trim();
    if (fallbackName.isNotEmpty) {
      return fallbackName;
    }

    final internalCode = (codeInterne ?? '').trim();
    if (internalCode.isNotEmpty) {
      return internalCode;
    }

    return '$logementId';
  }

  String get supportingLabel {
    final labels = <String>[
      if ((codeInterne ?? '').trim().isNotEmpty) codeInterne!.trim(),
      if (fullName.trim().isNotEmpty && fullName.trim() != displayLabel)
        fullName.trim(),
    ];
    return labels.join(' • ');
  }
}

class SharedExpensePaymentHousingSummary {
  const SharedExpensePaymentHousingSummary({
    required this.id,
    required this.email,
    required this.codeInterne,
    required this.firstName,
    required this.lastName,
  });

  factory SharedExpensePaymentHousingSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return SharedExpensePaymentHousingSummary(
      id: _readInt(
            _readFirst(json, <String>['id', 'logementId', 'utilisateurId']),
          ) ??
          0,
      email:
          (_readFirst(
                json,
                <String>['email', 'logementEmail', 'utilisateurEmail'],
              )
              as String?)
              ?.trim() ??
          '',
      codeInterne:
          (_readFirst(json, <String>['codeInterne', 'code_interne']) as String?)
              ?.trim() ??
          '',
      firstName:
          (_readFirst(json, <String>['firstName']) as String?)?.trim() ?? '',
      lastName:
          (_readFirst(json, <String>['lastName']) as String?)?.trim() ?? '',
    );
  }

  final int id;
  final String email;
  final String codeInterne;
  final String firstName;
  final String lastName;

  String get displayLabel {
    if (email.isNotEmpty) {
      return email;
    }
    final fullName = [firstName, lastName]
        .where((part) => part.trim().isNotEmpty)
        .join(' ')
        .trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    if (codeInterne.isNotEmpty) {
      return codeInterne;
    }
    return '$id';
  }

  String get adminLabel {
    if (codeInterne.isNotEmpty) {
      return codeInterne;
    }
    return displayLabel;
  }
}

class SharedExpensePaymentExpenseSummary {
  const SharedExpensePaymentExpenseSummary({
    required this.id,
    required this.description,
  });

  factory SharedExpensePaymentExpenseSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return SharedExpensePaymentExpenseSummary(
      id: _readInt(_readFirst(json, <String>['id', 'depenseId'])) ?? 0,
      description:
          (_readFirst(
                json,
                <String>['description', 'libelle', 'titre', 'label'],
              )
              as String?)
              ?.trim() ??
          '',
    );
  }

  final int id;
  final String description;
}

class SharedExpensePaymentRecord {
  const SharedExpensePaymentRecord({
    required this.id,
    required this.expenseId,
    required this.logementId,
    required this.residenceId,
    required this.amount,
    required this.status,
    required this.paymentDate,
    required this.createdAt,
    required this.createdById,
    required this.createdByName,
    required this.logement,
    required this.expense,
  });

  factory SharedExpensePaymentRecord.fromJson(Map<String, dynamic> json) {
    final logementJson = _readFirst(
      json,
      <String>['logement', 'utilisateur', 'housing'],
    );
    final expenseJson = _readFirst(
      json,
      <String>['depense', 'expense', 'depensePartagee', 'sharedExpense'],
    );
    final createdByJson = _readFirst(
      json,
      <String>[
        'creePar',
        'cree_par',
        'createdBy',
        'demandePar',
        'demande_par',
        'requestedBy',
        'requested_by',
      ],
    );

    return SharedExpensePaymentRecord(
      id: _readInt(_readFirst(json, <String>['id', 'paiementId'])) ?? 0,
      expenseId:
          _readInt(
            _readFirst(
                  json,
                  <String>['depenseId', 'expenseId', 'sharedExpenseId'],
                ) ??
                (expenseJson is Map<String, dynamic> ? expenseJson['id'] : null),
          ) ??
          0,
      logementId:
          _readInt(
            _readFirst(
                  json,
                  <String>['logementId', 'utilisateurId', 'userId'],
                ) ??
                (logementJson is Map<String, dynamic>
                    ? _readFirst(
                        logementJson,
                        <String>['id', 'logementId', 'utilisateurId'],
                      )
                    : null),
          ) ??
          0,
      residenceId:
          _readInt(_readFirst(json, <String>['residenceId', 'residence_id'])) ??
          0,
      amount: _readDouble(
        _readFirst(
          json,
          <String>['montant', 'amount', 'montantPaye', 'paidAmount'],
        ),
      ),
      status:
          (_readFirst(json, <String>['status', 'statut']) as String?)?.trim() ??
          '',
      paymentDate: _readDateTime(
        _readFirst(
          json,
          <String>['datePaiement', 'paymentDate'],
        ) as String?,
      ),
      createdAt: _readDateTime(
        _readFirst(
          json,
          <String>['dateCreation', 'createdAt', 'date_creation'],
        ) as String?,
      ),
      createdById:
          _readInt(
            _readFirst(
              json,
              <String>['creeParId', 'createdById', 'requestedById'],
            ),
          ) ??
          0,
      createdByName: _resolveSharedExpensePaymentRequesterName(
        json,
        createdByJson,
      ),
      logement: logementJson is Map<String, dynamic>
          ? SharedExpensePaymentHousingSummary.fromJson(logementJson)
          : null,
      expense: expenseJson is Map<String, dynamic>
          ? SharedExpensePaymentExpenseSummary.fromJson(expenseJson)
          : null,
    );
  }

  final int id;
  final int expenseId;
  final int logementId;
  final int residenceId;
  final double amount;
  final String status;
  final DateTime? paymentDate;
  final DateTime? createdAt;
  final int createdById;
  final String createdByName;
  final SharedExpensePaymentHousingSummary? logement;
  final SharedExpensePaymentExpenseSummary? expense;

  String get logementLabel => logement?.displayLabel ?? '$logementId';

  String get adminLogementLabel => logement?.adminLabel ?? logementLabel;

  String get expenseLabel {
    final description = expense?.description.trim() ?? '';
    if (description.isNotEmpty) {
      return description;
    }
    return expenseId > 0 ? 'Depense #$expenseId' : '';
  }
}

String _resolveSharedExpensePaymentRequesterName(
  Map<String, dynamic> json,
  Object? createdByJson,
) {
  final directName = (_readFirst(
    json,
    <String>[
      'creeParNomComplet',
      'cree_par_nom_complet',
      'createdByName',
      'created_by_name',
      'requestedByName',
      'requested_by_name',
      'fullName',
      'nomComplet',
      'nom_complet',
    ],
  ) as String?)
      ?.trim();

  if (directName != null && directName.isNotEmpty) {
    return directName;
  }

  if (createdByJson is Map<String, dynamic>) {
    final nestedFullName =
        (_readFirst(createdByJson, <String>['fullName', 'nomComplet'])
                as String?)
            ?.trim() ??
        '';
    if (nestedFullName.isNotEmpty) {
      return nestedFullName;
    }

    final firstName =
        (_readFirst(createdByJson, <String>['firstName']) as String?)?.trim() ??
        '';
    final lastName =
        (_readFirst(createdByJson, <String>['lastName']) as String?)?.trim() ??
        '';
    final combined = [firstName, lastName]
        .where((part) => part.isNotEmpty)
        .join(' ')
        .trim();
    if (combined.isNotEmpty) {
      return combined;
    }
  }

  return '';
}

Object? _readFirst(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) {
      return json[key];
    }
  }
  return null;
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
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

double? _readNullableDouble(Object? value) {
  if (value == null) {
    return null;
  }
  return _readDouble(value);
}

DateTime? _readDateTime(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

String? _normalizeEnum(String? value) {
  if (value == null) {
    return null;
  }
  return value
      .trim()
      .toUpperCase()
      .replaceAll(' ', '_')
      .replaceAll('-', '_')
      .replaceAll(RegExp(r'[^A-Z_]'), '');
}

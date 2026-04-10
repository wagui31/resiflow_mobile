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
    required this.expenses,
  });

  final ResidenceFundBalance balance;
  final List<ExpenseCategory> categories;
  final List<ExpenseRecord> expenses;
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

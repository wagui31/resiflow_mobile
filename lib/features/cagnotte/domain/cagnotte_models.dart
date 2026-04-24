enum ResidenceFundTransactionType {
  contribution,
  depense,
  correction,
  unknown;

  factory ResidenceFundTransactionType.fromApi(String? value) {
    return switch (_normalizeEnum(value)) {
      'CONTRIBUTION' => ResidenceFundTransactionType.contribution,
      'DEPENSE' => ResidenceFundTransactionType.depense,
      'CORRECTION' => ResidenceFundTransactionType.correction,
      _ => ResidenceFundTransactionType.unknown,
    };
  }
}

class ResidenceFundTransaction {
  const ResidenceFundTransaction({
    required this.id,
    required this.residenceId,
    required this.logementId,
    required this.logementCodeInterne,
    required this.type,
    required this.amount,
    required this.referenceId,
    required this.createdAt,
  });

  factory ResidenceFundTransaction.fromJson(Map<String, dynamic> json) {
    return ResidenceFundTransaction(
      id: _readInt(json['id']) ?? 0,
      residenceId: _readInt(json['residenceId'] ?? json['residence_id']) ?? 0,
      logementId: _readInt(json['logementId'] ?? json['logement_id']),
      logementCodeInterne: _readString(
        json['logementCodeInterne'] ?? json['logement_code_interne'],
      ),
      type: ResidenceFundTransactionType.fromApi(
        (json['type'] ?? json['transactionType']) as String?,
      ),
      amount: _readDouble(json['montant'] ?? json['amount']),
      referenceId: _readInt(json['referenceId'] ?? json['reference_id']),
      createdAt: _readDateTime(
        (json['dateCreation'] ?? json['date_creation'] ?? json['createdAt'])
            as String?,
      ),
    );
  }

  final int id;
  final int residenceId;
  final int? logementId;
  final String? logementCodeInterne;
  final ResidenceFundTransactionType type;
  final double amount;
  final int? referenceId;
  final DateTime? createdAt;
}

class CreateResidenceFundCorrectionResult {
  const CreateResidenceFundCorrectionResult({
    required this.residenceId,
    required this.ancienSolde,
    required this.nouveauSolde,
    required this.delta,
    required this.correctionId,
    required this.transactionId,
    required this.typeTransaction,
    required this.dateCreation,
  });

  factory CreateResidenceFundCorrectionResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return CreateResidenceFundCorrectionResult(
      residenceId: _readInt(json['residenceId'] ?? json['residence_id']) ?? 0,
      ancienSolde: _readDouble(json['ancienSolde'] ?? json['ancien_solde']),
      nouveauSolde: _readDouble(json['nouveauSolde'] ?? json['nouveau_solde']),
      delta: _readDouble(json['delta']),
      correctionId:
          _readInt(json['correctionId'] ?? json['correction_id']) ?? 0,
      transactionId:
          _readInt(json['transactionId'] ?? json['transaction_id']) ?? 0,
      typeTransaction: ResidenceFundTransactionType.fromApi(
        (json['typeTransaction'] ?? json['type_transaction']) as String?,
      ),
      dateCreation: _readDateTime(
        (json['dateCreation'] ?? json['date_creation']) as String?,
      ),
    );
  }

  final int residenceId;
  final double ancienSolde;
  final double nouveauSolde;
  final double delta;
  final int correctionId;
  final int transactionId;
  final ResidenceFundTransactionType typeTransaction;
  final DateTime? dateCreation;
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

String? _readString(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return null;
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

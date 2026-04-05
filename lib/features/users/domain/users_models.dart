import '../../auth/domain/auth_models.dart';

class ResidenceUser {
  const ResidenceUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.residenceId,
    required this.residenceName,
    required this.residenceCode,
    required this.currency,
    required this.numeroImmeuble,
    required this.codeLogement,
    required this.role,
    required this.status,
    required this.paymentStatus,
    this.residenceEntryDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ResidenceUser.fromJson(Map<String, dynamic> json) {
    return ResidenceUser(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: (json['firstName'] as String?)?.trim(),
      lastName: (json['lastName'] as String?)?.trim(),
      residenceId: json['residenceId'] as int?,
      residenceName: (json['residenceName'] as String?)?.trim(),
      residenceCode: (json['residenceCode'] as String?)?.trim(),
      currency: (json['currency'] as String?)?.trim(),
      numeroImmeuble: (json['numeroImmeuble'] as String?)?.trim(),
      codeLogement: (json['codeLogement'] as String?)?.trim(),
      role: UserRole.fromApi(json['role'] as String?),
      status: UserStatus.fromApi(json['status'] as String?),
      paymentStatus: PaymentStatus.fromApi(json['statutPaiement'] as String?),
      residenceEntryDate: DateTime.tryParse(
        json['dateEntreeResidence'] as String? ?? '',
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final int? residenceId;
  final String? residenceName;
  final String? residenceCode;
  final String? currency;
  final String? numeroImmeuble;
  final String? codeLogement;
  final UserRole role;
  final UserStatus status;
  final PaymentStatus paymentStatus;
  final DateTime? residenceEntryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    final parts = <String>[
      if ((firstName ?? '').trim().isNotEmpty) firstName!.trim(),
      if ((lastName ?? '').trim().isNotEmpty) lastName!.trim(),
    ];
    return parts.isEmpty ? email.trim() : parts.join(' ');
  }

  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;
}

class UpdateCurrentUserPayload {
  const UpdateCurrentUserPayload({
    required this.firstName,
    required this.lastName,
    this.numeroImmeuble,
    this.codeLogement,
  });

  final String firstName;
  final String lastName;
  final String? numeroImmeuble;
  final String? codeLogement;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'numeroImmeuble': _normalizeOptional(numeroImmeuble),
      'codeLogement': _normalizeOptional(codeLogement),
    };
  }

  String? _normalizeOptional(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class UpdateResidenceEntryDatePayload {
  const UpdateResidenceEntryDatePayload({required this.date});

  final DateTime date;

  Map<String, dynamic> toJson() {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return <String, dynamic>{
      'dateEntreeResidence': '$year-$month-$day',
    };
  }
}

class UpdateUserRolePayload {
  const UpdateUserRolePayload({required this.role});

  final UserRole role;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'role': switch (role) {
        UserRole.admin => 'ADMIN',
        UserRole.user => 'USER',
        UserRole.superAdmin => 'SUPER_ADMIN',
        UserRole.unknown => 'UNKNOWN',
      },
    };
  }
}

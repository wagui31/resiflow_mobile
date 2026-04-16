enum UserRole {
  superAdmin,
  admin,
  user,
  unknown;

  factory UserRole.fromApi(String? value) {
    return switch (value) {
      'SUPER_ADMIN' => UserRole.superAdmin,
      'ADMIN' => UserRole.admin,
      'USER' => UserRole.user,
      _ => UserRole.unknown,
    };
  }
}

enum UserStatus {
  pending,
  active,
  rejected,
  unknown;

  factory UserStatus.fromApi(String? value) {
    return switch (value) {
      'PENDING' => UserStatus.pending,
      'ACTIVE' => UserStatus.active,
      'REJECTED' => UserStatus.rejected,
      _ => UserStatus.unknown,
    };
  }
}

enum PaymentStatus {
  upToDate,
  late,
  unknown;

  factory PaymentStatus.fromApi(String? value) {
    return switch (value) {
      'A_JOUR' => PaymentStatus.upToDate,
      'EN_RETARD' => PaymentStatus.late,
      _ => PaymentStatus.unknown,
    };
  }
}

class CaptchaPublicConfig {
  const CaptchaPublicConfig({
    required this.registerEnabled,
    required this.siteKey,
  });

  factory CaptchaPublicConfig.fromJson(Map<String, dynamic> json) {
    return CaptchaPublicConfig(
      registerEnabled: json['registerEnabled'] == true,
      siteKey: (json['siteKey'] as String?)?.trim(),
    );
  }

  final bool registerEnabled;
  final String? siteKey;
}

class PublicAppConfig {
  const PublicAppConfig({required this.captcha});

  factory PublicAppConfig.fromJson(Map<String, dynamic> json) {
    final captchaJson = json['captcha'];
    return PublicAppConfig(
      captcha: captchaJson is Map<String, dynamic>
          ? CaptchaPublicConfig.fromJson(captchaJson)
          : const CaptchaPublicConfig(registerEnabled: false, siteKey: null),
    );
  }

  final CaptchaPublicConfig captcha;
}

class RegistrationLogementOption {
  const RegistrationLogementOption({
    required this.logementId,
    required this.typeLogement,
    required this.numero,
    required this.immeuble,
    required this.etage,
    required this.codeInterne,
    required this.active,
    required this.occupiedCount,
    required this.maxOccupants,
    required this.full,
  });

  factory RegistrationLogementOption.fromJson(Map<String, dynamic> json) {
    return RegistrationLogementOption(
      logementId: json['logementId'] as int? ?? 0,
      typeLogement: (json['typeLogement'] as String?)?.trim(),
      numero: (json['numero'] as String?)?.trim(),
      immeuble: (json['immeuble'] as String?)?.trim(),
      etage: (json['etage'] as String?)?.trim(),
      codeInterne: (json['codeInterne'] as String?)?.trim() ?? '',
      active: json['active'] == true,
      occupiedCount: json['occupiedCount'] as int? ?? 0,
      maxOccupants: json['maxOccupants'] as int? ?? 0,
      full: json['full'] == true,
    );
  }

  final int logementId;
  final String? typeLogement;
  final String? numero;
  final String? immeuble;
  final String? etage;
  final String codeInterne;
  final bool active;
  final int occupiedCount;
  final int maxOccupants;
  final bool full;

  bool get isFirstResident => occupiedCount == 0;

  String get displayLabel {
    final buffer = <String>[
      if ((immeuble ?? '').trim().isNotEmpty) immeuble!.trim(),
      if ((numero ?? '').trim().isNotEmpty) numero!.trim(),
    ];
    if (buffer.isNotEmpty) {
      return buffer.join(' - ');
    }
    return codeInterne;
  }
}

class LoginResult {
  const LoginResult({
    required this.userId,
    required this.email,
    required this.residenceId,
    required this.currency,
    required this.role,
    required this.status,
    required this.token,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      userId: json['userId'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      residenceId: json['residenceId'] as int?,
      currency: (json['currency'] as String?)?.trim(),
      role: UserRole.fromApi(json['role'] as String?),
      status: UserStatus.fromApi(json['status'] as String?),
      token: json['token'] as String? ?? '',
    );
  }

  final int userId;
  final String email;
  final int? residenceId;
  final String? currency;
  final UserRole role;
  final UserStatus status;
  final String token;
}

class UserLogementSummary {
  const UserLogementSummary({
    required this.logementId,
    required this.numero,
    required this.immeuble,
    required this.typeLogement,
    required this.codeInterne,
    required this.active,
  });

  factory UserLogementSummary.fromJson(Map<String, dynamic> json) {
    return UserLogementSummary(
      logementId: json['logementId'] as int? ?? 0,
      numero: (json['numero'] as String?)?.trim(),
      immeuble: (json['immeuble'] as String?)?.trim(),
      typeLogement: (json['typeLogement'] as String?)?.trim(),
      codeInterne:
          (json['codeInterne'] as String?)?.trim() ??
          (json['code_interne'] as String?)?.trim(),
      active: json['active'] == true,
    );
  }

  final int logementId;
  final String? numero;
  final String? immeuble;
  final String? typeLogement;
  final String? codeInterne;
  final bool active;

  String get displayLabel {
    final parts = <String>[
      if ((immeuble ?? '').trim().isNotEmpty) immeuble!.trim(),
      if ((numero ?? '').trim().isNotEmpty) numero!.trim(),
    ];
    if (parts.isNotEmpty) {
      return parts.join(' - ');
    }
    return '';
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.residenceId,
    required this.residenceName,
    required this.residenceCode,
    required this.currency,
    required this.logement,
    required this.numeroImmeuble,
    required this.codeLogement,
    required this.role,
    required this.status,
    required this.paymentStatus,
    this.residenceEntryDate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final logementJson = json['logement'];
    final logement = logementJson is Map<String, dynamic>
        ? UserLogementSummary.fromJson(logementJson)
        : null;
    return UserProfile(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: (json['firstName'] as String?)?.trim(),
      lastName: (json['lastName'] as String?)?.trim(),
      residenceId: json['residenceId'] as int?,
      residenceName: (json['residenceName'] as String?)?.trim(),
      residenceCode: json['residenceCode'] as String?,
      currency: (json['currency'] as String?)?.trim(),
      logement: logement,
      numeroImmeuble:
          (json['numeroImmeuble'] as String?)?.trim() ?? logement?.immeuble,
      codeLogement:
          (json['codeLogement'] as String?)?.trim() ??
          (json['codeInterne'] as String?)?.trim() ??
          (json['code_interne'] as String?)?.trim() ??
          logement?.codeInterne ??
          logement?.numero,
      role: UserRole.fromApi(json['role'] as String?),
      status: UserStatus.fromApi(json['status'] as String?),
      paymentStatus: PaymentStatus.fromApi(
        (json['statutPaiement'] ?? json['paymentStatus']) as String?,
      ),
      residenceEntryDate: DateTime.tryParse(
        json['dateEntreeResidence'] as String? ?? '',
      ),
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
  final UserLogementSummary? logement;
  final String? numeroImmeuble;
  final String? codeLogement;
  final UserRole role;
  final UserStatus status;
  final PaymentStatus paymentStatus;
  final DateTime? residenceEntryDate;

  String get displayName {
    final parts = <String>[
      if ((firstName ?? '').trim().isNotEmpty) firstName!.trim(),
      if ((lastName ?? '').trim().isNotEmpty) lastName!.trim(),
    ];
    return parts.join(' ').trim();
  }
}

class RegisterPayload {
  const RegisterPayload({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.residenceCode,
    required this.logementId,
    required this.captchaToken,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String residenceCode;
  final int logementId;
  final String? captchaToken;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim(),
      'password': password.trim(),
      'residenceCode': residenceCode.trim(),
      'logementId': logementId,
      'captchaToken': _normalizeOptional(captchaToken),
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

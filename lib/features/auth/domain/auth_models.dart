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
  const PublicAppConfig({
    required this.captcha,
  });

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

class LoginResult {
  const LoginResult({
    required this.userId,
    required this.email,
    required this.residenceId,
    required this.role,
    required this.status,
    required this.token,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      userId: json['userId'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      residenceId: json['residenceId'] as int?,
      role: UserRole.fromApi(json['role'] as String?),
      status: UserStatus.fromApi(json['status'] as String?),
      token: json['token'] as String? ?? '',
    );
  }

  final int userId;
  final String email;
  final int? residenceId;
  final UserRole role;
  final UserStatus status;
  final String token;
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
    required this.numeroImmeuble,
    required this.codeLogement,
    required this.role,
    required this.status,
    required this.paymentStatus,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: (json['firstName'] as String?)?.trim(),
      lastName: (json['lastName'] as String?)?.trim(),
      residenceId: json['residenceId'] as int?,
      residenceName: (json['residenceName'] as String?)?.trim(),
      residenceCode: json['residenceCode'] as String?,
      numeroImmeuble: json['numeroImmeuble'] as String?,
      codeLogement: json['codeLogement'] as String?,
      role: UserRole.fromApi(json['role'] as String?),
      status: UserStatus.fromApi(json['status'] as String?),
      paymentStatus: PaymentStatus.fromApi(json['statutPaiement'] as String?),
    );
  }

  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final int? residenceId;
  final String? residenceName;
  final String? residenceCode;
  final String? numeroImmeuble;
  final String? codeLogement;
  final UserRole role;
  final UserStatus status;
  final PaymentStatus paymentStatus;
}

class RegisterPayload {
  const RegisterPayload({
    required this.email,
    required this.password,
    required this.residenceCode,
    required this.numeroImmeuble,
    required this.codeLogement,
    required this.captchaToken,
  });

  final String email;
  final String password;
  final String residenceCode;
  final String? numeroImmeuble;
  final String? codeLogement;
  final String? captchaToken;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email.trim(),
      'password': password.trim(),
      'residenceCode': residenceCode.trim(),
      'numeroImmeuble': _normalizeOptional(numeroImmeuble),
      'codeLogement': _normalizeOptional(codeLogement),
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

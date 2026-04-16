import '../../auth/domain/auth_models.dart';

enum ResidencePaymentStatus {
  upToDate,
  late,
  inactive,
  unknown;

  factory ResidencePaymentStatus.fromApi(String? value) {
    return switch (value) {
      'A_JOUR' || 'UP_TO_DATE' => ResidencePaymentStatus.upToDate,
      'EN_RETARD' || 'OVERDUE' => ResidencePaymentStatus.late,
      'INACTIVE' => ResidencePaymentStatus.inactive,
      _ => ResidencePaymentStatus.unknown,
    };
  }
}

enum ResidenceCagnotteStatus {
  positive,
  negative,
  neutral;

  factory ResidenceCagnotteStatus.fromApi(String? value) {
    return switch (value) {
      'POSITIVE' => ResidenceCagnotteStatus.positive,
      'NEGATIVE' => ResidenceCagnotteStatus.negative,
      _ => ResidenceCagnotteStatus.neutral,
    };
  }
}

class ResidenceViewData {
  const ResidenceViewData({
    required this.overview,
    required this.logements,
    required this.pendingLogements,
  });

  factory ResidenceViewData.fromJson(Map<String, dynamic> json) {
    final overviewJson = json['overview'];
    final logementsJson = json['logements'];
    final pendingJson = json['pendingLogements'];

    return ResidenceViewData(
      overview: overviewJson is Map<String, dynamic>
          ? ResidenceOverview.fromJson(overviewJson)
          : const ResidenceOverview.empty(),
      logements: _asList(logementsJson)
          .map(ResidenceHousingCard.fromJson)
          .toList(),
      pendingLogements: _asList(pendingJson)
          .map(ResidencePendingHousingCard.fromJson)
          .toList(),
    );
  }

  final ResidenceOverview overview;
  final List<ResidenceHousingCard> logements;
  final List<ResidencePendingHousingCard> pendingLogements;

  int get pendingResidentsCount => pendingLogements.fold<int>(
    0,
    (count, card) => count + card.pendingResidents.length,
  );

  static List<Map<String, dynamic>> _asList(Object? value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }
    return value.whereType<Map<String, dynamic>>().toList();
  }
}

class ResidenceOverview {
  const ResidenceOverview({
    required this.residenceId,
    required this.totalLogements,
    required this.activeLogements,
    required this.inactiveLogements,
    required this.totalResidents,
    required this.activeResidents,
    required this.pendingResidents,
    required this.adminResidents,
    required this.userResidents,
    required this.cagnotteSolde,
    required this.cagnotteStatus,
    required this.logementsAJour,
    required this.logementsEnRetard,
  });

  const ResidenceOverview.empty()
    : residenceId = 0,
      totalLogements = 0,
      activeLogements = 0,
      inactiveLogements = 0,
      totalResidents = 0,
      activeResidents = 0,
      pendingResidents = 0,
      adminResidents = 0,
      userResidents = 0,
      cagnotteSolde = 0,
      cagnotteStatus = ResidenceCagnotteStatus.neutral,
      logementsAJour = 0,
      logementsEnRetard = 0;

  factory ResidenceOverview.fromJson(Map<String, dynamic> json) {
    return ResidenceOverview(
      residenceId: json['residenceId'] as int? ?? 0,
      totalLogements: json['totalLogements'] as int? ?? 0,
      activeLogements: json['activeLogements'] as int? ?? 0,
      inactiveLogements: json['inactiveLogements'] as int? ?? 0,
      totalResidents: json['totalResidents'] as int? ?? 0,
      activeResidents: json['activeResidents'] as int? ?? 0,
      pendingResidents: json['pendingResidents'] as int? ?? 0,
      adminResidents: json['adminResidents'] as int? ?? 0,
      userResidents: json['userResidents'] as int? ?? 0,
      cagnotteSolde: (json['cagnotteSolde'] as num?)?.toDouble() ?? 0,
      cagnotteStatus: ResidenceCagnotteStatus.fromApi(
        json['cagnotteStatus'] as String?,
      ),
      logementsAJour: json['logementsAJour'] as int? ?? 0,
      logementsEnRetard: json['logementsEnRetard'] as int? ?? 0,
    );
  }

  final int residenceId;
  final int totalLogements;
  final int activeLogements;
  final int inactiveLogements;
  final int totalResidents;
  final int activeResidents;
  final int pendingResidents;
  final int adminResidents;
  final int userResidents;
  final double cagnotteSolde;
  final ResidenceCagnotteStatus cagnotteStatus;
  final int logementsAJour;
  final int logementsEnRetard;
}

class ResidenceHousingInfo {
  const ResidenceHousingInfo({
    required this.id,
    required this.residenceId,
    required this.typeLogement,
    required this.numero,
    required this.immeuble,
    required this.etage,
    required this.codePostal,
    required this.adresse,
    required this.codeInterne,
    required this.active,
    required this.dateActivation,
  });

  factory ResidenceHousingInfo.fromJson(Map<String, dynamic> json) {
    return ResidenceHousingInfo(
      id: json['id'] as int? ?? 0,
      residenceId: json['residenceId'] as int? ?? 0,
      typeLogement: (json['typeLogement'] as String?)?.trim(),
      numero: (json['numero'] as String?)?.trim(),
      immeuble: (json['immeuble'] as String?)?.trim(),
      etage: (json['etage'] as String?)?.trim(),
      codePostal: (json['codePostal'] as String?)?.trim(),
      adresse: (json['adresse'] as String?)?.trim(),
      codeInterne: (json['codeInterne'] as String?)?.trim() ?? '',
      active: json['active'] == true,
      dateActivation: DateTime.tryParse(
        json['dateActivation'] as String? ?? '',
      ),
    );
  }

  final int id;
  final int residenceId;
  final String? typeLogement;
  final String? numero;
  final String? immeuble;
  final String? etage;
  final String? codePostal;
  final String? adresse;
  final String codeInterne;
  final bool active;
  final DateTime? dateActivation;

  String get displayLabel {
    final parts = <String>[
      if ((immeuble ?? '').trim().isNotEmpty) immeuble!.trim(),
      if ((numero ?? '').trim().isNotEmpty) numero!.trim(),
    ];
    return parts.isEmpty ? codeInterne : parts.join(' - ');
  }
}

class ResidenceHousingOccupancy {
  const ResidenceHousingOccupancy({
    required this.logementId,
    required this.occupiedCount,
    required this.maxOccupants,
    required this.full,
  });

  factory ResidenceHousingOccupancy.fromJson(Map<String, dynamic> json) {
    return ResidenceHousingOccupancy(
      logementId: json['logementId'] as int? ?? 0,
      occupiedCount: json['occupiedCount'] as int? ?? 0,
      maxOccupants: json['maxOccupants'] as int? ?? 0,
      full: json['full'] == true,
    );
  }

  final int logementId;
  final int occupiedCount;
  final int maxOccupants;
  final bool full;
}

class ResidencePerson {
  const ResidencePerson({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.status,
    required this.residenceEntryDate,
  });

  factory ResidencePerson.fromJson(Map<String, dynamic> json) {
    return ResidencePerson(
      id: json['id'] as int? ?? 0,
      firstName: (json['firstName'] as String?)?.trim(),
      lastName: (json['lastName'] as String?)?.trim(),
      email: (json['email'] as String?)?.trim() ?? '',
      role: UserRole.fromApi(json['role'] as String?),
      status: UserStatus.fromApi(json['status'] as String?),
      residenceEntryDate: DateTime.tryParse(
        json['dateEntreeResidence'] as String? ?? '',
      ),
    );
  }

  final int id;
  final String? firstName;
  final String? lastName;
  final String email;
  final UserRole role;
  final UserStatus status;
  final DateTime? residenceEntryDate;

  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;

  String get displayName {
    final parts = <String>[
      if ((firstName ?? '').trim().isNotEmpty) firstName!.trim(),
      if ((lastName ?? '').trim().isNotEmpty) lastName!.trim(),
    ];
    return parts.isEmpty ? email : parts.join(' ');
  }
}

class ResidenceHousingPayment {
  const ResidenceHousingPayment({
    required this.status,
    required this.dateFin,
    required this.nextDueWarning,
    required this.overdueMonths,
    required this.pendingPayment,
  });

  factory ResidenceHousingPayment.fromJson(Map<String, dynamic> json) {
    final pendingJson = json['pendingPayment'];
    return ResidenceHousingPayment(
      status: ResidencePaymentStatus.fromApi(json['status'] as String?),
      dateFin: DateTime.tryParse(json['dateFin'] as String? ?? ''),
      nextDueWarning: json['nextDueWarning'] == true,
      overdueMonths: _parseOverdueMonths(json['overdueMonths']),
      pendingPayment: pendingJson is Map<String, dynamic>
          ? ResidencePendingPayment.fromJson(pendingJson)
          : null,
    );
  }

  final ResidencePaymentStatus status;
  final DateTime? dateFin;
  final bool nextDueWarning;
  final List<String> overdueMonths;
  final ResidencePendingPayment? pendingPayment;
}

class ResidencePendingPayment {
  const ResidencePendingPayment({
    required this.id,
    required this.montantTotal,
    required this.nombreMois,
    required this.dateDebut,
    required this.dateFin,
  });

  factory ResidencePendingPayment.fromJson(Map<String, dynamic> json) {
    return ResidencePendingPayment(
      id: json['id'] as int? ?? 0,
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0,
      nombreMois: json['nombreMois'] as int? ?? 0,
      dateDebut: DateTime.tryParse(json['dateDebut'] as String? ?? ''),
      dateFin: DateTime.tryParse(json['dateFin'] as String? ?? ''),
    );
  }

  final int id;
  final double montantTotal;
  final int nombreMois;
  final DateTime? dateDebut;
  final DateTime? dateFin;
}

class ResidenceHousingCard {
  const ResidenceHousingCard({
    required this.logement,
    required this.occupancy,
    required this.payment,
    required this.residents,
  });

  factory ResidenceHousingCard.fromJson(Map<String, dynamic> json) {
    final logementJson = json['logement'];
    final occupancyJson = json['occupancy'];
    final paymentJson = json['payment'];
    final residentsJson = json['residents'];

    return ResidenceHousingCard(
      logement: logementJson is Map<String, dynamic>
          ? ResidenceHousingInfo.fromJson(logementJson)
          : const ResidenceHousingInfo(
              id: 0,
              residenceId: 0,
              typeLogement: null,
              numero: null,
              immeuble: null,
              etage: null,
              codePostal: null,
              adresse: null,
              codeInterne: '',
              active: false,
              dateActivation: null,
            ),
      occupancy: occupancyJson is Map<String, dynamic>
          ? ResidenceHousingOccupancy.fromJson(occupancyJson)
          : const ResidenceHousingOccupancy(
              logementId: 0,
              occupiedCount: 0,
              maxOccupants: 0,
              full: false,
            ),
      payment: paymentJson is Map<String, dynamic>
          ? ResidenceHousingPayment.fromJson(paymentJson)
          : const ResidenceHousingPayment(
              status: ResidencePaymentStatus.unknown,
              dateFin: null,
              nextDueWarning: false,
              overdueMonths: <String>[],
              pendingPayment: null,
            ),
      residents: (residentsJson is List ? residentsJson : const <Object>[])
          .whereType<Map<String, dynamic>>()
          .map(ResidencePerson.fromJson)
          .toList(),
    );
  }

  final ResidenceHousingInfo logement;
  final ResidenceHousingOccupancy occupancy;
  final ResidenceHousingPayment payment;
  final List<ResidencePerson> residents;

  bool get hasAdminResident => residents.any((resident) => resident.isAdmin);
}

List<String> _parseOverdueMonths(Object? value) {
  if (value is! List) {
    return const <String>[];
  }

  return value.map((item) => item?.toString().trim() ?? '').where((item) => item.isNotEmpty).toList();
}

class ResidencePendingHousingCard {
  const ResidencePendingHousingCard({
    required this.logement,
    required this.occupancy,
    required this.existingResidents,
    required this.pendingResidents,
  });

  factory ResidencePendingHousingCard.fromJson(Map<String, dynamic> json) {
    final logementJson = json['logement'];
    final occupancyJson = json['occupancy'];
    final existingJson = json['existingResidents'];
    final pendingJson = json['pendingResidents'];

    return ResidencePendingHousingCard(
      logement: logementJson is Map<String, dynamic>
          ? ResidenceHousingInfo.fromJson(logementJson)
          : const ResidenceHousingInfo(
              id: 0,
              residenceId: 0,
              typeLogement: null,
              numero: null,
              immeuble: null,
              etage: null,
              codePostal: null,
              adresse: null,
              codeInterne: '',
              active: false,
              dateActivation: null,
            ),
      occupancy: occupancyJson is Map<String, dynamic>
          ? ResidenceHousingOccupancy.fromJson(occupancyJson)
          : const ResidenceHousingOccupancy(
              logementId: 0,
              occupiedCount: 0,
              maxOccupants: 0,
              full: false,
            ),
      existingResidents: (existingJson is List ? existingJson : const <Object>[])
          .whereType<Map<String, dynamic>>()
          .map(ResidencePerson.fromJson)
          .toList(),
      pendingResidents: (pendingJson is List ? pendingJson : const <Object>[])
          .whereType<Map<String, dynamic>>()
          .map(ResidencePerson.fromJson)
          .toList(),
    );
  }

  final ResidenceHousingInfo logement;
  final ResidenceHousingOccupancy occupancy;
  final List<ResidencePerson> existingResidents;
  final List<ResidencePerson> pendingResidents;
}

class UpdateCurrentUserPayload {
  const UpdateCurrentUserPayload({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
    };
  }
}

class UpdateResidenceEntryDatePayload {
  const UpdateResidenceEntryDatePayload({required this.date});

  final DateTime date;

  Map<String, dynamic> toJson() {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return <String, dynamic>{'dateEntreeResidence': '$year-$month-$day'};
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

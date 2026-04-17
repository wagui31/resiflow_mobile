const int voteCommentMaxLength = 48;

enum VoteBusinessStatus {
  ouvert,
  cloture,
  valide,
  rejete,
  unknown;

  factory VoteBusinessStatus.fromApi(String? value) {
    return switch (_normalizeEnum(value)) {
      'OUVERT' => VoteBusinessStatus.ouvert,
      'CLOTURE' => VoteBusinessStatus.cloture,
      'VALIDE' => VoteBusinessStatus.valide,
      'REJETE' => VoteBusinessStatus.rejete,
      _ => VoteBusinessStatus.unknown,
    };
  }
}

enum VoteDisplayStatus {
  enCours,
  termine,
  unknown;

  factory VoteDisplayStatus.fromApi(String? value) {
    return switch (_normalizeEnum(value)) {
      'EN_COURS' => VoteDisplayStatus.enCours,
      'TERMINE' => VoteDisplayStatus.termine,
      _ => VoteDisplayStatus.unknown,
    };
  }
}

enum VoteChoice {
  pour,
  contre,
  neutre,
  egalite,
  aucun,
  unknown;

  factory VoteChoice.fromApi(String? value) {
    return switch (_normalizeEnum(value)) {
      'POUR' => VoteChoice.pour,
      'CONTRE' => VoteChoice.contre,
      'NEUTRE' => VoteChoice.neutre,
      'EGALITE' => VoteChoice.egalite,
      'AUCUN' => VoteChoice.aucun,
      _ => VoteChoice.unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      VoteChoice.pour => 'POUR',
      VoteChoice.contre => 'CONTRE',
      VoteChoice.neutre => 'NEUTRE',
      VoteChoice.egalite => 'EGALITE',
      VoteChoice.aucun => 'AUCUN',
      VoteChoice.unknown => 'UNKNOWN',
    };
  }
}

class VoteHousingParticipation {
  const VoteHousingParticipation({
    required this.logementId,
    required this.codeInterne,
    required this.totalEligibleVoters,
    required this.totalVoters,
    required this.hasVoted,
  });

  factory VoteHousingParticipation.fromJson(Map<String, dynamic> json) {
    return VoteHousingParticipation(
      logementId: _readInt(json['logementId']) ?? 0,
      codeInterne: (json['codeInterne'] as String?)?.trim() ?? '',
      totalEligibleVoters: _readInt(json['totalEligibleVoters']) ?? 0,
      totalVoters: _readInt(json['totalVoters']) ?? 0,
      hasVoted: json['hasVoted'] == true,
    );
  }

  final int logementId;
  final String codeInterne;
  final int totalEligibleVoters;
  final int totalVoters;
  final bool hasVoted;
}

class VoteOverview {
  const VoteOverview({
    required this.id,
    required this.residenceId,
    required this.title,
    required this.description,
    required this.estimatedAmount,
    required this.businessStatus,
    required this.displayStatus,
    required this.startDate,
    required this.endDate,
    required this.createdById,
    required this.createdByName,
    required this.expenseId,
    required this.totalPour,
    required this.totalContre,
    required this.totalNeutre,
    required this.totalVoters,
    required this.totalEligibleVoters,
    required this.leadingChoice,
    required this.currentUserHasVoted,
    required this.currentUserChoice,
    required this.currentUserComment,
    required this.currentUserCanVote,
    required this.daysRemaining,
    required this.nearEnd,
    required this.housingParticipations,
  });

  factory VoteOverview.fromJson(Map<String, dynamic> json) {
    return VoteOverview(
      id: _readInt(json['id']) ?? 0,
      residenceId: _readInt(json['residenceId']) ?? 0,
      title: (json['titre'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim() ?? '',
      estimatedAmount: _readDouble(json['montantEstime']),
      businessStatus: VoteBusinessStatus.fromApi(
        json['statutMetier'] as String? ?? json['statut'] as String?,
      ),
      displayStatus: VoteDisplayStatus.fromApi(
        json['statutAffichage'] as String?,
      ),
      startDate: _readDateTime(json['dateDebut'] as String?),
      endDate: _readDateTime(json['dateFin'] as String?),
      createdById: _readInt(json['creeParId']),
      createdByName: (json['creeParNom'] as String?)?.trim() ?? '',
      expenseId: _readInt(json['depenseId']),
      totalPour: _readInt(json['totalPour']) ?? 0,
      totalContre: _readInt(json['totalContre']) ?? 0,
      totalNeutre: _readInt(json['totalNeutre']) ?? 0,
      totalVoters: _readInt(json['totalVotants']) ?? 0,
      totalEligibleVoters: _readInt(json['totalVotantsEligibles']) ?? 0,
      leadingChoice: VoteChoice.fromApi(json['choixMajoritaire'] as String?),
      currentUserHasVoted: json['currentUserHasVoted'] == true,
      currentUserChoice: VoteChoice.fromApi(
        json['currentUserChoice'] as String?,
      ),
      currentUserComment: (json['currentUserComment'] as String?)?.trim(),
      currentUserCanVote: json['currentUserCanVote'] == true,
      daysRemaining: _readInt(json['joursRestants']) ?? 0,
      nearEnd: json['finProche'] == true,
      housingParticipations:
          (json['participationsLogements'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(VoteHousingParticipation.fromJson)
              .toList(),
    );
  }

  final int id;
  final int residenceId;
  final String title;
  final String description;
  final double estimatedAmount;
  final VoteBusinessStatus businessStatus;
  final VoteDisplayStatus displayStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? createdById;
  final String createdByName;
  final int? expenseId;
  final int totalPour;
  final int totalContre;
  final int totalNeutre;
  final int totalVoters;
  final int totalEligibleVoters;
  final VoteChoice leadingChoice;
  final bool currentUserHasVoted;
  final VoteChoice currentUserChoice;
  final String? currentUserComment;
  final bool currentUserCanVote;
  final int daysRemaining;
  final bool nearEnd;
  final List<VoteHousingParticipation> housingParticipations;

  int get leadingVotes {
    return switch (leadingChoice) {
      VoteChoice.pour => totalPour,
      VoteChoice.contre => totalContre,
      VoteChoice.neutre => totalNeutre,
      _ => 0,
    };
  }

  double get turnoutProgress {
    if (totalEligibleVoters <= 0) {
      return 0;
    }
    return (totalVoters / totalEligibleVoters).clamp(0, 1).toDouble();
  }

  double get pourShare {
    if (totalVoters <= 0) {
      return 0;
    }
    return totalPour / totalVoters;
  }

  double get contreShare {
    if (totalVoters <= 0) {
      return 0;
    }
    return totalContre / totalVoters;
  }

  double get neutreShare {
    if (totalVoters <= 0) {
      return 0;
    }
    return totalNeutre / totalVoters;
  }
}

class CreateVotePayload {
  const CreateVotePayload({
    required this.residenceId,
    required this.title,
    required this.description,
    required this.estimatedAmount,
    required this.startDate,
    required this.endDate,
  });

  final int residenceId;
  final String title;
  final String description;
  final double? estimatedAmount;
  final DateTime startDate;
  final DateTime endDate;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'residenceId': residenceId,
      'titre': title.trim(),
      'description': description.trim(),
      'montantEstime': estimatedAmount,
      'dateDebut': startDate.toIso8601String(),
      'dateFin': endDate.toIso8601String(),
    };
  }
}

class VoteActionPayload {
  const VoteActionPayload({required this.choice, this.comment});

  final VoteChoice choice;
  final String? comment;

  Map<String, dynamic> toJson() {
    final normalizedComment = comment?.trim();
    return <String, dynamic>{
      'choix': choice.apiValue,
      if (normalizedComment != null && normalizedComment.isNotEmpty)
        'commentaire': normalizedComment,
    };
  }
}

class VoteCommentDetail {
  const VoteCommentDetail({
    required this.userId,
    required this.userEmail,
    required this.logementId,
    required this.logementCodeInterne,
    required this.choice,
    required this.comment,
    required this.dateVote,
  });

  factory VoteCommentDetail.fromJson(Map<String, dynamic> json) {
    return VoteCommentDetail(
      userId: _readInt(json['userId']) ?? 0,
      userEmail: (json['userEmail'] as String?)?.trim() ?? '',
      logementId: _readInt(json['logementId']),
      logementCodeInterne: (json['logementCodeInterne'] as String?)?.trim(),
      choice: VoteChoice.fromApi(json['choix'] as String?),
      comment: (json['commentaire'] as String?)?.trim() ?? '',
      dateVote: _readDateTime(json['dateVote'] as String?),
    );
  }

  final int userId;
  final String userEmail;
  final int? logementId;
  final String? logementCodeInterne;
  final VoteChoice choice;
  final String comment;
  final DateTime? dateVote;

  bool get hasComment => comment.isNotEmpty;
}

class VoteDetails {
  const VoteDetails({required this.voteId, required this.comments});

  factory VoteDetails.fromJson(Map<String, dynamic> json) {
    return VoteDetails(
      voteId: _readInt(json['voteId']) ?? 0,
      comments: (json['votesUtilisateurs'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(VoteCommentDetail.fromJson)
          .where((detail) => detail.hasComment)
          .toList(),
    );
  }

  final int voteId;
  final List<VoteCommentDetail> comments;
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

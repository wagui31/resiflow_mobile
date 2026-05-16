enum AppNotificationType {
  userRegistrationPending,
  cagnottePaymentPendingAdmin,
  sharedExpensePaymentPendingAdmin,
  paymentValidated,
  expenseCreated,
  cagnotteCorrectionCreated,
  voteCreated,
  unknown;

  factory AppNotificationType.fromApi(String? value) {
    return switch ((value ?? '').trim().toUpperCase()) {
      'USER_REGISTRATION_PENDING' =>
        AppNotificationType.userRegistrationPending,
      'CAGNOTTE_PAYMENT_PENDING_ADMIN' =>
        AppNotificationType.cagnottePaymentPendingAdmin,
      'SHARED_EXPENSE_PAYMENT_PENDING_ADMIN' =>
        AppNotificationType.sharedExpensePaymentPendingAdmin,
      'PAYMENT_VALIDATED' => AppNotificationType.paymentValidated,
      'EXPENSE_CREATED' => AppNotificationType.expenseCreated,
      'CAGNOTTE_CORRECTION_CREATED' =>
        AppNotificationType.cagnotteCorrectionCreated,
      'VOTE_CREATED' => AppNotificationType.voteCreated,
      _ => AppNotificationType.unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      AppNotificationType.userRegistrationPending =>
        'USER_REGISTRATION_PENDING',
      AppNotificationType.cagnottePaymentPendingAdmin =>
        'CAGNOTTE_PAYMENT_PENDING_ADMIN',
      AppNotificationType.sharedExpensePaymentPendingAdmin =>
        'SHARED_EXPENSE_PAYMENT_PENDING_ADMIN',
      AppNotificationType.paymentValidated => 'PAYMENT_VALIDATED',
      AppNotificationType.expenseCreated => 'EXPENSE_CREATED',
      AppNotificationType.cagnotteCorrectionCreated =>
        'CAGNOTTE_CORRECTION_CREATED',
      AppNotificationType.voteCreated => 'VOTE_CREATED',
      AppNotificationType.unknown => 'UNKNOWN',
    };
  }
}

enum AppNotificationEntityType {
  user,
  paiement,
  depense,
  vote,
  cagnotteCorrection,
  unknown;

  factory AppNotificationEntityType.fromApi(String? value) {
    return switch ((value ?? '').trim().toUpperCase()) {
      'USER' => AppNotificationEntityType.user,
      'PAIEMENT' => AppNotificationEntityType.paiement,
      'DEPENSE' => AppNotificationEntityType.depense,
      'VOTE' => AppNotificationEntityType.vote,
      'CAGNOTTE_CORRECTION' => AppNotificationEntityType.cagnotteCorrection,
      _ => AppNotificationEntityType.unknown,
    };
  }
}

class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.residenceId,
    required this.type,
    required this.title,
    required this.body,
    required this.relatedEntityType,
    required this.relatedEntityId,
    required this.createdAt,
    required this.isRead,
    required this.readAt,
  });

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: _readInt(json['id']) ?? 0,
      residenceId: _readInt(json['residenceId']) ?? 0,
      type: AppNotificationType.fromApi(json['type'] as String?),
      title: (json['title'] as String? ?? '').trim(),
      body: (json['body'] as String? ?? '').trim(),
      relatedEntityType: AppNotificationEntityType.fromApi(
        json['relatedEntityType'] as String?,
      ),
      relatedEntityId: _readInt(json['relatedEntityId']),
      createdAt: _readDateTime(json['createdAt']),
      isRead: json['read'] as bool? ?? false,
      readAt: _readDateTime(json['readAt']),
    );
  }

  final int id;
  final int residenceId;
  final AppNotificationType type;
  final String title;
  final String body;
  final AppNotificationEntityType relatedEntityType;
  final int? relatedEntityId;
  final DateTime? createdAt;
  final bool isRead;
  final DateTime? readAt;

  AppNotificationItem copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return AppNotificationItem(
      id: id,
      residenceId: residenceId,
      type: type,
      title: title,
      body: body,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}

class AppUnreadNotificationCount {
  const AppUnreadNotificationCount({required this.count});

  factory AppUnreadNotificationCount.fromJson(Map<String, dynamic> json) {
    return AppUnreadNotificationCount(count: _readInt(json['count']) ?? 0);
  }

  final int count;
}

int? _readInt(Object? value) {
  return switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text),
    _ => null,
  };
}

DateTime? _readDateTime(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

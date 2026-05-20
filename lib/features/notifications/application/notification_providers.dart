import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../data/notification_repository.dart';
import '../domain/notification_models.dart';

const Duration _notificationsRefreshInterval = Duration(seconds: 20);
const int _notificationsDrawerLimit = 60;

final notificationsCenterControllerProvider = AsyncNotifierProvider<
  NotificationsCenterController,
  List<AppNotificationItem>
>(NotificationsCenterController.new);

final unreadNotificationsCountProvider = FutureProvider.autoDispose<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Future<int>.value(0);
  }

  final timer = Timer.periodic(_notificationsRefreshInterval, (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  return ref.read(notificationRepositoryProvider).fetchUnreadCount();
});

final usersNotificationCountProvider = FutureProvider.autoDispose<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Future<int>.value(0);
  }

  final timer = Timer.periodic(_notificationsRefreshInterval, (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  return ref.read(notificationRepositoryProvider).fetchUnreadCount(
    types: const <AppNotificationType>[
      AppNotificationType.userRegistrationPending,
    ],
  );
});

final paymentNotificationCountProvider = FutureProvider.autoDispose<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Future<int>.value(0);
  }

  final timer = Timer.periodic(_notificationsRefreshInterval, (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  return ref.read(notificationRepositoryProvider).fetchUnreadCount(
    types: const <AppNotificationType>[
      AppNotificationType.cagnottePaymentPendingAdmin,
      AppNotificationType.sharedExpensePaymentPendingAdmin,
      AppNotificationType.paymentValidated,
    ],
  );
});

final expenseNotificationCountProvider = FutureProvider.autoDispose<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Future<int>.value(0);
  }

  final timer = Timer.periodic(_notificationsRefreshInterval, (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  return ref.read(notificationRepositoryProvider).fetchUnreadCount(
    types: const <AppNotificationType>[
      AppNotificationType.expenseCreated,
      AppNotificationType.cagnotteCorrectionCreated,
    ],
  );
});

final voteNotificationCountProvider = FutureProvider.autoDispose<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Future<int>.value(0);
  }

  final timer = Timer.periodic(_notificationsRefreshInterval, (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  return ref.read(notificationRepositoryProvider).fetchUnreadCount(
    types: const <AppNotificationType>[
      AppNotificationType.voteCreated,
      AppNotificationType.voteClosed,
      AppNotificationType.voteDeleted,
    ],
  );
});

class NotificationsCenterController
    extends AsyncNotifier<List<AppNotificationItem>> {
  Timer? _timer;

  @override
  Future<List<AppNotificationItem>> build() async {
    ref.watch(currentUserProvider);
    _timer?.cancel();
    _timer = Timer.periodic(_notificationsRefreshInterval, (_) {
      ref.invalidateSelf();
    });
    ref.onDispose(() {
      _timer?.cancel();
    });
    return _fetch();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> markAsRead(int notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    final updated = await repository.markAsRead(notificationId);
    final currentItems = state.valueOrNull;
    if (currentItems != null) {
      state = AsyncValue.data(
        currentItems
            .map((item) => item.id == notificationId ? updated : item)
            .toList(),
      );
    } else {
      state = await AsyncValue.guard(_fetch);
    }
    _invalidateCounts();
  }

  Future<void> markAllAsRead() async {
    await ref.read(notificationRepositoryProvider).markAllAsRead();
    final currentItems = state.valueOrNull;
    if (currentItems != null) {
      final now = DateTime.now();
      state = AsyncValue.data(
        currentItems
            .map((item) => item.copyWith(isRead: true, readAt: now))
            .toList(),
      );
    } else {
      state = await AsyncValue.guard(_fetch);
    }
    _invalidateCounts();
  }

  Future<List<AppNotificationItem>> _fetch() {
    return ref.read(notificationRepositoryProvider).fetchNotifications(
      limit: _notificationsDrawerLimit,
    );
  }

  void _invalidateCounts() {
    ref.invalidate(unreadNotificationsCountProvider);
    ref.invalidate(usersNotificationCountProvider);
    ref.invalidate(paymentNotificationCountProvider);
    ref.invalidate(expenseNotificationCountProvider);
    ref.invalidate(voteNotificationCountProvider);
  }
}

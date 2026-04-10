import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../data/paiement_repository.dart';
import '../domain/paiement_models.dart';

enum PaymentViewMode { mine, resident, pending }
enum PaymentAdminAction { validate, reject }

const Duration _pendingPaymentsRefreshInterval = Duration(seconds: 15);

final paymentViewModeProvider = StateProvider<PaymentViewMode>(
  (ref) => PaymentViewMode.mine,
);

final selectedResidentEmailProvider = StateProvider<String?>((ref) => null);

final adminResidentPaymentProvider =
    FutureProvider.autoDispose.family<ResidentPaymentOverview, String>((
      ref,
      email,
    ) {
      ref.watch(currentUserProvider);
      return ref
          .read(paiementRepositoryProvider)
          .fetchAdminUserPaymentStatus(email);
    });

final residentPaymentControllerProvider =
    AsyncNotifierProvider<ResidentPaymentController, ResidentPaymentOverview>(
      ResidentPaymentController.new,
    );

final adminPendingPaymentsProvider =
    FutureProvider.autoDispose<List<PaymentRecord>>((ref) {
      ref.watch(currentUserProvider);
      final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
      final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;

      if (isAdmin) {
        final timer = Timer.periodic(_pendingPaymentsRefreshInterval, (_) {
          ref.invalidateSelf();
        });
        ref.onDispose(timer.cancel);
      }

      return ref.read(paiementRepositoryProvider).fetchAdminPendingPayments();
    });

final pendingPaymentsCountProvider = Provider.autoDispose<AsyncValue<int>>((
  ref,
) {
  final role = ref.watch(currentUserRoleProvider) ?? UserRole.unknown;
  final isAdmin = role == UserRole.admin || role == UserRole.superAdmin;

  if (!isAdmin) {
    return const AsyncValue.data(0);
  }

  final pendingPaymentsAsync = ref.watch(adminPendingPaymentsProvider);
  return pendingPaymentsAsync.whenData((payments) => payments.length);
});

class ResidentPaymentController extends AsyncNotifier<ResidentPaymentOverview> {
  @override
  Future<ResidentPaymentOverview> build() async {
    ref.watch(currentUserProvider);
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<PaymentRecord> createMyPayment(CreateMyPaymentPayload payload) async {
    final repository = ref.read(paiementRepositoryProvider);
    final createdPayment = await repository.createMyPayment(payload);
    state = await AsyncValue.guard(_fetch);
    return createdPayment;
  }

  Future<void> deletePendingPayment(int paymentId) async {
    final repository = ref.read(paiementRepositoryProvider);
    await repository.deletePendingPayment(paymentId);
    state = await AsyncValue.guard(_fetch);
  }

  Future<ResidentPaymentOverview> _fetch() {
    return ref.read(paiementRepositoryProvider).fetchMyPaymentStatus();
  }
}

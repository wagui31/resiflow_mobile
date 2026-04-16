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

final selectedPaymentLogementProvider =
    StateProvider<PaymentLogementOption?>((ref) => null);

final paymentResidenceLogementsProvider =
    FutureProvider.autoDispose<List<PaymentLogementOption>>((ref) async {
      final user = ref.watch(currentUserProvider);
      final residenceId = user?.residenceId;
      if (residenceId == null) {
        return <PaymentLogementOption>[];
      }

      return ref
          .read(paiementRepositoryProvider)
          .fetchResidenceLogements(residenceId);
    });

final adminResidentPaymentProvider =
    FutureProvider.autoDispose.family<ResidentPaymentOverview, int>((
      ref,
      logementId,
    ) {
      ref.watch(currentUserProvider);
      return ref
          .read(paiementRepositoryProvider)
          .fetchAdminUserPaymentStatus(logementId);
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

      if (!isAdmin) {
        return Future.value(const <PaymentRecord>[]);
      }

      final timer = Timer.periodic(_pendingPaymentsRefreshInterval, (_) {
        ref.invalidateSelf();
      });
      ref.onDispose(timer.cancel);

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

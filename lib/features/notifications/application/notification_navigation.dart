import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../depense/application/depense_providers.dart';
import '../../paiement/application/paiement_providers.dart';
import '../../users/application/users_providers.dart';
import '../domain/notification_models.dart';

void openNotificationTarget(
  BuildContext context,
  ProviderContainer container,
  AppNotificationType type,
) {
  switch (type) {
    case AppNotificationType.userRegistrationPending:
      container.read(usersTabProvider.notifier).state = UsersTab.pending;
      container.invalidate(residenceViewProvider);
      context.goNamed(settingsRouteName);
      return;
    case AppNotificationType.cagnottePaymentPendingAdmin:
    case AppNotificationType.sharedExpensePaymentPendingAdmin:
    case AppNotificationType.paymentValidated:
      container.read(paymentViewModeProvider.notifier).state =
          type == AppNotificationType.paymentValidated
          ? PaymentViewMode.mine
          : PaymentViewMode.pending;
      container.invalidate(adminPendingPaymentsProvider);
      context.goNamed(paiementRouteName);
      return;
    case AppNotificationType.expenseCreated:
    case AppNotificationType.cagnotteCorrectionCreated:
      container.read(expenseViewTabProvider.notifier).state =
          ExpenseViewTab.shared;
      container.invalidate(expenseOverviewProvider);
      context.goNamed(depenseRouteName);
      return;
    case AppNotificationType.voteCreated:
    case AppNotificationType.voteClosed:
    case AppNotificationType.voteDeleted:
      context.goNamed(voteRouteName);
      return;
    case AppNotificationType.unknown:
      context.goNamed(dashboardRouteName);
      return;
  }
}

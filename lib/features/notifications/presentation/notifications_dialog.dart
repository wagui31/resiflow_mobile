import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../application/notification_navigation.dart';
import '../../notifications/application/notification_providers.dart';
import '../domain/notification_models.dart';

Future<void> showNotificationsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const _NotificationsDialog(),
  );
}

class _NotificationsDialog extends ConsumerWidget {
  const _NotificationsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsCenterControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _dialogTitle(context),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: notificationsAsync.valueOrNull?.isEmpty ?? true
                        ? null
                        : () => ref
                              .read(
                                notificationsCenterControllerProvider.notifier,
                              )
                              .markAllAsRead(),
                    icon: const Icon(Icons.done_all_rounded),
                    label: Text(_markAllLabel(context)),
                  ),
                  IconButton(
                    tooltip: _closeLabel(context),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _dialogBody(context),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: notificationsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => _NotificationsErrorState(
                    message: _resolveNotificationsErrorMessage(context, error),
                    onRetry: () => ref
                        .read(notificationsCenterControllerProvider.notifier)
                        .refresh(),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return _NotificationsEmptyState(
                        title: _emptyTitle(context),
                        body: _emptyBody(context),
                      );
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _NotificationTile(item: item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.item});

  final AppNotificationItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _notificationAccentColor(context, item.type);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () async {
        await ref
            .read(notificationsCenterControllerProvider.notifier)
            .markAsRead(item.id);
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop();
        openNotificationTarget(
          context,
          ProviderScope.containerOf(context),
          item.type,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.28)
              : accentColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: item.isRead
                ? colorScheme.outlineVariant.withValues(alpha: 0.45)
                : accentColor.withValues(alpha: 0.34),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _notificationIcon(item.type),
                color: accentColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!item.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatNotificationDate(context, item.createdAt),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.notifications_none_rounded,
              size: 34,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsErrorState extends StatelessWidget {
  const _NotificationsErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 34,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorTitle(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(_retryLabel(context)),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _notificationIcon(AppNotificationType type) {
  return switch (type) {
    AppNotificationType.userRegistrationPending =>
      Icons.person_add_alt_1_rounded,
    AppNotificationType.cagnottePaymentPendingAdmin =>
      Icons.payments_rounded,
    AppNotificationType.sharedExpensePaymentPendingAdmin =>
      Icons.account_balance_wallet_rounded,
    AppNotificationType.paymentValidated => Icons.check_circle_rounded,
    AppNotificationType.expenseCreated => Icons.receipt_long_rounded,
    AppNotificationType.cagnotteCorrectionCreated => Icons.tune_rounded,
    AppNotificationType.voteCreated => Icons.how_to_vote_rounded,
    AppNotificationType.unknown => Icons.notifications_rounded,
  };
}

Color _notificationAccentColor(BuildContext context, AppNotificationType type) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (type) {
    AppNotificationType.userRegistrationPending => colorScheme.error,
    AppNotificationType.cagnottePaymentPendingAdmin =>
      colorScheme.primary,
    AppNotificationType.sharedExpensePaymentPendingAdmin =>
      colorScheme.primary,
    AppNotificationType.paymentValidated => Colors.green.shade700,
    AppNotificationType.expenseCreated => colorScheme.tertiary,
    AppNotificationType.cagnotteCorrectionCreated => colorScheme.secondary,
    AppNotificationType.voteCreated => colorScheme.primary,
    AppNotificationType.unknown => colorScheme.primary,
  };
}

String _formatNotificationDate(BuildContext context, DateTime? date) {
  if (date == null) {
    return '';
  }
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).add_Hm().format(date);
}

String _resolveNotificationsErrorMessage(BuildContext context, Object error) {
  final exception = ApiException.fromError(error);
  return switch (exception.kind) {
    ApiExceptionKind.timeout => _timeoutMessage(context),
    ApiExceptionKind.network => _networkMessage(context),
    ApiExceptionKind.unauthorized => _unauthorizedMessage(context),
    ApiExceptionKind.badRequest => exception.message,
    ApiExceptionKind.forbidden => exception.message,
    ApiExceptionKind.notFound => exception.message,
    ApiExceptionKind.unknown => exception.message,
  };
}

String _dialogTitle(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Notifications' : 'Notifications';
}

String _dialogBody(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Consultez les derniers evenements de votre residence et ouvrez directement le module concerne.'
      : 'Review the latest residence events and open the related module directly.';
}

String _markAllLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Tout lire' : 'Mark all read';
}

String _closeLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Fermer' : 'Close';
}

String _emptyTitle(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Aucune notification'
      : 'No notification';
}

String _emptyBody(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Les nouveaux evenements de la residence apparaitront ici.'
      : 'New residence events will appear here.';
}

String _errorTitle(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Impossible de charger les notifications'
      : 'Unable to load notifications';
}

String _retryLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Reessayer' : 'Retry';
}

String _timeoutMessage(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'La requete a pris trop de temps.'
      : 'The request took too long.';
}

String _networkMessage(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Impossible de contacter le serveur.'
      : 'Unable to contact the server.';
}

String _unauthorizedMessage(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Votre session ne permet pas d acceder aux notifications.'
      : 'Your session cannot access notifications.';
}

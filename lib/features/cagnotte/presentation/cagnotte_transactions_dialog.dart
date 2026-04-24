import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../application/cagnotte_providers.dart';
import '../domain/cagnotte_models.dart';

class CagnotteTransactionsDialog extends ConsumerWidget {
  const CagnotteTransactionsDialog({
    required this.residenceId,
    required this.currencyCode,
    super.key,
  });

  final int residenceId;
  final String? currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(
      residenceFundTransactionsProvider(residenceId),
    );
    final size = MediaQuery.of(context).size;
    final dialogWidth = size.width * 0.9;
    final dialogHeight = size.height * 0.9;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _DialogHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: transactionsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _DialogState(
                    icon: Icons.error_outline_rounded,
                    title: _dialogErrorTitle(context),
                    body: _resolveDialogErrorMessage(context, error),
                  ),
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return _DialogState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: _emptyTitle(context),
                        body: _emptyBody(context),
                      );
                    }

                    return _TransactionsTable(
                      transactions: transactions,
                      currencyCode: currencyCode,
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

class _DialogHeader extends StatelessWidget {
  const _DialogHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _dialogTitle(context),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _dialogBody(context),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _LegendBadge(
                      icon: Icons.arrow_upward_rounded,
                      color: _transactionTone(
                        context,
                        ResidenceFundTransactionType.contribution,
                      ),
                      label: context.l10n.cagnotteDialogLegendContribution,
                    ),
                    const SizedBox(width: 10),
                    _LegendBadge(
                      icon: Icons.arrow_downward_rounded,
                      color: _transactionTone(
                        context,
                        ResidenceFundTransactionType.depense,
                      ),
                      label: context.l10n.cagnotteDialogLegendExpense,
                    ),
                    const SizedBox(width: 10),
                    _LegendBadge(
                      icon: Icons.tune_rounded,
                      color: _transactionTone(
                        context,
                        ResidenceFundTransactionType.correction,
                      ),
                      label: _correctionLegendLabel(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _LegendBadge extends StatelessWidget {
  const _LegendBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsTable extends StatelessWidget {
  const _TransactionsTable({
    required this.transactions,
    required this.currencyCode,
  });

  final List<ResidenceFundTransaction> transactions;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
              ),
              columns: <DataColumn>[
                DataColumn(label: Text(_typeColumn(context))),
                DataColumn(
                  numeric: true,
                  label: Text(_amountColumn(context, currencyCode)),
                ),
                DataColumn(label: Text(_housingColumn(context))),
                DataColumn(label: Text(_createdAtColumn(context))),
              ],
              rows: transactions.map((transaction) {
                final tone = _transactionTone(context, transaction.type);
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Center(
                        child: Icon(
                          _transactionIcon(transaction.type),
                          color: tone,
                          size: 20,
                        ),
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          CurrencyFormatter.formatNumber(
                            context,
                            transaction.amount,
                          ),
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _housingValue(context, transaction),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatDate(context, transaction.createdAt),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogState extends StatelessWidget {
  const _DialogState({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 34, color: colorScheme.primary),
            const SizedBox(height: 14),
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
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCagnotteTransactionsDialog(
  BuildContext context, {
  required int residenceId,
  required String? currencyCode,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => CagnotteTransactionsDialog(
      residenceId: residenceId,
      currencyCode: currencyCode,
    ),
  );
}

String _dialogTitle(BuildContext context) {
  return context.l10n.cagnotteDialogTitle;
}

String _dialogBody(BuildContext context) {
  return context.l10n.cagnotteDialogBody;
}

String _dialogErrorTitle(BuildContext context) {
  return context.l10n.cagnotteDialogErrorTitle;
}

String _emptyTitle(BuildContext context) {
  return context.l10n.cagnotteDialogEmptyTitle;
}

String _emptyBody(BuildContext context) {
  return context.l10n.cagnotteDialogEmptyBody;
}

String _housingColumn(BuildContext context) {
  return context.l10n.cagnotteDialogHousingColumn;
}

String _typeColumn(BuildContext context) {
  return context.l10n.cagnotteDialogTypeColumn;
}

String _amountColumn(BuildContext context, String? currencyCode) {
  final label = context.l10n.cagnotteDialogAmountColumn;
  final normalizedCurrency = CurrencyFormatter.normalizeCurrency(currencyCode);
  if (normalizedCurrency == null) {
    return label;
  }
  return '$label $normalizedCurrency';
}

String _createdAtColumn(BuildContext context) {
  return context.l10n.cagnotteDialogDateColumn;
}

String _housingValue(
  BuildContext context,
  ResidenceFundTransaction transaction,
) {
  final value = (transaction.logementCodeInterne ?? '').trim();
  if (value.isNotEmpty) {
    return value;
  }
  return context.l10n.cagnotteDialogHousingUnavailable;
}

Color _transactionTone(
  BuildContext context,
  ResidenceFundTransactionType type,
) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (type) {
    ResidenceFundTransactionType.contribution => Colors.green.shade700,
    ResidenceFundTransactionType.depense => colorScheme.error,
    ResidenceFundTransactionType.correction => colorScheme.primary,
    ResidenceFundTransactionType.unknown => colorScheme.onSurfaceVariant,
  };
}

IconData _transactionIcon(ResidenceFundTransactionType type) {
  return switch (type) {
    ResidenceFundTransactionType.contribution => Icons.arrow_upward_rounded,
    ResidenceFundTransactionType.depense => Icons.arrow_downward_rounded,
    ResidenceFundTransactionType.correction => Icons.tune_rounded,
    ResidenceFundTransactionType.unknown => Icons.remove_rounded,
  };
}

String _correctionLegendLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Correction' : 'Correction';
}

String _formatDate(BuildContext context, DateTime? value) {
  if (value == null) {
    return context.l10n.paymentDateUnavailable;
  }
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
}

String _resolveDialogErrorMessage(BuildContext context, Object error) {
  final exception = ApiException.fromError(error);
  return switch (exception.kind) {
    ApiExceptionKind.timeout => context.l10n.authErrorTimeout,
    ApiExceptionKind.network => context.l10n.authErrorNetwork,
    ApiExceptionKind.unauthorized => context.l10n.authErrorUnauthorized,
    ApiExceptionKind.badRequest => exception.message,
    ApiExceptionKind.forbidden => exception.message,
    ApiExceptionKind.notFound => exception.message,
    ApiExceptionKind.unknown => exception.message,
  };
}

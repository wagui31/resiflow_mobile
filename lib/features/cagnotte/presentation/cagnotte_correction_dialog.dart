import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../../depense/application/depense_providers.dart';
import '../../users/application/users_providers.dart';
import '../application/cagnotte_providers.dart';
import '../data/cagnotte_repository.dart';

const confirmationDeltaTextKey = ValueKey<String>(
  'cagnotte-correction-confirm-delta',
);

Future<void> showCagnotteCorrectionDialog(
  BuildContext context, {
  required int residenceId,
  required double currentBalance,
  required String? currencyCode,
}) {
  final parentContext = context;
  return showDialog<void>(
    context: context,
    builder: (context) => _CagnotteCorrectionDialog(
      parentContext: parentContext,
      residenceId: residenceId,
      currentBalance: currentBalance,
      currencyCode: currencyCode,
    ),
  );
}

class _CagnotteCorrectionDialog extends ConsumerStatefulWidget {
  const _CagnotteCorrectionDialog({
    required this.parentContext,
    required this.residenceId,
    required this.currentBalance,
    required this.currencyCode,
  });

  final BuildContext parentContext;
  final int residenceId;
  final double currentBalance;
  final String? currencyCode;

  @override
  ConsumerState<_CagnotteCorrectionDialog> createState() =>
      _CagnotteCorrectionDialogState();
}

class _CagnotteCorrectionDialogState
    extends ConsumerState<_CagnotteCorrectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _balanceController = TextEditingController();
  final _motifController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _balanceController.text = widget.currentBalance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _motifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(_title(context)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _body(context),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ReadOnlyAmountRow(
                        label: _currentBalanceLabel(context),
                        amount: widget.currentBalance,
                        currencyCode: widget.currencyCode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                  ],
                  decoration:
                      InputDecoration(
                            labelText: _newBalanceFieldLabel(context),
                            hintText: '0.00',
                          )
                          .applyDefaults(theme.inputDecorationTheme)
                          .copyWith(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                  validator: (value) {
                    final amount = _parseAmount(value);
                    if (amount == null) {
                      return _newBalanceRequiredError(context);
                    }
                    if (amount < 0) {
                      return _newBalanceNegativeError(context);
                    }
                    if ((amount - widget.currentBalance).abs() < 0.0001) {
                      return _sameBalanceError(context);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _motifController,
                  minLines: 3,
                  maxLines: 5,
                  decoration:
                      InputDecoration(
                            labelText: _reasonFieldLabel(context),
                            alignLabelWithHint: true,
                          )
                          .applyDefaults(theme.inputDecorationTheme)
                          .copyWith(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return _reasonRequiredError(context);
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.paymentDialogCancel),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.tune_rounded),
          label: Text(_submitLabel(context)),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final nouveauSolde = _parseAmount(_balanceController.text);
    if (nouveauSolde == null) {
      return;
    }

    final motif = _motifController.text.trim();
    final parentContext = widget.parentContext;
    final container = ProviderScope.containerOf(parentContext, listen: false);
    final messenger = ScaffoldMessenger.of(parentContext);
    final navigator = Navigator.of(context);
    final localeCode = Localizations.localeOf(
      parentContext,
    ).languageCode.toLowerCase();
    final timeoutError = parentContext.l10n.authErrorTimeout;
    final networkError = parentContext.l10n.authErrorNetwork;
    final unauthorizedError = parentContext.l10n.authErrorUnauthorized;

    navigator.pop();

    final confirmed = await _confirmCorrection(
      parentContext,
      nouveauSolde: nouveauSolde,
      motif: motif,
    );
    if (confirmed != true) {
      return;
    }

    final pendingMessage = _pendingConfirmationMessage(localeCode);
    final successMessage = _successMessage(localeCode);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pendingMessage)));

    try {
      await container
          .read(cagnotteRepositoryProvider)
          .createCorrection(
            residenceId: widget.residenceId,
            nouveauSolde: nouveauSolde,
            motif: motif,
          );

      container.invalidate(dashboardSnapshotProvider);
      container.invalidate(expenseOverviewProvider);
      container.invalidate(residenceViewProvider);
      container.invalidate(
        residenceFundTransactionsProvider(widget.residenceId),
      );

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      final errorMessage = _resolveErrorMessage(
        error,
        timeoutError: timeoutError,
        networkError: networkError,
        unauthorizedError: unauthorizedError,
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<bool?> _confirmCorrection(
    BuildContext parentContext, {
    required double nouveauSolde,
    required String motif,
  }) {
    final delta = double.parse(
      (nouveauSolde - widget.currentBalance).toStringAsFixed(2),
    );
    final isNegative = delta < 0;
    final deltaColor = isNegative ? Colors.red.shade700 : Colors.green.shade700;

    return showDialog<bool>(
      context: parentContext,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final absoluteDelta = delta.abs();

        return AlertDialog(
          title: Text(_confirmationTitle(dialogContext)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ReadOnlyAmountRow(
                  label: _currentBalanceLabel(dialogContext),
                  amount: widget.currentBalance,
                  currencyCode: widget.currencyCode,
                ),
                const SizedBox(height: 8),
                _ReadOnlyAmountRow(
                  label: _newBalanceFieldLabel(dialogContext),
                  amount: nouveauSolde,
                  currencyCode: widget.currencyCode,
                ),
                const SizedBox(height: 8),
                Text(
                  _reasonFieldLabel(dialogContext),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(motif),
                const SizedBox(height: 16),
                Text(
                  _deltaConfirmationLabel(dialogContext),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(
                    dialogContext,
                    absoluteDelta,
                    currencyCode: widget.currencyCode,
                  ),
                  key: confirmationDeltaTextKey,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isNegative
                      ? _negativeConfirmationWarning(dialogContext)
                      : _positiveConfirmationWarning(dialogContext),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(dialogContext.l10n.paymentDialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(_confirmationActionLabel(dialogContext)),
            ),
          ],
        );
      },
    );
  }
}

class _ReadOnlyAmountRow extends StatelessWidget {
  const _ReadOnlyAmountRow({
    required this.label,
    required this.amount,
    required this.currencyCode,
  });

  final String label;
  final double? amount;
  final String? currencyCode;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          amount == null
              ? '-'
              : CurrencyFormatter.format(
                  context,
                  amount!,
                  currencyCode: currencyCode,
                ),
          textAlign: TextAlign.right,
          style: textStyle,
        ),
      ],
    );
  }
}

double? _parseAmount(String? rawValue) {
  if (rawValue == null) {
    return null;
  }
  final normalized = rawValue.trim().replaceAll(',', '.');
  if (normalized.isEmpty) {
    return null;
  }
  return double.tryParse(normalized);
}

String _title(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Correction du solde cagnotte'
      : 'Fund balance correction';
}

String _body(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Saisissez le montant corrige et le motif. Une transaction de correction sera creee et apparaitra dans l historique.'
      : 'Adjust the current fund balance. A correction transaction will be created and added to the history.';
}

String _currentBalanceLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Solde actuel' : 'Current balance';
}

String _newBalanceFieldLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Montant corrige' : 'Corrected amount';
}

String _reasonFieldLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Motif' : 'Reason';
}

String _submitLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Corriger' : 'Apply correction';
}

String _confirmationTitle(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Confirmer la correction' : 'Confirm correction';
}

String _confirmationActionLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Confirmer' : 'Confirm';
}

String _deltaConfirmationLabel(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Delta visible' : 'Visible delta';
}

String _negativeConfirmationWarning(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Attention vous allez baisser le solde de la cagnotte de ce delta. Cela va etre visible pour tous les residents.'
      : 'Warning: you are about to decrease the fund balance by this delta. This will be visible to all residents.';
}

String _positiveConfirmationWarning(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Attention vous allez augmenter le solde de la cagnotte de ce delta. Cela va etre visible pour tous les residents.'
      : 'Warning: you are about to increase the fund balance by this delta. This will be visible to all residents.';
}

String _newBalanceRequiredError(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Saisissez un nouveau solde valide.'
      : 'Enter a valid new balance.';
}

String _newBalanceNegativeError(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Le nouveau solde doit etre superieur ou egal a zero.'
      : 'The new balance must be greater than or equal to zero.';
}

String _sameBalanceError(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr'
      ? 'Le nouveau solde doit etre different du solde actuel.'
      : 'The new balance must be different from the current balance.';
}

String _reasonRequiredError(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode.toLowerCase();
  return locale == 'fr' ? 'Le motif est obligatoire.' : 'A reason is required.';
}

String _successMessage(String localeCode) {
  return localeCode == 'fr'
      ? 'La correction de cagnotte a ete enregistree.'
      : 'The fund correction has been recorded.';
}

String _pendingConfirmationMessage(String localeCode) {
  return localeCode == 'fr'
      ? 'Confirmation admin en cours...'
      : 'Admin confirmation in progress...';
}

String _resolveErrorMessage(
  Object error, {
  required String timeoutError,
  required String networkError,
  required String unauthorizedError,
}) {
  final exception = ApiException.fromError(error);
  return switch (exception.kind) {
    ApiExceptionKind.timeout => timeoutError,
    ApiExceptionKind.network => networkError,
    ApiExceptionKind.unauthorized => unauthorizedError,
    ApiExceptionKind.badRequest => exception.message,
    ApiExceptionKind.forbidden => exception.message,
    ApiExceptionKind.notFound => exception.message,
    ApiExceptionKind.unknown => exception.message,
  };
}

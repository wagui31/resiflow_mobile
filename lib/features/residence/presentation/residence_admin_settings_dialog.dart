import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../../depense/application/depense_providers.dart';
import '../../users/application/users_providers.dart';
import '../data/residence_repository.dart';
import '../domain/residence_models.dart';

Future<bool?> showResidenceAdminSettingsDialog(
  BuildContext context, {
  required int residenceId,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        _ResidenceAdminSettingsDialog(residenceId: residenceId),
  );
}

class _ResidenceAdminSettingsDialog extends ConsumerStatefulWidget {
  const _ResidenceAdminSettingsDialog({required this.residenceId});

  final int residenceId;

  @override
  ConsumerState<_ResidenceAdminSettingsDialog> createState() =>
      _ResidenceAdminSettingsDialogState();
}

class _ResidenceAdminSettingsDialogState
    extends ConsumerState<_ResidenceAdminSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _codeController = TextEditingController();
  final _amountController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _errorText;
  String? _currencyCode;
  int _maxOccupants = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _codeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ResponsiveBuilder(
      builder: (context, layout) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: layout.isMobile ? 16 : 24,
            vertical: 24,
          ),
          titlePadding: EdgeInsets.fromLTRB(
            layout.isMobile ? 20 : 28,
            layout.isMobile ? 20 : 24,
            layout.isMobile ? 20 : 28,
            0,
          ),
          contentPadding: EdgeInsets.fromLTRB(
            layout.isMobile ? 20 : 28,
            18,
            layout.isMobile ? 20 : 28,
            0,
          ),
          actionsPadding: EdgeInsets.fromLTRB(
            layout.isMobile ? 16 : 24,
            12,
            layout.isMobile ? 16 : 24,
            layout.isMobile ? 16 : 20,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                context.l10n.accountMenuResidenceData,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.residenceAdminSettingsSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: layout.isMobile ? 420 : 560,
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _DialogSection(
                            title: context.l10n.residenceAdminSettingsSection,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: _nameController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: context
                                        .l10n
                                        .residenceAdminSettingsNameLabel,
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return context
                                          .l10n
                                          .residenceAdminSettingsNameError;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _addressController,
                                  textInputAction: TextInputAction.next,
                                  minLines: 2,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    labelText: context
                                        .l10n
                                        .residenceAdminSettingsAddressLabel,
                                    alignLabelWithHint: true,
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return context
                                          .l10n
                                          .residenceAdminSettingsAddressError;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _codeController,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: InputDecoration(
                                    labelText: context
                                        .l10n
                                        .residenceAdminSettingsCodeLabel,
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return context
                                          .l10n
                                          .residenceAdminSettingsCodeError;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _amountController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9,\.]'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: context
                                        .l10n
                                        .residenceAdminSettingsMonthlyAmountLabel,
                                    suffixText: _currencyCode,
                                  ),
                                  validator: (value) {
                                    final amount = _parseAmount(value);
                                    if (amount == null || amount <= 0) {
                                      return context
                                          .l10n
                                          .residenceAdminSettingsMonthlyAmountError;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                DropdownButtonFormField<int>(
                                  initialValue: _maxOccupants,
                                  decoration: InputDecoration(
                                    labelText: context
                                        .l10n
                                        .residenceAdminSettingsMaxOccupantsLabel,
                                  ),
                                  items: List<DropdownMenuItem<int>>.generate(5, (
                                    index,
                                  ) {
                                    final value = index + 1;
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                        context.l10n
                                            .residenceAdminSettingsOccupantsValue(
                                              value,
                                            ),
                                      ),
                                    );
                                  }),
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() {
                                      _maxOccupants = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (_errorText != null) ...<Widget>[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer.withValues(
                                  alpha: 0.72,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                _errorText!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _saving
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(context.l10n.paymentDialogCancel),
            ),
            FilledButton(
              onPressed: _loading || _saving ? null : _submit,
              child: Text(
                _saving
                    ? context.l10n.authSubmittingLabel
                    : context.l10n.usersSaveAction,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ref
          .read(residenceRepositoryProvider)
          .fetchAdminSettings(widget.residenceId);
      if (!mounted) {
        return;
      }
      setState(() {
        _nameController.text = settings.name;
        _addressController.text = settings.address;
        _codeController.text = settings.code;
        _amountController.text = settings.montantMensuel.toStringAsFixed(2);
        _currencyCode = settings.currency;
        _maxOccupants = settings.maxOccupantsParLogement.clamp(1, 5);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = _resolveErrorMessage(context, error);
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final amount = _parseAmount(_amountController.text);
    if (amount == null) {
      setState(() {
        _errorText = context.l10n.residenceAdminSettingsMonthlyAmountError;
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await ref
          .read(residenceRepositoryProvider)
          .updateAdminSettings(
            widget.residenceId,
            UpdateResidenceAdminSettingsPayload(
              name: _nameController.text,
              address: _addressController.text,
              code: _codeController.text.toUpperCase(),
              montantMensuel: amount,
              maxOccupantsParLogement: _maxOccupants,
            ),
          );

      ref.invalidate(dashboardSnapshotProvider);
      ref.invalidate(expenseOverviewProvider);
      ref.invalidate(residenceViewProvider);
      ref.invalidate(residenceAlertsProvider);
      await ref
          .read(authSessionControllerProvider.notifier)
          .refreshCurrentUser();

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = _resolveErrorMessage(context, error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  double? _parseAmount(String? value) {
    final normalized = (value ?? '').trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  String _resolveErrorMessage(BuildContext context, Object error) {
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
}

class _DialogSection extends StatelessWidget {
  const _DialogSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.62),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../../features/auth/domain/auth_models.dart';
import '../../features/users/data/users_repository.dart';
import '../../features/users/domain/users_models.dart';
import '../api/api_exception.dart';
import '../i18n/extensions/app_localizations_x.dart';
import '../responsive/responsive_builder.dart';

Future<bool?> showAccountSettingsDialog(
  BuildContext context, {
  required UserProfile currentUser,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _AccountSettingsDialog(currentUser: currentUser),
  );
}

class _AccountSettingsDialog extends ConsumerStatefulWidget {
  const _AccountSettingsDialog({required this.currentUser});

  final UserProfile currentUser;

  @override
  ConsumerState<_AccountSettingsDialog> createState() =>
      _AccountSettingsDialogState();
}

class _AccountSettingsDialogState
    extends ConsumerState<_AccountSettingsDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _submitting = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.currentUser.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.currentUser.lastName ?? '',
    );
    _currentPasswordController.addListener(_handlePasswordFieldsChanged);
    _newPasswordController.addListener(_handlePasswordFieldsChanged);
    _confirmPasswordController.addListener(_handlePasswordFieldsChanged);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _currentPasswordController
      ..removeListener(_handlePasswordFieldsChanged)
      ..dispose();
    _newPasswordController
      ..removeListener(_handlePasswordFieldsChanged)
      ..dispose();
    _confirmPasswordController
      ..removeListener(_handlePasswordFieldsChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final passwordDraft = _PasswordDraft(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    final hasPasswordInput = passwordDraft.hasAnyValue;
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.82;

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
                context.l10n.accountSettingsTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.accountSettingsSubtitle,
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
              maxHeight: maxDialogHeight,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _DialogSection(
                    title: context.l10n.accountSettingsIdentitySection,
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _firstNameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: context.l10n.usersFirstNameLabel,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _lastNameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: context.l10n.usersLastNameLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DialogSection(
                    title: context.l10n.accountSettingsPasswordSection,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          context.l10n.accountSettingsPasswordHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrentPassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText:
                                context.l10n.accountSettingsCurrentPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: context.l10n.accountSettingsNewPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submitting ? null : _submit(),
                          decoration: InputDecoration(
                            labelText: context.l10n.authConfirmPasswordLabel,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _PasswordCriteriaList(
                          draft: passwordDraft,
                          active: hasPasswordInput,
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
          actions: <Widget>[
            TextButton(
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(context.l10n.paymentDialogCancel),
            ),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(
                _submitting
                    ? context.l10n.authSubmittingLabel
                    : context.l10n.usersSaveAction,
              ),
            ),
          ],
        );
      },
    );
  }

  void _handlePasswordFieldsChanged() {
    if (_errorText == null) {
      return;
    }
    setState(() {
      _errorText = null;
    });
  }

  Future<void> _submit() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final passwordDraft = _PasswordDraft(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    final validationError = _validate(firstName, lastName, passwordDraft);
    if (validationError != null) {
      setState(() {
        _errorText = validationError;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      final repository = ref.read(usersRepositoryProvider);
      final updatedUser = await repository.updateCurrentUser(
        UpdateCurrentUserPayload(firstName: firstName, lastName: lastName),
      );

      if (passwordDraft.hasAnyValue) {
        await repository.updateCurrentUserPassword(
          UpdateCurrentUserPasswordPayload(
            currentPassword: passwordDraft.currentPassword.trim(),
            newPassword: passwordDraft.newPassword.trim(),
            confirmPassword: passwordDraft.confirmPassword.trim(),
          ),
        );
      }

      ref
          .read(authSessionControllerProvider.notifier)
          .setCurrentUser(updatedUser);

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
          _submitting = false;
        });
      }
    }
  }

  String? _validate(
    String firstName,
    String lastName,
    _PasswordDraft passwordDraft,
  ) {
    if (firstName.isEmpty || lastName.isEmpty) {
      return context.l10n.authRequiredFieldsMessage;
    }

    if (!passwordDraft.hasAnyValue) {
      return null;
    }

    if (!passwordDraft.hasAllValues) {
      return context.l10n.accountSettingsPasswordRequiredFields;
    }
    if (!passwordDraft.hasMinLength) {
      return context.l10n.accountSettingsPasswordMinLength;
    }
    if (!passwordDraft.hasUppercase) {
      return context.l10n.accountSettingsPasswordUppercase;
    }
    if (!passwordDraft.hasLowercase) {
      return context.l10n.accountSettingsPasswordLowercase;
    }
    if (!passwordDraft.hasSpecialCharacter) {
      return context.l10n.accountSettingsPasswordSpecialCharacter;
    }
    if (!passwordDraft.matchesConfirmation) {
      return context.l10n.authPasswordMismatchMessage;
    }
    return null;
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

class _PasswordCriteriaList extends StatelessWidget {
  const _PasswordCriteriaList({required this.draft, required this.active});

  final _PasswordDraft draft;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _PasswordCriterionRow(
          label: context.l10n.accountSettingsPasswordMinLength,
          satisfied: draft.hasMinLength,
          active: active,
        ),
        const SizedBox(height: 8),
        _PasswordCriterionRow(
          label: context.l10n.accountSettingsPasswordUppercase,
          satisfied: draft.hasUppercase,
          active: active,
        ),
        const SizedBox(height: 8),
        _PasswordCriterionRow(
          label: context.l10n.accountSettingsPasswordLowercase,
          satisfied: draft.hasLowercase,
          active: active,
        ),
        const SizedBox(height: 8),
        _PasswordCriterionRow(
          label: context.l10n.accountSettingsPasswordSpecialCharacter,
          satisfied: draft.hasSpecialCharacter,
          active: active,
        ),
        const SizedBox(height: 8),
        _PasswordCriterionRow(
          label: context.l10n.accountSettingsPasswordConfirmation,
          satisfied:
              draft.matchesConfirmation &&
              draft.confirmPassword.trim().isNotEmpty,
          active: active,
        ),
      ],
    );
  }
}

class _PasswordCriterionRow extends StatelessWidget {
  const _PasswordCriterionRow({
    required this.label,
    required this.satisfied,
    required this.active,
  });

  final String label;
  final bool satisfied;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedColor = !active
        ? colorScheme.onSurfaceVariant
        : satisfied
        ? const Color(0xFF1F8A4C)
        : colorScheme.error;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          satisfied
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 18,
          color: resolvedColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: resolvedColor,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordDraft {
  const _PasswordDraft({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  bool get hasAnyValue =>
      currentPassword.trim().isNotEmpty ||
      newPassword.trim().isNotEmpty ||
      confirmPassword.trim().isNotEmpty;

  bool get hasAllValues =>
      currentPassword.trim().isNotEmpty &&
      newPassword.trim().isNotEmpty &&
      confirmPassword.trim().isNotEmpty;

  bool get hasMinLength => newPassword.trim().length >= 8;

  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(newPassword.trim());

  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(newPassword.trim());

  bool get hasSpecialCharacter =>
      RegExp(r'[^A-Za-z0-9]').hasMatch(newPassword.trim());

  bool get matchesConfirmation => newPassword.trim() == confirmPassword.trim();
}

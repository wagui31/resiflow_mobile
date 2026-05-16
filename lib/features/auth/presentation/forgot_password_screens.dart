import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/language_switcher.dart';
import '../application/auth_error_message_resolver.dart';
import '../application/forgot_password_controller.dart';

class ForgotPasswordCodeRouteData {
  const ForgotPasswordCodeRouteData({required this.email});

  final String email;
}

class ForgotPasswordResetRouteData {
  const ForgotPasswordResetRouteData({
    required this.email,
    required this.resetSessionToken,
    required this.resetSessionExpiresAt,
  });

  final String email;
  final String resetSessionToken;
  final DateTime? resetSessionExpiresAt;
}

class ForgotPasswordEmailScreen extends ConsumerStatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  ConsumerState<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState
    extends ConsumerState<ForgotPasswordEmailScreen> {
  late final TextEditingController _emailController;
  late final FocusNode _emailFocusNode;
  String? _feedbackMessage;
  bool _feedbackIsError = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    return _ForgotPasswordShell(
      title: context.l10n.authForgotPasswordEmailTitle,
      subtitle: context.l10n.authForgotPasswordEmailSubtitle,
      stage: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ForgotPasswordStageHeader(
            icon: Icons.mail_outline_rounded,
            title: context.l10n.authForgotPasswordStageEmail,
            body: context.l10n.authForgotPasswordEmailBody,
          ),
          const SizedBox(height: 24),
          if (_feedbackMessage != null) ...<Widget>[
            _ForgotPasswordBanner(
              message: _feedbackMessage!,
              isError: _feedbackIsError,
            ),
            const SizedBox(height: 18),
          ],
          TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.email],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: context.l10n.authEmailLabel,
              hintText: 'lea.martin@example.com',
              prefixIcon: const Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 12),
          _ForgotPasswordHint(message: context.l10n.authForgotPasswordEmailHint),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isSubmitting ? null : _submit,
              icon: state.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Icon(Icons.mark_email_unread_outlined),
              label: Text(
                state.isSubmitting
                    ? context.l10n.authSubmittingLabel
                    : context.l10n.authForgotPasswordSendCode,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => context.goNamed(loginRouteName),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(context.l10n.authBackToLogin),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _setFeedback(context.l10n.authRequiredFieldsMessage, isError: true);
      return;
    }
    if (!_isValidEmail(email)) {
      _setFeedback(context.l10n.authInvalidEmailMessage, isError: true);
      return;
    }

    try {
      final result = await ref
          .read(forgotPasswordControllerProvider.notifier)
          .requestCode(email: email);
      if (!mounted) {
        return;
      }
      _setFeedback(
        result.message.isEmpty
            ? context.l10n.authForgotPasswordGenericSuccess
            : result.message,
        isError: false,
      );
      context.pushNamed(
        forgotPasswordCodeRouteName,
        extra: ForgotPasswordCodeRouteData(email: email),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _setFeedback(
        AuthErrorMessageResolver.resolve(context.l10n, error),
        isError: true,
      );
    }
  }

  void _setFeedback(String message, {required bool isError}) {
    setState(() {
      _feedbackMessage = message;
      _feedbackIsError = isError;
    });
  }
}

class ForgotPasswordCodeScreen extends ConsumerStatefulWidget {
  const ForgotPasswordCodeScreen({required this.email, super.key});

  final String email;

  @override
  ConsumerState<ForgotPasswordCodeScreen> createState() =>
      _ForgotPasswordCodeScreenState();
}

class _ForgotPasswordCodeScreenState
    extends ConsumerState<ForgotPasswordCodeScreen> {
  late final TextEditingController _codeController;
  late final FocusNode _codeFocusNode;
  Timer? _cooldownTimer;
  int _cooldownSecondsRemaining = 0;
  String? _feedbackMessage;
  bool _feedbackIsError = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _codeFocusNode = FocusNode();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    return _ForgotPasswordShell(
      title: context.l10n.authForgotPasswordCodeTitle,
      subtitle: context.l10n.authForgotPasswordCodeSubtitle(widget.email),
      stage: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ForgotPasswordStageHeader(
            icon: Icons.pin_outlined,
            title: context.l10n.authForgotPasswordStageCode,
            body: context.l10n.authForgotPasswordCodeBody,
          ),
          const SizedBox(height: 24),
          if (_feedbackMessage != null) ...<Widget>[
            _ForgotPasswordBanner(
              message: _feedbackMessage!,
              isError: _feedbackIsError,
            ),
            const SizedBox(height: 18),
          ],
          _OtpPreviewField(
            controller: _codeController,
            focusNode: _codeFocusNode,
            length: 6,
            label: context.l10n.authForgotPasswordCodeLabel,
          ),
          const SizedBox(height: 12),
          _ForgotPasswordHint(
            message: context.l10n.authForgotPasswordCodeValidity,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isSubmitting ? null : _verifyCode,
              icon: state.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Icon(Icons.verified_user_outlined),
              label: Text(
                state.isSubmitting
                    ? context.l10n.authSubmittingLabel
                    : context.l10n.authForgotPasswordVerifyCode,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.edit_rounded),
                label: Text(context.l10n.authForgotPasswordChangeEmail),
              ),
              TextButton.icon(
                onPressed: _cooldownSecondsRemaining > 0 || state.isSubmitting
                    ? null
                    : _resendCode,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  _cooldownSecondsRemaining > 0
                      ? context.l10n.authForgotPasswordResendCooldown(
                          _cooldownSecondsRemaining,
                        )
                      : context.l10n.authForgotPasswordResendCode,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.goNamed(loginRouteName),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(context.l10n.authBackToLogin),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _setFeedback(
        context.l10n.authForgotPasswordCodeFormatError,
        isError: true,
      );
      return;
    }

    try {
      final result = await ref
          .read(forgotPasswordControllerProvider.notifier)
          .verifyCode(email: widget.email, code: code);
      if (!mounted) {
        return;
      }
      context.pushNamed(
        forgotPasswordResetRouteName,
        extra: ForgotPasswordResetRouteData(
          email: widget.email,
          resetSessionToken: result.resetSessionToken,
          resetSessionExpiresAt: result.resetSessionExpiresAt,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _setFeedback(
        AuthErrorMessageResolver.resolve(context.l10n, error),
        isError: true,
      );
    }
  }

  Future<void> _resendCode() async {
    try {
      final result = await ref
          .read(forgotPasswordControllerProvider.notifier)
          .requestCode(email: widget.email);
      if (!mounted) {
        return;
      }
      _codeController.clear();
      _startCooldown();
      _setFeedback(
        result.message.isEmpty
            ? context.l10n.authForgotPasswordGenericSuccess
            : result.message,
        isError: false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _setFeedback(
        AuthErrorMessageResolver.resolve(context.l10n, error),
        isError: true,
      );
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() {
      _cooldownSecondsRemaining = 60;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _cooldownSecondsRemaining <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _cooldownSecondsRemaining = 0;
          });
        }
        return;
      }
      setState(() {
        _cooldownSecondsRemaining -= 1;
      });
    });
  }

  void _setFeedback(String message, {required bool isError}) {
    setState(() {
      _feedbackMessage = message;
      _feedbackIsError = isError;
    });
  }
}

class ForgotPasswordResetScreen extends ConsumerStatefulWidget {
  const ForgotPasswordResetScreen({
    required this.email,
    required this.resetSessionToken,
    required this.resetSessionExpiresAt,
    super.key,
  });

  final String email;
  final String resetSessionToken;
  final DateTime? resetSessionExpiresAt;

  @override
  ConsumerState<ForgotPasswordResetScreen> createState() =>
      _ForgotPasswordResetScreenState();
}

class _ForgotPasswordResetScreenState
    extends ConsumerState<ForgotPasswordResetScreen> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _feedbackMessage;
  bool _feedbackIsError = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    return _ForgotPasswordShell(
      title: context.l10n.authForgotPasswordResetTitle,
      subtitle: context.l10n.authForgotPasswordResetSubtitle(widget.email),
      stage: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ForgotPasswordStageHeader(
            icon: Icons.lock_reset_rounded,
            title: context.l10n.authForgotPasswordStageReset,
            body: context.l10n.authForgotPasswordResetBody,
          ),
          const SizedBox(height: 24),
          if (_feedbackMessage != null) ...<Widget>[
            _ForgotPasswordBanner(
              message: _feedbackMessage!,
              isError: _feedbackIsError,
            ),
            const SizedBox(height: 18),
          ],
          if (widget.resetSessionExpiresAt != null) ...<Widget>[
            _ForgotPasswordHint(
              message: context.l10n.authForgotPasswordResetSessionHint(
                _formatResetSession(context, widget.resetSessionExpiresAt!),
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enableSuggestions: false,
            autocorrect: false,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: context.l10n.accountSettingsNewPassword,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            enableSuggestions: false,
            autocorrect: false,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: context.l10n.authConfirmPasswordLabel,
              prefixIcon: const Icon(Icons.verified_outlined),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PasswordCriteriaPanel(
            password: password,
            confirmPassword: confirmPassword,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isSubmitting ? null : _resetPassword,
              icon: state.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                state.isSubmitting
                    ? context.l10n.authSubmittingLabel
                    : context.l10n.authForgotPasswordResetCta,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(context.l10n.authRegisterStepBack),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (password.trim().isEmpty || confirmPassword.trim().isEmpty) {
      _setFeedback(context.l10n.authRequiredFieldsMessage, isError: true);
      return;
    }
    if (password != confirmPassword) {
      _setFeedback(context.l10n.authPasswordMismatchMessage, isError: true);
      return;
    }

    try {
      await ref.read(forgotPasswordControllerProvider.notifier).resetPassword(
        resetSessionToken: widget.resetSessionToken,
        newPassword: password,
        confirmPassword: confirmPassword,
      );
      if (!mounted) {
        return;
      }
      _setFeedback(context.l10n.authForgotPasswordResetSuccess, isError: false);
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) {
        return;
      }
      context.goNamed(loginRouteName);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _setFeedback(
        AuthErrorMessageResolver.resolve(context.l10n, error),
        isError: true,
      );
    }
  }

  String _formatResetSession(BuildContext context, DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month ${context.l10n.authForgotPasswordAtLabel} $hour:$minute';
  }

  void _setFeedback(String message, {required bool isError}) {
    setState(() {
      _feedbackMessage = message;
      _feedbackIsError = isError;
    });
  }
}

class _ForgotPasswordShell extends StatelessWidget {
  const _ForgotPasswordShell({
    required this.title,
    required this.subtitle,
    required this.stage,
    required this.child,
  });

  final String title;
  final String subtitle;
  final int stage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: _ForgotPasswordBackground(
        child: SafeArea(
          child: ResponsiveBuilder(
            builder: (context, layout) {
              final card = ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: layout.isDesktop
                      ? 520
                      : (layout.isTablet ? 560 : double.infinity),
                ),
                child: _ForgotPasswordGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: AppLogo(
                          logoAssetPath: AppAssets.appLogo(brightness),
                          size: layout.isMobile ? 84 : 96,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _ForgotPasswordStageProgress(stage: stage),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 28),
                      child,
                    ],
                  ),
                ),
              );

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  layout.horizontalPadding,
                  layout.verticalPadding,
                  layout.horizontalPadding,
                  layout.verticalPadding,
                ),
                child: Column(
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.centerRight,
                      child: LanguageSwitcher(),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: card,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordStageHeader extends StatelessWidget {
  const _ForgotPasswordStageHeader({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordStageProgress extends StatelessWidget {
  const _ForgotPasswordStageProgress({required this.stage});

  final int stage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: List<Widget>.generate(3, (index) {
        final current = index + 1;
        final active = current <= stage;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _OtpPreviewField extends StatelessWidget {
  const _OtpPreviewField({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.label,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final value = controller.text.trim();
        return GestureDetector(
      onTap: focusNode.requestFocus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                children: List<Widget>.generate(length, (index) {
                  final hasValue = index < value.length;
                  return Expanded(
                    child: Container(
                      height: 64,
                      margin: EdgeInsets.only(right: index == length - 1 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: hasValue
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          width: hasValue ? 1.6 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        hasValue ? value[index] : '•',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: hasValue
                                  ? colorScheme.onSurface
                                  : colorScheme.outline,
                            ),
                      ),
                    ),
                  );
                }),
              ),
              Opacity(
                opacity: 0.02,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  maxLength: length,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(length),
                  ],
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}

class _PasswordCriteriaPanel extends StatelessWidget {
  const _PasswordCriteriaPanel({
    required this.password,
    required this.confirmPassword,
  });

  final String password;
  final String confirmPassword;

  @override
  Widget build(BuildContext context) {
    final items = <(bool, String)>[
      (password.trim().length >= 8, context.l10n.accountSettingsPasswordMinLength),
      (RegExp(r'.*[A-Z].*').hasMatch(password),
          context.l10n.accountSettingsPasswordUppercase),
      (RegExp(r'.*[a-z].*').hasMatch(password),
          context.l10n.accountSettingsPasswordLowercase),
      (RegExp(r'.*[^A-Za-z0-9].*').hasMatch(password),
          context.l10n.accountSettingsPasswordSpecialCharacter),
      (
        password.isNotEmpty && password == confirmPassword,
        context.l10n.accountSettingsPasswordConfirmation,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.4,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          final isMet = item.$1;
          final label = item.$2;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Icon(
                  isMet
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: isMet
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ForgotPasswordBanner extends StatelessWidget {
  const _ForgotPasswordBanner({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = isError
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final foreground = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ForgotPasswordHint extends StatelessWidget {
  const _ForgotPasswordHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
    );
  }
}

class _ForgotPasswordBackground extends StatelessWidget {
  const _ForgotPasswordBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surface,
            colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.08),
            colorScheme.tertiary.withValues(alpha: isDark ? 0.14 : 0.06),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top: -110,
            left: -40,
            child: _ForgotPasswordOrb(
              size: 240,
              color: colorScheme.primary.withValues(
                alpha: isDark ? 0.18 : 0.12,
              ),
            ),
          ),
          Positioned(
            right: -90,
            bottom: -130,
            child: _ForgotPasswordOrb(
              size: 300,
              color: colorScheme.tertiary.withValues(
                alpha: isDark ? 0.16 : 0.1,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ForgotPasswordGlassCard extends StatelessWidget {
  const _ForgotPasswordGlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldDisableBlurOnNativeMobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final content = Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: isDark ? 0.74 : 0.82),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: shouldDisableBlurOnNativeMobile
          ? content
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: content,
            ),
    );
  }
}

class _ForgotPasswordOrb extends StatelessWidget {
  const _ForgotPasswordOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

bool _isValidEmail(String value) {
  final email = value.trim();
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
}

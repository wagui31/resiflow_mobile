import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/assets/app_assets.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_session_controller.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';
import 'widgets/turnstile_captcha_view.dart';

enum AuthScreenMode {
  login,
  register;
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({
    required this.mode,
    super.key,
  });

  final AuthScreenMode mode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late final TextEditingController _loginEmailController;
  late final TextEditingController _loginPasswordController;
  late final TextEditingController _registerEmailController;
  late final TextEditingController _registerPasswordController;
  late final TextEditingController _residenceCodeController;
  late final TextEditingController _buildingController;
  late final TextEditingController _housingController;

  bool _isLoginSubmitting = false;
  bool _isRegisterSubmitting = false;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  String? _feedbackMessage;
  bool _feedbackIsError = false;
  String? _captchaToken;
  int _captchaNonce = 0;

  @override
  void initState() {
    super.initState();
    _loginEmailController = TextEditingController();
    _loginPasswordController = TextEditingController();
    _registerEmailController = TextEditingController();
    _registerPasswordController = TextEditingController();
    _residenceCodeController = TextEditingController();
    _buildingController = TextEditingController();
    _housingController = TextEditingController();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _residenceCodeController.dispose();
    _buildingController.dispose();
    _housingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = widget.mode == AuthScreenMode.register
        ? ref.watch(publicAppConfigProvider)
        : const AsyncData<PublicAppConfig>(
            PublicAppConfig(
              captcha: CaptchaPublicConfig(
                registerEnabled: false,
                siteKey: null,
              ),
            ),
          );

    return Scaffold(
      body: _AuthBackground(
        child: SafeArea(
          child: ResponsiveBuilder(
            builder: (context, layout) {
              final viewportHeight = MediaQuery.sizeOf(context).height;
              final cardMinHeight = layout.isMobile ? viewportHeight * 0.84 : 620.0;
              final cardMaxWidth = layout.isDesktop ? 460.0 : (layout.isTablet ? 520.0 : double.infinity);

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: layout.horizontalPadding,
                  vertical: layout.verticalPadding,
                ),
                child: Column(
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.centerRight,
                      child: LanguageSwitcher(),
                    ),
                    SizedBox(height: layout.isMobile ? 16 : 24),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: cardMaxWidth),
                          child: _GlassAuthCard(
                            minHeight: cardMinHeight,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: KeyedSubtree(
                                key: ValueKey<AuthScreenMode>(widget.mode),
                                child: widget.mode == AuthScreenMode.login
                                    ? _buildLoginCard(context, layout)
                                    : _buildRegisterCard(context, layout, configAsync),
                              ),
                            ),
                          ),
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

  Widget _buildLoginCard(BuildContext context, ResponsiveLayout layout) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Spacer(),
        Center(
          child: AppLogo(
            logoAssetPath: AppAssets.appLogo(brightness),
            size: layout.isMobile ? 84 : 96,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          context.l10n.authLoginPageTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const Spacer(),
        if (_feedbackMessage != null) ...<Widget>[
          _FeedbackBanner(
            message: _feedbackMessage!,
            isError: _feedbackIsError,
          ),
          const SizedBox(height: 20),
        ],
        _buildLoginForm(context),
        const Spacer(),
        _SecondaryAuthLink(
          prompt: context.l10n.authNoAccountPrompt,
          actionLabel: context.l10n.authRegisterLinkLabel,
          onPressed: () => context.goNamed(registerRouteName),
        ),
      ],
    );
  }

  Widget _buildRegisterCard(
    BuildContext context,
    ResponsiveLayout layout,
    AsyncValue<PublicAppConfig> configAsync,
  ) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () => context.goNamed(loginRouteName),
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: context.l10n.authBackToLogin,
            ),
            const Spacer(),
          ],
        ),
        Center(
          child: AppLogo(
            logoAssetPath: AppAssets.appLogo(brightness),
            size: layout.isMobile ? 72 : 80,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.authSignUpHeading,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.authSignUpDescription,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        if (_feedbackMessage != null) ...<Widget>[
          _FeedbackBanner(
            message: _feedbackMessage!,
            isError: _feedbackIsError,
          ),
          const SizedBox(height: 20),
        ],
        Expanded(
          child: SingleChildScrollView(
            child: _buildRegisterForm(context, configAsync),
          ),
        ),
        const SizedBox(height: 20),
        _SecondaryAuthLink(
          prompt: context.l10n.authAlreadyHaveAccountPrompt,
          actionLabel: context.l10n.authLoginButton,
          onPressed: () => context.goNamed(loginRouteName),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final theme = Theme.of(context);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[
              AutofillHints.username,
              AutofillHints.email,
            ],
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.l10n.authEmailLabel,
              prefixIcon: const Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            autofillHints: const <String>[AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!_isLoginSubmitting) {
                _handleLogin();
              }
            },
            decoration: InputDecoration(
              labelText: context.l10n.authPasswordLabel,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureLoginPassword = !_obscureLoginPassword;
                  });
                },
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoginSubmitting ? null : _handleLogin,
              icon: _isLoginSubmitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(
                _isLoginSubmitting
                    ? context.l10n.authSubmittingLabel
                    : context.l10n.authLoginButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(
    BuildContext context,
    AsyncValue<PublicAppConfig> configAsync,
  ) {
    return configAsync.when(
      data: (config) => _buildRegisterFormContent(context, config),
      loading: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(context.l10n.authLoadingConfig),
          ],
        ),
      ),
      error: (error, stackTrace) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            context.l10n.authConfigErrorTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            ApiException.fromError(error).message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => ref.invalidate(publicAppConfigProvider),
              child: Text(context.l10n.authRetryButton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterFormContent(BuildContext context, PublicAppConfig config) {
    final captcha = config.captcha;
    final needsCaptcha = captcha.registerEnabled;
    final missingSiteKey = needsCaptcha && !(captcha.siteKey?.isNotEmpty ?? false);
    final canSubmit = !_isRegisterSubmitting &&
        _registerEmailController.text.trim().isNotEmpty &&
        _registerPasswordController.text.trim().isNotEmpty &&
        _residenceCodeController.text.trim().isNotEmpty &&
        (!needsCaptcha || _captchaToken != null) &&
        !missingSiteKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: _registerEmailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: context.l10n.authEmailLabel,
            prefixIcon: const Icon(Icons.mail_outline_rounded),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _registerPasswordController,
          obscureText: _obscureRegisterPassword,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: context.l10n.authPasswordLabel,
            prefixIcon: const Icon(Icons.key_rounded),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureRegisterPassword = !_obscureRegisterPassword;
                });
              },
              icon: Icon(
                _obscureRegisterPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _residenceCodeController,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: context.l10n.authResidenceCodeLabel,
            prefixIcon: const Icon(Icons.domain_verification_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _buildingController,
                decoration: InputDecoration(
                  labelText: context.l10n.authBuildingLabel,
                  prefixIcon: const Icon(Icons.apartment_outlined),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _housingController,
                decoration: InputDecoration(
                  labelText: context.l10n.authHousingLabel,
                  prefixIcon: const Icon(Icons.meeting_room_outlined),
                ),
              ),
            ),
          ],
        ),
        if (needsCaptcha) ...<Widget>[
          const SizedBox(height: 20),
          Text(
            context.l10n.authCaptchaLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.authCaptchaDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          if (missingSiteKey)
            _InlineHint(message: context.l10n.authCaptchaMissingSiteKey)
          else
            TurnstileCaptchaView(
              key: ValueKey<int>(_captchaNonce),
              siteKey: captcha.siteKey!,
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
              onTokenChanged: (token) {
                setState(() {
                  _captchaToken = token;
                });
              },
            ),
          const SizedBox(height: 12),
          _InlineHint(
            message: _captchaToken == null
                ? context.l10n.authCaptchaPending
                : context.l10n.authCaptchaReady,
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: canSubmit ? _handleRegister : null,
            child: Text(
              _isRegisterSubmitting
                  ? context.l10n.authSubmittingLabel
                  : context.l10n.authRegisterButton,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_loginEmailController.text.trim().isEmpty ||
        _loginPasswordController.text.trim().isEmpty) {
      _setFeedback(
        _localization.authRequiredFieldsMessage,
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoginSubmitting = true;
    });

    try {
      await ref.read(authSessionControllerProvider.notifier).signIn(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      _setFeedback(_localization.authLoginSuccess, isError: false);
      context.goNamed(dashboardRouteName);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _setFeedback(ApiException.fromError(error).message, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoginSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    final config = ref.read(publicAppConfigProvider).valueOrNull;
    final captchaRequired = config?.captcha.registerEnabled == true;

    if (_registerEmailController.text.trim().isEmpty ||
        _registerPasswordController.text.trim().isEmpty ||
        _residenceCodeController.text.trim().isEmpty) {
      _setFeedback(
        _localization.authRequiredFieldsMessage,
        isError: true,
      );
      return;
    }

    if (captchaRequired && _captchaToken == null) {
      _setFeedback(
        _localization.authCaptchaPending,
        isError: true,
      );
      return;
    }

    setState(() {
      _isRegisterSubmitting = true;
    });

    try {
      final payload = RegisterPayload(
        email: _registerEmailController.text,
        password: _registerPasswordController.text,
        residenceCode: _residenceCodeController.text,
        numeroImmeuble: _buildingController.text,
        codeLogement: _housingController.text,
        captchaToken: _captchaToken,
      );
      final user = await ref
          .read(authSessionControllerProvider.notifier)
          .register(payload);

      if (!mounted) {
        return;
      }

      setState(() {
        _captchaToken = null;
        _captchaNonce++;
        _registerPasswordController.clear();
      });
      _setFeedback(
        user.status == UserStatus.pending
            ? _localization.authRegisterSuccessPending
            : _localization.authRegisterSuccessGeneric,
        isError: false,
      );
      context.goNamed(accountStatusRouteName);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _setFeedback(ApiException.fromError(error).message, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isRegisterSubmitting = false;
        });
      }
    }
  }

  void _setFeedback(String message, {required bool isError}) {
    setState(() {
      _feedbackMessage = message;
      _feedbackIsError = isError;
    });
  }

  AppLocalizations get _localization => context.l10n;
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground({
    required this.child,
  });

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
            top: -120,
            left: -60,
            child: _BackgroundOrb(
              size: 260,
              color: colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.12),
            ),
          ),
          Positioned(
            right: -80,
            bottom: -140,
            child: _BackgroundOrb(
              size: 320,
              color: colorScheme.tertiary.withValues(alpha: isDark ? 0.14 : 0.1),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlassAuthCard extends StatelessWidget {
  const _GlassAuthCard({
    required this.child,
    required this.minHeight,
  });

  final Widget child;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: isDark ? 0.74 : 0.8),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.32 : 0.14),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _SecondaryAuthLink extends StatelessWidget {
  const _SecondaryAuthLink({
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: <Widget>[
          Text(
            prompt,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        isError ? colorScheme.errorContainer : colorScheme.primaryContainer;
    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _InlineHint extends StatelessWidget {
  const _InlineHint({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

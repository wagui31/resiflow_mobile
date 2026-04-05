import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_error_message_resolver.dart';
import '../application/auth_session_controller.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';
import 'widgets/turnstile_captcha_view.dart';

enum AuthScreenMode { login, register }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({required this.mode, super.key});

  final AuthScreenMode mode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late final TextEditingController _loginEmailController;
  late final TextEditingController _loginPasswordController;
  late final TextEditingController _registerFirstNameController;
  late final TextEditingController _registerLastNameController;
  late final TextEditingController _registerEmailController;
  late final TextEditingController _registerPasswordController;
  late final TextEditingController _registerConfirmPasswordController;
  late final TextEditingController _residenceCodeController;
  late final ScrollController _registerScrollController;
  late final FocusNode _registerFirstNameFocusNode;
  late final FocusNode _registerLastNameFocusNode;
  late final FocusNode _registerEmailFocusNode;
  late final FocusNode _residenceCodeFocusNode;
  late final FocusNode _registerPasswordFocusNode;
  late final FocusNode _registerConfirmPasswordFocusNode;

  final GlobalKey _registerFirstNameFieldKey = GlobalKey();
  final GlobalKey _registerLastNameFieldKey = GlobalKey();
  final GlobalKey _registerEmailFieldKey = GlobalKey();
  final GlobalKey _residenceCodeFieldKey = GlobalKey();
  final GlobalKey _registerPasswordFieldKey = GlobalKey();
  final GlobalKey _registerConfirmPasswordFieldKey = GlobalKey();

  bool _isLoginSubmitting = false;
  bool _isRegisterSubmitting = false;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;
  bool _registerCompleted = false;
  String? _feedbackMessage;
  bool _feedbackIsError = false;
  String? _captchaToken;
  int _captchaNonce = 0;

  @override
  void initState() {
    super.initState();
    _loginEmailController = TextEditingController();
    _loginPasswordController = TextEditingController();
    _registerFirstNameController = TextEditingController();
    _registerLastNameController = TextEditingController();
    _registerEmailController = TextEditingController();
    _registerPasswordController = TextEditingController();
    _registerConfirmPasswordController = TextEditingController();
    _residenceCodeController = TextEditingController();
    _registerScrollController = ScrollController();
    _registerFirstNameFocusNode = FocusNode();
    _registerLastNameFocusNode = FocusNode();
    _registerEmailFocusNode = FocusNode();
    _residenceCodeFocusNode = FocusNode();
    _registerPasswordFocusNode = FocusNode();
    _registerConfirmPasswordFocusNode = FocusNode();

    _registerFirstNameFocusNode.addListener(
      () => _handleRegisterFieldFocus(
        _registerFirstNameFocusNode,
        _registerFirstNameFieldKey,
      ),
    );
    _registerLastNameFocusNode.addListener(
      () => _handleRegisterFieldFocus(
        _registerLastNameFocusNode,
        _registerLastNameFieldKey,
      ),
    );
    _registerEmailFocusNode.addListener(
      () => _handleRegisterFieldFocus(
        _registerEmailFocusNode,
        _registerEmailFieldKey,
      ),
    );
    _residenceCodeFocusNode.addListener(
      () => _handleRegisterFieldFocus(
        _residenceCodeFocusNode,
        _residenceCodeFieldKey,
      ),
    );
    _registerPasswordFocusNode.addListener(
      () => _handleRegisterFieldFocus(
        _registerPasswordFocusNode,
        _registerPasswordFieldKey,
      ),
    );
    _registerConfirmPasswordFocusNode.addListener(
      () => _handleRegisterFieldFocus(
        _registerConfirmPasswordFocusNode,
        _registerConfirmPasswordFieldKey,
      ),
    );
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerFirstNameController.dispose();
    _registerLastNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _residenceCodeController.dispose();
    _registerScrollController.dispose();
    _registerFirstNameFocusNode.dispose();
    _registerLastNameFocusNode.dispose();
    _registerEmailFocusNode.dispose();
    _residenceCodeFocusNode.dispose();
    _registerPasswordFocusNode.dispose();
    _registerConfirmPasswordFocusNode.dispose();
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
      resizeToAvoidBottomInset: true,
      body: _AuthBackground(
        child: SafeArea(
          child: ResponsiveBuilder(
            builder: (context, layout) {
              final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
              final shouldUseScrollableLayout = layout.isMobile;
              final isRegisterMobile =
                  widget.mode == AuthScreenMode.register && layout.isMobile;
              final cardMinHeight = layout.isMobile ? null : 620.0;
              final cardMaxWidth = layout.isDesktop
                  ? 460.0
                  : (layout.isTablet ? 520.0 : double.infinity);
              final card = ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardMaxWidth),
                child: _GlassAuthCard(
                  minHeight: cardMinHeight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: KeyedSubtree(
                      key: ValueKey<String>(
                        '${widget.mode.name}-$_registerCompleted',
                      ),
                      child: widget.mode == AuthScreenMode.login
                          ? _buildLoginCard(context, layout)
                          : _buildRegisterCard(context, layout, configAsync),
                    ),
                  ),
                ),
              );

              final content = shouldUseScrollableLayout
                  ? SingleChildScrollView(
                      controller: isRegisterMobile
                          ? _registerScrollController
                          : null,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        children: <Widget>[
                          const Align(
                            alignment: Alignment.centerRight,
                            child: LanguageSwitcher(),
                          ),
                          const SizedBox(height: 16),
                          card,
                        ],
                      ),
                    )
                  : Column(
                      children: <Widget>[
                        const Align(
                          alignment: Alignment.centerRight,
                          child: LanguageSwitcher(),
                        ),
                        SizedBox(height: layout.isMobile ? 16 : 24),
                        Expanded(child: Center(child: card)),
                      ],
                    );

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  layout.horizontalPadding,
                  layout.verticalPadding,
                  layout.horizontalPadding,
                  layout.verticalPadding +
                      (shouldUseScrollableLayout ? keyboardInset : 0),
                ),
                child: content,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, ResponsiveLayout layout) {
    final brightness = Theme.of(context).brightness;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;
        final isCompact =
            hasBoundedHeight &&
            constraints.maxHeight < (layout.isMobile ? 430 : 520);
        final topSpacing = isCompact ? 8.0 : 24.0;
        final titleSpacing = isCompact ? 20.0 : 28.0;
        final formSpacing = isCompact ? 20.0 : 28.0;
        final bottomSpacing = isCompact ? 16.0 : 24.0;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: topSpacing),
            Center(
              child: AppLogo(
                logoAssetPath: AppAssets.appLogo(brightness),
                size: layout.isMobile ? 84 : 96,
              ),
            ),
            SizedBox(height: titleSpacing),
            Text(
              context.l10n.authLoginPageTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            SizedBox(height: formSpacing),
            if (_feedbackMessage != null) ...<Widget>[
              _FeedbackBanner(
                message: _feedbackMessage!,
                isError: _feedbackIsError,
              ),
              const SizedBox(height: 20),
            ],
            _buildLoginForm(context),
            SizedBox(height: bottomSpacing),
            _SecondaryAuthLink(
              prompt: context.l10n.authNoAccountPrompt,
              actionLabel: context.l10n.authRegisterLinkLabel,
              onPressed: () => context.goNamed(registerRouteName),
            ),
          ],
        );

        if (isCompact) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: content,
          );
        }

        return content;
      },
    );
  }

  Widget _buildRegisterCard(
    BuildContext context,
    ResponsiveLayout layout,
    AsyncValue<PublicAppConfig> configAsync,
  ) {
    final brightness = Theme.of(context).brightness;

    if (_registerCompleted) {
      return _buildRegisterSuccessCard(context, layout, brightness);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < (layout.isMobile ? 640 : 560);
        final topSpacing = isCompact ? 12.0 : 24.0;
        final titleSpacing = isCompact ? 20.0 : 28.0;
        final sectionSpacing = isCompact ? 16.0 : 24.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: topSpacing),
            Center(
              child: AppLogo(
                logoAssetPath: AppAssets.appLogo(brightness),
                size: layout.isMobile ? 84 : 96,
              ),
            ),
            SizedBox(height: titleSpacing),
            Text(
              context.l10n.authRegisterPageTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            SizedBox(height: sectionSpacing),
            if (_feedbackMessage != null) ...<Widget>[
              _FeedbackBanner(
                message: _feedbackMessage!,
                isError: _feedbackIsError,
              ),
              const SizedBox(height: 20),
            ],
            _buildRegisterForm(context, configAsync, layout),
            SizedBox(height: isCompact ? 12 : 20),
            _SecondaryAuthLink(
              prompt: context.l10n.authAlreadyHaveAccountPrompt,
              actionLabel: context.l10n.authLoginButton,
              onPressed: () => context.goNamed(loginRouteName),
            ),
          ],
        );
      },
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

  Widget _buildRegisterSuccessCard(
    BuildContext context,
    ResponsiveLayout layout,
    Brightness brightness,
  ) {
    final theme = Theme.of(context);

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
          context.l10n.authRegisterSuccessTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.verified_user_outlined,
                size: 36,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.authRegisterSuccessPending,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => context.goNamed(loginRouteName),
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(context.l10n.authBackToLogin),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(
    BuildContext context,
    AsyncValue<PublicAppConfig> configAsync,
    ResponsiveLayout layout,
  ) {
    const fallbackConfig = PublicAppConfig(
      captcha: CaptchaPublicConfig(registerEnabled: false, siteKey: null),
    );

    return configAsync.when(
      data: (config) => _buildRegisterFormContent(context, config, layout),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _FeedbackBanner(
            message:
                '${context.l10n.authConfigErrorTitle}. '
                '${AuthErrorMessageResolver.resolve(context.l10n, error)}',
            isError: true,
            action: OutlinedButton(
              onPressed: () => ref.invalidate(publicAppConfigProvider),
              child: Text(context.l10n.authRetryButton),
            ),
          ),
          const SizedBox(height: 20),
          _buildRegisterFormContent(context, fallbackConfig, layout),
        ],
      ),
    );
  }

  Widget _buildRegisterFormContent(
    BuildContext context,
    PublicAppConfig config,
    ResponsiveLayout layout,
  ) {
    final theme = Theme.of(context);
    final captcha = _effectiveCaptchaConfig(config.captcha);
    final needsCaptcha = captcha.registerEnabled;
    final missingSiteKey =
        needsCaptcha && !(captcha.siteKey?.isNotEmpty ?? false);
    final canSubmit =
        !_isRegisterSubmitting &&
        _registerFirstNameController.text.trim().isNotEmpty &&
        _registerLastNameController.text.trim().isNotEmpty &&
        _registerEmailController.text.trim().isNotEmpty &&
        _registerPasswordController.text.trim().isNotEmpty &&
        _registerConfirmPasswordController.text.trim().isNotEmpty &&
        _residenceCodeController.text.trim().isNotEmpty &&
        (!needsCaptcha || _captchaToken != null) &&
        !missingSiteKey;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          KeyedSubtree(
            key: _registerFirstNameFieldKey,
            child: TextField(
              controller: _registerFirstNameController,
              focusNode: _registerFirstNameFocusNode,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: const <String>[AutofillHints.givenName],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.l10n.usersFirstNameLabel,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
          ),
          const SizedBox(height: 16),
          KeyedSubtree(
            key: _registerLastNameFieldKey,
            child: TextField(
              controller: _registerLastNameController,
              focusNode: _registerLastNameFocusNode,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: const <String>[AutofillHints.familyName],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.l10n.usersLastNameLabel,
                prefixIcon: const Icon(Icons.account_box_outlined),
              ),
            ),
          ),
          const SizedBox(height: 16),
          KeyedSubtree(
            key: _registerEmailFieldKey,
            child: TextField(
              controller: _registerEmailController,
              focusNode: _registerEmailFocusNode,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const <String>[
                AutofillHints.username,
                AutofillHints.email,
              ],
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.l10n.authEmailLabel,
                prefixIcon: const Icon(Icons.alternate_email_rounded),
              ),
            ),
          ),
          const SizedBox(height: 16),
          KeyedSubtree(
            key: _residenceCodeFieldKey,
            child: TextField(
              controller: _residenceCodeController,
              focusNode: _residenceCodeFocusNode,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.l10n.authResidenceCodeLabel,
                prefixIcon: const Icon(Icons.domain_verification_outlined),
                suffixIcon: _ResidenceCodeInfoButton(
                  isMobile: layout.isMobile,
                  tooltip: context.l10n.authResidenceCodeHelp,
                  onPressed: () => _showResidenceCodeHelp(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          KeyedSubtree(
            key: _registerPasswordFieldKey,
            child: TextField(
              controller: _registerPasswordController,
              focusNode: _registerPasswordFocusNode,
              obscureText: _obscureRegisterPassword,
              autofillHints: const <String>[AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.l10n.authPasswordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
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
          ),
          const SizedBox(height: 16),
          KeyedSubtree(
            key: _registerConfirmPasswordFieldKey,
            child: TextField(
              controller: _registerConfirmPasswordController,
              focusNode: _registerConfirmPasswordFocusNode,
              obscureText: _obscureRegisterConfirmPassword,
              autofillHints: const <String>[AutofillHints.newPassword],
              textInputAction: needsCaptcha
                  ? TextInputAction.next
                  : TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (!needsCaptcha && canSubmit) {
                  _handleRegister();
                }
              },
              decoration: InputDecoration(
                labelText: context.l10n.authConfirmPasswordLabel,
                prefixIcon: const Icon(Icons.lock_person_outlined),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureRegisterConfirmPassword =
                          !_obscureRegisterConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureRegisterConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
          ),
          if (needsCaptcha) ...<Widget>[
            const SizedBox(height: 20),
            Text(
              context.l10n.authCaptchaLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.authCaptchaDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (missingSiteKey)
              _InlineHint(message: context.l10n.authCaptchaMissingSiteKey)
            else
              TurnstileCaptchaView(
                key: ValueKey<int>(_captchaNonce),
                siteKey: captcha.siteKey!,
                isDarkMode: theme.brightness == Brightness.dark,
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canSubmit ? _handleRegister : null,
              icon: _isRegisterSubmitting
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
                  : const Icon(Icons.person_add_alt_1_rounded),
              label: Text(
                _isRegisterSubmitting
                    ? context.l10n.authSubmittingLabel
                    : context.l10n.authRegisterCta,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegisterFieldFocus(FocusNode focusNode, GlobalKey fieldKey) {
    if (!focusNode.hasFocus) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _scrollRegisterFieldIntoView(fieldKey);
    });
  }

  Future<void> _scrollRegisterFieldIntoView(GlobalKey fieldKey) async {
    final fieldContext = fieldKey.currentContext;
    if (fieldContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      fieldContext,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: 0.18,
    );
  }

  Future<void> _handleLogin() async {
    if (_loginEmailController.text.trim().isEmpty ||
        _loginPasswordController.text.trim().isEmpty) {
      _setFeedback(_localization.authRequiredFieldsMessage, isError: true);
      return;
    }

    setState(() {
      _isLoginSubmitting = true;
    });

    try {
      await ref
          .read(authSessionControllerProvider.notifier)
          .signIn(
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
      _setFeedback(
        AuthErrorMessageResolver.resolve(_localization, error),
        isError: true,
      );
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
    final captchaRequired =
        _effectiveCaptchaConfig(config?.captcha).registerEnabled == true;

    final firstName = _registerFirstNameController.text.trim();
    final lastName = _registerLastNameController.text.trim();
    final email = _registerEmailController.text.trim();
    final residenceCode = _residenceCodeController.text.trim();
    final password = _registerPasswordController.text;
    final confirmPassword = _registerConfirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.trim().isEmpty ||
        residenceCode.isEmpty) {
      _setFeedback(_localization.authRequiredFieldsMessage, isError: true);
      return;
    }

    if (!_isValidEmail(email)) {
      _setFeedback(_localization.authInvalidEmailMessage, isError: true);
      return;
    }

    if (confirmPassword.trim().isEmpty) {
      _setFeedback(_localization.authRequiredFieldsMessage, isError: true);
      return;
    }

    if (password != confirmPassword) {
      _setFeedback(_localization.authPasswordMismatchMessage, isError: true);
      return;
    }

    if (captchaRequired && _captchaToken == null) {
      _setFeedback(_localization.authCaptchaPending, isError: true);
      return;
    }

    setState(() {
      _isRegisterSubmitting = true;
    });

    try {
      final payload = RegisterPayload(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        residenceCode: residenceCode,
        numeroImmeuble: null,
        codeLogement: null,
        captchaToken: _captchaToken,
      );
      await ref.read(authSessionControllerProvider.notifier).register(payload);

      if (!mounted) {
        return;
      }

      setState(() {
        _registerCompleted = true;
        _feedbackMessage = null;
        _captchaToken = null;
        _captchaNonce++;
        _registerFirstNameController.clear();
        _registerLastNameController.clear();
        _registerEmailController.clear();
        _residenceCodeController.clear();
        _registerPasswordController.clear();
        _registerConfirmPasswordController.clear();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      _setFeedback(
        AuthErrorMessageResolver.resolve(_localization, error),
        isError: true,
      );
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
      _registerCompleted = false;
      _feedbackMessage = message;
      _feedbackIsError = isError;
    });
  }

  Future<void> _showResidenceCodeHelp(BuildContext context) async {
    final message = context.l10n.authResidenceCodeHelp;

    if (MediaQuery.sizeOf(context).width < 600) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          );
        },
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String value) {
    final normalized = value.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalized);
  }

  CaptchaPublicConfig _effectiveCaptchaConfig(CaptchaPublicConfig? captcha) {
    final resolvedCaptcha =
        captcha ??
        const CaptchaPublicConfig(registerEnabled: false, siteKey: null);
    if (_isTemporarilyBypassedMobileCaptcha) {
      return const CaptchaPublicConfig(registerEnabled: false, siteKey: null);
    }
    return resolvedCaptcha;
  }

  bool get _isTemporarilyBypassedMobileCaptcha {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  AppLocalizations get _localization => context.l10n;
}

class _ResidenceCodeInfoButton extends StatelessWidget {
  const _ResidenceCodeInfoButton({
    required this.isMobile,
    required this.tooltip,
    required this.onPressed,
  });

  final bool isMobile;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.info_outline_rounded),
      tooltip: tooltip,
    );

    if (isMobile) {
      return button;
    }

    return Tooltip(message: tooltip, child: button);
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground({required this.child});

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
              color: colorScheme.primary.withValues(
                alpha: isDark ? 0.16 : 0.12,
              ),
            ),
          ),
          Positioned(
            right: -80,
            bottom: -140,
            child: _BackgroundOrb(
              size: 320,
              color: colorScheme.tertiary.withValues(
                alpha: isDark ? 0.14 : 0.1,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlassAuthCard extends StatelessWidget {
  const _GlassAuthCard({required this.child, required this.minHeight});

  final Widget child;
  final double? minHeight;

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
          constraints: BoxConstraints(minHeight: minHeight ?? 0),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: isDark ? 0.74 : 0.8),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha: isDark ? 0.32 : 0.14,
                ),
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
  const _BackgroundOrb({required this.size, required this.color});

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
    this.action,
  });

  final String message;
  final bool isError;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isError
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (action != null) ...<Widget>[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

class _InlineHint extends StatelessWidget {
  const _InlineHint({required this.message});

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

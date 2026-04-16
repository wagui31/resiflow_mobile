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

enum _RegisterStep { logement, profile }

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
  late final FocusNode _loginEmailFocusNode;
  late final FocusNode _loginPasswordFocusNode;
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
  _RegisterStep _registerStep = _RegisterStep.logement;
  bool _isLoadingRegisterLogements = false;
  bool _hasLoadedRegisterLogements = false;
  List<RegistrationLogementOption> _registerLogements =
      const <RegistrationLogementOption>[];
  RegistrationLogementOption? _selectedRegisterLogement;

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
    _loginEmailFocusNode = FocusNode();
    _loginPasswordFocusNode = FocusNode();
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
    _loginEmailFocusNode.dispose();
    _loginPasswordFocusNode.dispose();
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
                  child: widget.mode == AuthScreenMode.login
                      ? _buildLoginCard(context, layout)
                      : _buildRegisterCard(context, layout, configAsync),
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
                  layout.verticalPadding,
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

        // On mobile, the page is already wrapped in a parent scroll view.
        // Switching this subtree to another scroll view when the keyboard
        // reduces the available height can rebuild the focused field and make
        // Android cancel the IME show request.
        if (isCompact && !layout.isMobile) {
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
            focusNode: _loginEmailFocusNode,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.username],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              _loginPasswordFocusNode.requestFocus();
            },
            decoration: InputDecoration(
              labelText: context.l10n.authEmailLabel,
              prefixIcon: const Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _loginPasswordController,
            focusNode: _loginPasswordFocusNode,
            obscureText: _obscureLoginPassword,
            autofillHints: const <String>[AutofillHints.password],
            keyboardType: TextInputType.visiblePassword,
            enableSuggestions: false,
            autocorrect: false,
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
    final captcha = _effectiveCaptchaConfig(config.captcha);
    final needsCaptcha = captcha.registerEnabled;
    final missingSiteKey =
        needsCaptcha && !(captcha.siteKey?.isNotEmpty ?? false);

    return AutofillGroup(
      child: _registerStep == _RegisterStep.logement
          ? _buildRegisterLogementStep(context, layout)
          : ListenableBuilder(
              listenable: Listenable.merge(<Listenable>[
                _registerFirstNameController,
                _registerLastNameController,
                _registerEmailController,
                _registerPasswordController,
                _registerConfirmPasswordController,
              ]),
              builder: (context, _) {
                final canSubmit =
                    !_isRegisterSubmitting &&
                    _selectedRegisterLogement != null &&
                    _registerFirstNameController.text.trim().isNotEmpty &&
                    _registerLastNameController.text.trim().isNotEmpty &&
                    _registerEmailController.text.trim().isNotEmpty &&
                    _registerPasswordController.text.trim().isNotEmpty &&
                    _registerConfirmPasswordController.text.trim().isNotEmpty &&
                    (!needsCaptcha || _captchaToken != null) &&
                    !missingSiteKey;

                return _buildRegisterProfileStep(
                  context,
                  needsCaptcha: needsCaptcha,
                  missingSiteKey: missingSiteKey,
                  canSubmit: canSubmit,
                  captcha: captcha,
                );
              },
            ),
    );
  }

  Widget _buildRegisterLogementStep(
    BuildContext context,
    ResponsiveLayout layout,
  ) {
    final canContinue =
        !_isLoadingRegisterLogements &&
        _selectedRegisterLogement != null &&
        !_selectedRegisterLogement!.full;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _RegisterStepHeader(
          title: context.l10n.authRegisterHousingStageTitle,
          icon: Icons.apartment_rounded,
        ),
        const SizedBox(height: 12),
        _InlineHint(message: _registerLogementIntro(context)),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: _residenceCodeFieldKey,
          child: TextField(
            controller: _residenceCodeController,
            focusNode: _residenceCodeFocusNode,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              setState(() {
                _registerStep = _RegisterStep.logement;
                _hasLoadedRegisterLogements = false;
                _registerLogements = const <RegistrationLogementOption>[];
                _selectedRegisterLogement = null;
                _feedbackMessage = null;
              });
            },
            onSubmitted: (_) {
              if (!_isLoadingRegisterLogements) {
                _handleLoadRegisterLogements();
              }
            },
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
        FilledButton.icon(
          onPressed: _isLoadingRegisterLogements
              ? null
              : _handleLoadRegisterLogements,
          icon: _isLoadingRegisterLogements
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                )
              : const Icon(Icons.apartment_rounded),
          label: Text(
            _isLoadingRegisterLogements
                ? context.l10n.authSubmittingLabel
                : _registerSearchLogementsLabel(context),
          ),
        ),
        if (_registerLogements.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          Text(
            _registerSelectLogementTitle(context),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ..._registerLogements.map(
            (logement) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RegisterLogementOptionCard(
                logement: logement,
                selected:
                    _selectedRegisterLogement?.logementId == logement.logementId,
                onTap: () {
                  setState(() {
                    _selectedRegisterLogement = logement;
                  });
                },
              ),
            ),
          ),
        ],
        if (_registerLogements.isEmpty &&
            _hasLoadedRegisterLogements &&
            !_isLoadingRegisterLogements) ...<Widget>[
          const SizedBox(height: 20),
          _InlineHint(message: _registerNoLogementMessage(context)),
        ],
        if (_selectedRegisterLogement != null) ...<Widget>[
          const SizedBox(height: 12),
          _RegisterLogementStatusCard(
            logement: _selectedRegisterLogement!,
            message: _registerSelectedLogementMessage(
              context,
              _selectedRegisterLogement!,
            ),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: canContinue
              ? () {
                  setState(() {
                    _feedbackMessage = null;
                    _registerStep = _RegisterStep.profile;
                  });
                }
              : null,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(_registerNextLabel(context)),
        ),
      ],
    );
  }

  Widget _buildRegisterProfileStep(
    BuildContext context, {
    required bool needsCaptcha,
    required bool missingSiteKey,
    required bool canSubmit,
    required CaptchaPublicConfig captcha,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _RegisterStepHeader(
          title: context.l10n.authRegisterProfileStageTitle,
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 12),
        _SelectedLogementBanner(
          title: _selectedRegisterLogement?.displayLabel ?? '',
          codeInterne: _selectedRegisterLogement?.codeInterne ?? '',
          onEdit: () {
            setState(() {
              _registerStep = _RegisterStep.logement;
            });
          },
        ),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: _registerFirstNameFieldKey,
          child: TextField(
            controller: _registerFirstNameController,
            focusNode: _registerFirstNameFocusNode,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const <String>[AutofillHints.givenName],
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
            autofillHints: const <String>[AutofillHints.username],
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.l10n.authEmailLabel,
              prefixIcon: const Icon(Icons.alternate_email_rounded),
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
            keyboardType: TextInputType.visiblePassword,
            enableSuggestions: false,
            autocorrect: false,
            textInputAction: TextInputAction.next,
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
            keyboardType: TextInputType.visiblePassword,
            enableSuggestions: false,
            autocorrect: false,
            textInputAction: needsCaptcha
                ? TextInputAction.next
                : TextInputAction.done,
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
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isRegisterSubmitting
                    ? null
                    : () {
                        setState(() {
                          _registerStep = _RegisterStep.logement;
                        });
                      },
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(_registerBackLabel(context)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
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
      ],
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

  Future<void> _handleLoadRegisterLogements() async {
    final residenceCode = _residenceCodeController.text.trim();
    if (residenceCode.isEmpty) {
      _setFeedback(_localization.authRequiredFieldsMessage, isError: true);
      return;
    }

    setState(() {
      _isLoadingRegisterLogements = true;
      _hasLoadedRegisterLogements = false;
      _registerLogements = const <RegistrationLogementOption>[];
      _selectedRegisterLogement = null;
    });

    try {
      final logements = await ref
          .read(authRepositoryProvider)
          .fetchRegistrationLogements(residenceCode);
      if (!mounted) {
        return;
      }
      setState(() {
        _feedbackMessage = null;
        _hasLoadedRegisterLogements = true;
        _registerLogements = logements;
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
          _isLoadingRegisterLogements = false;
        });
      }
    }
  }

  String _registerLogementIntro(BuildContext context) {
    return context.l10n.authRegisterStepHousingIntro;
  }

  String _registerSearchLogementsLabel(BuildContext context) {
    return context.l10n.authRegisterStepHousingSearch;
  }

  String _registerSelectLogementTitle(BuildContext context) {
    return context.l10n.authRegisterStepHousingTitle;
  }

  String _registerNoLogementMessage(BuildContext context) {
    return context.l10n.authRegisterStepHousingEmpty;
  }

  String _registerSelectedLogementMessage(
    BuildContext context,
    RegistrationLogementOption logement,
  ) {
    if (logement.full) {
      return context.l10n.authRegisterStepHousingFull(logement.maxOccupants);
    }
    if (logement.isFirstResident) {
      return context.l10n.authRegisterStepHousingFirstResident;
    }
    return context.l10n.authRegisterStepHousingOccupied(logement.occupiedCount);
  }

  String _registerNextLabel(BuildContext context) {
    return context.l10n.authRegisterStepNext;
  }

  String _registerBackLabel(BuildContext context) {
    return context.l10n.authRegisterStepBack;
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
        residenceCode.isEmpty ||
        _selectedRegisterLogement == null) {
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
        logementId: _selectedRegisterLogement!.logementId,
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
        _registerStep = _RegisterStep.logement;
        _hasLoadedRegisterLogements = false;
        _registerLogements = const <RegistrationLogementOption>[];
        _selectedRegisterLogement = null;
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

class _RegisterLogementOptionCard extends StatelessWidget {
  const _RegisterLogementOptionCard({
    required this.logement,
    required this.selected,
    required this.onTap,
  });

  final RegistrationLogementOption logement;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = logement.full
        ? colorScheme.error
        : (logement.active ? colorScheme.primary : colorScheme.tertiary);
    final statusLabel = logement.full
        ? context.l10n.authRegisterHousingStatusFull
        : (logement.active
              ? context.l10n.authRegisterHousingStatusActive
              : context.l10n.authRegisterHousingStatusAvailable);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        logement.displayLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      _HousingBadge(
                        label: statusLabel,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _HousingMetaChip(
                        icon: Icons.qr_code_2_rounded,
                        label:
                            '${context.l10n.authRegisterHousingCode}: ${logement.codeInterne}',
                      ),
                      if ((logement.typeLogement ?? '').isNotEmpty)
                        _HousingMetaChip(
                          icon: Icons.home_work_outlined,
                          label: logement.typeLogement!,
                        ),
                      if ((logement.etage ?? '').isNotEmpty)
                        _HousingMetaChip(
                          icon: Icons.layers_outlined,
                          label: logement.etage!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.authRegisterHousingOccupancy(
                      logement.occupiedCount,
                      logement.maxOccupants,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

class _RegisterLogementStatusCard extends StatelessWidget {
  const _RegisterLogementStatusCard({
    required this.logement,
    required this.message,
  });

  final RegistrationLogementOption logement;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isFull = logement.full;
    final background = isFull
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final foreground = isFull
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;
    final occupancyLabel = context.l10n.authRegisterHousingOccupancy(
      logement.occupiedCount,
      logement.maxOccupants,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            occupancyLabel,
            style: theme.textTheme.bodySmall?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _SelectedLogementBanner extends StatelessWidget {
  const _SelectedLogementBanner({
    required this.title,
    required this.codeInterne,
    required this.onEdit,
  });

  final String title;
  final String codeInterne;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  codeInterne,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
            label: Text(context.l10n.authRegisterHousingEdit),
          ),
        ],
      ),
    );
  }
}

class _RegisterStepHeader extends StatelessWidget {
  const _RegisterStepHeader({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _HousingBadge extends StatelessWidget {
  const _HousingBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HousingMetaChip extends StatelessWidget {
  const _HousingMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
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
    final shouldDisableBlurOnNativeMobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final cardDecoration = BoxDecoration(
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
    );
    final cardContent = Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: cardDecoration,
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: shouldDisableBlurOnNativeMobile
          ? cardContent
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: cardContent,
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

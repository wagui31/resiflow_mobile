import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/auth_token_provider.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/widgets/responsive_page_container.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';
import 'widgets/turnstile_captcha_view.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
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
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final configAsync = ref.watch(publicAppConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.moduleAuthTitle),
        actions: const <Widget>[
          LanguageSwitcher(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.tertiary.withValues(alpha: 0.05),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ResponsivePageContainer(
          child: ResponsiveBuilder(
            builder: (context, layout) {
              final content = layout.isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _HeroPanel(currentUser: _currentUser),
                        SizedBox(height: layout.sectionSpacing),
                        _buildAuthCard(context, configAsync, layout),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 11,
                          child: _HeroPanel(currentUser: _currentUser),
                        ),
                        SizedBox(width: layout.sectionSpacing),
                        Expanded(
                          flex: 10,
                          child: _buildAuthCard(context, configAsync, layout),
                        ),
                      ],
                    );

              return ListView(children: <Widget>[content]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard(
    BuildContext context,
    AsyncValue<PublicAppConfig> configAsync,
    dynamic layout,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(layout.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: <Widget>[
                  Tab(text: context.l10n.authSignInTab),
                  Tab(text: context.l10n.authSignUpTab),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_feedbackMessage != null) ...<Widget>[
              _FeedbackBanner(
                message: _feedbackMessage!,
                isError: _feedbackIsError,
              ),
              const SizedBox(height: 20),
            ],
            SizedBox(
              height: 640,
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  _buildLoginForm(context),
                  _buildRegisterForm(context, configAsync),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.l10n.authSignInHeading,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.authSignInDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: context.l10n.authEmailLabel,
            prefixIcon: const Icon(Icons.alternate_email_rounded),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPassword,
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
        const Spacer(),
        FilledButton(
          onPressed: _isLoginSubmitting ? null : _handleLogin,
          child: Text(
            _isLoginSubmitting
                ? context.l10n.authSubmittingLabel
                : context.l10n.authLoginButton,
          ),
        ),
      ],
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
          const Spacer(),
          OutlinedButton(
            onPressed: () => ref.invalidate(publicAppConfigProvider),
            child: Text(context.l10n.authRetryButton),
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

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        Text(
          context.l10n.authSignUpHeading,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.authSignUpDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
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
        FilledButton(
          onPressed: canSubmit ? _handleRegister : null,
          child: Text(
            _isRegisterSubmitting
                ? context.l10n.authSubmittingLabel
                : context.l10n.authRegisterButton,
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
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.login(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );
      ref.read(authTokenProvider.notifier).setToken(result.token);
      final currentUser = await repository.getCurrentUser();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = currentUser;
      });
      _setFeedback(_localization.authLoginSuccess, isError: false);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ref.read(authTokenProvider.notifier).clearToken();
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
      final user = await ref.read(authRepositoryProvider).register(payload);

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = null;
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
      _tabController.animateTo(0);
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

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.currentUser,
  });

  final UserProfile? currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              context.l10n.authHeroEyebrow,
              style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.authHeroTitle,
            style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.authHeroDescription,
            style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _FeatureChip(label: context.l10n.authFeatureResidenceCode),
              _FeatureChip(label: context.l10n.authFeatureAdminValidation),
              _FeatureChip(label: context.l10n.authFeatureSecureAccess),
            ],
          ),
          const SizedBox(height: 28),
          if (currentUser != null) _CurrentUserCard(user: currentUser!),
        ],
      ),
    );
  }
}

class _CurrentUserCard extends StatelessWidget {
  const _CurrentUserCard({
    required this.user,
  });

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.authCurrentUserTitle,
            style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _CurrentUserRow(
            label: context.l10n.authEmailLabel,
            value: user.email,
          ),
          _CurrentUserRow(
            label: context.l10n.authRoleLabel,
            value: _roleLabel(context, user.role),
          ),
          _CurrentUserRow(
            label: context.l10n.authStatusLabel,
            value: _statusLabel(context, user.status),
          ),
          _CurrentUserRow(
            label: context.l10n.authResidenceLabel,
            value: user.residenceCode ?? '-',
          ),
        ],
      ),
    );
  }

  static String _roleLabel(BuildContext context, UserRole role) {
    return switch (role) {
      UserRole.superAdmin => context.l10n.authRoleSuperAdmin,
      UserRole.admin => context.l10n.authRoleAdmin,
      UserRole.user => context.l10n.authRoleUser,
      UserRole.unknown => '-',
    };
  }

  static String _statusLabel(BuildContext context, UserStatus status) {
    return switch (status) {
      UserStatus.pending => context.l10n.authStatusPending,
      UserStatus.active => context.l10n.authStatusActive,
      UserStatus.rejected => context.l10n.authStatusRejected,
      UserStatus.unknown => '-',
    };
  }
}

class _CurrentUserRow extends StatelessWidget {
  const _CurrentUserRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
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

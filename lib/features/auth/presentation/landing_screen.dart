import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/widgets/responsive_page_container.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
        actions: const <Widget>[
          LanguageSwitcher(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.secondary.withValues(alpha: 0.06),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ResponsivePageContainer(
          child: ResponsiveBuilder(
            builder: (context, layout) {
              final heroCard = _LandingHeroCard(
                onLoginPressed: () => context.goNamed(loginRouteName),
                onRegisterPressed: () => context.goNamed(registerRouteName),
              );

              if (layout.isMobile) {
                return ListView(
                  children: <Widget>[
                    heroCard,
                  ],
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: heroCard,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LandingHeroCard extends StatelessWidget {
  const _LandingHeroCard({
    required this.onLoginPressed,
    required this.onRegisterPressed,
  });

  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;

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
            colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
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
              _LandingFeatureChip(label: context.l10n.authFeatureResidenceCode),
              _LandingFeatureChip(label: context.l10n.authFeatureAdminValidation),
              _LandingFeatureChip(label: context.l10n.authFeatureSecureAccess),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton(
                onPressed: onLoginPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                ),
                child: Text(context.l10n.authLoginButton),
              ),
              OutlinedButton(
                onPressed: onRegisterPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                ),
                child: Text(context.l10n.authRegisterButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LandingFeatureChip extends StatelessWidget {
  const _LandingFeatureChip({
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

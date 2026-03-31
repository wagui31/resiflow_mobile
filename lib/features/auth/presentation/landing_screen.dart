import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/widgets/responsive_page_container.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final imageAsset = AppAssets.landingImage(brightness);
    final logoAsset = AppAssets.appLogo(brightness);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.tertiary.withValues(alpha: 0.06),
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
                imageAsset: imageAsset,
                logoAsset: logoAsset,
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

              return heroCard;
            },
          ),
        ),
      ),
    );
  }
}

class _LandingHeroCard extends StatelessWidget {
  const _LandingHeroCard({
    required this.imageAsset,
    required this.logoAsset,
    required this.onLoginPressed,
    required this.onRegisterPressed,
  });

  final String imageAsset;
  final String logoAsset;
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveBuilder(
      builder: (context, layout) {
        final isCompact = layout.isMobile;
        final content = _LandingContentPanel(
          logoAsset: logoAsset,
          isCompact: isCompact,
          onLoginPressed: onLoginPressed,
          onRegisterPressed: onRegisterPressed,
        );
        final image = _LandingVisualPanel(
          imageAsset: imageAsset,
          isCompact: isCompact,
        );

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: isDark ? 0.78 : 0.9),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.24 : 0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: isCompact
                ? Column(
                    children: <Widget>[
                      image,
                      content,
                    ],
                  )
                : ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: layout.isDesktop ? 640 : 560,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: layout.isDesktop ? 11 : 10,
                          child: content,
                        ),
                        Expanded(
                          flex: layout.isDesktop ? 9 : 8,
                          child: image,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _LandingContentPanel extends StatelessWidget {
  const _LandingContentPanel({
    required this.logoAsset,
    required this.isCompact,
    required this.onLoginPressed,
    required this.onRegisterPressed,
  });

  final String logoAsset;
  final bool isCompact;
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCompact ? 20 : 32,
        isCompact ? 20 : 28,
        isCompact ? 20 : 32,
        isCompact ? 24 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppLogo(
                      logoAssetPath: logoAsset,
                      size: isCompact ? 56 : 68,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        context.l10n.appName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const LanguageSwitcher(),
            ],
          ),
          const SizedBox(height: 24),
          _LandingBadge(label: context.l10n.landingBadge),
          const SizedBox(height: 18),
          Text(
            context.l10n.landingTitle,
            style: (isCompact
                    ? theme.textTheme.headlineLarge
                    : theme.textTheme.displaySmall)
                ?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 0.98,
                ),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.landingDescription,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _LandingFeatureChip(label: context.l10n.landingFeatureNeighbors),
              _LandingFeatureChip(
                label: context.l10n.landingFeatureSharedManagement,
              ),
              _LandingFeatureChip(label: context.l10n.landingFeatureCagnotte),
              _LandingFeatureChip(label: context.l10n.landingFeaturePayments),
            ],
          ),
          if (isCompact) const SizedBox(height: 24) else const Spacer(),
          Container(
            padding: EdgeInsets.all(isCompact ? 16 : 18),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.landingCtaTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.landingCtaDescription,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          FilledButton(
                            onPressed: onLoginPressed,
                            child: Text(context.l10n.landingLoginButton),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: onRegisterPressed,
                            child: Text(context.l10n.landingRegisterButton),
                          ),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          Expanded(
                            child: FilledButton(
                              onPressed: onLoginPressed,
                              child: Text(context.l10n.landingLoginButton),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onRegisterPressed,
                              child: Text(context.l10n.landingRegisterButton),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingVisualPanel extends StatelessWidget {
  const _LandingVisualPanel({
    required this.imageAsset,
    required this.isCompact,
  });

  final String imageAsset;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        minHeight: isCompact ? 280 : 0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.16),
            colorScheme.tertiary.withValues(alpha: 0.12),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            left: -32,
            top: -16,
            child: _GlowOrb(
              size: isCompact ? 140 : 180,
              color: colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            right: -28,
            bottom: -20,
            child: _GlowOrb(
              size: isCompact ? 120 : 170,
              color: colorScheme.tertiary.withValues(alpha: 0.16),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isCompact ? 20 : 28),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isCompact ? 420 : 520,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: isCompact ? 1.22 : 0.95,
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingBadge extends StatelessWidget {
  const _LandingBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
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
          gradient: RadialGradient(
            colors: <Color>[
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/language_switcher.dart';

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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(imageAsset, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  colorScheme.surface.withValues(
                    alpha: brightness == Brightness.dark ? 0.16 : 0.08,
                  ),
                  colorScheme.shadow.withValues(
                    alpha: brightness == Brightness.dark ? 0.32 : 0.22,
                  ),
                  colorScheme.shadow.withValues(
                    alpha: brightness == Brightness.dark ? 0.74 : 0.68,
                  ),
                ],
                stops: const <double>[0, 0.42, 1],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colorScheme.primary.withValues(
                    alpha: brightness == Brightness.dark ? 0.18 : 0.12,
                  ),
                  Colors.transparent,
                  colorScheme.tertiary.withValues(
                    alpha: brightness == Brightness.dark ? 0.18 : 0.1,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: ResponsiveBuilder(
              builder: (context, layout) {
                final horizontalPadding = layout.horizontalPadding;
                final verticalPadding = layout.verticalPadding;
                final maxWidth = layout.isDesktop
                    ? 560.0
                    : (layout.isTablet ? 640.0 : double.infinity);

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.topRight,
                        child: LanguageSwitcher(),
                      ),
                      const Spacer(),
                      Align(
                        alignment: layout.isMobile
                            ? Alignment.bottomLeft
                            : Alignment.bottomCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: _LandingOverlayContent(
                            logoAsset: logoAsset,
                            isMobile: layout.isMobile,
                            onRegisterPressed: () =>
                                context.goNamed(registerRouteName),
                            onLoginPressed: () =>
                                context.goNamed(loginRouteName),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingOverlayContent extends StatelessWidget {
  const _LandingOverlayContent({
    required this.logoAsset,
    required this.onRegisterPressed,
    required this.onLoginPressed,
    required this.isMobile,
  });

  final String logoAsset;
  final VoidCallback onRegisterPressed;
  final VoidCallback onLoginPressed;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 8 : 20),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.14 : 0.12,
          ),
          borderRadius: BorderRadius.circular(isMobile ? 28 : 32),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 28 : 32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppLogo(logoAssetPath: logoAsset, size: isMobile ? 60 : 72),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        context.l10n.appName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.landingTitle,
                  style:
                      (isMobile
                              ? theme.textTheme.headlineLarge
                              : theme.textTheme.displaySmall)
                          ?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            height: 0.96,
                          ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.landingDescription,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.86),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.landingCtaDescription,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onRegisterPressed,
                    child: Text(context.l10n.landingRegisterButton),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: <Widget>[
                      Text(
                        context.l10n.landingLoginPrompt,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.86),
                        ),
                      ),
                      TextButton(
                        onPressed: onLoginPressed,
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: colorScheme.onSurface,
                          ),
                        ),
                        child: Text(context.l10n.landingLoginButton),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

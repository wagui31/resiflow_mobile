import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../../features/auth/domain/auth_models.dart';
import '../../features/dashboard/application/dashboard_providers.dart';
import '../../features/dashboard/domain/dashboard_models.dart';
import '../branding/app_branding.dart';
import '../i18n/extensions/app_localizations_x.dart';
import '../responsive/responsive_builder.dart';
import '../router/app_router.dart';
import 'account_settings_dialog.dart';
import 'app_logo.dart';
import 'formatted_amount_text.dart';
import 'language_selection_dialog.dart';

class GlobalTopBanner extends ConsumerWidget {
  const GlobalTopBanner({
    required this.bottomNavigationHeight,
    super.key,
  });

  final double bottomNavigationHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = ref.watch(currentUserProvider);
    final currencyCode = ref.watch(currentCurrencyCodeProvider);
    final dashboardSnapshotAsync = ref.watch(dashboardSnapshotProvider);
    const branding = AppBranding.current;

    return ResponsiveBuilder(
      builder: (context, layout) {
        const leftPadding = 0.0;
        final rightPadding = layout.isMobile ? 12.0 : 18.0;
        final verticalPadding = layout.isMobile ? 4.0 : 6.0;
        final bottomPadding = layout.isMobile ? 4.0 : 6.0;
        final logoSize = layout.isMobile ? 56.0 : 72.0;
        final iconButtonSize = layout.isMobile ? 36.0 : 40.0;
        final centerSafePadding = layout.isMobile ? 76.0 : 104.0;
        final userName = currentUser?.displayName.trim() ?? '';
        final userEmail = currentUser?.email.trim() ?? '';

        return Material(
          color: colorScheme.surface.withValues(alpha: 0.96),
          elevation: 10,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                leftPadding,
                verticalPadding,
                rightPadding,
                bottomPadding,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.65),
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    colorScheme.surface,
                    colorScheme.surfaceContainerLowest.withValues(alpha: 0.94),
                    colorScheme.surfaceContainerHigh.withValues(alpha: 0.88),
                  ],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppLogo(
                        logoAssetPath: branding.logoAssetPath,
                        size: logoSize,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: centerSafePadding,
                      ),
                      child: _FundBalancePill(
                        balanceAsync: dashboardSnapshotAsync,
                        currencyCode: currencyCode,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.74,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.72,
                            ),
                          ),
                        ),
                        child: PopupMenuButton<_ShellMenuAction>(
                          tooltip: context.l10n.accountMenuTooltip,
                          onSelected: (action) =>
                              _handleAction(context, ref, action, currentUser),
                          position: PopupMenuPosition.under,
                          offset: const Offset(0, 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          itemBuilder: (context) =>
                              <PopupMenuEntry<_ShellMenuAction>>[
                                PopupMenuItem<_ShellMenuAction>(
                                  enabled: false,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: layout.isMobile ? 14 : 16,
                                    vertical: 0,
                                  ),
                                  child: _AccountMenuHeader(
                                    name: userName,
                                    email: userEmail,
                                  ),
                                ),
                                const PopupMenuDivider(height: 1),
                                PopupMenuItem<_ShellMenuAction>(
                                  value: _ShellMenuAction.account,
                                  child: _MenuItemContent(
                                    icon: Icons.person_rounded,
                                    label: context.l10n.accountMenuProfile,
                                  ),
                                ),
                                PopupMenuItem<_ShellMenuAction>(
                                  value: _ShellMenuAction.language,
                                  child: _MenuItemContent(
                                    icon: Icons.language_rounded,
                                    label: context.l10n.accountMenuLanguage,
                                  ),
                                ),
                                PopupMenuItem<_ShellMenuAction>(
                                  value: _ShellMenuAction.logout,
                                  child: _MenuItemContent(
                                    icon: Icons.logout_rounded,
                                    label: context.l10n.authLogoutButton,
                                  ),
                                ),
                              ],
                          child: SizedBox(
                            width: iconButtonSize,
                            height: iconButtonSize,
                            child: Icon(
                              Icons.menu_rounded,
                              size: layout.isMobile ? 20 : 22,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _ShellMenuAction action,
    UserProfile? currentUser,
  ) async {
    switch (action) {
      case _ShellMenuAction.account:
        if (currentUser == null) {
          return;
        }
        final updated = await showAccountSettingsDialog(
          context,
          currentUser: currentUser,
        );
        if (updated == true && context.mounted) {
          ref.invalidate(dashboardSnapshotProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.usersProfileUpdatedSuccess),
              margin: EdgeInsets.only(bottom: bottomNavigationHeight + 12),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      case _ShellMenuAction.language:
        await showLanguageSelectionDialog(context);
        return;
      case _ShellMenuAction.logout:
        ref.read(authSessionControllerProvider.notifier).clearSession();
        if (context.mounted) {
          context.goNamed(landingRouteName);
        }
        return;
    }
  }
}

enum _ShellMenuAction { account, language, logout }

class _FundBalancePill extends StatelessWidget {
  const _FundBalancePill({
    required this.balanceAsync,
    required this.currencyCode,
  });

  final AsyncValue<DashboardSnapshot> balanceAsync;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return balanceAsync.when(
      loading: () => SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colorScheme.primary,
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (snapshot) => Center(
        child: FormattedAmountText(
          snapshot.stats.currentBalance,
          currencyCode: currencyCode,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

class _MenuItemContent extends StatelessWidget {
  const _MenuItemContent({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _AccountMenuHeader extends StatelessWidget {
  const _AccountMenuHeader({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedName = name.isNotEmpty ? name : email;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              resolvedName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            if (email.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_dashboard_theme.dart';
import '../../../../core/widgets/global_page_header.dart';
import '../../../auth/domain/auth_models.dart';

class DashboardAction {
  const DashboardAction({
    required this.title,
    required this.description,
    required this.routeName,
    required this.icon,
  });

  final String title;
  final String description;
  final String routeName;
  final IconData icon;
}

class DashboardMetric {
  const DashboardMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.toneColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color toneColor;
}

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({required this.title, required this.layout, super.key});

  final String title;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return GlobalPageHeader(title: title, layout: layout);
  }
}

class DashboardHero extends StatelessWidget {
  const DashboardHero({required this.layout, required this.user, super.key});

  final ResponsiveLayout layout;
  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    final userName = (user?.firstName ?? '').trim();
    final residenceName = (user?.residenceName ?? '').trim();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dashboardTheme.heroRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            dashboardTheme.heroStartColor,
            dashboardTheme.heroEndColor,
          ],
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dashboardTheme.heroGlowColor,
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(dashboardTheme.heroRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: layout.isMobile ? 18 : 22,
              vertical: layout.isMobile ? 14 : 16,
            ),
            child: _HeroContent(
              layout: layout,
              userName: userName,
              residenceName: residenceName,
              paymentStatus: user?.paymentStatus ?? PaymentStatus.unknown,
              paymentStatusTone: _paymentTone(
                user?.paymentStatus ?? PaymentStatus.unknown,
                context,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _paymentTone(PaymentStatus status, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);

    return switch (status) {
      PaymentStatus.upToDate => dashboardTheme.successColor,
      PaymentStatus.late => dashboardTheme.warningColor,
      PaymentStatus.unknown => colorScheme.primary,
    };
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.layout,
    required this.userName,
    required this.residenceName,
    required this.paymentStatus,
    required this.paymentStatusTone,
  });

  final ResponsiveLayout layout;
  final String userName;
  final String residenceName;
  final PaymentStatus paymentStatus;
  final Color paymentStatusTone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                userName.isNotEmpty
                    ? context.l10n.dashboardGreeting(userName)
                    : context.l10n.dashboardGreetingGeneric,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (layout.isMobile
                            ? theme.textTheme.titleLarge
                            : theme.textTheme.headlineSmall)
                        ?.copyWith(fontWeight: FontWeight.w900, height: 1.05),
              ),
            ),
            const SizedBox(width: 12),
            PaymentStatusIcon(status: paymentStatus, color: paymentStatusTone),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          residenceName.isNotEmpty
              ? context.l10n.dashboardWelcomeResidenceCompact(residenceName)
              : context.l10n.dashboardWelcomeResidenceCompactFallback,
          maxLines: layout.isMobile ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.25,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    required this.layout,
    required this.child,
    super.key,
  });

  final ResponsiveLayout layout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);

    return Container(
      padding: EdgeInsets.all(layout.isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(dashboardTheme.sectionRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    required this.metric,
    required this.layout,
    super.key,
  });

  final DashboardMetric metric;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(layout.isMobile ? 18 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: metric.toneColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(metric.icon, color: metric.toneColor),
          ),
          const SizedBox(height: 18),
          Text(
            metric.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metric.value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardStatusBadge extends StatelessWidget {
  const DashboardStatusBadge({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class PaymentStatusIcon extends StatelessWidget {
  const PaymentStatusIcon({
    required this.status,
    required this.color,
    super.key,
  });

  final PaymentStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (icon, message) = switch (status) {
      PaymentStatus.upToDate => (
        Icons.verified_rounded,
        context.l10n.dashboardPaymentStatusTooltipUpToDate,
      ),
      PaymentStatus.late => (
        Icons.warning_amber_rounded,
        context.l10n.dashboardPaymentStatusTooltipLate,
      ),
      PaymentStatus.unknown => (
        Icons.help_outline_rounded,
        context.l10n.dashboardPaymentStatusTooltipUnknown,
      ),
    };

    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DashboardErrorState extends StatelessWidget {
  const DashboardErrorState({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.dashboardErrorTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: Text(context.l10n.authRetryButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

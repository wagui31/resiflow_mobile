import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/extensions/app_localizations_x.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_dashboard_theme.dart';
import '../../../auth/domain/auth_models.dart';
import '../../../paiement/application/paiement_providers.dart';
import '../../../paiement/domain/paiement_models.dart';
import '../../domain/dashboard_models.dart';

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
    this.supportingText,
    this.trailingSupportingText,
  });

  final String title;
  final Widget value;
  final IconData icon;
  final Color toneColor;
  final String? supportingText;
  final String? trailingSupportingText;
}

class DashboardHero extends ConsumerWidget {
  const DashboardHero({
    required this.layout,
    required this.user,
    required this.paymentHousingStats,
    super.key,
  });

  final ResponsiveLayout layout;
  final UserProfile? user;
  final DashboardPaymentHousingStats paymentHousingStats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    final userName = user?.displayName ?? '';
    final residenceName = (user?.residenceName ?? '').trim();
    final logement = user?.logement;
    final housingStatusLabel = switch (logement?.active) {
      true => context.l10n.dashboardCurrentHousingActive,
      false => context.l10n.dashboardCurrentHousingPending,
      null => context.l10n.dashboardCurrentHousingUnavailable,
    };
    final housingStatusColor = switch (logement?.active) {
      true => dashboardTheme.successColor,
      false => dashboardTheme.warningColor,
      null => colorScheme.onSurfaceVariant,
    };
    final paymentStatus = ref
        .watch(residentPaymentControllerProvider)
        .maybeWhen(
          data: (overview) => overview.status,
          orElse: () => ResidentPaymentStatus.unknown,
        );

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
              housingCode: (logement?.codeInterne ?? user?.codeLogement ?? '')
                  .trim(),
              housingStatusLabel: housingStatusLabel,
              housingStatusColor: housingStatusColor,
              paymentStatusLabel: _paymentStatusLabel(paymentStatus, context),
              paymentStatusTone: _paymentTone(paymentStatus, context),
              activeHousingCount: paymentHousingStats.totalActiveHousing,
              inactiveHousingCount: paymentHousingStats.totalInactiveHousing,
            ),
          ),
        ),
      ),
    );
  }

  Color _paymentTone(ResidentPaymentStatus status, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);

    return switch (status) {
      ResidentPaymentStatus.upToDate => dashboardTheme.successColor,
      ResidentPaymentStatus.overdue => const Color(0xFFC62828),
      ResidentPaymentStatus.unknown => colorScheme.primary,
    };
  }

  String _paymentStatusLabel(
    ResidentPaymentStatus status,
    BuildContext context,
  ) {
    return switch (status) {
      ResidentPaymentStatus.upToDate => 'Paiement \u00E0 jour',
      ResidentPaymentStatus.overdue => 'Paiement en retard',
      ResidentPaymentStatus.unknown =>
        '${context.l10n.modulePaymentTitle} ${context.l10n.paymentStatusUnknown}',
    };
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.layout,
    required this.userName,
    required this.residenceName,
    required this.housingCode,
    required this.housingStatusLabel,
    required this.housingStatusColor,
    required this.paymentStatusLabel,
    required this.paymentStatusTone,
    required this.activeHousingCount,
    required this.inactiveHousingCount,
  });

  final ResponsiveLayout layout;
  final String userName;
  final String residenceName;
  final String housingCode;
  final String housingStatusLabel;
  final Color housingStatusColor;
  final String paymentStatusLabel;
  final Color paymentStatusTone;
  final int activeHousingCount;
  final int inactiveHousingCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    final greetingStyle =
        (layout.isMobile
                ? theme.textTheme.titleLarge
                : theme.textTheme.headlineSmall)
            ?.copyWith(fontWeight: FontWeight.w900, height: 1.05);
    final secondaryTextColor = colorScheme.onSurfaceVariant;
    final residenceLabel = residenceName.isNotEmpty
        ? residenceName
        : 'Votre residence';
    final housingLabel = housingCode.isNotEmpty
        ? housingCode
        : context.l10n.dashboardCurrentHousingUnavailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: layout.isDesktop ? 560 : layout.maxContentWidth,
              ),
              child: Text(
                context.l10n.dashboardGreetingGeneric,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: greetingStyle,
              ),
            ),
            DashboardStatusBadge(
              label: housingStatusLabel,
              color: housingStatusColor,
            ),
            DashboardStatusBadge(
              label: paymentStatusLabel,
              color: paymentStatusTone,
            ),
          ],
        ),
        if (userName.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: secondaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: <Widget>[
            _HeroInlineDetail(
              label: 'Residence',
              value: residenceLabel,
              valueColor: colorScheme.onSurface,
            ),
            _HeroInlineDetail(
              label: 'Logement',
              value: housingLabel,
              valueColor: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Un apercu fluide de votre espace resident pour suivre les paiements, votre logement et la vie de votre residence.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: secondaryTextColor,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 18,
          runSpacing: 10,
          children: <Widget>[
            _HeroStatInline(
              label: 'Logements actifs',
              value: activeHousingCount.toString(),
              color: dashboardTheme.successColor,
            ),
            _HeroStatInline(
              label: 'Logements non actifs',
              value: inactiveHousingCount.toString(),
              color: dashboardTheme.warningColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroInlineDetail extends StatelessWidget {
  const _HeroInlineDetail({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.3,
        ),
        children: <InlineSpan>[
          TextSpan(
            text: '$label : ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _HeroStatInline extends StatelessWidget {
  const _HeroStatInline({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          height: 1.25,
        ),
        children: <InlineSpan>[
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
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
    final cardPadding = layout.isMobile ? 16.0 : 20.0;
    final iconPadding = layout.isMobile ? 8.0 : 10.0;
    final spacingAfterIcon = layout.isMobile ? 14.0 : 18.0;
    final spacingBeforeValue = layout.isMobile ? 6.0 : 8.0;
    final spacingBeforeSupporting = layout.isMobile ? 8.0 : 10.0;
    final valueStyle =
        (layout.isMobile
                ? theme.textTheme.titleLarge
                : theme.textTheme.headlineSmall)
            ?.copyWith(fontWeight: FontWeight.w900);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: metric.toneColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(metric.icon, color: metric.toneColor),
          ),
          SizedBox(height: spacingAfterIcon),
          Text(
            metric.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacingBeforeValue),
          DefaultTextStyle(
            style: valueStyle ?? const TextStyle(),
            child: metric.value,
          ),
          if (metric.supportingText != null ||
              metric.trailingSupportingText != null) ...<Widget>[
            SizedBox(height: spacingBeforeSupporting),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    metric.supportingText ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (metric.trailingSupportingText != null) ...<Widget>[
                  const SizedBox(width: 8),
                  Text(
                    metric.trailingSupportingText!,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
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

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_dashboard_theme.dart';
import '../../domain/dashboard_models.dart';
import 'dashboard_panels.dart';

class DashboardPieChartsSection extends StatelessWidget {
  const DashboardPieChartsSection({
    required this.layout,
    required this.paymentHousingStats,
    required this.expenseCategoryStats,
    super.key,
  });

  final ResponsiveLayout layout;
  final DashboardPaymentHousingStats paymentHousingStats;
  final DashboardExpenseCategoryStats expenseCategoryStats;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      SizedBox(
        width: _cardWidth(layout),
        child: _DashboardPieChartCard(
          layout: layout,
          title: 'Paiement des logements',
          subtitle: 'Repartition des paiements entre logements a jour et en retard.',
          totalLabel: '${paymentHousingStats.lateHousing} logements en retard',
          segments: <_ChartSegment>[
            _ChartSegment(
              label: 'A jour',
              value: paymentHousingStats.upToDateHousing.toDouble(),
              color: _successColor(context),
            ),
            _ChartSegment(
              label: 'En retard',
              value: paymentHousingStats.lateHousing.toDouble(),
              color: _lateColor(),
            ),
          ],
          emptyTitle: 'Aucun logement actif a afficher.',
        ),
      ),
      SizedBox(
        width: _cardWidth(layout),
        child: _DashboardPieChartCard(
          layout: layout,
          title: 'Depenses par categorie',
          subtitle: 'Nombre de depenses enregistrees par categorie.',
          totalLabel:
              '${expenseCategoryStats.categories.fold<int>(0, (sum, item) => sum + item.expenseCount)} depenses',
          segments: expenseCategoryStats.categories
              .map(
                (category) => _ChartSegment(
                  label: category.categoryName,
                  value: category.expenseCount.toDouble(),
                  color: _categoryColor(context, category.categoryName),
                ),
              )
              .toList(),
          emptyTitle: 'Aucune depense disponible pour le moment.',
        ),
      ),
    ];

    return Wrap(
      spacing: layout.itemSpacing,
      runSpacing: layout.itemSpacing,
      children: cards,
    );
  }

  double _cardWidth(ResponsiveLayout layout) {
    if (layout.isDesktop) {
      return (layout.maxContentWidth - layout.itemSpacing) / 2;
    }
    return layout.maxContentWidth;
  }

  Color _successColor(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);
    return dashboardTheme.successColor;
  }

  Color _lateColor() {
    return const Color(0xFFC62828);
  }

  Color _categoryColor(BuildContext context, String label) {
    final palette = <Color>[
      const Color(0xFF005F73),
      const Color(0xFF0A9396),
      const Color(0xFF94D2BD),
      const Color(0xFFEE9B00),
      const Color(0xFFCA6702),
      const Color(0xFFD97706),
      const Color(0xFFF59E0B),
      const Color(0xFFFB923C),
    ];
    final seed = label.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return palette[seed % palette.length];
  }
}

class _DashboardPieChartCard extends StatelessWidget {
  const _DashboardPieChartCard({
    required this.layout,
    required this.title,
    required this.subtitle,
    required this.totalLabel,
    required this.segments,
    required this.emptyTitle,
  });

  final ResponsiveLayout layout;
  final String title;
  final String subtitle;
  final String totalLabel;
  final List<_ChartSegment> segments;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visibleSegments = segments.where((segment) => segment.value > 0).toList();
    final total = visibleSegments.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    return DashboardSectionCard(
      layout: layout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: layout.itemSpacing / 2),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          SizedBox(height: layout.sectionSpacing),
          if (visibleSegments.isEmpty)
            DashboardEmptyState(title: emptyTitle)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _PieChartVisual(
                  segments: visibleSegments,
                  totalLabel: totalLabel,
                ),
                SizedBox(height: layout.itemSpacing),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: visibleSegments
                      .map(
                        (segment) => SizedBox(
                          width: layout.isMobile
                              ? layout.maxContentWidth - 36
                              : 220,
                          child: _PieLegendTile(
                            segment: segment,
                            total: total,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PieChartVisual extends StatelessWidget {
  const _PieChartVisual({
    required this.segments,
    required this.totalLabel,
  });

  final List<_ChartSegment> segments;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context).width < 420 ? 180.0 : 220.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: Size.square(size),
            painter: _PieChartPainter(
              segments: segments,
              baseColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          Container(
            width: size * 0.52,
            height: size * 0.52,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12),
            child: Text(
              totalLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieLegendTile extends StatelessWidget {
  const _PieLegendTile({required this.segment, required this.total});

  final _ChartSegment segment;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percent = total == 0 ? 0 : ((segment.value / total) * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: segment.color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              segment.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${segment.value.toInt()} | $percent%',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  const _PieChartPainter({
    required this.segments,
    required this.baseColor,
  });

  final List<_ChartSegment> segments;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (sum, segment) => sum + segment.value);
    final rect = Offset.zero & size;
    final strokeWidth = size.width * 0.18;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    paint.color = baseColor.withValues(alpha: 0.35);
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, math.pi * 2, false, paint);

    if (total <= 0) {
      return;
    }

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * math.pi * 2;
      paint.color = segment.color;
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.segments != segments || oldDelegate.baseColor != baseColor;
  }
}

class _ChartSegment {
  const _ChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

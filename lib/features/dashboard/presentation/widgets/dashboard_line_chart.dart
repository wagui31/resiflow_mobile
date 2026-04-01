import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_dashboard_theme.dart';
import '../../domain/dashboard_models.dart';

class DashboardLineChart extends StatelessWidget {
  const DashboardLineChart({
    required this.points,
    super.key,
  });

  final List<DashboardBalancePoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardTheme =
        theme.extension<AppDashboardTheme>() ??
        AppDashboardTheme.light(colorScheme);

    if (points.length < 2) {
      return const SizedBox.shrink();
    }

    final labels = _visibleLabels(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 220,
          child: CustomPaint(
            painter: _DashboardChartPainter(
              points: points,
              lineColor: colorScheme.primary,
              fillColor: dashboardTheme.chartFillColor,
              guideColor: colorScheme.outlineVariant,
              pointColor: colorScheme.surface,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: labels
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  List<String> _visibleLabels(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final labelIndexes = <int>{
      0,
      points.length ~/ 2,
      points.length - 1,
    }.toList()
      ..sort();

    return labelIndexes
        .map((index) => _formatMonth(points[index].month, locale))
        .toList();
  }

  String _formatMonth(String rawValue, String locale) {
    final parsed = DateTime.tryParse('$rawValue-01');
    if (parsed == null) {
      return rawValue;
    }
    return DateFormat.MMM(locale).format(parsed);
  }
}

class _DashboardChartPainter extends CustomPainter {
  const _DashboardChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.guideColor,
    required this.pointColor,
  });

  final List<DashboardBalancePoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color guideColor;
  final Color pointColor;

  @override
  void paint(Canvas canvas, Size size) {
    const chartPadding = EdgeInsets.fromLTRB(10, 12, 10, 18);
    final chartRect = Rect.fromLTWH(
      chartPadding.left,
      chartPadding.top,
      size.width - chartPadding.horizontal,
      size.height - chartPadding.vertical,
    );

    final minValue = points.map((point) => point.balance).reduce(math.min);
    final maxValue = points.map((point) => point.balance).reduce(math.max);
    final valueRange = (maxValue - minValue).abs() < 0.0001
        ? 1.0
        : maxValue - minValue;

    final path = Path();
    final fillPath = Path();
    Offset? firstOffset;
    Offset? lastOffset;

    for (var i = 0; i < points.length; i++) {
      final dx = chartRect.left +
          chartRect.width * (i / math.max(1, points.length - 1));
      final normalizedY = (points[i].balance - minValue) / valueRange;
      final dy = chartRect.bottom - (normalizedY * chartRect.height);
      final offset = Offset(dx, dy);

      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
        fillPath.moveTo(offset.dx, chartRect.bottom);
        fillPath.lineTo(offset.dx, offset.dy);
        firstOffset = offset;
      } else {
        final previousDx = chartRect.left +
            chartRect.width * ((i - 1) / math.max(1, points.length - 1));
        final previousNormalizedY =
            (points[i - 1].balance - minValue) / valueRange;
        final previousDy =
            chartRect.bottom - (previousNormalizedY * chartRect.height);
        final controlDx = (previousDx + offset.dx) / 2;

        path.cubicTo(
          controlDx,
          previousDy,
          controlDx,
          offset.dy,
          offset.dx,
          offset.dy,
        );
        fillPath.cubicTo(
          controlDx,
          previousDy,
          controlDx,
          offset.dy,
          offset.dx,
          offset.dy,
        );
      }

      lastOffset = offset;
    }

    if (firstOffset != null && lastOffset != null) {
      fillPath
        ..lineTo(lastOffset.dx, chartRect.bottom)
        ..close();
    }

    final guidePaint = Paint()
      ..color = guideColor.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 3; i++) {
      final dy = chartRect.top + (chartRect.height / 2) * i;
      canvas.drawLine(
        Offset(chartRect.left, dy),
        Offset(chartRect.right, dy),
        guidePaint,
      );
    }

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          fillColor,
          fillColor.withValues(alpha: 0.02),
        ],
      ).createShader(chartRect);
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    final markerOuterPaint = Paint()..color = lineColor;
    final markerInnerPaint = Paint()..color = pointColor;

    for (var i = 0; i < points.length; i++) {
      final dx = chartRect.left +
          chartRect.width * (i / math.max(1, points.length - 1));
      final normalizedY = (points[i].balance - minValue) / valueRange;
      final dy = chartRect.bottom - (normalizedY * chartRect.height);
      canvas.drawCircle(Offset(dx, dy), 5.5, markerOuterPaint);
      canvas.drawCircle(Offset(dx, dy), 2.5, markerInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashboardChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.guideColor != guideColor ||
        oldDelegate.pointColor != pointColor;
  }
}

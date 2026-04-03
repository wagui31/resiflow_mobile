import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatting/currency_formatter.dart';
import '../../../../core/theme/app_dashboard_theme.dart';
import '../../domain/dashboard_models.dart';

class DashboardLineChart extends StatelessWidget {
  const DashboardLineChart({
    required this.points,
    required this.currencyCode,
    super.key,
  });

  final List<DashboardBalancePoint> points;
  final String? currencyCode;

  static const double _chartHeight = 220;
  static const double _yAxisWidth = 72;

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

    final monthLabels = _visibleLabels(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: _chartHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = math.max(
                0.0,
                constraints.maxWidth - _yAxisWidth,
              );
              final layout = _ChartLayout.compute(
                points: points,
                size: Size(chartWidth, _chartHeight),
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: _yAxisWidth,
                    child: _YAxisLabels(
                      tickValues: layout.tickValues,
                      chartRect: layout.chartRect,
                      currencyCode: currencyCode,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DashboardChartPainter(
                              points: points,
                              lineColor: colorScheme.primary,
                              fillColor: dashboardTheme.chartFillColor,
                              guideColor: colorScheme.outlineVariant,
                              pointColor: colorScheme.surface,
                              chartLayout: layout,
                            ),
                          ),
                        ),
                        ...layout.pointOffsets.asMap().entries.map((entry) {
                          final index = entry.key;
                          final offset = entry.value;
                          final label = CurrencyFormatter.format(
                            context,
                            points[index].balance,
                            currencyCode: currencyCode,
                            compact: true,
                            decimalDigits: 0,
                          );

                          return Positioned(
                            left:
                                ((offset.dx - 34).clamp(
                                      0.0,
                                      math.max(0.0, chartWidth - 68),
                                    ))
                                    as double,
                            top: math.max(0.0, offset.dy - 26),
                            width: 68,
                            child: IgnorePointer(
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: _yAxisWidth),
          child: Row(
            children: monthLabels
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
    }.toList()..sort();

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

class _YAxisLabels extends StatelessWidget {
  const _YAxisLabels({
    required this.tickValues,
    required this.chartRect,
    required this.currencyCode,
  });

  final List<double> tickValues;
  final Rect chartRect;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: tickValues.map((value) {
        final top =
            chartRect.top +
            (1 -
                    ((value - tickValues.last) /
                        (tickValues.first - tickValues.last))) *
                chartRect.height;

        return Positioned(
          top: top - 8,
          left: 0,
          right: 10,
          child: Text(
            CurrencyFormatter.format(
              context,
              value,
              currencyCode: currencyCode,
              compact: true,
              decimalDigits: 0,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChartLayout {
  const _ChartLayout({
    required this.chartRect,
    required this.axisMin,
    required this.axisMax,
    required this.tickValues,
    required this.pointOffsets,
  });

  final Rect chartRect;
  final double axisMin;
  final double axisMax;
  final List<double> tickValues;
  final List<Offset> pointOffsets;

  static _ChartLayout compute({
    required List<DashboardBalancePoint> points,
    required Size size,
  }) {
    const chartPadding = EdgeInsets.fromLTRB(10, 12, 10, 18);
    final chartRect = Rect.fromLTWH(
      chartPadding.left,
      chartPadding.top,
      math.max(0.0, size.width - chartPadding.horizontal),
      math.max(0.0, size.height - chartPadding.vertical),
    );

    final rawMin = points.map((point) => point.balance).reduce(math.min);
    final rawMax = points.map((point) => point.balance).reduce(math.max);
    final niceAxis = _NiceAxis.compute(rawMin: rawMin, rawMax: rawMax);

    final pointOffsets = points.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      final dx =
          chartRect.left +
          chartRect.width * (index / math.max(1, points.length - 1));
      final normalizedY = (point.balance - niceAxis.min) / niceAxis.range;
      final dy = chartRect.bottom - (normalizedY * chartRect.height);
      return Offset(dx, dy);
    }).toList();

    final tickValues = <double>[
      for (
        var value = niceAxis.max;
        value >= niceAxis.min - (niceAxis.step / 2);
        value -= niceAxis.step
      )
        value,
    ];

    return _ChartLayout(
      chartRect: chartRect,
      axisMin: niceAxis.min,
      axisMax: niceAxis.max,
      tickValues: tickValues,
      pointOffsets: pointOffsets,
    );
  }
}

class _NiceAxis {
  const _NiceAxis({required this.min, required this.max, required this.step});

  final double min;
  final double max;
  final double step;

  double get range => max - min;

  static _NiceAxis compute({
    required double rawMin,
    required double rawMax,
    int targetTickCount = 4,
  }) {
    final boundedMin = rawMin >= 0 ? 0.0 : rawMin;
    final boundedMax = rawMax <= boundedMin ? boundedMin + 1 : rawMax;
    final roughRange = boundedMax - boundedMin;
    final step = _niceNumber(
      roughRange / math.max(1, targetTickCount - 1),
      true,
    );
    final niceMin = (boundedMin / step).floor() * step;
    final niceMax = (boundedMax / step).ceil() * step;

    return _NiceAxis(
      min: niceMin,
      max: niceMax == niceMin ? niceMin + step : niceMax,
      step: step,
    );
  }

  static double _niceNumber(double range, bool round) {
    if (range <= 0) {
      return 1;
    }

    final exponent = math
        .pow(10, (math.log(range) / math.ln10).floor())
        .toDouble();
    final fraction = range / exponent;
    final niceFraction = switch ((fraction, round)) {
      (< 1.5, true) => 1.0,
      (< 3.0, true) => 2.0,
      (< 7.0, true) => 5.0,
      (_, true) => 10.0,
      (<= 1.0, false) => 1.0,
      (<= 2.0, false) => 2.0,
      (<= 5.0, false) => 5.0,
      (_, false) => 10.0,
    };

    return niceFraction * exponent;
  }
}

class _DashboardChartPainter extends CustomPainter {
  const _DashboardChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.guideColor,
    required this.pointColor,
    required this.chartLayout,
  });

  final List<DashboardBalancePoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color guideColor;
  final Color pointColor;
  final _ChartLayout chartLayout;

  @override
  void paint(Canvas canvas, Size size) {
    final chartRect = chartLayout.chartRect;
    final path = Path();
    final fillPath = Path();
    Offset? firstOffset;
    Offset? lastOffset;

    for (var i = 0; i < chartLayout.pointOffsets.length; i++) {
      final offset = chartLayout.pointOffsets[i];

      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
        fillPath.moveTo(offset.dx, chartRect.bottom);
        fillPath.lineTo(offset.dx, offset.dy);
        firstOffset = offset;
      } else {
        final previousOffset = chartLayout.pointOffsets[i - 1];
        final controlDx = (previousOffset.dx + offset.dx) / 2;

        path.cubicTo(
          controlDx,
          previousOffset.dy,
          controlDx,
          offset.dy,
          offset.dx,
          offset.dy,
        );
        fillPath.cubicTo(
          controlDx,
          previousOffset.dy,
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
    for (final tickValue in chartLayout.tickValues) {
      final normalizedY =
          (tickValue - chartLayout.axisMin) /
          (chartLayout.axisMax - chartLayout.axisMin);
      final dy = chartRect.bottom - (normalizedY * chartRect.height);
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
        colors: <Color>[fillColor, fillColor.withValues(alpha: 0.02)],
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

    for (final offset in chartLayout.pointOffsets) {
      canvas.drawCircle(offset, 5.5, markerOuterPaint);
      canvas.drawCircle(offset, 2.5, markerInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashboardChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.guideColor != guideColor ||
        oldDelegate.pointColor != pointColor ||
        oldDelegate.chartLayout != chartLayout;
  }
}

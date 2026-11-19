import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:doctavia/core/models/model-chart-data.dart';

/// An animated line chart drawn via CustomPainter.
class DoctaviaLineChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final Color? lineColor;
  final String? title;

  const DoctaviaLineChart({super.key, required this.data, this.lineColor, this.title});

  @override
  State<DoctaviaLineChart> createState() => _DoctaviaLineChartState();
}

class _DoctaviaLineChartState extends State<DoctaviaLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.lineColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(widget.title!, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
        AnimatedBuilder(
          animation: _progress,
          builder: (context, _) => CustomPaint(
            size: const Size(double.infinity, 150),
            painter: _LineChartPainter(
              data: widget.data,
              progress: _progress.value,
              color: color,
              labelStyle: theme.textTheme.labelSmall ?? const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double progress;
  final Color color;
  final TextStyle labelStyle;

  _LineChartPainter({required this.data, required this.progress, required this.color, required this.labelStyle});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.map((d) => d.value).reduce(math.max);
    final minVal = data.map((d) => d.value).reduce(math.min);
    final valueRange = (maxVal - minVal) == 0 ? 1.0 : maxVal - minVal;

    final chartHeight = size.height - 24;
    final stepX = size.width / (data.length - 1);

    List<Offset> points = List.generate(data.length, (i) {
      final normVal = (data[i].value - minVal) / valueRange;
      return Offset(i * stepX, chartHeight - normVal * chartHeight);
    });

    // Visible count based on animation progress
    final visibleCount = (points.length * progress).ceil().clamp(2, points.length);
    final visiblePoints = points.sublist(0, visibleCount);

    // Draw gradient fill
    final path = Path()..moveTo(visiblePoints.first.dx, visiblePoints.first.dy);
    for (int i = 1; i < visiblePoints.length; i++) {
      final p0 = visiblePoints[i - 1];
      final p1 = visiblePoints[i];
      final cp1 = Offset((p0.dx + p1.dx) / 2, p0.dy);
      final cp2 = Offset((p0.dx + p1.dx) / 2, p1.dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(visiblePoints.last.dx, chartHeight)
      ..lineTo(visiblePoints.first.dx, chartHeight)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight)),
    );

    // Draw line
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Draw dots + labels
    final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;

    for (int i = 0; i < visiblePoints.length; i++) {
      final p = visiblePoints[i];
      canvas.drawCircle(p, 5, dotPaint);
      canvas.drawCircle(p, 5, dotBorderPaint);

      // X-axis labels
      final tp = TextPainter(
        text: TextSpan(text: data[i].label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.progress != progress;
}

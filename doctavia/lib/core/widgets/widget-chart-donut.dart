import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:doctavia/core/models/model-chart-data.dart';

class DoctaviaDonutChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final String? centreLabel;
  final String? title;

  const DoctaviaDonutChart({super.key, required this.data, this.centreLabel, this.title});

  @override
  State<DoctaviaDonutChart> createState() => _DoctaviaDonutChartState();
}

class _DoctaviaDonutChartState extends State<DoctaviaDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
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
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      Colors.orange,
      Colors.teal,
      Colors.purple,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(widget.title!, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _progress,
              builder: (context, _) => CustomPaint(
                size: const Size(130, 130),
                painter: _DonutPainter(
                  data: widget.data,
                  progress: _progress.value,
                  colors: colors,
                  centreLabel: widget.centreLabel,
                  labelStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.data.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(widget.data[i].label, style: theme.textTheme.bodySmall)),
                        Text('${widget.data[i].value.toInt()}%', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double progress;
  final List<Color> colors;
  final String? centreLabel;
  final TextStyle labelStyle;

  _DonutPainter({required this.data, required this.progress, required this.colors, this.centreLabel, required this.labelStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<double>(0, (s, d) => s + d.value);
    if (total == 0) return;

    final centre = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 22.0;
    final rect = Rect.fromCircle(center: centre, radius: radius - strokeWidth / 2);

    double startAngle = -math.pi / 2;
    for (int i = 0; i < data.length; i++) {
      final sweep = (data[i].value / total) * 2 * math.pi * progress;
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      startAngle += (data[i].value / total) * 2 * math.pi;
    }

    // Centre label
    if (centreLabel != null) {
      final tp = TextPainter(
        text: TextSpan(text: centreLabel, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, centre - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress;
}

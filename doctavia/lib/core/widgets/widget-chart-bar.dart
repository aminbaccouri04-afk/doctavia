import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:doctavia/core/models/model-chart-data.dart';

class DoctaviaBarChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final String? title;

  const DoctaviaBarChart({super.key, required this.data, this.title});

  @override
  State<DoctaviaBarChart> createState() => _DoctaviaBarChartState();
}

class _DoctaviaBarChartState extends State<DoctaviaBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
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
            painter: _BarChartPainter(
              data: widget.data,
              progress: _progress.value,
              primaryColor: theme.colorScheme.primary,
              secondaryColor: theme.colorScheme.primaryContainer,
              labelStyle: theme.textTheme.labelSmall ?? const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final TextStyle labelStyle;

  _BarChartPainter({required this.data, required this.progress, required this.primaryColor, required this.secondaryColor, required this.labelStyle});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.map((d) => d.value).reduce(math.max);
    final barWidth = (size.width / data.length) * 0.55;
    final gap = (size.width / data.length) * 0.45;
    final chartHeight = size.height - 24;

    for (int i = 0; i < data.length; i++) {
      final normVal = maxVal == 0 ? 0 : data[i].value / maxVal;
      final barH = (normVal * chartHeight * progress).toDouble();
      final x = i * (barWidth + gap) + gap / 2;
      final y = chartHeight - barH;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barH),
        const Radius.circular(6),
      );

      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(x, y, barWidth, barH)),
      );

      // Label
      final tp = TextPainter(
        text: TextSpan(text: data[i].label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + barWidth / 2 - tp.width / 2, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.progress != progress;
}

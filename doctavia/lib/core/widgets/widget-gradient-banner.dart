import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';

/// A full-width gradient banner card with a title, subtitle, and icon.
/// Used across vault trends, home doctor dashboard, and analytics screens.
class WidgetGradientBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const WidgetGradientBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gradientColors = colors ?? [scheme.primary, scheme.secondary];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: begin, end: end),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 48),
        ],
      ),
    );
  }
}

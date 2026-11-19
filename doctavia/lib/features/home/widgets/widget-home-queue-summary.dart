import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-secretary.dart';
import 'package:doctavia/core/theme/theme.dart';

class WidgetHomeQueueSummary extends StatelessWidget {
  final SecretaryProvider provider;

  const WidgetHomeQueueSummary({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final waiting = provider.registry.where((a) => a.status == 'confirmed').length;
    final checkedIn = provider.registry.where((a) => a.status == 'checked_in').length;
    final active = provider.registry.where((a) => a.status == 'in_progress').length;

    return Row(
      children: [
        _buildMiniStat('WAITING', '$waiting', AppColors.warning),
        const SizedBox(width: AppSpacing.sm),
        _buildMiniStat('CHECKED-IN', '$checkedIn', AppColors.success),
        const SizedBox(width: AppSpacing.sm),
        _buildMiniStat('ACTIVE', '$active', AppColors.primary),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

/// A color-coded status badge for appointment cards.
class WidgetAppointmentStatusBadge extends StatelessWidget {
  final String status;
  final bool large;

  const WidgetAppointmentStatusBadge(this.status, {super.key, this.large = false});

  static Color colorFor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.destructive;
      case 'checked_in':
        return Colors.teal;
      case 'in_progress':
        return AppColors.primary;
      default:
        return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(large ? 20 : 4),
      ),
      child: Text(
        AppContent.get('common.status.${status.toLowerCase()}').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: large ? 11 : 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

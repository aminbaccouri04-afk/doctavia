import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/theme/theme.dart';

class WidgetHomeActiveSession extends StatelessWidget {
  final dynamic appointment;

  const WidgetHomeActiveSession({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency_outlined, color: AppColors.primaryForeground),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppContent.get('home.activeSession.title'),
                  style: const TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold),
                ),
                Text(
                  AppContent.get('home.activeSession.withLabel').replaceAll('{name}', appointment.patientName),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/doctor/consultation/${appointment.id}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.card,
              foregroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            ),
            child: Text(AppContent.get('home.activeSession.resume')),
          ),
        ],
      ),
    );
  }
}

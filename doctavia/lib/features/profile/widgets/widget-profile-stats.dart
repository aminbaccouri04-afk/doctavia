import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/providers/provider-appointment.dart'; // For AppointmentProvider
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class WidgetProfileStats extends StatelessWidget {
  const WidgetProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final familyProv = context.watch<FamilyProvider>();
    final apptProv = context.watch<AppointmentProvider>();
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              value: familyProv.profiles.length.toString(),
              label: AppContent.get('profile.manager.statProfiles'),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              value: apptProv.myAppointments.length.toString(),
              label: AppContent.get('profile.manager.statAppointments'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

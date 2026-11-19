import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import 'package:doctavia/core/providers/provider-secretary.dart';
import 'package:doctavia/core/theme/theme.dart';

class WidgetRegistryQueueCard extends StatelessWidget {
  final Appointment appt;
  final SecretaryProvider provider;
  final VoidCallback? onSuccess;

  const WidgetRegistryQueueCard({
    super.key,
    required this.appt,
    required this.provider,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCheckIn = appt.status == 'confirmed';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: WidgetCard(
        border: appt.status == 'in_progress' 
          ? Border.all(color: AppColors.primary, width: 2)
          : null, // Will fall back to default WidgetCard border
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    appt.patientName?[0].toUpperCase() ?? 'P',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appt.patientName ?? AppContent.get('common.labels.unknownPatient'),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${AppContent.get('common.labels.withDr')} ${appt.doctorName ?? AppContent.get('common.labels.unknownDoctor')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(appt.status),
              ],
            ),
            const Divider(height: AppSpacing.xl, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      '${AppContent.get('appointments.card.time')}: ${appt.startTimeSnapshot.hour}:${appt.startTimeSnapshot.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (canCheckIn)
                  ElevatedButton(
                    onPressed: () async {
                      final success = await provider.checkInPatient(appt.id);
                      if (success && onSuccess != null) onSuccess!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Text(AppContent.get('registry.card.checkedIn')),
                  )
                else if (appt.status == 'in_progress')
                   Row(
                    children: [
                      const Icon(Icons.medical_services, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(AppContent.get('registry.card.consulting'), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'confirmed': color = AppColors.warning; break;
      case 'checked_in': color = AppColors.success; break;
      case 'in_progress': color = AppColors.primary; break;
      default: color = AppColors.mutedForeground;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

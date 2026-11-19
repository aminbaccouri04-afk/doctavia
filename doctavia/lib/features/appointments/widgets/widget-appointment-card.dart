import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/widget-user-avatar.dart';
import '../../../core/widgets/widget-confirm-dialog.dart';
import '../../../core/widgets/widget-snackbar.dart';
import 'package:doctavia/core/providers/provider-appointment.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import 'package:doctavia/features/appointments/widgets/widget-appointment-review-dialog.dart';
import 'package:doctavia/features/appointments/widgets/widget-appointment-status-badge.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-info-row.dart';

class WidgetAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isHistorical;

  const WidgetAppointmentCard({
    super.key,
    required this.appointment,
    this.isHistorical = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = appointment.status == 'completed';
    final isCancelled = appointment.status == 'cancelled';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                WidgetAppointmentStatusBadge(appointment.status),
                const Spacer(),
                Text(
                  DateFormat.yMMMd().format(appointment.startTimeSnapshot),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              appointment.doctorName ?? AppContent.get('appointments.card.appointmentWith'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (appointment.offeringName != null) ...[
              const SizedBox(height: 2),
              Text(
                appointment.offeringName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat.jm().format(appointment.startTimeSnapshot)} - ${DateFormat.jm().format(appointment.endTimeSnapshot)}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${AppContent.get('appointments.card.profileLabel')}${appointment.patientName ?? appointment.patientProfileId}',
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isCompleted) ...[
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppContent.get('appointments.card.consultationSummaryAvailable'),
                      style: const TextStyle(color: AppColors.success, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showNotes(context),
                    child: Text(AppContent.get('appointments.card.view')),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _showReviewDialog(context),
                    child: Text(
                      AppContent.get('appointments.card.rateReview'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (!isCompleted && !isCancelled) ...[
              const Divider(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _handleCancel(context),
                    child: Text(AppContent.get('appointments.card.reschedule')),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () => _showDetailsSheet(context),
                    child: Text(AppContent.get('appointments.card.details')),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showNotes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppContent.get('appointments.card.summary'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppContent.get('appointments.card.summaryPlaceholder'),
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppContent.get('appointments.card.close')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => WidgetAppointmentReviewDialog(
        appointmentId: appointment.id,
        doctorName: appointment.doctorName ?? AppContent.get('appointments.card.doctorFallback'),
      ),
    );
  }

  void _showDetailsSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mutedForeground.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                WidgetUserAvatar(
                  avatarUrl: appointment.doctorAvatarUrl,
                  radius: 30,
                  fallbackIcon: Icons.medical_services,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName ?? AppContent.get('appointments.card.doctorFallback'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppContent.get('appointments.card.provider'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                WidgetAppointmentStatusBadge(appointment.status, large: true),
              ],
            ),
            const Divider(height: AppSpacing.xxl),
            WidgetInfoRow(
              icon: Icons.calendar_today,
              label: AppContent.get('appointments.card.date'),
              value: DateFormat.yMMMMEEEEd().format(appointment.startTimeSnapshot),
            ),
            WidgetInfoRow(
              icon: Icons.access_time,
              label: AppContent.get('appointments.card.time'),
              value: '${DateFormat.jm().format(appointment.startTimeSnapshot)} - ${DateFormat.jm().format(appointment.endTimeSnapshot)}',
            ),
            WidgetInfoRow(
              icon: Icons.person_outline,
              label: AppContent.get('appointments.card.profileLabel'),
              value: appointment.patientName ?? AppContent.get('appointments.card.self'),
            ),
            if (appointment.offeringName != null)
              WidgetInfoRow(
                icon: Icons.medical_services_outlined,
                label: AppContent.get('appointments.card.serviceLabel'),
                value: appointment.offeringName!,
              ),
            WidgetInfoRow(
              icon: Icons.tag,
              label: AppContent.get('appointments.card.appointmentId'),
              value: '#${appointment.id}',
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppContent.get('appointments.card.backToList')),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context) async {
    final confirmed = await WidgetConfirmDialog.show(
      context,
      title: AppContent.get('appointments.cancel.title'),
      message: AppContent.get('appointments.cancel.message'),
      confirmLabel: AppContent.get('appointments.cancel.confirm'),
      cancelLabel: AppContent.get('appointments.cancel.keep'),
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      final success = await context.read<AppointmentProvider>().cancelAppointment(
        appointment.id,
      );
      if (context.mounted) {
        success
            ? WidgetSnackbar.success(context, AppContent.get('appointments.cancel.success'))
            : WidgetSnackbar.error(context, AppContent.get('appointments.cancel.failed'));
      }
    }
  }
}


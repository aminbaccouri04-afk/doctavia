import 'package:flutter/material.dart';
import 'package:doctavia/core/models/model-medicine-reminder.dart';
import 'package:doctavia/core/providers/provider-reminder.dart';
import 'package:doctavia/core/widgets/widget-confirm-dialog.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

/// A swipe-to-delete reminder card with toggle and time pills.
class WidgetRemindersReminderCard extends StatelessWidget {
  final MedicineReminder reminder;
  final ReminderProvider provider;

  const WidgetRemindersReminderCard({super.key, required this.reminder, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(reminder.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.destructive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.destructive),
      ),
      confirmDismiss: (_) => WidgetConfirmDialog.show(
        context,
        title: AppContent.get('reminders.screen.deleteConfirmTitle'),
        message: AppContent.get('reminders.screen.deleteConfirmMsg').replaceAll('{name}', reminder.medicationName),
        confirmLabel: AppContent.get('common.buttons.delete'),
        isDestructive: true,
      ),
      onDismissed: (_) => provider.deleteReminder(reminder.id),
      child: WidgetCard(
        border: Border.all(
          color: reminder.isActive ? AppColors.primary.withValues(alpha: 0.15) : AppColors.border,
          width: 1,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: reminder.isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.muted,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: reminder.isActive ? AppColors.primary : AppColors.mutedForeground,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.medicationName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: reminder.isActive ? null : AppColors.mutedForeground,
                        ),
                      ),
                      if (reminder.dosage.isNotEmpty)
                        Text(
                          '${reminder.dosage} · ${reminder.frequency}',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
                        ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: reminder.isActive,
                  activeTrackColor: AppColors.primary,
                  onChanged: (_) => provider.toggleReminder(reminder.id),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              children: reminder.times.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: reminder.isActive ? AppColors.primary.withValues(alpha: 0.08) : AppColors.muted,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.alarm, size: 14, color: reminder.isActive ? AppColors.primary : AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(t),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: reminder.isActive ? AppColors.primary : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? AppContent.get('common.labels.am') : AppContent.get('common.labels.pm');
    return '$hour:$minute $period';
  }
}

import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-reminder.dart';
import 'package:doctavia/core/widgets/widget-snackbar.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/models/model-prescription.dart';

/// Bottom sheet that lets users import prescriptions as reminders.
class WidgetRemindersImportSheet extends StatelessWidget {
  final List<PrescriptionModel> prescriptions;
  final ReminderProvider reminderProvider;

  const WidgetRemindersImportSheet({
    super.key,
    required this.prescriptions,
    required this.reminderProvider,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollCtrl) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppContent.get('reminders.screen.import'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppContent.get('reminders.screen.importSub'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  itemCount: prescriptions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final rx = prescriptions[i];
                    return ListTile(
                      leading: const Icon(Icons.medication_outlined, color: AppColors.primary),
                      title: Text(rx.medicationName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${rx.dosage} · ${rx.frequency}'),
                      trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      onTap: () async {
                        final reminder = reminderProvider.importFromPrescription(rx);
                        await reminderProvider.addReminder(reminder);
                        if (context.mounted) {
                          Navigator.pop(context);
                          WidgetSnackbar.success(context, AppContent.get('reminders.screen.reminderCreated').replaceAll('{name}', reminder.medicationName));
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

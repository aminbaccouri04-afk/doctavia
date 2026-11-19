import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import './widgets/widget-appointment-slot-generator.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenAppointmentsSchedule extends StatefulWidget {
  const ScreenAppointmentsSchedule({super.key});

  @override
  State<ScreenAppointmentsSchedule> createState() => _ScreenAppointmentsScheduleState();
}

class _ScreenAppointmentsScheduleState extends State<ScreenAppointmentsSchedule> {
  Future<void> _handleGenerateSlots(
    DateTime date,
    TimeOfDay start,
    TimeOfDay end,
  ) async {
    final provider = context.read<DoctorProvider>();

    // Generate the raw slot layout locally
    final rawSlots = provider.generateDaySlots(date, start, end);

    // Show a confirmation dialog before pushing to DB
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppContent.get('appointments.schedule.confirmTitle')),
        content: Text(
          AppContent.get('appointments.schedule.confirmMsg')
              .replaceAll('{count}', rawSlots.length.toString())
              .replaceAll('{date}', DateFormat.yMd().format(date)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppContent.get('common.buttons.cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppContent.get('common.buttons.confirm')),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await provider.submitAvailability(rawSlots);

      if (mounted && provider.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppContent.get('appointments.schedule.success').replaceAll('{count}', rawSlots.length.toString())),
          ),
        );
      } else if (mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<DoctorProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(AppContent.get('appointments.schedule.title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetAppointmentSlotGenerator(
              onGenerate: _handleGenerateSlots,
              isLoading: provider.isLoading,
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(AppContent.get('appointments.schedule.recent'), style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            if (provider.recentSlots.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Text(
                    AppContent.get('appointments.schedule.noRecent'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
              ),

            if (provider.recentSlots.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.recentSlots.length,
                itemBuilder: (context, index) {
                  final slot = provider.recentSlots[index];
                  final formattedDate = DateFormat.yMMMd().format(
                    slot.startTime,
                  );
                  final timeRange =
                      '${DateFormat.jm().format(slot.startTime)} - ${DateFormat.jm().format(slot.endTime)}';

                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: ListTile(
                      leading: Icon(
                        slot.isBooked ? Icons.lock : Icons.event_available,
                        color: slot.isBooked
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                      title: Text(timeRange, style: theme.textTheme.bodyLarge),
                      subtitle: Text(formattedDate),
                      trailing: slot.isBooked
                          ? Chip(
                              label: Text(
                                AppContent.get('appointments.schedule.booked'),
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: AppColors.destructive.withValues(
                                alpha: 0.1,
                              ),
                              labelStyle: const TextStyle(
                                color: AppColors.destructive,
                                fontSize: 10,
                              ),
                            )
                          : Chip(
                              label: Text(
                                AppContent.get('appointments.schedule.open'),
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: AppColors.success.withValues(
                                alpha: 0.1,
                              ),
                              labelStyle: const TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                              ),
                            ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

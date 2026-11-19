import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-reminder.dart';
import 'package:doctavia/core/providers/provider-clinical.dart';
import 'package:doctavia/core/widgets/widget-empty-state.dart';
import 'package:doctavia/core/widgets/widget-shimmer-loaders.dart';
import 'package:doctavia/core/widgets/widget-snackbar.dart';
import 'package:doctavia/features/reminders/widgets/widget-reminders-reminder-card.dart';
import 'package:doctavia/features/reminders/widgets/widget-reminders-import-sheet.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenRemindersList extends StatefulWidget {
  const ScreenRemindersList({super.key});

  @override
  State<ScreenRemindersList> createState() => _ScreenRemindersListState();
}

class _ScreenRemindersListState extends State<ScreenRemindersList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadReminders();
    });
  }

  void _showImportSheet(BuildContext context) {
    final clinicalProvider = context.read<ClinicalProvider>();
    final reminderProvider = context.read<ReminderProvider>();
    final prescriptions = clinicalProvider.prescriptions;

    if (prescriptions.isEmpty) {
      WidgetSnackbar.show(
        context,
        AppContent.get('reminders.screen.noPrescriptions'),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius2xl),
        ),
      ),
      builder: (_) => WidgetRemindersImportSheet(
        prescriptions: prescriptions,
        reminderProvider: reminderProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('reminders.screen.title')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.download_outlined),
              tooltip: AppContent.get('reminders.screen.import'),
              onPressed: () => _showImportSheet(context),
            ),
          ),
        ],
      ),
      body: provider.isLoading
          ? const ShimmerList(itemCount: 4, child: RecordCardShimmer())
          : provider.reminders.isEmpty
          ? WidgetEmptyState(
              icon: Icons.medication_outlined,
              title: AppContent.get('reminders.screen.emptyTitle'),
              subtitle: AppContent.get('reminders.screen.emptySub'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: provider.reminders.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final reminder = provider.reminders[index];
                return WidgetRemindersReminderCard(
                  reminder: reminder,
                  provider: provider,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/reminders/add'),
        icon: const Icon(Icons.add),
        label: Text(AppContent.get('common.buttons.add')),
      ),
    );
  }
}

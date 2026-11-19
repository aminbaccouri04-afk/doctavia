import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';

class WidgetConsultationPrescriptionsTab extends StatefulWidget {
  final List<Map<String, String>> prescriptions;

  const WidgetConsultationPrescriptionsTab({
    super.key,
    required this.prescriptions,
  });

  @override
  State<WidgetConsultationPrescriptionsTab> createState() =>
      _WidgetConsultationPrescriptionsTabState();
}

class _WidgetConsultationPrescriptionsTabState
    extends State<WidgetConsultationPrescriptionsTab> {
  void _addPrescription() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final name = TextEditingController();
        final dose = TextEditingController();
        final freq = TextEditingController();
        final dur = TextEditingController();
        final inst = TextEditingController();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppContent.get('appointments.consultation.addPrescription'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),
                WidgetDoctaviaInput(
                  controller: name,
                  label: AppContent.get(
                    'appointments.consultation.medicationName',
                  ),
                  hint: 'ex: Paracétamol',
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: WidgetDoctaviaInput(
                        controller: dose,
                        label: AppContent.get(
                          'appointments.consultation.dosage',
                        ),
                        hint: 'ex: 500mg',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: WidgetDoctaviaInput(
                        controller: freq,
                        label: AppContent.get(
                          'appointments.consultation.frequency',
                        ),
                        hint: 'ex: 3x / jour',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                WidgetDoctaviaInput(
                  controller: dur,
                  label: AppContent.get('appointments.consultation.duration'),
                  hint: 'ex: 5 jours',
                ),
                const SizedBox(height: AppSpacing.md),
                WidgetDoctaviaInput(
                  controller: inst,
                  label: AppContent.get(
                    'appointments.consultation.instructions',
                  ),
                  hint: 'ex: Après les repas',
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xl),
                WidgetDoctaviaButton(
                  text: AppContent.get('common.buttons.confirm'),
                  onPressed: () {
                    if (name.text.isEmpty) return;
                    setState(() {
                      widget.prescriptions.add({
                        'medicationName': name.text,
                        'dosage': dose.text,
                        'frequency': freq.text,
                        'duration': dur.text,
                        'instructions': inst.text,
                      });
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppContent.get('appointments.consultation.medications'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton.filled(
                onPressed: _addPrescription,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: widget.prescriptions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 64,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppContent.get(
                            'appointments.consultation.noMedications',
                          ),
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: widget.prescriptions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final p = widget.prescriptions[index];
                      return ListTile(
                        tileColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          p['medicationName']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${p['dosage']} - ${p['frequency']} (${p['duration']})',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.destructive,
                          ),
                          onPressed: () =>
                              setState(() => widget.prescriptions.removeAt(index)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/providers/provider-reminder.dart';
import 'package:doctavia/core/models/model-medicine-reminder.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';

class ScreenRemindersAdd extends StatefulWidget {
  const ScreenRemindersAdd({super.key});

  @override
  State<ScreenRemindersAdd> createState() => _ScreenRemindersAddState();
}

class _ScreenRemindersAddState extends State<ScreenRemindersAdd> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();

  String _frequency = AppContent.get('reminders.freq.once');
  List<TimeOfDay> _times = [TimeOfDay.now()];

  List<String> get _frequencyOptions => [
    AppContent.get('reminders.freq.once'),
    AppContent.get('reminders.freq.twice'),
    AppContent.get('reminders.freq.thrice'),
    AppContent.get('common.labels.custom'),
  ];

  void _onFrequencyChanged(String value) {
    setState(() {
      _frequency = value;
      if (value == AppContent.get('reminders.freq.once')) {
        _times = [TimeOfDay.now()];
      } else if (value == AppContent.get('reminders.freq.twice')) {
        _times = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
      } else if (value == AppContent.get('reminders.freq.thrice')) {
        _times = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
      }
    });
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _times[index] = picked);
    }
  }

  void _addTimeSlot() {
    setState(() {
      _times.add(const TimeOfDay(hour: 12, minute: 0));
    });
  }

  void _removeTimeSlot(int index) {
    if (_times.length <= 1) return;
    setState(() {
      _times.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final reminder = MedicineReminder(
      id: DateTime.now().millisecondsSinceEpoch % 2147483647,
      medicationName: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      frequency: _frequency,
      times: List.from(_times),
    );

    await context.read<ReminderProvider>().addReminder(reminder);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppContent.get(
              'reminders.screen.reminderCreated',
            ).replaceAll('{name}', reminder.medicationName),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppContent.get('reminders.screen.addTitle'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ─── Medication Info Section ──────────────────────────
            _buildSectionHeader(
              theme,
              AppContent.get('reminders.form.medication'),
              Icons.medication_outlined,
            ),
            const SizedBox(height: AppSpacing.sm),
            WidgetDoctaviaInput(
              controller: _nameCtrl,
              label: AppContent.get('reminders.form.medication'),
              hint: AppContent.get('reminders.form.medicationHint'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppContent.get('reminders.form.medicationHint')
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            WidgetDoctaviaInput(
              controller: _dosageCtrl,
              label: AppContent.get('reminders.form.dosage'),
              hint: AppContent.get('reminders.form.dosageHint'),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ─── Frequency Section ─────────────────────────────────
            _buildSectionHeader(
              theme,
              AppContent.get('reminders.form.frequency'),
              Icons.repeat,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _frequencyOptions.map((opt) {
                final isSelected = _frequency == opt;
                return ChoiceChip(
                  label: Text(opt),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.foreground,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (_) => _onFrequencyChanged(opt),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ─── Dose Times Section ────────────────────────────────
            _buildSectionHeader(
              theme,
              AppContent.get('reminders.form.times'),
              Icons.alarm,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppContent.get('reminders.screen.emptySub'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            ...List.generate(_times.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(i),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm + 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                _formatTime(_times[i]),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Spacer(),
                              Flexible(
                                child: Text(
                                  AppContent.get('common.buttons.tapToChange'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_frequency == AppContent.get('reminders.freq.custom') &&
                        _times.length > 1) ...[
                      const SizedBox(width: AppSpacing.xs),
                      IconButton(
                        onPressed: () => _removeTimeSlot(i),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.destructive,
                        ),
                        tooltip: AppContent.get('reminders.screen.removeTime'),
                      ),
                    ],
                  ],
                ),
              );
            }),

            if (_frequency == AppContent.get('reminders.freq.custom'))
              Center(
                child: TextButton.icon(
                  onPressed: _addTimeSlot,
                  icon: const Icon(Icons.add),
                  label: Text(AppContent.get('reminders.form.addTime')),
                ),
              ),

            const SizedBox(height: AppSpacing.xxl),

            // ─── Preview Card ──────────────────────────────────────
            if (_nameCtrl.text.isNotEmpty)
              Card(
                color: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppContent.get('common.labels.preview'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '💊 ${_nameCtrl.text}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_dosageCtrl.text.isNotEmpty)
                        Text(
                          '${_dosageCtrl.text} · $_frequency',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppContent.get('reminders.form.alarms').replaceAll(
                          '{times}',
                          _times.map((t) => _formatTime(t)).join(", "),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.xl),

            WidgetDoctaviaButton(
              text: AppContent.get('reminders.screen.save'),
              onPressed: _save,
            ),

            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am
        ? AppContent.get('common.labels.am')
        : AppContent.get('common.labels.pm');
    return '$hour:$minute $period';
  }
}

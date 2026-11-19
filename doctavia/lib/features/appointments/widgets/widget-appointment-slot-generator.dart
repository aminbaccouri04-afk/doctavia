import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/theme/theme.dart';

class WidgetAppointmentSlotGenerator extends StatefulWidget {
  final Future<void> Function(DateTime date, TimeOfDay start, TimeOfDay end) onGenerate;
  final bool isLoading;

  const WidgetAppointmentSlotGenerator({
    super.key,
    required this.onGenerate,
    this.isLoading = false,
  });

  @override
  State<WidgetAppointmentSlotGenerator> createState() => _SlotGeneratorCardState();
}

class _SlotGeneratorCardState extends State<WidgetAppointmentSlotGenerator> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppContent.get('appointments.slots.openBlocks'), style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            
            // Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
              title: Text(AppContent.get('appointments.card.date')),
              subtitle: Text('${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
              onTap: _pickDate,
            ),
            
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.access_time, color: theme.colorScheme.primary),
                    title: Text(AppContent.get('appointments.slots.start')),
                    subtitle: Text(_formatTime(_startTime)),
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.access_time_filled, color: theme.colorScheme.primary),
                    title: Text(AppContent.get('appointments.slots.end')),
                    subtitle: Text(_formatTime(_endTime)),
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: widget.isLoading 
                ? null 
                : () => widget.onGenerate(_selectedDate, _startTime, _endTime),
              child: widget.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(AppContent.get('appointments.slots.generate')),
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

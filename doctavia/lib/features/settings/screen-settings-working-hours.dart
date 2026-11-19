import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/provider-content.dart';
import '../../core/providers/provider-doctor-schedule.dart';
import '../../core/models/model-working-hour.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widget-doctavia-button.dart';

class ScreenSettingsWorkingHours extends StatefulWidget {
  const ScreenSettingsWorkingHours({super.key});

  @override
  State<ScreenSettingsWorkingHours> createState() => _ScreenSettingsWorkingHoursState();
}

class _ScreenSettingsWorkingHoursState extends State<ScreenSettingsWorkingHours> {
  final List<WorkingHour> _localHours = [];
  bool _isInitialized = false;

  final List<String> _daysFr = [
    'Dimanche',
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final provider = context.read<DoctorScheduleProvider>();
      provider.fetchWorkingHours().then((_) {
        setState(() {
          _localHours.clear();
          // Ensure we have an entry for each day
          for (int i = 0; i < 7; i++) {
            final existing = provider.workingHours.where((wh) => wh.dayOfWeek == i).toList();
            if (existing.isEmpty) {
              _localHours.add(WorkingHour(doctorId: 0, dayOfWeek: i, isClosed: true));
            } else {
              _localHours.addAll(existing);
            }
          }
          _isInitialized = true;
        });
      });
    }
  }

  void _addShift(int dayOfWeek) {
    setState(() {
      _localHours.add(WorkingHour(
        doctorId: 0, 
        dayOfWeek: dayOfWeek, 
        startTime: '09:00', 
        endTime: '17:00',
        isClosed: false
      ));
    });
  }

  void _removeShift(int index) {
    setState(() {
      _localHours.removeAt(index);
    });
  }

  Future<void> _selectTime(int index, bool isStart) async {
    final current = isStart 
        ? _localHours[index].startTime ?? '09:00'
        : _localHours[index].endTime ?? '17:00';
    
    final parts = current.split(':');
    final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isStart) {
          _localHours[index] = _localHours[index].copyWith(startTime: timeStr);
        } else {
          _localHours[index] = _localHours[index].copyWith(endTime: timeStr);
        }
      });
    }
  }

  Future<void> _save() async {
    final success = await context.read<DoctorScheduleProvider>().saveWorkingHours(_localHours);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppContent.get('settings.practice.saveSuccess'))),
      );
    }
  }

  Future<void> _generate() async {
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 30));
    
    final success = await context.read<DoctorScheduleProvider>().generateSlots(
      startDate: now,
      endDate: endDate,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppContent.get('settings.practice.generateSuccess'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DoctorScheduleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('settings.practice.hours')),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: provider.isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 7,
                    itemBuilder: (context, dayIndex) {
                      final dayShifts = _localHours
                          .asMap()
                          .entries
                          .where((e) => e.value.dayOfWeek == dayIndex)
                          .toList();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _daysFr[dayIndex],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                    onPressed: () => _addShift(dayIndex),
                                  ),
                                ],
                              ),
                              if (dayShifts.isEmpty)
                                Text(AppContent.get('settings.practice.closed'), style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                              else
                                ...dayShifts.map((entry) {
                                  final index = entry.key;
                                  final shift = entry.value;

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => _selectTime(index, true),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade300),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(shift.startTime ?? '--:--'),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(AppContent.get('settings.practice.to')),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => _selectTime(index, false),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade300),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(shift.endTime ?? '--:--'),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          onPressed: () => _removeShift(index),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      WidgetDoctaviaButton(
                        text: AppContent.get('settings.practice.saveAction'),
                        onPressed: _save,
                        isLoading: provider.isLoading,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _generate,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        child: Text(AppContent.get('settings.practice.generateAction')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

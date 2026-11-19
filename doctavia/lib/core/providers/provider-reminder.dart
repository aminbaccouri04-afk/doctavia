import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/service-notification.dart';
import '../services/service-reminder.dart';
import 'package:doctavia/core/models/model-medicine-reminder.dart';

import 'package:doctavia/core/models/model-prescription.dart';

/// Manages medicine reminders: server-side persistence with
/// local alarm scheduling via NotificationService.
class ReminderProvider extends ChangeNotifier {
  final ReminderService _service;
  static const _storageKey = 'doctavia_medicine_reminders';

  List<MedicineReminder> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  ReminderProvider(this._service);

  List<MedicineReminder> get reminders => _reminders;
  List<MedicineReminder> get activeReminders => _reminders.where((r) => r.isActive).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all reminders from server.
  Future<void> loadReminders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reminders = await _service.getMyReminders();
      await _persist(); // Cache locally
      // Re-schedule all active alarms to be sure
      for (final r in activeReminders) {
        await _scheduleAlarms(r);
      }
    } catch (e) {
      _errorMessage = 'Failed to sync reminders: $e';
      // Fallback to local cache if offline
      await _loadFromCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        _reminders = MedicineReminder.decodeList(raw);
      }
    } catch (_) {}
  }

  /// Add a new reminder, persist to server, and schedule alarms.
  Future<void> addReminder(MedicineReminder reminder) async {
    // 1. Add locally and schedule alarms immediately
    _reminders.add(reminder);
    await _persist();
    await _scheduleAlarms(reminder);
    notifyListeners();

    // 2. Try to sync with server in background
    try {
      await _service.createReminder(reminder);
    } catch (e) {
      debugPrint('Warning: Failed to sync reminder to server: $e');
      // We don't block the user since it works locally
    }
  }

  /// Toggle a reminder on/off. Syncs with server.
  Future<void> toggleReminder(int id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final updated = _reminders[index].copyWith(isActive: !_reminders[index].isActive);
    
    // 1. Update locally and adjust alarms immediately
    _reminders[index] = updated;
    if (updated.isActive) {
      await _scheduleAlarms(updated);
    } else {
      await _cancelAlarms(updated);
    }
    await _persist();
    notifyListeners();

    // 2. Try to sync with server
    try {
      await _service.updateReminder(updated);
    } catch (e) {
      debugPrint('Warning: Failed to sync toggle to server: $e');
    }
  }

  /// Delete a reminder from server and cancel alarms.
  Future<void> deleteReminder(int id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final reminder = _reminders[index];

    // 1. Delete locally and cancel alarms immediately
    _reminders.removeAt(index);
    await _cancelAlarms(reminder);
    await _persist();
    notifyListeners();

    // 2. Try to sync with server
    try {
      await _service.deleteReminder(id);
    } catch (e) {
      debugPrint('Warning: Failed to sync deletion to server: $e');
    }
  }

  /// Create a reminder pre-filled from a prescription.
  MedicineReminder importFromPrescription(PrescriptionModel prescription) {
    final frequency = prescription.frequency;
    final times = _defaultTimesForFrequency(frequency);

    return MedicineReminder(
      id: DateTime.now().millisecondsSinceEpoch % 2147483647,
      medicationName: prescription.medicationName,
      dosage: prescription.dosage,
      frequency: frequency,
      times: times,
    );
  }

  // ─── Private Helpers ──────────────────────────────────────────

  /// Persist the full reminder list to SharedPreferences.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, MedicineReminder.encodeList(_reminders));
  }

  /// Schedule alarm notifications for each dose time in a reminder.
  /// Alarms fire every 5 minutes in the 15-minute window before the dose time.
  Future<void> _scheduleAlarms(MedicineReminder reminder) async {
    debugPrint('Scheduling alarms for: ${reminder.medicationName} (${reminder.times.length} times)');
    final ns = NotificationService.instance;
    final now = DateTime.now();

    // The offsets in minutes before the dose time (0 = exactly at dose time)
    final offsets = [15, 10, 5, 0];

    for (int i = 0; i < reminder.times.length; i++) {
      final doseTime = reminder.times[i];

      for (int j = 0; j < offsets.length; j++) {
        final offset = offsets[j];
        
        // Calculate the alarm time
        DateTime alarmDt = DateTime(
          now.year, now.month, now.day,
          doseTime.hour, doseTime.minute,
        ).subtract(Duration(minutes: offset));

        // If time already passed today, schedule for tomorrow
        if (alarmDt.isBefore(now)) {
          alarmDt = alarmDt.add(const Duration(days: 1));
        }

        // Unique ID for each sub-alarm
        final notifId = _notificationId(reminder.id, i, j);

        await ns.scheduleReminder(
          id: notifId,
          title: '💊 ${reminder.medicationName}',
          body: offset == 0 
            ? 'C\'est l\'heure de votre prise ! (${reminder.dosage})'
            : 'Prise dans $offset minutes (${_formatTime(doseTime)})',
          scheduledTime: alarmDt,
        );
      }
    }
  }

  /// Cancel all alarms for a reminder.
  Future<void> _cancelAlarms(MedicineReminder reminder) async {
    final ns = NotificationService.instance;
    for (int i = 0; i < reminder.times.length; i++) {
      for (int j = 0; j < 4; j++) {
        await ns.cancelReminder(_notificationId(reminder.id, i, j));
      }
    }
  }

  /// Generate a stable integer ID for a notification.
  int _notificationId(int reminderId, int timeIndex, int subIndex) {
    // subIndex (0-2) ensures unique IDs for the 15, 10, 5 min intervals
    return (reminderId.hashCode + timeIndex * 10 + subIndex).abs() % 2147483647;
  }

  /// Provide sensible default times based on frequency string.
  List<TimeOfDay> _defaultTimesForFrequency(String frequency) {
    final lower = frequency.toLowerCase();
    if (lower.contains('three') || lower.contains('3')) {
      return const [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 14, minute: 0),
        TimeOfDay(hour: 20, minute: 0),
      ];
    } else if (lower.contains('twice') || lower.contains('2')) {
      return const [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 20, minute: 0),
      ];
    } else {
      return const [TimeOfDay(hour: 9, minute: 0)];
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

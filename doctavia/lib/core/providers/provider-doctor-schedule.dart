import 'package:flutter/foundation.dart';
import '../models/model-working-hour.dart';
import '../services/service-doctor-schedule.dart';

class DoctorScheduleProvider with ChangeNotifier {
  final DoctorScheduleService _service;

  List<WorkingHour> _workingHours = [];
  bool _isLoading = false;
  String? _error;

  DoctorScheduleProvider(this._service);

  List<WorkingHour> get workingHours => _workingHours;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWorkingHours() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workingHours = await _service.getWorkingHours();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveWorkingHours(List<WorkingHour> hours) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateWorkingHours(hours);
      _workingHours = hours;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generateSlots({
    required DateTime startDate,
    required DateTime endDate,
    int slotDurationMinutes = 30,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.generateSlots(
        startDate: startDate,
        endDate: endDate,
        slotDurationMinutes: slotDurationMinutes,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import '../api/api-client.dart';
import '../models/model-working-hour.dart';

class DoctorScheduleService {
  final ApiClient _api;

  DoctorScheduleService(this._api);

  Future<List<WorkingHour>> getWorkingHours() async {
    final response = await _api.get('/working-hours');
    final List data = response['data'] ?? [];
    return data.map((json) => WorkingHour.fromJson(json)).toList();
  }

  Future<void> updateWorkingHours(List<WorkingHour> hours) async {
    await _api.put('/working-hours', body: {
      'workingHours': hours.map((h) => h.toJson()).toList()
    });
  }

  Future<void> generateSlots({
    required DateTime startDate,
    required DateTime endDate,
    int slotDurationMinutes = 30,
  }) async {
    await _api.post('/working-hours/generate-slots', body: {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'slotDurationMinutes': slotDurationMinutes,
    });
  }
}

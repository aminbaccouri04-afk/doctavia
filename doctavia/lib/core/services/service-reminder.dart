import '../api/api-client.dart';
import '../models/model-medicine-reminder.dart';

class ReminderService {
  final ApiClient _apiClient;

  ReminderService(this._apiClient);

  Future<List<MedicineReminder>> getMyReminders() async {
    final response = await _apiClient.get('/reminders');
    final List<dynamic> data = response['data']['reminders'];
    return data.map((json) => MedicineReminder.fromJson(json)).toList();
  }

  Future<MedicineReminder> createReminder(MedicineReminder reminder) async {
    final response = await _apiClient.post('/reminders', body: reminder.toJson());
    return MedicineReminder.fromJson(response['data']['reminder']);
  }

  Future<MedicineReminder> updateReminder(MedicineReminder reminder) async {
    final response = await _apiClient.patch('/reminders/${reminder.id}', body: reminder.toJson());
    return MedicineReminder.fromJson(response['data']['reminder']);
  }

  Future<void> deleteReminder(int id) async {
    await _apiClient.delete('/reminders/$id');
  }
}

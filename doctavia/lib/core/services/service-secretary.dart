import '../../../core/api/api-client.dart';
import 'package:doctavia/core/models/model-appointment.dart';

class SecretaryService {
  final ApiClient _api;

  SecretaryService(this._api);

  Future<void> linkToDoctor(String authCode) async {
    await _api.post('/staff/link', body: {'authCode': authCode});
  }

  Future<List<Appointment>> getRegistry() async {
    final response = await _api.get('/staff/registry');
    final List<dynamic> data = response['data']?['appointments'] ?? [];
    return data.map((j) => Appointment.fromJson(j)).toList();
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await _api.get('/analytics');
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> checkInAppointment(int id) async {
    await _api.post('/staff/registry/$id/check-in');
  }
}

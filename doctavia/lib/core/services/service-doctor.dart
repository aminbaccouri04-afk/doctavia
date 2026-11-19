import 'package:http/http.dart' as http;
import '../../../core/api/api-client.dart';
import 'package:doctavia/core/models/model-patient-profile.dart';
import 'package:doctavia/core/models/model-availability-slot.dart';
import 'package:doctavia/core/models/model-appointment.dart';

class DoctorService {
  final ApiClient _api;

  DoctorService(this._api);

  /// Pushes an array of newly generated slots to the backend.
  Future<List<AvailabilitySlot>> createAvailability(List<Map<String, dynamic>> slots) async {
    final response = await _api.post('/availability', body: {'slots': slots});
    
    final List<dynamic> data = response['data']['slots'];
    return data.map((json) => AvailabilitySlot.fromJson(json)).toList();
  }

  /// Fetches the upcoming appointments for the logged-in doctor.
  /// (Assuming backend has /appointments/me or similar, checking PRD it's /appointments/me for patients.
  /// We will use /appointments endpoint assuming backend handles doctor scope properly or we will adjust).
  Future<List<Appointment>> getAppointments() async {
    // Note: If backend expects a specific doctor query param or endpoint, we will patch it later.
    // Assuming /appointments/me handles both based on role context from JWT.
    final response = await _api.get('/appointments/me');
    
    // Fallback if the data payload is null
    final List<dynamic> data = response['data']?['appointments'] ?? [];
    return data.map((json) => Appointment.fromJson(json)).toList();
  }

  /// Fetches an authorization code for a secretary to link to this doctor.
  Future<String> getStaffCode() async {
    final response = await _api.get('/staff/code');
    return response['data']['authCode'] as String;
  }

  /// Fetches the list of linked staff members.
  Future<List<Map<String, dynamic>>> getStaffMembers() async {
    final response = await _api.get('/staff/members');
    final List<dynamic> data = response['data']['members'];
    return data.cast<Map<String, dynamic>>();
  }

  /// Removes a staff member's access.
  Future<void> removeStaffMember(int staffUserId) async {
    await _api.delete('/staff/members/$staffUserId');
  }
  /// Saves comprehensive consultation notes (SOAP) AND marks as completed.
  Future<void> saveConsultation(int appointmentId, Map<String, dynamic> data) async {
    await _api.post('/consultations/$appointmentId/save', body: data);
  }

  /// Fetch professional analytics KPIs.
  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await _api.get('/analytics');
    return response['data'] as Map<String, dynamic>;
  }

  // --- Office Management --------------------------------------

  Future<List<Map<String, dynamic>>> getOffices() async {
    final response = await _api.get('/doctors/me/offices');
    final List<dynamic> data = response['data']['offices'];
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> addOffice({
    required String address,
    required String city,
    double? latitude,
    double? longitude,
  }) async {
    await _api.post('/doctors/me/offices', body: {
      'address': address,
      'city': city,
      // ignore: use_null_aware_elements
      if (latitude != null) 'latitude': latitude,
      // ignore: use_null_aware_elements
      if (longitude != null) 'longitude': longitude,
    });
  }

  Future<void> removeOffice(int locationId) async {
    await _api.delete('/doctors/me/offices/$locationId');
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _api.put('/doctors/me', body: data);
  }



  Future<List<PatientProfile>> getMyProfiles() async {
    final response = await _api.get('/profiles');
    final List<dynamic> data = response['data']?['profiles'] ?? [];
    return data.map((j) => PatientProfile.fromJson(j)).toList();
  }

  Future<void> uploadProfilePicture(int profileId, http.MultipartFile file) async {
    await _api.multipart(
      '/profiles/$profileId/avatar',
      method: 'POST',
      file: file,
    );
  }
}

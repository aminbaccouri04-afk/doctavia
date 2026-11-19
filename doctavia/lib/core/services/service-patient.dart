import 'package:http/http.dart' as http;
import '../../../core/api/api-client.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import 'package:doctavia/core/models/model-doctor.dart';
import 'package:doctavia/core/models/model-patient-profile.dart';
import 'package:doctavia/core/models/model-medical-record.dart';
import 'package:doctavia/core/models/model-prescription.dart';

class PatientService {
  final ApiClient _api;

  PatientService(this._api);

  ApiClient get apiClient => _api;

  // --- Profiles -----------------------------------------------

  Future<List<PatientProfile>> getProfiles() async {
    final response = await _api.get('/profiles');
    final List<dynamic> data = response['data']?['profiles'] ?? [];
    return data.map((j) => PatientProfile.fromJson(j)).toList();
  }

  Future<PatientProfile> createProfile(String fullName, String relationship, String dateOfBirth) async {
    final response = await _api.post('/profiles', body: {
      'fullName': fullName,
      'relationship': relationship,
      'dateOfBirth': dateOfBirth,
    });
    return PatientProfile.fromJson(response['data']['profile']);
  }

  Future<void> updateProfile(int profileId, String fullName, String relationship, String dateOfBirth) async {
    await _api.put('/profiles/$profileId', body: {
      'fullName': fullName,
      'relationship': relationship,
      'dateOfBirth': dateOfBirth,
    });
  }

  Future<void> deleteProfile(int profileId) async {
    await _api.delete('/profiles/$profileId');
  }

  Future<void> uploadProfilePicture(int profileId, http.MultipartFile file) async {
    await _api.multipart(
      '/profiles/$profileId/avatar',
      method: 'POST',
      file: file,
    );
  }

  // --- Medical Records ------------------------------------------

  Future<List<MedicalRecord>> getMedicalRecords(int profileId) async {
    final response = await _api.get('/records/$profileId');
    final List<dynamic> data = response['data']?['records'] ?? [];
    return data.map((j) => MedicalRecord.fromJson(j)).toList();
  }

  Future<void> uploadMedicalRecord(int profileId, http.MultipartFile file) async {
    await _api.multipart(
      '/records/$profileId',
      method: 'POST',
      file: file,
    );
  }

  Future<void> deleteMedicalRecord(int recordId) async {
    await _api.delete('/records/$recordId');
  }

  // --- Discovery ----------------------------------------------

  Future<List<DoctorModel>> searchDoctors({
    String? specialty,
    String? date,
    double? lat,
    double? lng,
    double? radius,
  }) async {
    final Map<String, String> query = {};
    if (specialty != null) query['specialty'] = specialty;
    if (date != null) query['date'] = date;
    if (lat != null) query['lat'] = lat.toString();
    if (lng != null) query['lng'] = lng.toString();
    if (radius != null) query['radius'] = radius.toString();

    final response = await _api.get('/doctors', queryParams: query.isEmpty ? null : query);
    
    final List<dynamic> data = response['data']?['doctors'] ?? [];
    return data.map((j) => DoctorModel.fromJson(j)).toList();
  }

  Future<DoctorModel> getDoctorById(int id) async {
    final response = await _api.get('/doctors/$id');
    return DoctorModel.fromJson(response['data']['doctor']);
  }

  // --- Booking & Appointments ---------------------------------

  Future<Appointment> bookAppointment(int slotId, int patientProfileId, {int? offeringId}) async {
    final response = await _api.post('/appointments', body: {
      'slotId': slotId,
      'patientProfileId': patientProfileId,
      'offeringId': ?offeringId,
    });
    
    return Appointment.fromJson(response['data']['appointment']);
  }

  Future<List<Appointment>> getMyAppointments() async {
    final response = await _api.get('/appointments/me');
    final List<dynamic> data = response['data']?['appointments'] ?? [];
    return data.map((j) => Appointment.fromJson(j)).toList();
  }

  Future<void> cancelAppointment(int appointmentId) async {
    await _api.delete('/appointments/$appointmentId');
  }

  // --- Favorites ----------------------------------------------
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final response = await _api.get('/doctors/favorites');
    final List<dynamic> data = response['data']?['favorites'] ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> toggleFavorite(int doctorId) async {
    await _api.post('/doctors/$doctorId/favorite');
  }

  Future<void> submitReview(int appointmentId, double rating, String comment) async {
    await _api.post('/reviews', body: {
      'appointmentId': appointmentId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<Appointment> getAppointmentDetails(int appointmentId) async {
    final response = await _api.get('/appointments/me'); 
    final List<dynamic> data = response['data']?['appointments'] ?? [];
    final json = data.firstWhere((a) => a['id'] == appointmentId);
    return Appointment.fromJson(json);
  }

  // --- Phase 8: Clinical Management ------------------------------
  Future<List<PrescriptionModel>> getPrescriptions(int profileId) async {
    final response = await _api.get('/consultations/prescriptions/$profileId');
    final List<dynamic> data = response['data']?['prescriptions'] ?? [];
    return data.map((j) => PrescriptionModel.fromJson(j)).toList();
  }

  Future<List<Map<String, dynamic>>> getHealthTrends(int profileId) async {
    final response = await _api.get('/profiles/$profileId/trends');
    final List<dynamic> data = response['data']?['trends'] ?? [];
    return data.cast<Map<String, dynamic>>();
  }
}

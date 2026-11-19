import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/api/api-client.dart';
import 'package:doctavia/core/models/model-patient-profile.dart';
import 'package:doctavia/core/models/model-availability-slot.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import 'package:doctavia/core/services/service-doctor.dart';

class DoctorProvider extends ChangeNotifier {
  final DoctorService _service;

  bool _isLoading = false;
  String? _errorMessage;

  List<Appointment> _appointments = [];
  List<AvailabilitySlot> _recentSlots = [];
  PatientProfile? _myProfile;
  Map<String, dynamic>? _analytics;
  List<Map<String, dynamic>> _staffMembers = [];

  DoctorProvider(this._service);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Appointment> get appointments => _appointments;
  List<AvailabilitySlot> get recentSlots => _recentSlots;
  PatientProfile? get myProfile => _myProfile;
  Map<String, dynamic>? get analytics => _analytics;
  List<Map<String, dynamic>> get staffMembers => _staffMembers;

  /// Returns the first appointment currently with 'in_progress' status
  Appointment? get activeConsultation {
    try {
      return _appointments.firstWhere((a) => a.status == 'in_progress');
    } catch (e) {
      return null;
    }
  }

  /// Helper utility to generate 30-minute interval slots locally before backend push.
  List<Map<String, dynamic>> generateDaySlots(
    DateTime date,
    TimeOfDay start,
    TimeOfDay end,
  ) {
    final List<Map<String, dynamic>> slots = [];

    DateTime current = DateTime(
      date.year,
      date.month,
      date.day,
      start.hour,
      start.minute,
    );
    final DateTime endTime = DateTime(
      date.year,
      date.month,
      date.day,
      end.hour,
      end.minute,
    );

    while (current.isBefore(endTime)) {
      final slotEnd = current.add(const Duration(minutes: 30));
      if (slotEnd.isAfter(endTime)) break; // Don't overflow the end time

      slots.add({
        'startTime': current.toUtc().toIso8601String(),
        'endTime': slotEnd.toUtc().toIso8601String(),
      });

      current = slotEnd;
    }

    return slots;
  }

  /// Pushes the generated slots to the backend to open them up for booking.
  Future<void> submitAvailability(List<Map<String, dynamic>> rawSlots) async {
    if (rawSlots.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedSlots = await _service.createAvailability(rawSlots);
      _recentSlots = [...savedSlots, ..._recentSlots]; // Prepend
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to submit availability.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pulls the doctor's upcoming schedule
  Future<void> fetchSchedule() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await _service.getAppointments();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load schedule.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// One-off fetch for the staff authorization code.
  Future<String?> fetchStaffCode() async {
    _errorMessage = null;
    // We don't set _isLoading here to prevent the whole dashboard from shimmering
    // when just fetching a small piece of data for a dialog.

    try {
      final code = await _service.getStaffCode();
      return code;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Failed to fetch staff code.';
      notifyListeners();
      return null;
    }
  }

  /// Saves consultation notes AND marks the appointment as completed.
  Future<bool> finishConsultation(
    int appointmentId,
    Map<String, dynamic> consultationData,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.saveConsultation(appointmentId, consultationData);
      await fetchSchedule();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to finish consultation.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDoctorProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateProfile(data);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Get primary schedule
      _appointments = await _service.getAppointments();

      // 2. Get profile details
      final profiles = await _service.getMyProfiles();
      _myProfile = profiles.firstWhere(
        (p) => p.relationship.toLowerCase() == 'self',
        orElse: () => profiles.isNotEmpty
            ? profiles.first
            : throw Exception('Identity profile not found'),
      );
    } catch (e) {
      _errorMessage = 'Dashboard load partially failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnalytics() async {
    try {
      _analytics = await _service.getAnalytics();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> uploadProfilePicture(http.MultipartFile file) async {
    if (_myProfile == null) return false;
    _errorMessage = null;

    try {
      await _service.uploadProfilePicture(_myProfile!.id, file);
      // Refresh only the profile data
      final profiles = await _service.getMyProfiles();
      _myProfile = profiles.firstWhere(
        (profile) => profile.relationship.toLowerCase() == 'self',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to upload profile picture.';
      notifyListeners();
      return false;
    }
  }

  // --- Office Management --------------------------------------

  Future<List<Map<String, dynamic>>> fetchOffices() async {
    return await _service.getOffices();
  }

  Future<void> addOffice({
    required String address,
    required String city,
    double? latitude,
    double? longitude,
  }) async {
    await _service.addOffice(
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> removeOffice(int locationId) async {
    await _service.removeOffice(locationId);
  }

  // --- Staff Management --------------------------------------

  Future<void> fetchStaffMembers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _staffMembers = await _service.getStaffMembers();
    } on ApiException catch (e) {
      // If the backend returns 500 because the user simply has no staff association yet,
      // we treat it as an empty list rather than an error state.
      if (e.statusCode == 500 && e.message.contains('PracticeStaff')) {
        _staffMembers = [];
      } else {
        _errorMessage = e.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load staff members.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeStaffMember(int staffUserId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.removeStaffMember(staffUserId);
      _staffMembers.removeWhere((m) => m['id'] == staffUserId);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to remove staff member.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

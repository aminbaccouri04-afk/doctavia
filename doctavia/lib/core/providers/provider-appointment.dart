import 'package:flutter/material.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import 'package:doctavia/core/services/service-patient.dart';
import 'package:doctavia/core/api/api-client.dart';

/// Now renamed/refocused to handle Appointments specifically.
/// Other logic moved to ClinicalProvider, FamilyProvider, and DiscoveryProvider.
class AppointmentProvider extends ChangeNotifier {
  final PatientService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<Appointment> _myAppointments = [];
  Appointment? _currentAppointment;

  AppointmentProvider(this._service);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Appointment> get myAppointments => _myAppointments;
  Appointment? get currentAppointment => _currentAppointment;

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myAppointments = await _service.getMyAppointments();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load appointments.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAppointmentDetails(int appointmentId) async {
    try {
      _currentAppointment = await _service.getAppointmentDetails(appointmentId);
      notifyListeners();
    } catch (e) {
      // Background poll fail
    }
  }

  Future<bool> bookSlot(int slotId, int profileId, {int? offeringId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newAppt = await _service.bookAppointment(slotId, profileId, offeringId: offeringId);
      _myAppointments.insert(0, newAppt);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Booking failed.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.cancelAppointment(appointmentId);
      final index = _myAppointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        final appt = _myAppointments[index];
        _myAppointments[index] = appt.copyWith(status: 'cancelled');
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to cancel appointment.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview(int appointmentId, double rating, String comment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.submitReview(appointmentId, rating, comment);
      await fetchAppointments();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to submit review.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

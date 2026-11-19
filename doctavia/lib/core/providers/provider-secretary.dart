import 'package:flutter/material.dart';
import '../../../core/api/api-client.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import 'package:doctavia/core/services/service-secretary.dart';

class SecretaryProvider extends ChangeNotifier {
  final SecretaryService _service;

  bool _isLoading = false;
  String? _errorMessage;
  final List<Appointment> _registry = [];
  final Map<String, dynamic> _analytics = {};

  SecretaryProvider(this._service);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Appointment> get registry => _registry;
  Map<String, dynamic> get analytics => _analytics;

  Future<bool> linkDoctor(String authCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.linkToDoctor(authCode);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to link with doctor.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRegistry() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getRegistry();
      _registry.clear();
      _registry.addAll(data);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load registry.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getAnalytics();
      _analytics.clear();
      _analytics.addAll(data);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load analytics.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkInPatient(int appointmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.checkInAppointment(appointmentId);
      await fetchRegistry();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Check-in failed.';
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

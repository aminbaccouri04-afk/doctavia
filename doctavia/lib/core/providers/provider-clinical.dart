import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/api-client.dart';
import '../models/model-medical-record.dart';
import '../models/model-prescription.dart';
import '../models/model-health-metric.dart';
import '../services/service-patient.dart';

class ClinicalProvider extends ChangeNotifier {
  final PatientService _service;

  ClinicalProvider(this._service);

  ApiClient get apiClient => _service.apiClient;

  List<MedicalRecord> _medicalRecords = [];
  List<PrescriptionModel> _prescriptions = [];
  List<HealthMetric> _metrics = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MedicalRecord> get medicalRecords => _medicalRecords;
  List<PrescriptionModel> get prescriptions => _prescriptions;
  List<HealthMetric> get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMedicalRecords(int profileId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _medicalRecords = await _service.getMedicalRecords(profileId);
    } catch (_) {
      _errorMessage = 'Failed to load records.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPrescriptions(int profileId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _prescriptions = await _service.getPrescriptions(profileId);
    } catch (_) {
      _errorMessage = 'Failed to load prescriptions.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHealthTrends(int profileId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawTrends = await _service.getHealthTrends(profileId);
      _metrics = rawTrends.asMap().entries.map((entry) {
        final t = entry.value;
        return HealthMetric(
          id: entry.key,
          profileId: profileId,
          type: t['type'] ?? '',
          value: (t['value'] as num).toDouble(),
          unit: t['unit'] ?? '',
          updatedAt: t['date'] != null ? DateTime.parse(t['date'].toString()) : DateTime.now(),
        );
      }).toList();
    } catch (_) {
      _errorMessage = 'Failed to load trends.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadRecord(int profileId, http.MultipartFile file) async {
    try {
      await _service.uploadMedicalRecord(profileId, file);
      await fetchMedicalRecords(profileId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteRecord(int recordId) async {
    try {
      await _service.deleteMedicalRecord(recordId);
      _medicalRecords.removeWhere((r) => r.id == recordId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearError() => _errorMessage = null;
}

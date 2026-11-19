import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/model-patient-profile.dart';
import '../services/service-patient.dart';

class FamilyProvider extends ChangeNotifier {
  final PatientService _service;

  FamilyProvider(this._service);

  List<PatientProfile> _profiles = [];
  int? _selectedProfileId;
  bool _isLoading = false;
  String? _errorMessage;

  List<PatientProfile> get profiles => _profiles;
  int? get selectedProfileId => _selectedProfileId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSelectedProfileId(int? id) {
    _selectedProfileId = id;
    notifyListeners();
  }

  Future<void> fetchProfiles() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profiles = await _service.getProfiles();
    } catch (e) {
      _errorMessage =
          'Une erreur réseau est survenue lors du chargement des profils.';
      debugPrint('fetchProfiles Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProfile(
    String fullName,
    String relationship,
    String dob,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final p = await _service.createProfile(fullName, relationship, dob);
      _profiles.add(p);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create profile.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(
    int id,
    String fullName,
    String relationship,
    String dob,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateProfile(id, fullName, relationship, dob);
      final index = _profiles.indexWhere((p) => p.id == id);
      if (index != -1) {
        _profiles[index] = PatientProfile(
          id: id,
          accountId: _profiles[index].accountId,
          fullName: fullName,
          relationship: relationship,
          dateOfBirth: dob,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProfile(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.deleteProfile(id);
      _profiles.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete profile.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadAvatar(int id, http.MultipartFile file) async {
    try {
      await _service.uploadProfilePicture(id, file);
      await fetchProfiles();
      return true;
    } catch (e) {
      _errorMessage = 'Upload failed.';
      return false;
    }
  }

  void clearError() => _errorMessage = null;
}

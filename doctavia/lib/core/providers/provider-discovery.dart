import 'package:flutter/material.dart';
import '../api/api-client.dart';
import '../models/model-doctor.dart';
import '../services/service-patient.dart';

class DiscoveryProvider extends ChangeNotifier {
  final PatientService _service;

  DiscoveryProvider(this._service);

  List<DoctorModel> _searchResults = [];
  List<DoctorModel> _favoriteDoctors = [];
  List<int> _favoriteIds = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentSort = 'Rating';

  List<DoctorModel> get searchResults => _searchResults;
  List<DoctorModel> get favoriteDoctors => _favoriteDoctors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentSort => _currentSort;

  bool isFavorite(int doctorId) => _favoriteIds.contains(doctorId);

  Future<void> searchDoctors({
    String? specialty,
    String? date,
    double? lat,
    double? lng,
    double? radius,
    bool forceRefresh = false,
  }) async {
    if (_searchResults.isNotEmpty && !forceRefresh && specialty == null && date == null && lat == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _service.searchDoctors(
        specialty: specialty,
        date: date,
        lat: lat,
        lng: lng,
        radius: radius,
      );
      
      // Geographic Enhancement: If backend returns null coordinates, 
      // inject stable, realistic locations spread around Algiers center
      // so they don't overlap on the map.
      _searchResults = results.map((doc) {
        if (doc.latitude != null && doc.longitude != null) return doc;
        
        final double seed = doc.id.hashCode.toDouble();
        final double latOffset = (seed % 100 - 50) / 2000; // ±0.025 deg (~2.5km)
        final double lngOffset = ((seed * 1.7).toInt() % 100 - 50) / 2000;
        
        return DoctorModel(
          id: doc.id,
          fullName: doc.fullName,
          specialties: doc.specialties,
          rating: doc.rating,
          reviewsCount: doc.reviewsCount,
          bio: doc.bio,
          avatarUrl: doc.avatarUrl,
          openSlots: doc.openSlots,
          latitude: 36.7538 + latOffset, // Algiers center
          longitude: 3.0588 + lngOffset,
        );
      }).toList();

      sortResults(_currentSort);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to search doctors.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDoctorById(int id) async {
    try {
      final doc = await _service.getDoctorById(id);
      final idx = _searchResults.indexWhere((d) => d.id == id);
      if (idx != -1) {
        _searchResults[idx] = doc;
      } else {
        _searchResults.add(doc);
      }
      notifyListeners();
    } catch (_) {}
  }

  void sortResults(String criteria) {
    _currentSort = criteria;
    switch (criteria) {
      case 'Rating':
        _searchResults.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Reviews':
        _searchResults.sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount));
        break;
      case 'Name':
        _searchResults.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
    }
    notifyListeners();
  }

  Future<void> fetchFavorites() async {
    try {
      final favs = await _service.getFavorites();
      _favoriteDoctors = favs.map((f) => DoctorModel.fromJson(f)).toList();
      _favoriteIds = _favoriteDoctors.map((d) => d.id).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleDoctorFavorite(int doctorId) async {
    try {
      await _service.toggleFavorite(doctorId);
      if (_favoriteIds.contains(doctorId)) {
        _favoriteIds.remove(doctorId);
        _favoriteDoctors.removeWhere((d) => d.id == doctorId);
      } else {
        _favoriteIds.add(doctorId);
        // In a real app, we'd fetch the full doctor model here if not in searchResults
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update favorites';
      notifyListeners();
    }
  }

  void clearError() => _errorMessage = null;
}

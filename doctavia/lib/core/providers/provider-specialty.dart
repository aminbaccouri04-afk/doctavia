import 'package:flutter/material.dart';
import '../../../core/api/api-client.dart';
import 'package:doctavia/core/models/model-specialty.dart';

class SpecialtyProvider extends ChangeNotifier {
  final ApiClient _api;

  List<Specialty> _specialties = [];
  bool _isLoading = false;
  String? _errorMessage;

  SpecialtyProvider(this._api);

  List<Specialty> get specialties => _specialties;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSpecialties() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get('/lookup/specialties');
      final List<dynamic> data = response['data']?['specialties'] ?? [];
      _specialties = data.map((json) => Specialty.fromJson(json)).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load specialties.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

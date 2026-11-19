import 'package:flutter/material.dart';
import '../../../core/api/api-client.dart';
import '../../../core/services/service-storage.dart';
import 'package:doctavia/core/models/model-user.dart';
import 'package:doctavia/core/services/service-auth.dart';

/// Manages authentication state and exposes it to the widget tree.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storage;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService, this._storage, ApiClient apiClient) {
    apiClient.onUnauthorized = logout;
  }

  // --- Getters --------------------------------------------------
  UserModel? get currentUser  => _currentUser;
  bool get isAuthenticated    => _currentUser != null;
  bool get isLoading          => _isLoading;
  String? get errorMessage    => _errorMessage;
  String? get userRole        => _currentUser?.role;

  // --- Actions --------------------------------------------------

  /// Try to restore a previous session on app start.
  Future<void> tryAutoLogin() async {
    final hasSession = await _authService.hasSession();
    if (hasSession) {
      final role = await _storage.getRole();
      final email = await _storage.getEmail();
      if (role != null) {
        _currentUser = UserModel(id: 0, email: email ?? '', role: role, profiles: []);
        notifyListeners();
      }
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(
        email: email,
        password: password,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Connection failed. Is the server running?';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String dateOfBirth,
    String? authCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signup(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        authCode: authCode,
      );

      // Auto-login after successful signup
      _currentUser = await _authService.login(
        email: email,
        password: password,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Connection failed. Is the server running?';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = 'Connection failed. Is the server running?';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

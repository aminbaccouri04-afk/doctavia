import '../../../core/api/api-client.dart';
import '../../../core/services/service-storage.dart';
import 'package:doctavia/core/models/model-user.dart';

/// Handles signup, login, logout against the Doctavia backend.
class AuthService {
  final ApiClient _api;
  final StorageService _storage;

  AuthService(this._api, this._storage);

  /// Register a new user. Returns the created [UserModel].
  Future<UserModel> signup({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String dateOfBirth,
    String? authCode,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'role': role,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      // ignore: use_null_aware_elements
      if (authCode != null) 'authCode': authCode,
    };

    final res = await _api.post('/auth/signup', body: body);
    return UserModel.fromJson(res['data']['user']);
  }

  /// Authenticate and store JWT. Returns [UserModel] + token.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    final token = res['token'] as String;
    final user = UserModel.fromJson(res['data']['user']);

    await _storage.saveToken(token);
    await _storage.saveRole(user.role);
    await _storage.saveEmail(user.email);

    return user;
  }

  /// Clear stored credentials.
  Future<void> logout() async {
    await _storage.clearAll();
  }

  /// Check if a valid token exists.
  Future<bool> hasSession() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Change the user's password.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _api.post('/auth/change-password', body: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }
}

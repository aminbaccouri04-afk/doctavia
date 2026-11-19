import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/services/service-auth.dart';
import 'package:doctavia/core/services/service-storage.dart';
import 'package:doctavia/core/models/model-user.dart';
import 'package:doctavia/core/api/api-client.dart';

class MockAuthService extends Mock implements AuthService {}
class MockStorageService extends Mock implements StorageService {}
class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthProvider authProvider;
  late MockAuthService mockAuthService;
  late MockStorageService mockStorageService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockAuthService = MockAuthService();
    mockStorageService = MockStorageService();
    mockApiClient = MockApiClient();
    authProvider = AuthProvider(mockAuthService, mockStorageService, mockApiClient);
  });

  group('AuthProvider Tests', () {
    final testUser = UserModel(id: 1, email: 'test@test.com', role: 'patient', profiles: []);

    test('Initial state is unauthenticated', () {
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, isNull);
    });

    test('login success updates current user', () async {
      // Arrange
      when(() => mockAuthService.login(email: 'test@test.com', password: 'password'))
          .thenAnswer((_) async => testUser);

      // Act
      final future = authProvider.login(email: 'test@test.com', password: 'password');
      
      expect(authProvider.isLoading, isTrue);
      
      await future;

      // Assert
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, 'test@test.com');
      expect(authProvider.errorMessage, isNull);
    });

    test('login failure sets errorMessage', () async {
      // Arrange
      when(() => mockAuthService.login(email: 'fail@test.com', password: 'password'))
          .thenThrow(ApiException('Invalid credentials', 401));

      // Act
      await authProvider.login(email: 'fail@test.com', password: 'password');

      // Assert
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, 'Invalid credentials');
    });

    test('tryAutoLogin restores session if available', () async {
      // Arrange
      when(() => mockAuthService.hasSession()).thenAnswer((_) async => true);
      when(() => mockStorageService.getRole()).thenAnswer((_) async => 'doctor');
      when(() => mockStorageService.getEmail()).thenAnswer((_) async => 'doc@doc.com');

      // Act
      await authProvider.tryAutoLogin();

      // Assert
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.userRole, 'doctor');
    });

    test('logout clears user data', () async {
      // Arrange
      when(() => mockAuthService.logout()).thenAnswer((_) async {});
      when(() => mockAuthService.login(email: 'test@test.com', password: 'password'))
          .thenAnswer((_) async => testUser);
          
      await authProvider.login(email: 'test@test.com', password: 'password');
      expect(authProvider.isAuthenticated, isTrue);

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-secretary.dart';
import 'package:doctavia/core/services/service-secretary.dart';

class MockSecretaryService extends Mock implements SecretaryService {}

void main() {
  late SecretaryProvider provider;
  late MockSecretaryService mockService;

  setUp(() {
    mockService = MockSecretaryService();
    provider = SecretaryProvider(mockService);
  });

  group('SecretaryProvider Tests', () {
    test('Initial state is clean', () {
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('fetchAppointments fetches data correctly', () async {
      when(() => mockService.getRegistry()).thenAnswer((_) async => []);

      await provider.fetchRegistry();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });
  });
}

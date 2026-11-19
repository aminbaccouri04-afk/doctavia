import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/services/service-patient.dart';

class MockPatientService extends Mock implements PatientService {}

void main() {
  late FamilyProvider provider;
  late MockPatientService mockService;

  setUp(() {
    mockService = MockPatientService();
    provider = FamilyProvider(mockService);
  });

  group('FamilyProvider Tests', () {
    test('Initial state is clean', () {
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.profiles, isEmpty);
    });

    test('fetchProfiles retrieves data', () async {
      when(() => mockService.getProfiles()).thenAnswer((_) async => []);

      await provider.fetchProfiles();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });
  });
}

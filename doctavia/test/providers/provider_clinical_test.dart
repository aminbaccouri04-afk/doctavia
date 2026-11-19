import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-clinical.dart';
import 'package:doctavia/core/services/service-patient.dart';
import 'package:doctavia/core/api/api-client.dart';

class MockPatientService extends Mock implements PatientService {}

void main() {
  late ClinicalProvider provider;
  late MockPatientService mockService;

  setUp(() {
    mockService = MockPatientService();
    provider = ClinicalProvider(mockService);
  });

  group('ClinicalProvider Tests', () {
    test('Initial state is clean', () {
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('fetchRecords handles failure correctly', () async {
      when(() => mockService.getMedicalRecords(any()))
          .thenThrow(ApiException('Error', 500));

      await provider.fetchMedicalRecords(1);

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, 'Failed to load records.');
    });
  });
}

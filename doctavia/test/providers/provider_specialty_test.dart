import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-specialty.dart';
import 'package:doctavia/core/api/api-client.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late SpecialtyProvider provider;
  late MockApiClient mockClient;

  setUp(() {
    mockClient = MockApiClient();
    provider = SpecialtyProvider(mockClient);
  });

  group('SpecialtyProvider Tests', () {
    test('Initial state is clean', () {
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.specialties, isEmpty);
    });

    test('fetchSpecialties handles errors', () async {
      when(() => mockClient.get('/lookup/specialties')).thenThrow(ApiException('Error', 500));

      await provider.fetchSpecialties();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, 'Error');
    });
  });
}

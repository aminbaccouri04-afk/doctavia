import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-discovery.dart';
import 'package:doctavia/core/services/service-patient.dart';
import 'package:doctavia/core/models/model-doctor.dart';

class MockPatientService extends Mock implements PatientService {}

void main() {
  late DiscoveryProvider provider;
  late MockPatientService mockService;

  setUp(() {
    mockService = MockPatientService();
    provider = DiscoveryProvider(mockService);
  });

  group('DiscoveryProvider Tests', () {
    test('Initial state is clean', () {
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.searchResults, isEmpty);
    });

    test('searchDoctors fetches and sorts correctly', () async {
      final docA = DoctorModel(id: 1, fullName: 'Dr. A', specialties: [], rating: 4.0, reviewsCount: 10);
      final docB = DoctorModel(id: 2, fullName: 'Dr. B', specialties: [], rating: 5.0, reviewsCount: 5);

      when(() => mockService.searchDoctors(specialty: any(named: 'specialty')))
          .thenAnswer((_) async => [docA, docB]);

      await provider.searchDoctors(specialty: 'Cardiology');

      expect(provider.searchResults.length, 2);
      expect(provider.searchResults.first.id, 2); // Default sort is Rating
    });

    test('toggleDoctorFavorite updates local state', () async {
      when(() => mockService.toggleFavorite(any())).thenAnswer((_) async {});
      when(() => mockService.getFavorites()).thenAnswer((_) async => []);

      await provider.toggleDoctorFavorite(101);
      expect(provider.isFavorite(101), isTrue);

      await provider.toggleDoctorFavorite(101);
      expect(provider.isFavorite(101), isFalse);
    });

    test('injects coordinates if missing', () async {
      final doc = DoctorModel(id: 1, fullName: 'Dr. A', specialties: [], rating: 4.0, reviewsCount: 10);
      when(() => mockService.searchDoctors(specialty: any(named: 'specialty')))
          .thenAnswer((_) async => [doc]);

      await provider.searchDoctors(specialty: 'Cardiology');
      
      expect(provider.searchResults.first.latitude, isNotNull);
      expect(provider.searchResults.first.longitude, isNotNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import 'package:doctavia/core/services/service-doctor.dart';

class MockDoctorService extends Mock implements DoctorService {}

void main() {
  late DoctorProvider provider;
  late MockDoctorService mockService;

  setUp(() {
    mockService = MockDoctorService();
    provider = DoctorProvider(mockService);
  });

  group('DoctorProvider Tests', () {
    test('submitAvailability should update recentSlots', () async {
      final mockSlots = [{'startTime': '2026-01-01T09:00:00Z', 'endTime': '2026-01-01T09:30:00Z'}];
      when(() => mockService.createAvailability(any())).thenAnswer((_) async => []);

      await provider.submitAvailability(mockSlots);

      expect(provider.isLoading, isFalse);
      verify(() => mockService.createAvailability(mockSlots)).called(1);
    });

    test('fetchStaffCode should return the code', () async {
      const mockCode = 'ABC-123';
      when(() => mockService.getStaffCode()).thenAnswer((_) async => mockCode);

      final code = await provider.fetchStaffCode();

      expect(code, mockCode);
    });

    test('updateDoctorProfile should call service', () async {
      final mockData = {'experienceYears': 10};
      when(() => mockService.updateProfile(any())).thenAnswer((_) async => {});

      final success = await provider.updateDoctorProfile(mockData);

      expect(success, isTrue);
      verify(() => mockService.updateProfile(mockData)).called(1);
    });

    test('fetchOffices should return office list', () async {
      final mockOffices = [{'id': '1', 'city': 'Paris'}];
      when(() => mockService.getOffices()).thenAnswer((_) async => mockOffices);

      final result = await provider.fetchOffices();

      expect(result, mockOffices);
    });

    test('removeStaffMember should update local list', () async {
      provider.staffMembers.add({'id': 1, 'name': 'John'});
      when(() => mockService.removeStaffMember(any())).thenAnswer((_) async => {});

      final success = await provider.removeStaffMember(1);

      expect(success, isTrue);
      expect(provider.staffMembers, isEmpty);
    });
  });
}

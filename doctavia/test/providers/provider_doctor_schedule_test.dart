import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-doctor-schedule.dart';
import 'package:doctavia/core/services/service-doctor-schedule.dart';
import 'package:doctavia/core/models/model-working-hour.dart';

class MockDoctorScheduleService extends Mock implements DoctorScheduleService {}

void main() {
  late DoctorScheduleProvider provider;
  late MockDoctorScheduleService mockService;

  setUp(() {
    mockService = MockDoctorScheduleService();
    provider = DoctorScheduleProvider(mockService);
  });

  group('DoctorScheduleProvider Tests', () {
    test('Initial state should be correct', () {
      expect(provider.workingHours, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('fetchWorkingHours should update workingHours and loading state', () async {
      final List<WorkingHour> mockHours = [
        WorkingHour(id: 1, doctorId: 101, dayOfWeek: 1, startTime: '09:00', endTime: '17:00'),
      ];
      when(() => mockService.getWorkingHours()).thenAnswer((_) async => mockHours);

      final future = provider.fetchWorkingHours();
      expect(provider.isLoading, isTrue);
      
      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.workingHours, mockHours);
      expect(provider.error, isNull);
    });

    test('saveWorkingHours should return true on success', () async {
      final List<WorkingHour> mockHours = [
        WorkingHour(id: 1, doctorId: 101, dayOfWeek: 1, startTime: '10:00', endTime: '18:00'),
      ];
      when(() => mockService.updateWorkingHours(any())).thenAnswer((_) async => {});

      final success = await provider.saveWorkingHours(mockHours);

      expect(success, isTrue);
      expect(provider.workingHours, mockHours);
      expect(provider.isLoading, isFalse);
    });

    test('generateSlots should return true on success', () async {
      final startDate = DateTime.now();
      final endDate = startDate.add(const Duration(days: 7));
      
      when(() => mockService.generateSlots(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        slotDurationMinutes: any(named: 'slotDurationMinutes'),
      )).thenAnswer((_) async => {});

      final success = await provider.generateSlots(
        startDate: startDate,
        endDate: endDate,
      );

      expect(success, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('should handle errors in fetchWorkingHours', () async {
      when(() => mockService.getWorkingHours()).thenThrow(Exception('Network Error'));

      await provider.fetchWorkingHours();

      expect(provider.isLoading, isFalse);
      expect(provider.error, contains('Network Error'));
    });
  });
}

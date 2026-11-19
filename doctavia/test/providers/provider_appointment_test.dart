import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-appointment.dart';
import 'package:doctavia/core/services/service-patient.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import 'package:doctavia/core/api/api-client.dart';

class MockPatientService extends Mock implements PatientService {}

void main() {
  late AppointmentProvider provider;
  late MockPatientService mockService;

  setUp(() {
    mockService = MockPatientService();
    provider = AppointmentProvider(mockService);
  });

  group('AppointmentProvider Tests', () {
    final testAppt = Appointment(
      id: 1,
      slotId: 10,
      status: 'confirmed',
      startTimeSnapshot: DateTime.now().add(const Duration(days: 1)),
      endTimeSnapshot: DateTime.now().add(const Duration(days: 1, hours: 1)),
      patientProfileId: 100,
      patientName: 'John Doe',
      doctorId: 50,
      doctorName: 'Dr. Smith',
    );

    test('Initial state is empty', () {
      expect(provider.myAppointments, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('fetchAppointments populates list on success', () async {
      when(() => mockService.getMyAppointments()).thenAnswer((_) async => [testAppt]);

      final future = provider.fetchAppointments();
      expect(provider.isLoading, isTrue);
      
      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.myAppointments.length, 1);
      expect(provider.myAppointments.first.id, 1);
    });

    test('fetchAppointments sets error on API exception', () async {
      when(() => mockService.getMyAppointments()).thenThrow(ApiException('Server error', 500));

      await provider.fetchAppointments();

      expect(provider.isLoading, isFalse);
      expect(provider.myAppointments, isEmpty);
      expect(provider.errorMessage, 'Server error');
    });

    test('bookSlot inserts new appointment on success', () async {
      when(() => mockService.bookAppointment(10, 100, offeringId: 500)).thenAnswer((_) async => testAppt);

      final success = await provider.bookSlot(10, 100, offeringId: 500);

      expect(success, isTrue);
      expect(provider.myAppointments.length, 1);
      expect(provider.myAppointments.first.id, 1);
    });

    test('cancelAppointment updates status to cancelled', () async {
      // First populate it
      when(() => mockService.getMyAppointments()).thenAnswer((_) async => [testAppt]);
      await provider.fetchAppointments();
      
      // Now cancel
      when(() => mockService.cancelAppointment(1)).thenAnswer((_) async {});

      final success = await provider.cancelAppointment(1);

      expect(success, isTrue);
      expect(provider.myAppointments.first.status, 'cancelled');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctavia/core/providers/provider-reminder.dart';
import 'package:doctavia/core/services/service-reminder.dart';

class MockReminderService extends Mock implements ReminderService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late ReminderProvider provider;
  late MockReminderService mockService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockService = MockReminderService();
    when(() => mockService.getMyReminders()).thenAnswer((_) async => []);
    provider = ReminderProvider(mockService);
  });

  group('ReminderProvider Tests', () {
    test('Initial state is clean', () {
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('loadReminders fetches correctly', () async {
      await provider.loadReminders();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });
  });
}

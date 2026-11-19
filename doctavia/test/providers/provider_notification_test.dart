import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-notification.dart';
import 'package:doctavia/core/api/api-client.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late NotificationProvider provider;
  late MockApiClient mockClient;

  setUp(() {
    mockClient = MockApiClient();
    provider = NotificationProvider(mockClient);
  });

  group('NotificationProvider Tests', () {
    test('Initial state is clean', () {
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.notifications, isEmpty);
    });

    test('fetchNotifications handles server error', () async {
      when(() => mockClient.get('/notifications')).thenThrow(ApiException('Error', 500));

      await provider.fetchNotifications();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, 'Error');
    });
  });
}

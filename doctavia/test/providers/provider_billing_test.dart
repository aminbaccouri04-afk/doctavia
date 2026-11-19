import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-billing.dart';
import 'package:doctavia/core/services/service-billing.dart';
import 'package:doctavia/core/api/api-client.dart';

class MockBillingService extends Mock implements BillingService {}

void main() {
  late BillingProvider provider;
  late MockBillingService mockService;

  setUp(() {
    mockService = MockBillingService();
    provider = BillingProvider(mockService);
  });

  group('BillingProvider Tests', () {
    test('Initial state is clean', () {
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.invoices, isEmpty);
    });

    test('fetchInvoices updates state correctly', () async {
      when(() => mockService.getMyInvoices()).thenAnswer((_) async => []);

      final future = provider.fetchInvoices();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('payInvoice handles failure correctly', () async {
      when(() => mockService.payInvoice(123))
          .thenThrow(ApiException('Payment failed', 400));

      final success = await provider.payInvoice(123);

      expect(success, isFalse);
      expect(provider.errorMessage, 'Payment failed');
      expect(provider.isLoading, isFalse);
    });
  });
}

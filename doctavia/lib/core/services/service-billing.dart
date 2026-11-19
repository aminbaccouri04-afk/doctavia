import '../../../core/api/api-client.dart';
import 'package:doctavia/core/models/model-invoice.dart';

class BillingService {
  final ApiClient _api;

  BillingService(this._api);

  /// Fetch all invoices for the current user.
  Future<List<InvoiceModel>> getMyInvoices() async {
    final response = await _api.get('/billing/invoices');
    final List<dynamic> data = response['data']?['invoices'] ?? [];
    return data.map((j) => InvoiceModel.fromJson(j)).toList();
  }

  /// Fetch a single invoice by ID.
  Future<InvoiceModel> getInvoiceById(int id) async {
    final response = await _api.get('/billing/invoices/$id');
    return InvoiceModel.fromJson(response['data']['invoice']);
  }

  /// Pay a pending invoice.
  Future<InvoiceModel> payInvoice(int id) async {
    final response = await _api.post('/billing/invoices/$id/pay');
    return InvoiceModel.fromJson(response['data']['invoice']);
  }

  /// [Doctor Only] Fetch revenue statistics.
  Future<Map<String, dynamic>> getRevenueStats() async {
    final response = await _api.get('/doctors/me/revenue');
    return response['data'] as Map<String, dynamic>;
  }
}

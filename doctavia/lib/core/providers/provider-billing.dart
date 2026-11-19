import 'package:flutter/material.dart';
import '../api/api-client.dart';
import '../models/model-invoice.dart';
import '../services/service-billing.dart';

class BillingProvider extends ChangeNotifier {
  final BillingService _service;

  BillingProvider(this._service);

  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _revenueStats;

  List<InvoiceModel> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get revenueStats => _revenueStats;

  double get totalPendingAmount {
    return _invoices
        .where((i) => i.isPending)
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  Future<void> fetchInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _invoices = await _service.getMyInvoices();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load invoices.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payInvoice(int invoiceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.payInvoice(invoiceId);
      await fetchInvoices();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Payment failed.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRevenueStats() async {
    try {
      _revenueStats = await _service.getRevenueStats();
      notifyListeners();
    } catch (_) {}
  }

  void clearError() => _errorMessage = null;
}

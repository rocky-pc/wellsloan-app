import 'package:flutter/material.dart';
import '../data/models/payment_model.dart';
import '../data/repositories/payment_repository.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentRepository _repo = PaymentRepository();

  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  List<PaymentModel> get upcomingPayments =>
      _payments.where((p) => p.status == 'pending' || p.status == 'overdue').toList();

  List<PaymentModel> get paidPayments =>
      _payments.where((p) => p.status == 'paid').toList();

  double get totalOutstanding =>
      upcomingPayments.fold(0.0, (sum, p) => sum + p.amount);

  double get totalPaid =>
      paidPayments.fold(0.0, (sum, p) => sum + p.amount);

  Future<void> fetchPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _payments = await _repo.getPayments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payPayment(String paymentId, {String method = "UPI"}) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repo.payPayment(paymentId, method: method);
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}

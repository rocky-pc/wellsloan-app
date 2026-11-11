import 'package:flutter/material.dart';
import '../data/models/dashboard_summary_model.dart';
import '../data/models/loan_model.dart';
import '../data/models/payment_model.dart';
import '../data/repositories/loan_repository.dart';
import '../data/repositories/payment_repository.dart';

class DashboardProvider with ChangeNotifier {
  final LoanRepository _loanRepo = LoanRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();

  DashboardSummaryModel? _summary;
  List<LoanModel> _activeLoans = [];
  List<PaymentModel> _upcomingPayments = [];
  bool _isLoading = false;
  String? _errorMessage;

  DashboardSummaryModel? get summary => _summary;
  List<LoanModel> get activeLoans => _activeLoans;
  List<PaymentModel> get upcomingPayments => _upcomingPayments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final summaryFuture = _loanRepo.getDashboardSummary();
      final loansFuture = _loanRepo.getLoans();
      final paymentsFuture = _paymentRepo.getPayments();

      final results = await Future.wait([summaryFuture, loansFuture, paymentsFuture]);

      _summary = results[0] as DashboardSummaryModel;
      final allLoans = results[1] as List<LoanModel>;
      _activeLoans = allLoans.where((l) => l.status != 'closed').toList();

      final allPayments = results[2] as List<PaymentModel>;
      _upcomingPayments = allPayments
          .where((p) => p.status == 'pending' || p.status == 'overdue')
          .take(3)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchDashboardData();
  }
}

import 'package:flutter/material.dart';
import '../data/models/eligibility_model.dart';
import '../data/models/loan_application_model.dart';
import '../data/models/loan_model.dart';
import '../data/repositories/loan_repository.dart';

class LoanProvider with ChangeNotifier {
  final LoanRepository _repo = LoanRepository();

  List<LoanModel> _loans = [];
  List<LoanApplicationModel> _applications = [];
  EligibilityResultModel? _eligibilityResult;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<LoanModel> get loans => _loans;
  List<LoanApplicationModel> get applications => _applications;
  EligibilityResultModel? get eligibilityResult => _eligibilityResult;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLoans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loans = await _repo.getLoans();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _applications = await _repo.getApplications();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LoanApplicationModel?> submitApplication({
    required String loanType,
    required double amount,
    required int tenureMonths,
    required String purpose,
    required String employmentType,
    required double monthlyIncome,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final app = await _repo.applyLoan(
        loanType: loanType,
        amount: amount,
        tenureMonths: tenureMonths,
        purpose: purpose,
        employmentType: employmentType,
        monthlyIncome: monthlyIncome,
      );
      _applications.insert(0, app);
      return app;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<EligibilityResultModel?> checkEligibility({
    required double monthlyIncome,
    required String employmentType,
    double? existingEmi,
    String? loanType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _eligibilityResult = await _repo.checkEligibility(
        monthlyIncome: monthlyIncome,
        employmentType: employmentType,
        existingEmi: existingEmi,
        loanType: loanType,
      );
      return _eligibilityResult;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

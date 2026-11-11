import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/dashboard_summary_model.dart';
import '../models/eligibility_model.dart';
import '../models/loan_application_model.dart';
import '../models/loan_model.dart';

class LoanRepository {
  final ApiClient _client;

  LoanRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<DashboardSummaryModel> getDashboardSummary() async {
    final response = await _client.get(ApiEndpoints.dashboardSummary);
    return DashboardSummaryModel.fromJson(response.data);
  }

  Future<List<LoanModel>> getLoans() async {
    final response = await _client.get(ApiEndpoints.loans);
    final list = response.data['loans'] as List? ?? [];
    return list.map((item) => LoanModel.fromJson(item)).toList();
  }

  Future<LoanModel> getLoanDetails(String loanId) async {
    final response = await _client.get('${ApiEndpoints.loans}/$loanId');
    return LoanModel.fromJson(response.data['loan']);
  }

  Future<List<LoanApplicationModel>> getApplications() async {
    final response = await _client.get(ApiEndpoints.applications);
    final list = response.data['applications'] as List? ?? [];
    return list.map((item) => LoanApplicationModel.fromJson(item)).toList();
  }

  Future<LoanApplicationModel> applyLoan({
    required String loanType,
    required double amount,
    required int tenureMonths,
    required String purpose,
    required String employmentType,
    required double monthlyIncome,
  }) async {
    final response = await _client.post(
      ApiEndpoints.applications,
      data: {
        'loanType': loanType,
        'amount': amount,
        'tenureMonths': tenureMonths,
        'purpose': purpose,
        'employmentType': employmentType,
        'monthlyIncome': monthlyIncome,
      },
    );
    return LoanApplicationModel.fromJson(response.data['application']);
  }

  Future<EligibilityResultModel> checkEligibility({
    required double monthlyIncome,
    required String employmentType,
    double? existingEmi,
    String? loanType,
  }) async {
    final response = await _client.post(
      ApiEndpoints.eligibilityCheck,
      data: {
        'monthlyIncome': monthlyIncome,
        'employmentType': employmentType,
        if (existingEmi != null) 'existingEmi': existingEmi,
        if (loanType != null) 'loanType': loanType,
      },
    );
    return EligibilityResultModel.fromJson(response.data);
  }
}

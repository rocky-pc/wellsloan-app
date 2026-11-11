class NextPaymentDueModel {
  final double amount;
  final String dueDate;

  NextPaymentDueModel({
    required this.amount,
    required this.dueDate,
  });

  factory NextPaymentDueModel.fromJson(Map<String, dynamic> json) {
    return NextPaymentDueModel(
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: json['dueDate'] ?? json['due_date'] ?? '',
    );
  }
}

class DashboardSummaryModel {
  final double totalLoanAmount;
  final double outstandingBalance;
  final NextPaymentDueModel nextPaymentDue;
  final int loansCount;
  final int activeLoansCount;
  final int pendingApplicationsCount;

  DashboardSummaryModel({
    required this.totalLoanAmount,
    required this.outstandingBalance,
    required this.nextPaymentDue,
    this.loansCount = 0,
    this.activeLoansCount = 0,
    this.pendingApplicationsCount = 0,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? json;
    return DashboardSummaryModel(
      totalLoanAmount: (summary['totalLoanAmount'] ?? summary['total_loan_amount'] ?? 0).toDouble(),
      outstandingBalance: (summary['outstandingBalance'] ?? summary['outstanding_balance'] ?? 0).toDouble(),
      nextPaymentDue: NextPaymentDueModel.fromJson(
        summary['nextPaymentDue'] ?? summary['next_payment_due'] ?? {},
      ),
      loansCount: json['loansCount'] ?? 0,
      activeLoansCount: json['activeLoansCount'] ?? 0,
      pendingApplicationsCount: json['pendingApplicationsCount'] ?? 0,
    );
  }
}

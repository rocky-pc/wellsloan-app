class EligibilityResultModel {
  final bool eligible;
  final double maxLoanAmount;
  final double interestRate;
  final double foir; // Fixed Obligation to Income Ratio
  final String reason;

  EligibilityResultModel({
    required this.eligible,
    required this.maxLoanAmount,
    required this.interestRate,
    required this.foir,
    required this.reason,
  });

  factory EligibilityResultModel.fromJson(Map<String, dynamic> json) {
    return EligibilityResultModel(
      eligible: json['eligible'] ?? true,
      maxLoanAmount: (json['maxLoanAmount'] ?? json['max_loan_amount'] ?? 200000).toDouble(),
      interestRate: (json['interestRate'] ?? json['interest_rate'] ?? 12.5).toDouble(),
      foir: (json['foir'] ?? 0.35).toDouble(),
      reason: json['reason'] ?? 'Pre-approved based on current income profile.',
    );
  }
}

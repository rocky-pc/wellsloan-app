class LoanApplicationModel {
  final String id;
  final String? userId;
  final String loanType;
  final double amount;
  final int tenureMonths;
  final String? purpose;
  final String? employmentType;
  final double? monthlyIncome;
  final String status; // pending, approved, rejected, under_review
  final String? appliedAt;
  final String? adminNote;

  LoanApplicationModel({
    required this.id,
    this.userId,
    required this.loanType,
    required this.amount,
    required this.tenureMonths,
    this.purpose,
    this.employmentType,
    this.monthlyIncome,
    required this.status,
    this.appliedAt,
    this.adminNote,
  });

  factory LoanApplicationModel.fromJson(Map<String, dynamic> json) {
    return LoanApplicationModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      loanType: json['loanType'] ?? json['loan_type'] ?? 'Personal Loan',
      amount: (json['amount'] ?? 0).toDouble(),
      tenureMonths: (json['tenureMonths'] ?? json['tenure_months'] ?? 12).toInt(),
      purpose: json['purpose'],
      employmentType: json['employmentType'] ?? json['employment_type'],
      monthlyIncome: json['monthlyIncome'] != null ? (json['monthlyIncome'] as num).toDouble() : null,
      status: json['status'] ?? 'pending',
      appliedAt: json['appliedAt'] ?? json['applied_at'] ?? json['created_at'],
      adminNote: json['adminNote'] ?? json['admin_note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loan_type': loanType,
      'amount': amount,
      'tenure_months': tenureMonths,
      'purpose': purpose,
      'employment_type': employmentType,
      'monthly_income': monthlyIncome,
    };
  }
}

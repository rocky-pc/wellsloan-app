class LoanModel {
  final String id;
  final String productName;
  final double principalAmount;
  final double outstandingBalance;
  final double interestRate;
  final String status; // active, pending, approved, overdue, closed
  final double nextPaymentAmount;
  final String? nextPaymentDueDate;
  final int tenureMonths;
  final String? appliedOn;

  LoanModel({
    required this.id,
    required this.productName,
    required this.principalAmount,
    required this.outstandingBalance,
    required this.interestRate,
    required this.status,
    required this.nextPaymentAmount,
    this.nextPaymentDueDate,
    required this.tenureMonths,
    this.appliedOn,
  });

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isOverdue => status == 'overdue';
  bool get isClosed => status == 'closed';

  double get paidAmount => principalAmount > outstandingBalance ? principalAmount - outstandingBalance : 0.0;
  double get progressRatio => principalAmount > 0 ? (paidAmount / principalAmount).clamp(0.0, 1.0) : 0.0;

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id']?.toString() ?? '',
      productName: json['productName'] ?? json['product_name'] ?? 'Personal Loan',
      principalAmount: (json['principalAmount'] ?? json['principal_amount'] ?? 0).toDouble(),
      outstandingBalance: (json['outstandingBalance'] ?? json['outstanding_balance'] ?? 0).toDouble(),
      interestRate: (json['interestRate'] ?? json['interest_rate'] ?? 12.5).toDouble(),
      status: json['status'] ?? 'pending',
      nextPaymentAmount: (json['nextPaymentAmount'] ?? json['next_payment_amount'] ?? 0).toDouble(),
      nextPaymentDueDate: json['nextPaymentDueDate'] ?? json['next_payment_due_date'],
      tenureMonths: (json['tenureMonths'] ?? json['tenure_months'] ?? 12).toInt(),
      appliedOn: json['appliedOn'] ?? json['applied_on'],
    );
  }
}

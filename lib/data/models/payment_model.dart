class PaymentModel {
  final String id;
  final String loanId;
  final String loanName;
  final double amount;
  final String dueDate;
  final String? paidDate;
  final String status; // paid, pending, overdue, failed
  final String? method;
  final String? transactionId;

  PaymentModel({
    required this.id,
    required this.loanId,
    required this.loanName,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.method,
    this.transactionId,
  });

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      loanId: json['loanId']?.toString() ?? json['loan_id']?.toString() ?? '',
      loanName: json['loanName'] ?? json['loan_name'] ?? 'EMI Repayment',
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: json['dueDate'] ?? json['due_date'] ?? '',
      paidDate: json['paidDate'] ?? json['paid_date'],
      status: json['status'] ?? 'pending',
      method: json['method'] ?? json['payment_method'],
      transactionId: json['transactionId'] ?? json['transaction_id'],
    );
  }
}

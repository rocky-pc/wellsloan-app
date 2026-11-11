import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/payment_model.dart';
import '../common/wells_button.dart';

class PaymentModal extends StatefulWidget {
  final PaymentModel payment;
  final Future<bool> Function(String method) onConfirmPay;

  const PaymentModal({
    super.key,
    required this.payment,
    required this.onConfirmPay,
  });

  static Future<bool?> show(
    BuildContext context, {
    required PaymentModel payment,
    required Future<bool> Function(String method) onConfirmPay,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentModal(payment: payment, onConfirmPay: onConfirmPay),
    );
  }

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  String _selectedMethod = "UPI";
  bool _isProcessing = false;
  bool _isSuccess = false;

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'UPI',
      'title': 'Instant UPI Auto-Debit',
      'subtitle': 'Google Pay, PhonePe, Paytm, BHIM',
      'icon': Icons.bolt_rounded,
      'color': AppColors.emerald,
    },
    {
      'id': 'Debit Card',
      'title': 'Debit / ATM Card',
      'subtitle': 'Visa, MasterCard, RuPay',
      'icon': Icons.credit_card_rounded,
      'color': AppColors.primary,
    },
    {
      'id': 'NetBanking',
      'title': 'Internet Banking',
      'subtitle': 'All major Indian commercial banks',
      'icon': Icons.account_balance_rounded,
      'color': AppColors.sky,
    },
  ];

  Future<void> _handlePay() async {
    setState(() => _isProcessing = true);
    final success = await widget.onConfirmPay(_selectedMethod);
    if (!mounted) return;

    if (success) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_isSuccess) ...[
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.emeraldLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.emerald,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "EMI Payment Received!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Paid ${CurrencyFormatter.format(widget.payment.amount)} via $_selectedMethod",
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ] else ...[
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pay Monthly EMI",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      widget.payment.loanName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormatter.format(widget.payment.amount),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Due on: ${DateHelper.formatFriendly(widget.payment.dueDate)}",
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Payment Methods
            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            ..._methods.map((method) {
              final isSelected = _selectedMethod == method['id'];
              final color = method['color'] as Color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMethod = method['id']),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : AppColors.borderLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(method['icon'] as IconData, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['title'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                method['subtitle'],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? color : AppColors.borderLight,
                              width: 2,
                            ),
                            color: isSelected ? color : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 13, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),
            WellsButton(
              text: "Confirm Payment of ${CurrencyFormatter.format(widget.payment.amount)}",
              isLoading: _isProcessing,
              onPressed: _handlePay,
            ),
          ],
        ],
      ),
    );
  }
}

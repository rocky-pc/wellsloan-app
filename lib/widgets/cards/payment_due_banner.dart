import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helper.dart';

class PaymentDueBanner extends StatelessWidget {
  final double amount;
  final String dueDate;
  final VoidCallback onPayPressed;

  const PaymentDueBanner({
    super.key,
    required this.amount,
    required this.dueDate,
    required this.onPayPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) return const SizedBox.shrink();

    final daysLeft = DateHelper.daysUntil(dueDate);
    final isOverdue = daysLeft < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverdue ? AppColors.roseLight : AppColors.amberLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isOverdue ? AppColors.rose : AppColors.amber).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isOverdue ? AppColors.rose : AppColors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOverdue ? Icons.warning_rounded : Icons.access_time_filled_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isOverdue ? "OVERDUE EMI" : "UPCOMING EMI",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isOverdue ? AppColors.roseDark : AppColors.amberDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOverdue
                          ? "(${daysLeft.abs()} days overdue)"
                          : "Due ${DateHelper.formatFriendly(dueDate)}",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? AppColors.roseDark : AppColors.amberDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  CurrencyFormatter.format(amount),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPayPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isOverdue ? AppColors.rose : AppColors.amberDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Pay Now",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

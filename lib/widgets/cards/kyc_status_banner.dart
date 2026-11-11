import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class KycStatusBanner extends StatelessWidget {
  final String status;
  final VoidCallback onActionPressed;

  const KycStatusBanner({
    super.key,
    required this.status,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'verified') {
      return const SizedBox.shrink(); // Don't clutter screen if verified
    }

    final isPending = status == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPending ? AppColors.amberLight : AppColors.roseLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isPending ? AppColors.amber : AppColors.rose).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPending ? AppColors.amber : AppColors.rose,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPending ? Icons.hourglass_top_rounded : Icons.shield_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPending ? "KYC Verification Under Review" : "KYC Verification Required",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPending
                      ? "Your documents are being verified by our compliance team."
                      : "Upload ID to activate pre-approved credit and instant disbursal.",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isPending ? AppColors.amberDark : AppColors.roseDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onActionPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isPending ? AppColors.amberDark : AppColors.rose,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPending ? "Status" : "Verify",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

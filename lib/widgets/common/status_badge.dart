import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    String label = customLabel ?? status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
      case 'active':
      case 'paid':
        bg = AppColors.emeraldLight;
        fg = AppColors.emeraldDark;
        border = AppColors.emerald.withOpacity(0.3);
        break;
      case 'pending':
      case 'under_review':
        bg = AppColors.amberLight;
        fg = AppColors.amberDark;
        border = AppColors.amber.withOpacity(0.3);
        label = customLabel ?? "IN REVIEW";
        break;
      case 'overdue':
      case 'rejected':
      case 'failed':
      case 'not_started':
        bg = AppColors.roseLight;
        fg = AppColors.roseDark;
        border = AppColors.rose.withOpacity(0.3);
        if (status.toLowerCase() == 'not_started') label = "ACTION NEEDED";
        break;
      case 'closed':
      default:
        bg = AppColors.surfaceLightSubtle;
        fg = AppColors.textMuted;
        border = AppColors.borderLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

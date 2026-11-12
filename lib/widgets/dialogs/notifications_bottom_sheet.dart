import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../screens/advisor/ai_advisor_screen.dart';
import '../../screens/apply/apply_loan_screen.dart';
import '../../screens/kyc/kyc_hub_screen.dart';
import '../../screens/loans/loans_list_screen.dart';
import '../../screens/payments/payments_screen.dart';

class NotificationsBottomSheet extends StatefulWidget {
  const NotificationsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsBottomSheet(),
    );
  }

  @override
  State<NotificationsBottomSheet> createState() => _NotificationsBottomSheetState();
}

class _NotificationsBottomSheetState extends State<NotificationsBottomSheet> {
  final NotificationRepository _repo = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final res = await _repo.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = res['notifications'] as List<NotificationModel>;
        _isLoading = false;
      });
    }
  }

  void _handleDeepLink(String deepLink) {
    Navigator.of(context).pop();
    switch (deepLink) {
      case 'kyc':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KycHubScreen()));
        break;
      case 'apply':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ApplyLoanScreen()));
        break;
      case 'payments':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentsScreen()));
        break;
      case 'loans':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoansListScreen()));
        break;
      case 'ai_advisor':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiAdvisorScreen()));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                if (_notifications.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await _repo.markAllAsRead();
                      _loadNotifications();
                    },
                    child: const Text(
                      "Mark all read",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 30),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No Notifications Yet",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "You're all caught up! Updates regarding loans, KYC, and offers will appear here.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, idx) {
                          final item = _notifications[idx];
                          final isUnread = !item.isRead;

                          return GestureDetector(
                            onTap: () {
                              if (isUnread) {
                                _repo.markAsRead(item.id);
                              }
                              _handleDeepLink(item.deepLink);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isUnread ? AppColors.primaryLight.withOpacity(0.4) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isUnread ? AppColors.primary.withOpacity(0.3) : AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: item.priority == 'urgent'
                                          ? AppColors.roseLight
                                          : (item.priority == 'high' ? AppColors.amberLight : AppColors.primaryLight),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      item.priority == 'urgent'
                                          ? Icons.warning_amber_rounded
                                          : (item.priority == 'high' ? Icons.priority_high_rounded : Icons.info_outline_rounded),
                                      color: item.priority == 'urgent'
                                          ? AppColors.rose
                                          : (item.priority == 'high' ? AppColors.amberDark : AppColors.primary),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.title,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                            ),
                                            if (item.createdAt != null)
                                              Text(
                                                DateHelper.formatDateTime(item.createdAt),
                                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.message,
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.3),
                                        ),
                                        if (item.deepLink != 'home') ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: const [
                                              Text(
                                                "Tap to view",
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (isUnread) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

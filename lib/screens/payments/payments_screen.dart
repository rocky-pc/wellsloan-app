import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/dialogs/payment_modal.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openPayModal(PaymentModel payment) {
    PaymentModal.show(
      context,
      payment: payment,
      onConfirmPay: (method) async {
        return await context.read<PaymentProvider>().payPayment(payment.id, method: method);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    final upcoming = paymentProvider.upcomingPayments;
    final paid = paymentProvider.paidPayments;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          "Repayments & EMIs",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: "Upcoming (${upcoming.length})"),
            Tab(text: "History (${paid.length})"),
          ],
        ),
      ),
      body: paymentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Hero Balance Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.luxuryMidnightGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Total Due",
                                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(paymentProvider.totalOutstanding),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Total Repaid",
                                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(paymentProvider.totalPaid),
                                  style: const TextStyle(
                                    color: AppColors.emerald,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Upcoming EMIs
                      _buildUpcomingList(upcoming),

                      // History Tab
                      _buildHistoryList(paid),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUpcomingList(List<PaymentModel> upcoming) {
    if (upcoming.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.emeraldLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.emerald, size: 32),
            ),
            const SizedBox(height: 14),
            const Text(
              "All Dues Cleared! ✨",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              "You have no pending payments. Your credit score is in great shape!",
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: upcoming.length,
      itemBuilder: (ctx, idx) {
        final payment = upcoming[idx];
        final daysLeft = DateHelper.daysUntil(payment.dueDate);
        final isOverdue = daysLeft < 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOverdue ? AppColors.rose.withOpacity(0.4) : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isOverdue ? AppColors.roseLight : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isOverdue ? Icons.priority_high_rounded : Icons.calendar_month_rounded,
                  color: isOverdue ? AppColors.rose : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.loanName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOverdue
                          ? "Overdue by ${daysLeft.abs()} days"
                          : "Due on ${DateHelper.formatFriendly(payment.dueDate)}",
                      style: TextStyle(
                        fontSize: 11,
                        color: isOverdue ? AppColors.roseDark : AppColors.textMuted,
                        fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(payment.amount),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _openPayModal(payment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOverdue ? AppColors.rose : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Pay", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(List<PaymentModel> paid) {
    if (paid.isEmpty) {
      return const Center(
        child: Text(
          "No past payment history found.",
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: paid.length,
      itemBuilder: (ctx, idx) {
        final payment = paid[idx];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.emeraldLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.emerald, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.loanName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    Text(
                      "Paid via ${payment.method ?? 'UPI'} on ${DateHelper.formatFriendly(payment.paidDate ?? payment.dueDate)}",
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    if (payment.transactionId != null)
                      Text(
                        "Txn: ${payment.transactionId}",
                        style: const TextStyle(fontSize: 10, color: AppColors.textSubtle),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(payment.amount),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  const StatusBadge(status: "paid"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

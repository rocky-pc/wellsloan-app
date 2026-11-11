import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/cards/credit_limit_card.dart';
import '../../widgets/cards/kyc_status_banner.dart';
import '../../widgets/cards/loan_card.dart';
import '../../widgets/cards/payment_due_banner.dart';
import '../../widgets/dialogs/payment_modal.dart';
import '../advisor/ai_advisor_screen.dart';
import '../apply/apply_loan_screen.dart';
import '../eligibility/eligibility_calculator_screen.dart';
import '../kyc/kyc_hub_screen.dart';
import '../payments/payments_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final user = auth.user;

    final firstName = user?.name.split(' ').first ?? 'Borrower';
    final isKycVerified = user?.isKycVerified ?? false;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => dashboard.refresh(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar: User Profile Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  user?.avatarInitials ?? "WL",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (isKycVerified)
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 7,
                                    backgroundColor: AppColors.emerald,
                                    child: Icon(Icons.check, size: 9, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, $firstName 👋",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                isKycVerified ? "Verified Member" : "Complete KYC to Unlock Limit",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isKycVerified ? AppColors.emeraldDark : AppColors.amberDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Icon(Icons.notifications_none_rounded, size: 20, color: AppColors.textDark),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // KYC Status Warning Banner
                if (!isKycVerified) ...[
                  KycStatusBanner(
                    status: user?.kycStatus ?? 'not_started',
                    onActionPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const KycHubScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Upcoming EMI Banner (if any)
                if (dashboard.upcomingPayments.isNotEmpty) ...[
                  PaymentDueBanner(
                    amount: dashboard.upcomingPayments.first.amount,
                    dueDate: dashboard.upcomingPayments.first.dueDate,
                    onPayPressed: () {
                      PaymentModal.show(
                        context,
                        payment: dashboard.upcomingPayments.first,
                        onConfirmPay: (method) async {
                          final success = await context
                              .read<PaymentProvider>()
                              .payPayment(dashboard.upcomingPayments.first.id, method: method);
                          if (success) {
                            dashboard.refresh();
                          }
                          return success;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Pre-Approved Credit Limit Hero Card
                CreditLimitCard(
                  limitAmount: 350000,
                  onApplyPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ApplyLoanScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Quick Action Buttons Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickAction(
                      icon: Icons.add_circle_outline_rounded,
                      label: "Apply Loan",
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ApplyLoanScreen()),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.credit_card_rounded,
                      label: "Pay EMI",
                      color: AppColors.emerald,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PaymentsScreen()),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.calculate_outlined,
                      label: "Calculator",
                      color: AppColors.amberDark,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EligibilityCalculatorScreen()),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.auto_awesome_rounded,
                      label: "AI Copilot",
                      color: AppColors.sky,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AiAdvisorScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Active Loans Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Active Loans",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (dashboard.activeLoans.isNotEmpty)
                      Text(
                        "${dashboard.activeLoans.length} Active",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (dashboard.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (dashboard.activeLoans.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No Active Debt Obligations",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Apply today to unlock instant credit at 11.99% p.a.",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...dashboard.activeLoans.map((loan) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LoanCard(loan: loan),
                    );
                  }).toList(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

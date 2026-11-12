import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/cards/credit_limit_card.dart';
import '../../widgets/cards/kyc_status_banner.dart';
import '../../widgets/cards/loan_card.dart';
import '../../widgets/cards/payment_due_banner.dart';
import '../../widgets/dialogs/notifications_bottom_sheet.dart';
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

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final user = auth.user;

    final firstName = user?.name.split(' ').first ?? 'Borrower';
    final isKycVerified = user?.isKycVerified ?? false;
    final timeGreeting = _getTimeGreeting();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => dashboard.refresh(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar: User Profile Header + Notification Bell
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
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, Color(0xFF7C3AED)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    user?.avatarInitials ?? "WL",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              if (isKycVerified)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const CircleAvatar(
                                      radius: 6.5,
                                      backgroundColor: AppColors.emerald,
                                      child: Icon(Icons.check, size: 9, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$timeGreeting, $firstName 👋",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isKycVerified ? AppColors.emerald : AppColors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isKycVerified ? "Premier Verified Member" : "Complete KYC to Unlock Limit",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isKycVerified ? AppColors.emeraldDark : AppColors.amberDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Top Action Icons
                    Row(
                      children: [
                        IconButton(
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.notifications_none_rounded, size: 20, color: AppColors.textDark),
                                Positioned(
                                  top: 9,
                                  right: 9,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.rose,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => NotificationsBottomSheet.show(context),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // KYC Status Action Alert (Floating banner if not yet verified)
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

                // Upcoming EMI Banner (if any due soon)
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

                // Flagship Pre-Approved Credit Limit Hero Card
                CreditLimitCard(
                  limitAmount: 350000,
                  interestRate: "11.99% p.a.",
                  onApplyPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ApplyLoanScreen()),
                    );
                  },
                ),

                const SizedBox(height: 18),

                // Financial Telemetry Micro-Stat Ribbon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricItem(
                        icon: Icons.trending_up_rounded,
                        iconColor: AppColors.emerald,
                        title: "768",
                        subtitle: "Credit Score",
                      ),
                      Container(width: 1, height: 26, color: AppColors.borderLight),
                      _buildMetricItem(
                        icon: Icons.flash_on_rounded,
                        iconColor: AppColors.amberDark,
                        title: "~2 Mins",
                        subtitle: "Disbursal SLA",
                      ),
                      Container(width: 1, height: 26, color: AppColors.borderLight),
                      _buildMetricItem(
                        icon: Icons.verified_user_rounded,
                        iconColor: AppColors.primary,
                        title: "100%",
                        subtitle: "RBI Regulated",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Quick Action Buttons Grid (Designed with micro-interactions)
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

                const SizedBox(height: 26),

                // Active Loans Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Active Debt Obligations",
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (dashboard.activeLoans.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${dashboard.activeLoans.length} Active",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.emeraldLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.emerald,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No Active Debt Obligations",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Your balance is spotless. Tap apply to withdraw up to ₹3,50,000 at 11.99% p.a.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            height: 1.3,
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
                  }),

                const SizedBox(height: 20),

                // Fintech Highlights Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E1B4B),
                        const Color(0xFF312E81),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Zero Foreclosure & Pre-payment Fee",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Repay early whenever you want without penalties.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

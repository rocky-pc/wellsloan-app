import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/loan_model.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/cards/loan_card.dart';
import '../../widgets/common/status_badge.dart';
import '../apply/apply_loan_screen.dart';
import 'loan_details_screen.dart';

class LoansListScreen extends StatefulWidget {
  const LoansListScreen({super.key});

  @override
  State<LoansListScreen> createState() => _LoansListScreenState();
}

class _LoansListScreenState extends State<LoansListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lp = context.read<LoanProvider>();
      lp.fetchLoans();
      lp.fetchApplications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<LoanProvider>();

    final activeLoans = loanProvider.loans.where((l) => l.status == 'active' || l.status == 'overdue').toList();
    final closedLoans = loanProvider.loans.where((l) => l.status == 'closed').toList();
    final applications = loanProvider.applications;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          "My Loan Portfolio",
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
            Tab(text: "Active (${activeLoans.length})"),
            Tab(text: "Applications (${applications.length})"),
            Tab(text: "Closed (${closedLoans.length})"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Active Loans Tab
          _buildLoansTab(
            loans: activeLoans,
            emptyTitle: "No Active Loans Found",
            emptySubtitle: "Need quick liquidity? Apply in 5 minutes with zero collateral.",
            isLoading: loanProvider.isLoading,
            onRefresh: () => loanProvider.fetchLoans(),
          ),

          // 2. Applications Tab
          _buildApplicationsTab(applications, loanProvider),

          // 3. Closed Loans Tab
          _buildLoansTab(
            loans: closedLoans,
            emptyTitle: "No Repaid Loans Yet",
            emptySubtitle: "Repaid loans will appear here with your perfect repayment record.",
            isLoading: loanProvider.isLoading,
            onRefresh: () => loanProvider.fetchLoans(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoansTab({
    required List<LoanModel> loans,
    required String emptyTitle,
    required String emptySubtitle,
    required bool isLoading,
    required Future<void> Function() onRefresh,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loans.isEmpty) {
      return _buildEmptyState(emptyTitle, emptySubtitle);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: loans.length,
        itemBuilder: (ctx, idx) {
          final loan = loans[idx];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LoanCard(
              loan: loan,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LoanDetailsScreen(loan: loan)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationsTab(List<dynamic> applications, LoanProvider lp) {
    if (lp.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (applications.isEmpty) {
      return _buildEmptyState(
        "No Applications in Progress",
        "Submit a quick loan application to get instant disbursement approval.",
      );
    }

    return RefreshIndicator(
      onRefresh: () => lp.fetchApplications(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: applications.length,
        itemBuilder: (ctx, idx) {
          final app = applications[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      app.loanType,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    StatusBadge(status: app.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Requested Amount", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text(
                          CurrencyFormatter.format(app.amount),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Tenure", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text(
                          "${app.tenureMonths} Months",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ],
                ),
                if (app.appliedAt != null) ...[
                  const Divider(height: 20),
                  Text(
                    "Submitted on: ${DateHelper.formatFriendly(app.appliedAt)}",
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_outlined, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ApplyLoanScreen()),
                );
              },
              child: const Text("Apply for Micro-Loan"),
            ),
          ],
        ),
      ),
    );
  }
}

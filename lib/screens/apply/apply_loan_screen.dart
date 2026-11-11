import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/common/wells_button.dart';
import '../../widgets/common/wells_text_field.dart';
import 'application_success_screen.dart';

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({super.key});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  double _loanAmount = 100000;
  int _tenureMonths = 12;
  String _loanPurpose = "Personal Expenses";
  String _employmentType = "salaried";
  final TextEditingController _incomeController = TextEditingController(text: "45000");

  final List<double> _presetAmounts = [25000, 50000, 100000, 200000, 500000];
  final List<int> _presetTenures = [3, 6, 12, 24, 36];

  final List<Map<String, dynamic>> _purposes = [
    {'id': 'Personal Expenses', 'label': 'Personal', 'icon': Icons.person_outline_rounded},
    {'id': 'Medical Emergency', 'label': 'Medical', 'icon': Icons.medical_services_outlined},
    {'id': 'Repay Credit Card', 'label': 'Credit Card', 'icon': Icons.credit_card_outlined},
    {'id': 'Business Expansion', 'label': 'Business', 'icon': Icons.business_center_outlined},
    {'id': 'Higher Education', 'label': 'Education', 'icon': Icons.school_outlined},
    {'id': 'Home Renovation', 'label': 'Home', 'icon': Icons.home_outlined},
  ];

  final List<Map<String, String>> _employmentTypes = [
    {'value': 'salaried', 'label': 'Salaried Professional'},
    {'value': 'self_employed', 'label': 'Self-Employed / Freelancer'},
    {'value': 'business', 'label': 'Business Owner'},
  ];

  // Mathematical EMI calculation
  double get _estimatedEmi {
    const annualRate = 12.5;
    final monthlyRate = annualRate / 12 / 100;
    final n = _tenureMonths;
    final p = _loanAmount;
    final numerator = p * monthlyRate * pow(1 + monthlyRate, n);
    final denominator = pow(1 + monthlyRate, n) - 1;
    return numerator / denominator;
  }

  double get _totalRepayable => _estimatedEmi * _tenureMonths;
  double get _totalInterest => _totalRepayable - _loanAmount;

  Future<void> _handleSubmit() async {
    final income = double.tryParse(_incomeController.text.trim()) ?? 0;
    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid monthly take-home income.")),
      );
      return;
    }

    final loanProvider = context.read<LoanProvider>();
    final app = await loanProvider.submitApplication(
      loanType: _loanPurpose,
      amount: _loanAmount,
      tenureMonths: _tenureMonths,
      purpose: _loanPurpose,
      employmentType: _employmentType,
      monthlyIncome: income,
    );

    if (app != null && mounted) {
      context.read<DashboardProvider>().refresh();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ApplicationSuccessScreen(
            application: app,
            emiAmount: _estimatedEmi,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<LoanProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          "Apply for Loan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loanProvider.errorMessage != null) ...[
              ErrorBanner(message: loanProvider.errorMessage!),
              const SizedBox(height: 16),
            ],

            // EMI Live Calculation Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.luxuryMidnightGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E1B4B).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Estimated Monthly EMI",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(_estimatedEmi.round()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat("Interest", CurrencyFormatter.format(_totalInterest.round())),
                        Container(width: 1, height: 24, color: Colors.white24),
                        _buildStat("Total Repayable", CurrencyFormatter.format(_totalRepayable.round())),
                        Container(width: 1, height: 24, color: Colors.white24),
                        _buildStat("Annual Rate", "12.5% p.a."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Loan Amount Slider & Presets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Loan Amount",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                Text(
                  CurrencyFormatter.format(_loanAmount.round()),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.borderLight,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withOpacity(0.12),
                trackHeight: 6,
              ),
              child: Slider(
                value: _loanAmount,
                min: 10000,
                max: 500000,
                divisions: 49,
                onChanged: (val) => setState(() => _loanAmount = val),
              ),
            ),

            // Amount Presets Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presetAmounts.map((amt) {
                  final isSelected = _loanAmount == amt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(CurrencyFormatter.formatCompact(amt)),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _loanAmount = amt),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Loan Tenure Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Repayment Tenure",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                Text(
                  "$_tenureMonths Months",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presetTenures.map((t) {
                final isSelected = _tenureMonths == t;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _tenureMonths = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${t}M",
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Loan Purpose Selector
            const Text(
              "Purpose of Loan",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _purposes.map((p) {
                  final isSelected = _loanPurpose == p['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _loanPurpose = p['id']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              p['icon'] as IconData,
                              size: 16,
                              color: isSelected ? AppColors.primary : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              p['label'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.primaryDark : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Income & Employment Details
            WellsTextField(
              label: "Net Monthly Take-Home Income (₹)",
              hint: "45000",
              controller: _incomeController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18),
            ),
            const SizedBox(height: 16),

            const Text(
              "Employment Type",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _employmentType,
                  isExpanded: true,
                  items: _employmentTypes.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['value'],
                      child: Text(
                        item['label']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _employmentType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            WellsButton(
              text: "Submit & Sanction ${CurrencyFormatter.format(_loanAmount.round())}",
              isLoading: loanProvider.isSubmitting,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

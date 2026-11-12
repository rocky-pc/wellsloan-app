import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/common/wells_button.dart';
import '../apply/apply_loan_screen.dart';

class EligibilityCalculatorScreen extends StatefulWidget {
  const EligibilityCalculatorScreen({super.key});

  @override
  State<EligibilityCalculatorScreen> createState() => _EligibilityCalculatorScreenState();
}

class _EligibilityCalculatorScreenState extends State<EligibilityCalculatorScreen> {
  double _monthlyIncome = 50000;
  double _existingEmi = 5000;

  // Calculations:
  // FOIR = (Existing EMIs + New EMI) / Monthly Income
  // Standard underwriting allows up to 40% - 50% max FOIR.
  double get _maxAllowedEmi {
    final maxFoirCapacity = _monthlyIncome * 0.45;
    final available = maxFoirCapacity - _existingEmi;
    return available > 0 ? available : 0;
  }

  // Estimated loan amount based on 24 months at 12.5% p.a.
  double get _sanctionableLimit {
    if (_maxAllowedEmi <= 0) return 0;
    final est = _maxAllowedEmi * 20.8;
    return (est / 1000).round() * 1000.0;
  }

  double get _foirPercentage {
    if (_monthlyIncome <= 0) return 0;
    return ((_existingEmi / _monthlyIncome) * 100).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          "Credit & Eligibility Meter",
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Max Credit Limit Result Hero Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.luxuryMidnightGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E1B4B).withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Maximum Estimated Loan Sanction",
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(_sanctionableLimit),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat("Max Safe EMI", CurrencyFormatter.format(_maxAllowedEmi.round())),
                        Container(width: 1, height: 26, color: Colors.white24),
                        _buildStat("Current FOIR", "${_foirPercentage.toStringAsFixed(0)}%"),
                        Container(width: 1, height: 26, color: Colors.white24),
                        _buildStat("Interest Rate", "11.99% p.a."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Income Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Monthly Take-Home Income",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                Text(
                  CurrencyFormatter.format(_monthlyIncome.round()),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
            Slider(
              value: _monthlyIncome,
              min: 15000,
              max: 250000,
              divisions: 47,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _monthlyIncome = val),
            ),
            const SizedBox(height: 16),

            // Existing EMI Obligations Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Existing Monthly EMIs",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                Text(
                  CurrencyFormatter.format(_existingEmi.round()),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.amberDark),
                ),
              ],
            ),
            Slider(
              value: _existingEmi,
              min: 0,
              max: 80000,
              divisions: 40,
              activeColor: AppColors.amberDark,
              onChanged: (val) => setState(() => _existingEmi = val),
            ),
            const SizedBox(height: 20),

            // Underwriting Health Indicators
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Credit Assessment Insights",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        _foirPercentage < 40 ? Icons.check_circle_rounded : Icons.info_rounded,
                        color: _foirPercentage < 40 ? AppColors.emerald : AppColors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _foirPercentage < 40
                              ? "Healthy debt-to-income ratio. High chance of instant 5-minute approval."
                              : "Moderate debt ratio. Consider longer tenure to reduce monthly burden.",
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            WellsButton(
              text: "Apply with Sanctioned Limit",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ApplyLoanScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
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

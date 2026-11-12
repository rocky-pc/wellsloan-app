import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../widgets/common/wells_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Instant Micro-Loans\nDirect to Bank',
      'desc': 'Pre-approved sanction limits up to ₹5,00,000 with industry-lowest rates from 11.99% p.a. and instant disbursal.',
      'icon': Icons.bolt_rounded,
      'color': AppColors.emerald,
    },
    {
      'title': 'Paperless AI KYC\nVerification',
      'desc': 'Snap your Aadhaar or PAN card. Our integrated Gemini Vision OCR engine verifies your identity in under 30 seconds.',
      'icon': Icons.document_scanner_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'Zero Hidden Fees &\n0-Penalty Prepayment',
      'desc': 'Transparent EMI tracking, customized tenures from 3 to 36 months, and complete freedom to prepay anytime at zero cost.',
      'icon': Icons.verified_user_rounded,
      'color': AppColors.amberDark,
    },
  ];

  Future<void> _completeOnboarding() async {
    final storage = SecureStorageService();
    await storage.setOnboardingSeen(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 26, height: 26),
            const SizedBox(width: 8),
            const Text(
              "Wellsloan",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textDark),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: const Text(
              "Skip",
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (ctx, index) {
                    final slide = _slides[index];
                    final color = slide['color'] as Color;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Large Glowing Hero Icon
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: color.withOpacity(0.2), width: 2),
                          ),
                          child: Center(
                            child: Icon(
                              slide['icon'] as IconData,
                              size: 64,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppColors.textDark,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['desc'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (idx) {
                  final isActive = idx == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // CTA Button
              WellsButton(
                text: _currentIndex == _slides.length - 1 ? "Get Started" : "Continue",
                onPressed: () {
                  if (_currentIndex < _slides.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

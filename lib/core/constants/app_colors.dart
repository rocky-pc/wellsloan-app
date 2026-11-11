import 'package:flutter/material.dart';

/// Wellsloan App Premium Fintech Color Palette
/// Designed for high visual hierarchy, trust, and micro-interactions
class AppColors {
  // Brand Primary & Gradients
  static const Color primary = Color(0xFF6366F1); // Modern Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryDeep = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFFEEF2FF);

  // Financial Accent Tones
  static const Color emerald = Color(0xFF10B981); // Disbursal / Approved / Growth
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFFECFDF5);

  static const Color amber = Color(0xFFF59E0B); // Pending / Action Required
  static const Color amberDark = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFFFBEB);

  static const Color rose = Color(0xFFEF4444); // Overdue / Rejected / Alert
  static const Color roseDark = Color(0xFFDC2626);
  static const Color roseLight = Color(0xFFFEF2F2);

  static const Color sky = Color(0xFF0EA5E9); // AI Copilot / Informational
  static const Color skyLight = Color(0xFFF0F9FF);

  // Backgrounds & Neutrals (Light Mode)
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightSubtle = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Backgrounds & Neutrals (Dark Mode)
  static const Color bgDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF151D2F);
  static const Color surfaceDarkSubtle = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);

  // Typography Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFF8FAFC);

  // Gradients for High-Impact Cards
  static const LinearGradient luxuryMidnightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A), // Deep Slate Navy
      Color(0xFF1E1B4B), // Rich Indigo
      Color(0xFF31104B), // Royal Violet
    ],
  );

  static const LinearGradient emeraldGrowthGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF064E3B),
      Color(0xFF059669),
      Color(0xFF10B981),
    ],
  );

  static const LinearGradient aiCopilotGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF312E81),
      Color(0xFF4F46E5),
      Color(0xFF7C3AED),
    ],
  );
}

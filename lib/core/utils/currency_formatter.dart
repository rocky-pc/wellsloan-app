import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Formats amount into Indian currency standard (e.g. ₹1,50,000)
  static String format(num? amount) {
    if (amount == null) return "₹0";
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Compact Indian grouping (e.g. ₹1.5 Lakhs, ₹10K)
  static String formatCompact(num? amount) {
    if (amount == null || amount == 0) return "₹0";
    if (amount >= 10000000) {
      return "₹${(amount / 10000000).toStringAsFixed(1)} Cr";
    }
    if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(1)} L";
    }
    if (amount >= 1000) {
      return "₹${(amount / 1000).toStringAsFixed(0)}K";
    }
    return "₹$amount";
  }
}

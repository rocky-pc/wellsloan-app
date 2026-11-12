import 'package:intl/intl.dart';

class DateHelper {
  /// Formats date string to friendly readable format (e.g. 15 Nov, 2026)
  static String formatFriendly(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "N/A";
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd MMM, yyyy').format(date);
    } catch (_) {
      return isoString;
    }
  }

  /// Formats DateTime object to friendly readable format
  static String formatDateTime(DateTime? dt) {
    if (dt == null) return "N/A";
    return DateFormat('dd MMM, yyyy').format(dt);
  }

  /// Calculates days remaining until due date
  static int daysUntil(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 0;
    try {
      final due = DateTime.parse(isoString);
      final today = DateTime.now();
      final diff = due.difference(today).inDays;
      return diff;
    } catch (_) {
      return 0;
    }
  }
}

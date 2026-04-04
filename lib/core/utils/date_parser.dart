// lib/core/utils/date_parser_helper.dart
class DateParserHelper {
  /// ✅ Format DateTime to "YYYY-MM-DD" (ISO format for APIs)
  /// Example: DateTime(2026, 1, 15) → "2026-01-15"
  static String toApiDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// ✅ Format DateTime to "DD/MM/YYYY" (common display format)
  /// Example: DateTime(2026, 1, 15) → "15/01/2026"
  static String toDisplayDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// ✅ Format DateTime to "MMM DD, YYYY" (friendly format)
  /// Example: DateTime(2026, 1, 15) → "Jan 15, 2026"
  static String toFriendlyDate(DateTime? date) {
    if (date == null) return 'N/A';

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${months[date.month - 1]} '
        '${date.day.toString().padLeft(2, '0')}, '
        '${date.year}';
  }

  /// ✅ Format DateTime to "Day, MMM DD" (for calendar headers)
  /// Example: DateTime(2026, 1, 15) → "Wed, Jan 15"
  static String toCalendarHeader(DateTime? date) {
    if (date == null) return 'N/A';

    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${days[date.weekday % 7]}, '
        '${months[date.month - 1]} '
        '${date.day}';
  }

  /// ✅ Get full day name (Monday, Tuesday, etc.)
  static String getDayName(DateTime? date) {
    if (date == null) return 'N/A';
    final days = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday'
    ];
    return days[date.weekday % 7];
  }

  /// ✅ Get full month name (January, February, etc.)
  static String getMonthName(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }

  /// ✅ Parse string to DateTime safely (returns null on failure)
  /// Supports formats: "2026-01-15", "15/01/2026", "Jan 15, 2026"
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) return null;

    final trimmed = dateString.trim();

    // Try ISO format first (2026-01-15)
    try {
      return DateTime.parse(trimmed);
    } catch (_) {
      // Try DD/MM/YYYY format
      try {
        final parts = trimmed.split(RegExp(r'[/\-.\s]'));
        if (parts.length >= 3) {
          final day = int.tryParse(parts[0]) ?? 0;
          final month = int.tryParse(parts[1]) ?? 0;
          final year = int.tryParse(parts[2]) ?? 0;

          if (day > 0 && month > 0 && year >= 1000) {
            return DateTime(year, month, day);
          }
        }
      } catch (_) {
        // Try friendly format (Jan 15, 2026)
        try {
          return _parseFriendlyDate(trimmed);
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  /// ✅ Check if two dates are the same day (ignores time)
  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// ✅ Format time as "HH:mm" (24-hour format)
  /// Example: 14:30:00 → "14:30"
  static String toTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// ✅ Format date + time together
  /// Example: "Jan 15, 2026 at 14:30"
  static String toDateTimeString(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${toFriendlyDate(dateTime)} at ${toTime(dateTime)}';
  }

  /// 🔒 Private helper: Parse "Jan 15, 2026" format
  static DateTime? _parseFriendlyDate(String text) {
    final months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
    };

    final parts = text.split(RegExp(r'[\s,]+'));
    if (parts.length < 3) return null;

    final monthAbbr = parts[0].toLowerCase().substring(0, 3);
    final month = months[monthAbbr];
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (month == null || day == null || year == null) return null;
    return DateTime(year, month, day);
  }


  /// ✅ Convert ISO string to display format "DD/MM/YYYY"
  static String isoToDisplay(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';

    try {
      final date = DateTime.parse(isoString);
      return toDisplayDate(date); // reuse your existing method
    } catch (_) {
      return 'N/A';
    }
  }



}
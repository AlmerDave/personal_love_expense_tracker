import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  // Format patterns
  static final DateFormat _fullDate = DateFormat('MMMM dd, yyyy');
  static final DateFormat _shortDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _monthDay = DateFormat('MMM dd');
  static final DateFormat _dayMonth = DateFormat('dd MMM');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _dayName = DateFormat('EEEE');
  static final DateFormat _shortDayName = DateFormat('EEE');

  /// Full date format (January 25, 2026)
  static String formatFull(DateTime date) {
    return _fullDate.format(date);
  }

  /// Short date format (Jan 25, 2026)
  static String formatShort(DateTime date) {
    return _shortDate.format(date);
  }

  /// Month and day only (Jan 25)
  static String formatMonthDay(DateTime date) {
    return _monthDay.format(date);
  }

  /// Time format (10:30 AM)
  static String formatTime(DateTime date) {
    return _time.format(date);
  }

  /// Month and year (January 2026)
  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  /// Day name (Sunday)
  static String formatDayName(DateTime date) {
    return _dayName.format(date);
  }

  /// Relative date (Today, Yesterday, Jan 25)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return _dayName.format(date);
    } else {
      return formatShort(date);
    }
  }

  /// Format date range (Jan 16 - Jan 25)
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${_monthDay.format(start)} - ${end.day}';
    }
    return '${_monthDay.format(start)} - ${_monthDay.format(end)}';
  }

  /// Format for transaction list header (Today, January 25)
  static String formatListHeader(DateTime date) {
    final relative = formatRelative(date);
    if (relative == 'Today' || relative == 'Yesterday') {
      return '$relative, ${_monthDay.format(date)}';
    }
    return _fullDate.format(date);
  }

  /// Get bi-weekly period dates
  static Map<String, DateTime> getBiWeeklyPeriod(DateTime date) {
    final day = date.day;
    DateTime start, end;

    if (day <= 15) {
      // Period 1: 1st - 15th
      start = DateTime(date.year, date.month, 1);
      end = DateTime(date.year, date.month, 15);
    } else {
      // Period 2: 16th - end of month
      start = DateTime(date.year, date.month, 16);
      end = DateTime(date.year, date.month + 1, 0); // Last day of month
    }

    return {'start': start, 'end': end};
  }

  /// Get current bi-weekly period label
  static String getBiWeeklyLabel(DateTime date) {
    final period = getBiWeeklyPeriod(date);
    return formatDateRange(period['start']!, period['end']!);
  }

  /// Get days remaining in bi-weekly period
  static int getDaysRemainingInBiWeekly(DateTime date) {
    final period = getBiWeeklyPeriod(date);
    return period['end']!.difference(date).inDays + 1;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day + (7 - weekday));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}

import 'package:flutter/material.dart';
import '../enums/period_type.dart';
import 'date_formatter.dart';

class Helpers {
  Helpers._();

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Calculate percentage
  static double calculatePercentage(double current, double total) {
    if (total <= 0) return 0;
    return (current / total) * 100;
  }

  /// Get date range based on period type
  static Map<String, DateTime> getDateRange(PeriodType period, [DateTime? baseDate]) {
    final date = baseDate ?? DateTime.now();
    
    switch (period) {
      case PeriodType.daily:
        return {
          'start': DateFormatter.startOfDay(date),
          'end': DateFormatter.endOfDay(date),
        };
      case PeriodType.weekly:
        return {
          'start': DateFormatter.startOfWeek(date),
          'end': DateFormatter.endOfWeek(date),
        };
      case PeriodType.biWeekly:
        return DateFormatter.getBiWeeklyPeriod(date);
      case PeriodType.monthly:
        return {
          'start': DateFormatter.startOfMonth(date),
          'end': DateFormatter.endOfMonth(date),
        };
    }
  }

  /// Get days remaining in period
  static int getDaysRemaining(PeriodType period, [DateTime? baseDate]) {
    final date = baseDate ?? DateTime.now();
    final range = getDateRange(period, date);
    return range['end']!.difference(date).inDays + 1;
  }

  /// Get period label with dates
  static String getPeriodLabel(PeriodType period, [DateTime? baseDate]) {
    final date = baseDate ?? DateTime.now();
    final range = getDateRange(period, date);
    
    switch (period) {
      case PeriodType.daily:
        return DateFormatter.formatFull(date);
      case PeriodType.weekly:
        return DateFormatter.formatDateRange(range['start']!, range['end']!);
      case PeriodType.biWeekly:
        return DateFormatter.formatDateRange(range['start']!, range['end']!);
      case PeriodType.monthly:
        return DateFormatter.formatMonthYear(date);
    }
  }

  /// Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Debounce helper
  static Function(Function) debounce(Duration duration) {
    DateTime? lastCall;
    return (Function callback) {
      final now = DateTime.now();
      if (lastCall == null || now.difference(lastCall!) > duration) {
        lastCall = now;
        callback();
      }
    };
  }

  /// Clamp value between min and max
  static double clampPercentage(double value) {
    return value.clamp(0.0, 100.0);
  }

  /// Check if running on web
  static bool get isWeb {
    return identical(0, 0.0);
  }
}

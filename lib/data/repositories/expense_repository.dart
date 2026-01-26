import '../local/hive_database.dart';
import '../models/expense.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/enums/period_type.dart';

class ExpenseRepository {
  ExpenseRepository._();

  static final ExpenseRepository instance = ExpenseRepository._();

  /// Get all expenses
  List<Expense> getAll() {
    return HiveDatabase.expenseBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get expense by ID
  Expense? getById(String id) {
    try {
      return HiveDatabase.expenseBox.values.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add new expense
  Future<void> add(Expense expense) async {
    await HiveDatabase.expenseBox.put(expense.id, expense);
  }

  /// Update expense
  Future<void> update(Expense expense) async {
    await HiveDatabase.expenseBox.put(expense.id, expense);
  }

  /// Delete expense
  Future<void> delete(String id) async {
    await HiveDatabase.expenseBox.delete(id);
  }

  /// Delete multiple expenses
  Future<void> deleteMultiple(List<String> ids) async {
    for (final id in ids) {
      await HiveDatabase.expenseBox.delete(id);
    }
  }

  /// Get expenses by date range
  List<Expense> getByDateRange(DateTime start, DateTime end) {
    final startDate = DateFormatter.startOfDay(start);
    final endDate = DateFormatter.endOfDay(end);

    return HiveDatabase.expenseBox.values
        .where((e) =>
            e.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            e.date.isBefore(endDate.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get expenses for today
  List<Expense> getToday() {
    final now = DateTime.now();
    return getByDateRange(now, now);
  }

  /// Get expenses for current week
  List<Expense> getCurrentWeek() {
    final now = DateTime.now();
    final start = DateFormatter.startOfWeek(now);
    final end = DateFormatter.endOfWeek(now);
    return getByDateRange(start, end);
  }

  /// Get expenses for current bi-weekly period
  List<Expense> getCurrentBiWeekly() {
    final now = DateTime.now();
    final period = DateFormatter.getBiWeeklyPeriod(now);
    return getByDateRange(period['start']!, period['end']!);
  }

  /// Get expenses for current month
  List<Expense> getCurrentMonth() {
    final now = DateTime.now();
    final start = DateFormatter.startOfMonth(now);
    final end = DateFormatter.endOfMonth(now);
    return getByDateRange(start, end);
  }

  /// Get expenses by period type
  List<Expense> getByPeriod(PeriodType period, [DateTime? baseDate]) {
    final date = baseDate ?? DateTime.now();

    switch (period) {
      case PeriodType.daily:
        return getByDateRange(date, date);
      case PeriodType.weekly:
        final start = DateFormatter.startOfWeek(date);
        final end = DateFormatter.endOfWeek(date);
        return getByDateRange(start, end);
      case PeriodType.biWeekly:
        final biWeekly = DateFormatter.getBiWeeklyPeriod(date);
        return getByDateRange(biWeekly['start']!, biWeekly['end']!);
      case PeriodType.monthly:
        final start = DateFormatter.startOfMonth(date);
        final end = DateFormatter.endOfMonth(date);
        return getByDateRange(start, end);
    }
  }

  /// Get total spent for period
  double getTotalSpent(PeriodType period, [DateTime? baseDate]) {
    final expenses = getByPeriod(period, baseDate);
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get expenses by category
  List<Expense> getByCategory(String category) {
    return HiveDatabase.expenseBox.values
        .where((e) => e.category == category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get category spending breakdown
  Map<String, double> getCategoryBreakdown(List<Expense> expenses) {
    final breakdown = <String, double>{};

    for (final expense in expenses) {
      final category = expense.categoryDisplayName;
      breakdown[category] = (breakdown[category] ?? 0) + expense.amount;
    }

    return breakdown;
  }

  /// Get recent transactions (limit)
  List<Expense> getRecent({int limit = 5}) {
    final all = getAll();
    return all.take(limit).toList();
  }

  /// Search expenses
  List<Expense> search(String query) {
    final lowercaseQuery = query.toLowerCase();
    return HiveDatabase.expenseBox.values
        .where((e) =>
            e.merchant.toLowerCase().contains(lowercaseQuery) ||
            e.categoryDisplayName.toLowerCase().contains(lowercaseQuery) ||
            (e.notes?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get expenses grouped by date
  Map<DateTime, List<Expense>> getGroupedByDate(List<Expense> expenses) {
    final grouped = <DateTime, List<Expense>>{};

    for (final expense in expenses) {
      final dateOnly = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );

      if (grouped.containsKey(dateOnly)) {
        grouped[dateOnly]!.add(expense);
      } else {
        grouped[dateOnly] = [expense];
      }
    }

    // Sort each group by time
    grouped.forEach((key, value) {
      value.sort((a, b) => b.date.compareTo(a.date));
    });

    return grouped;
  }

  /// Export all expenses to JSON
  List<Map<String, dynamic>> exportToJson() {
    return getAll().map((e) => e.toJson()).toList();
  }

  /// Clear all expenses
  Future<void> clearAll() async {
    await HiveDatabase.expenseBox.clear();
  }
}

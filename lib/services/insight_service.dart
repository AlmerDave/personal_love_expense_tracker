import '../data/models/expense.dart';
import '../data/models/insight_result.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/goal_repository.dart';
import '../core/enums/period_type.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/helpers.dart';
import 'gemini_service.dart';

class InsightService {
  InsightService._();

  static final InsightService instance = InsightService._();

  /// Generate insight for a date range
  Future<InsightResult> generateInsight({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get expenses for the date range
    final expenses = ExpenseRepository.instance.getByDateRange(startDate, endDate);
    
    // Calculate total spent
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    
    // Get category breakdown
    final categoryBreakdown = _getCategoryBreakdown(expenses, totalSpent);
    
    // Calculate days
    final totalDays = endDate.difference(startDate).inDays + 1;
    final daysRemaining = endDate.difference(DateTime.now()).inDays + 1;
    
    // Get goal amount (try bi-weekly first, then monthly)
    double? goalAmount = GoalRepository.instance.getGoalAmount(PeriodType.biWeekly);
    goalAmount ??= GoalRepository.instance.getGoalAmount(PeriodType.monthly);
    
    // Get previous period total for comparison
    final previousPeriodTotal = _getPreviousPeriodTotal(startDate, endDate);
    
    // Generate narrative from Gemini
    final categoryMap = <String, double>{};
    for (final cat in categoryBreakdown) {
      categoryMap[cat.category] = cat.amount;
    }
    
    final narrative = await GeminiService.instance.generateSpendingInsight(
      totalSpent: totalSpent,
      categoryBreakdown: categoryMap,
      daysInPeriod: totalDays,
      daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
      goalAmount: goalAmount,
      previousPeriodTotal: previousPeriodTotal,
    );
    
    return InsightResult.fromGeminiResponse(
      response: narrative,
      totalSpent: totalSpent,
      startDate: startDate,
      endDate: endDate,
      categoryBreakdown: categoryBreakdown,
      daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
      goalAmount: goalAmount,
    );
  }

  /// Generate quick insight for dashboard
  Future<String> generateQuickInsight() async {
    final today = DateTime.now();
    final biWeeklyPeriod = DateFormatter.getBiWeeklyPeriod(today);
    
    final expenses = ExpenseRepository.instance.getByDateRange(
      biWeeklyPeriod['start']!,
      biWeeklyPeriod['end']!,
    );
    
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final goalAmount = GoalRepository.instance.getGoalAmount(PeriodType.biWeekly);
    
    if (expenses.isEmpty) {
      return "No expenses recorded yet this period. Start tracking to get personalized insights! 📝";
    }
    
    if (goalAmount != null) {
      final percentage = Helpers.calculatePercentage(totalSpent, goalAmount);
      final daysRemaining = DateFormatter.getDaysRemainingInBiWeekly(today);
      
      if (percentage < 50) {
        return "Great pace! You've only used ${percentage.toStringAsFixed(0)}% of your budget with $daysRemaining days left. Keep it up! 🎉";
      } else if (percentage < 80) {
        return "You're at ${percentage.toStringAsFixed(0)}% of your budget. Stay mindful with $daysRemaining days remaining! 💪";
      } else if (percentage < 100) {
        return "Heads up! You've used ${percentage.toStringAsFixed(0)}% of your budget. Consider slowing down spending. ⚠️";
      } else {
        return "You've exceeded your budget by ${(percentage - 100).toStringAsFixed(0)}%. Let's plan better for next period! 🎯";
      }
    } else {
      final todayExpenses = ExpenseRepository.instance.getToday();
      final todayTotal = todayExpenses.fold(0.0, (sum, e) => sum + e.amount);
      
      if (todayTotal > 0) {
        return "You've spent ₱${todayTotal.toStringAsFixed(0)} today. Set a budget goal to track your progress! 🎯";
      } else {
        return "No spending today yet. Set a budget goal to get better insights! ✨";
      }
    }
  }

  /// Get category breakdown
  List<CategorySpending> _getCategoryBreakdown(List<Expense> expenses, double totalSpent) {
    final breakdown = <String, Map<String, dynamic>>{};
    
    for (final expense in expenses) {
      final category = expense.categoryDisplayName;
      final emoji = expense.categoryEmoji;
      
      if (breakdown.containsKey(category)) {
        breakdown[category]!['amount'] = (breakdown[category]!['amount'] as double) + expense.amount;
        breakdown[category]!['count'] = (breakdown[category]!['count'] as int) + 1;
      } else {
        breakdown[category] = {
          'emoji': emoji,
          'amount': expense.amount,
          'count': 1,
        };
      }
    }
    
    final result = breakdown.entries.map((entry) {
      final amount = entry.value['amount'] as double;
      return CategorySpending(
        category: entry.key,
        emoji: entry.value['emoji'] as String,
        amount: amount,
        percentage: totalSpent > 0 ? (amount / totalSpent) * 100 : 0,
        transactionCount: entry.value['count'] as int,
      );
    }).toList();
    
    // Sort by amount descending
    result.sort((a, b) => b.amount.compareTo(a.amount));
    
    return result;
  }

  /// Get previous period total for comparison
  double? _getPreviousPeriodTotal(DateTime startDate, DateTime endDate) {
    final periodLength = endDate.difference(startDate).inDays;
    final previousStart = startDate.subtract(Duration(days: periodLength + 1));
    final previousEnd = startDate.subtract(const Duration(days: 1));
    
    final previousExpenses = ExpenseRepository.instance.getByDateRange(
      previousStart,
      previousEnd,
    );
    
    if (previousExpenses.isEmpty) return null;
    
    return previousExpenses.fold(0.0, (sum, e) => sum! + e.amount);
  }
}

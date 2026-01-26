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
    
    // Check for active goals in priority order: daily -> weekly -> biWeekly -> monthly
    final activeGoals = [
      PeriodType.daily,
      PeriodType.weekly, 
      PeriodType.biWeekly,
      PeriodType.monthly
    ].map((period) => GoalRepository.instance.getByPeriod(period))
    .where((goal) => goal != null && goal.isActive)
    .toList();
    
    if (activeGoals.isEmpty) {
      return "Hoy Ate! Walang active goal mo! Paano mo mamo-monitor yang gastos mo? Set ka ng goal para may direction! 🎯";
    }
    
    // Use the highest priority active goal
    final activeGoal = activeGoals.first!;
    final periodType = activeGoal.period;
    final goalAmount = activeGoal.amount;
    
    // Get appropriate date range and expenses based on period type
    late DateTime startDate, endDate;
    late int daysRemaining, totalDays;
    
    switch (periodType) {
      case PeriodType.daily:
        startDate = DateFormatter.startOfDay(today);
        endDate = DateFormatter.endOfDay(today);
        daysRemaining = DateFormatter.isToday(today) ? 1 : 0;
        totalDays = 1;
        break;
        
      case PeriodType.weekly:
        startDate = DateFormatter.startOfWeek(today);
        endDate = DateFormatter.endOfWeek(today);
        daysRemaining = endDate.difference(today).inDays + 1;
        totalDays = 7;
        break;
        
      case PeriodType.biWeekly:
        final biWeeklyPeriod = DateFormatter.getBiWeeklyPeriod(today);
        startDate = biWeeklyPeriod['start']!;
        endDate = biWeeklyPeriod['end']!;
        daysRemaining = DateFormatter.getDaysRemainingInBiWeekly(today);
        totalDays = endDate.difference(startDate).inDays + 1;
        break;
        
      case PeriodType.monthly:
        startDate = DateFormatter.startOfMonth(today);
        endDate = DateFormatter.endOfMonth(today);
        daysRemaining = endDate.difference(today).inDays + 1;
        totalDays = endDate.difference(startDate).inDays + 1;
        break;
    }
    
    final expenses = ExpenseRepository.instance.getByDateRange(startDate, endDate);
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    
    if (expenses.isEmpty) {
      return _getNoExpensesMessage(periodType, daysRemaining);
    }
    
    final percentage = Helpers.calculatePercentage(totalSpent, goalAmount);
    final daysElapsed = totalDays - daysRemaining;
    final timeElapsedPercentage = daysElapsed > 0 ? (daysElapsed / totalDays) * 100 : 0;
    final isSpendingTooFast = percentage > (timeElapsedPercentage + _getSpeedThreshold(periodType));
    
    return _getInsightMessage(
      percentage, 
      periodType, 
      daysRemaining, 
      isSpendingTooFast,
      totalSpent,
    );
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

  String _getNoExpensesMessage(PeriodType periodType, int daysRemaining) {
    switch (periodType) {
      case PeriodType.daily:
        return "Walang gastos today Ate! Pero wag kampante, araw pa lang yan. Stay disciplined! 💪";
      case PeriodType.weekly:
        return "Hoy Ate! Week na to pero walang record ng gastos? Imposible yan! Start tracking para makita natin totoo! 📝";
      case PeriodType.biWeekly:
        return "Ate, bi-weekly period na to pero walang gastos recorded? Sus, hindi ako naniniwala! Track mo yan! 🕵️‍♀️";
      case PeriodType.monthly:
        return "Buong month walang gastos Ate? Hangin lang kinakain mo? Track mo naman yang mga expenses mo! 📊";
    }
  }

  double _getSpeedThreshold(PeriodType periodType) {
    switch (periodType) {
      case PeriodType.daily:
        return 0; // No speed threshold for daily
      case PeriodType.weekly:
        return 15;
      case PeriodType.biWeekly:
        return 20;
      case PeriodType.monthly:
        return 25;
    }
  }

  String _getInsightMessage(
    double percentage, 
    PeriodType periodType, 
    int daysRemaining,
    bool isSpendingTooFast,
    double totalSpent,
  ) {
    final periodLabel = _getPeriodLabel(periodType, daysRemaining);
    
    // Adjust aggression based on period type
    final aggressionMultiplier = _getAggressionMultiplier(periodType, daysRemaining);
    
    if (percentage <= 25) {
      if (isSpendingTooFast && periodType != PeriodType.daily) {
        return "Ate, 25% pa lang pero ang bilis mo mag-spend ${periodLabel}! Slow down baka ma-zero ka pa!";
      }
      return _getEncouragingMessage(percentage, periodType, periodLabel, aggressionMultiplier);
    } else if (percentage <= 40) {
      if (isSpendingTooFast) {
        return "Hoy Ate! ${percentage.toStringAsFixed(0)}% na yan ${periodLabel}! Mabilis masyado! May unnecessary purchases ka ba? 😤";
      }
      return "Ate, ${percentage.toStringAsFixed(0)}% na ${periodLabel}! Hindi pa kalahati pero medyo mataas na ah! Check mo yang wants vs needs! 🤔";
    } else if (percentage <= 60) {
      return _getMediumWarningMessage(percentage, periodType, periodLabel, aggressionMultiplier);
    } else if (percentage <= 80) {
      return _getHighWarningMessage(percentage, periodType, periodLabel, aggressionMultiplier);
    } else if (percentage <= 95) {
      return _getCriticalWarningMessage(percentage, periodType, periodLabel, aggressionMultiplier);
    } else if (percentage < 100) {
      return _getLastWarningMessage(percentage, periodType, periodLabel);
    } else if (percentage <= 120) {
      return _getOverBudgetMessage(percentage, periodType, periodLabel);
    } else if (percentage <= 150) {
      return _getSevereOverBudgetMessage(percentage, periodType);
    } else {
      return _getExtremeOverBudgetMessage(percentage, periodType, totalSpent);
    }
  }

  String _getPeriodLabel(PeriodType periodType, int daysRemaining) {
    switch (periodType) {
      case PeriodType.daily:
        return "today";
      case PeriodType.weekly:
        return "this week";
      case PeriodType.biWeekly:
        return "this period";
      case PeriodType.monthly:
        return "this month";
    }
  }

  double _getAggressionMultiplier(PeriodType periodType, int daysRemaining) {
    switch (periodType) {
      case PeriodType.daily:
        return 2.0; // Most aggressive
      case PeriodType.weekly:
        return daysRemaining <= 2 ? 1.5 : 1.2;
      case PeriodType.biWeekly:
        return daysRemaining <= 3 ? 1.3 : 1.0;
      case PeriodType.monthly:
        return daysRemaining <= 5 ? 1.2 : 0.8; // Least aggressive early in month
    }
  }

  String _getEncouragingMessage(double percentage, PeriodType periodType, String periodLabel, double multiplier) {
    if (periodType == PeriodType.daily) {
      return "Okay naman Ate, ${percentage.toStringAsFixed(0)}% pa lang today! Pero wag kampante, madami pa pwedeng mangyari! 💪";
    }
    return "Magaling Ate! ${percentage.toStringAsFixed(0)}% pa lang ${periodLabel}. Pero huwag kampante! Ipon pa more! 💪";
  }

  String _getMediumWarningMessage(double percentage, PeriodType periodType, String periodLabel, double multiplier) {
    if (periodType == PeriodType.daily) {
      return "Jusko Ate! ${percentage.toStringAsFixed(0)}% na today! Kalahati na ng daily budget mo! Anong nangyayari? 😠";
    }
    return "Jusko Ate! ${percentage.toStringAsFixed(0)}% na ${periodLabel}! Kalahati na! Anong plano mo sa natitira? Hangin? 😠";
  }

  String _getHighWarningMessage(double percentage, PeriodType periodType, String periodLabel, double multiplier) {
    if (periodType == PeriodType.daily) {
      return "GRABE NAMAN ATE! ${percentage.toStringAsFixed(0)}% NA NGAYONG ARAW! Halos ubos na daily budget mo!";
    }
    return "GRABE NAMAN ATE! ${percentage.toStringAsFixed(0)}% NA ${periodLabel}! Halos wala na! Review mo yang mga gastos mo!";
  }

  String _getCriticalWarningMessage(double percentage, PeriodType periodType, String periodLabel, double multiplier) {
    if (periodType == PeriodType.daily) {
      return "ATE ANONG GINAWA MO?! ${percentage.toStringAsFixed(0)}% NA TODAY! Halos ubos na ang daily budget! TIGIL NA! 😡";
    }
    return "ATE ANONG NANGYAYARI?! ${percentage.toStringAsFixed(0)}% NA ${periodLabel}! Sobrang lapit na sa limit! IPON MODE NA! 😡";
  }

  String _getLastWarningMessage(double percentage, PeriodType periodType, String periodLabel) {
    return "ATE LAST WARNING NA TO! ${percentage.toStringAsFixed(0)}% NA ${periodLabel}! Wag mo nang galawin yang wallet mo!";
  }

  String _getOverBudgetMessage(double percentage, PeriodType periodType, String periodLabel) {
    return "HAY NAKO ATE! LAMPAS KA NA NG ${(percentage - 100).toStringAsFixed(0)}% ${periodLabel}! Ano bang ginawa mo?! ";
  }

  String _getSevereOverBudgetMessage(double percentage, PeriodType periodType) {
    if (periodType == PeriodType.daily) {
      return "SOBRA NA ATE! ${percentage.toStringAsFixed(0)}% sa daily budget?! Anong emergency to? Bukas mo na ulit subukan! 🤦‍♀️";
    }
    return "SOBRA NA ATE! ${percentage.toStringAsFixed(0)}%?! Paano mo nasustain yang lifestyle mo kung ganyan ka mag-gastos?! 🤦‍♀️";
  }

  String _getExtremeOverBudgetMessage(double percentage, PeriodType periodType, double totalSpent) {
    if (periodType == PeriodType.daily) {
      return "ATE ${percentage.toStringAsFixed(0)}% SA ISANG ARAW?! ₱${totalSpent.toStringAsFixed(0)}?! Ano to, birthday mo? Mag-reflect ka muna!";
    }
    return "ATE ${percentage.toStringAsFixed(0)}%?! GRABE KA! Ano to shopping therapy?! May dagdag sahod ka ba na hindi ko alam?!";
  }
}

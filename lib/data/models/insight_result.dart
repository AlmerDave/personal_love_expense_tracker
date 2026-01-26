class InsightResult {
  final double totalSpent;
  final DateTime startDate;
  final DateTime endDate;
  final String narrative;
  final List<CategorySpending> categoryBreakdown;
  final String? suggestion;
  final double? dailyBudgetRemaining;
  final int daysRemaining;
  final double? goalAmount;
  final double? percentageUsed;

  InsightResult({
    required this.totalSpent,
    required this.startDate,
    required this.endDate,
    required this.narrative,
    required this.categoryBreakdown,
    this.suggestion,
    this.dailyBudgetRemaining,
    required this.daysRemaining,
    this.goalAmount,
    this.percentageUsed,
  });

  factory InsightResult.fromGeminiResponse({
    required String response,
    required double totalSpent,
    required DateTime startDate,
    required DateTime endDate,
    required List<CategorySpending> categoryBreakdown,
    required int daysRemaining,
    double? goalAmount,
  }) {
    double? percentageUsed;
    double? dailyBudget;
    
    if (goalAmount != null && goalAmount > 0) {
      percentageUsed = (totalSpent / goalAmount) * 100;
      final remaining = goalAmount - totalSpent;
      if (daysRemaining > 0) {
        dailyBudget = remaining / daysRemaining;
      }
    }

    return InsightResult(
      totalSpent: totalSpent,
      startDate: startDate,
      endDate: endDate,
      narrative: response,
      categoryBreakdown: categoryBreakdown,
      daysRemaining: daysRemaining,
      goalAmount: goalAmount,
      percentageUsed: percentageUsed,
      dailyBudgetRemaining: dailyBudget,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSpent': totalSpent,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'narrative': narrative,
      'categoryBreakdown': categoryBreakdown.map((c) => c.toJson()).toList(),
      'suggestion': suggestion,
      'dailyBudgetRemaining': dailyBudgetRemaining,
      'daysRemaining': daysRemaining,
      'goalAmount': goalAmount,
      'percentageUsed': percentageUsed,
    };
  }
}

class CategorySpending {
  final String category;
  final String emoji;
  final double amount;
  final double percentage;
  final int transactionCount;

  CategorySpending({
    required this.category,
    required this.emoji,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'emoji': emoji,
      'amount': amount,
      'percentage': percentage,
      'transactionCount': transactionCount,
    };
  }

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      category: json['category'] as String,
      emoji: json['emoji'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }
}

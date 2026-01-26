import '../local/hive_database.dart';
import '../models/goal.dart';
import '../../core/enums/period_type.dart';

class GoalRepository {
  GoalRepository._();

  static final GoalRepository instance = GoalRepository._();

  /// Get all goals
  List<Goal> getAll() {
    return HiveDatabase.goalBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get active goals
  List<Goal> getActive() {
    return HiveDatabase.goalBox.values.where((g) => g.isActive).toList();
  }

  /// Get goal by ID
  Goal? getById(String id) {
    try {
      return HiveDatabase.goalBox.values.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get goal by period type
  Goal? getByPeriod(PeriodType period) {
    try {
      return HiveDatabase.goalBox.values.firstWhere(
        (g) => g.periodType == period.name && g.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  /// Add new goal (deactivates existing goal for same period)
  Future<void> add(Goal goal) async {
    // Deactivate existing goal for the same period
    final existing = getByPeriod(goal.period);
    if (existing != null) {
      await update(existing.copyWith(isActive: false));
    }

    await HiveDatabase.goalBox.put(goal.id, goal);
  }

  /// Update goal
  Future<void> update(Goal goal) async {
    await HiveDatabase.goalBox.put(goal.id, goal);
  }

  /// Delete goal
  Future<void> delete(String id) async {
    await HiveDatabase.goalBox.delete(id);
  }

  /// Deactivate goal
  Future<void> deactivate(String id) async {
    final goal = getById(id);
    if (goal != null) {
      await update(goal.copyWith(isActive: false));
    }
  }

  /// Check if user has any active goal
  bool hasActiveGoal() {
    return HiveDatabase.goalBox.values.any((g) => g.isActive);
  }

  /// Get active goal for a specific period type
  double? getGoalAmount(PeriodType period) {
    final goal = getByPeriod(period);
    return goal?.amount;
  }

  /// Clear all goals
  Future<void> clearAll() async {
    await HiveDatabase.goalBox.clear();
  }
}

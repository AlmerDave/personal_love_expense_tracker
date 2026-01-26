import 'package:flutter/foundation.dart';
import '../data/models/goal.dart';
import '../data/repositories/goal_repository.dart';
import '../core/enums/period_type.dart';

class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveGoal => GoalRepository.instance.hasActiveGoal();

  // Initialize and load goals
  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = GoalRepository.instance.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add goal
  Future<bool> addGoal(Goal goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await GoalRepository.instance.add(goal);
      await loadGoals();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create and add goal
  Future<bool> createGoal({
    required PeriodType period,
    required double amount,
  }) async {
    final goal = Goal.create(period: period, amount: amount);
    return addGoal(goal);
  }

  // Update goal
  Future<bool> updateGoal(Goal goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await GoalRepository.instance.update(goal);
      await loadGoals();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete goal
  Future<bool> deleteGoal(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await GoalRepository.instance.delete(id);
      await loadGoals();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Deactivate goal
  Future<bool> deactivateGoal(String id) async {
    try {
      await GoalRepository.instance.deactivate(id);
      await loadGoals();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get goal by period
  Goal? getGoalByPeriod(PeriodType period) {
    return GoalRepository.instance.getByPeriod(period);
  }

  // Get goal amount by period
  double? getGoalAmount(PeriodType period) {
    return GoalRepository.instance.getGoalAmount(period);
  }

  // Clear all goals
  Future<void> clearAllGoals() async {
    await GoalRepository.instance.clearAll();
    await loadGoals();
  }
}

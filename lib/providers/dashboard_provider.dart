import 'package:flutter/foundation.dart';
import '../data/models/expense.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/goal_repository.dart';
import '../core/enums/period_type.dart';
import '../core/enums/budget_status.dart';
import '../core/utils/helpers.dart';
import '../core/utils/date_formatter.dart';
import '../services/insight_service.dart';

class DashboardProvider extends ChangeNotifier {
  PeriodType _selectedPeriod = PeriodType.biWeekly;
  double _totalSpent = 0;
  double? _goalAmount;
  double _percentageUsed = 0;
  int _daysRemaining = 0;
  String _periodLabel = '';
  BudgetStatus _budgetStatus = BudgetStatus.noGoal;
  String _quickInsight = '';
  List<Expense> _recentExpenses = [];
  bool _isLoading = false;
  bool _isLoadingInsight = false;
  String? _error;

  // Getters
  PeriodType get selectedPeriod => _selectedPeriod;
  double get totalSpent => _totalSpent;
  double? get goalAmount => _goalAmount;
  double get percentageUsed => _percentageUsed;
  int get daysRemaining => _daysRemaining;
  String get periodLabel => _periodLabel;
  BudgetStatus get budgetStatus => _budgetStatus;
  String get quickInsight => _quickInsight;
  List<Expense> get recentExpenses => _recentExpenses;
  bool get isLoading => _isLoading;
  bool get isLoadingInsight => _isLoadingInsight;
  String? get error => _error;

  // Initialize dashboard data
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _updateDashboardData();
      await _loadRecentExpenses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change selected period
  Future<void> setPeriod(PeriodType period) async {
    _selectedPeriod = period;
    await _updateDashboardData();
    notifyListeners();
  }

  // Refresh dashboard
  Future<void> refresh() async {
    await loadDashboard();
  }

  // Load quick insight
  Future<void> loadQuickInsight() async {
    _isLoadingInsight = true;
    notifyListeners();

    try {
      _quickInsight = await InsightService.instance.generateQuickInsight();
    } catch (e) {
      _quickInsight = "Tap to get AI-powered insights about your spending! ✨";
    } finally {
      _isLoadingInsight = false;
      notifyListeners();
    }
  }

  // Update dashboard data based on selected period
  Future<void> _updateDashboardData() async {
    final now = DateTime.now();
    
    // Get total spent for selected period
    _totalSpent = ExpenseRepository.instance.getTotalSpent(_selectedPeriod);
    
    // Get goal amount for selected period
    _goalAmount = GoalRepository.instance.getGoalAmount(_selectedPeriod);
    
    // Calculate percentage used
    if (_goalAmount != null && _goalAmount! > 0) {
      _percentageUsed = Helpers.calculatePercentage(_totalSpent, _goalAmount!);
      _budgetStatus = BudgetStatusExtension.fromPercentage(_percentageUsed);
    } else {
      _percentageUsed = 0;
      _budgetStatus = BudgetStatus.noGoal;
    }
    
    // Get days remaining
    _daysRemaining = Helpers.getDaysRemaining(_selectedPeriod);
    
    // Get period label
    _periodLabel = Helpers.getPeriodLabel(_selectedPeriod);
  }

  // Load recent expenses
  Future<void> _loadRecentExpenses() async {
    _recentExpenses = ExpenseRepository.instance.getRecent(limit: 5);
  }

  // Get formatted amount remaining
  String get amountRemaining {
    if (_goalAmount == null) return '—';
    final remaining = _goalAmount! - _totalSpent;
    if (remaining < 0) {
      return '-₱${(-remaining).toStringAsFixed(2)}';
    }
    return '₱${remaining.toStringAsFixed(2)}';
  }

  // Get daily budget for remaining days
  double? get dailyBudgetRemaining {
    if (_goalAmount == null || _daysRemaining <= 0) return null;
    final remaining = _goalAmount! - _totalSpent;
    if (remaining <= 0) return 0;
    return remaining / _daysRemaining;
  }
}

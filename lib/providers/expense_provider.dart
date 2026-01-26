import 'package:flutter/foundation.dart';
import '../data/models/expense.dart';
import '../data/repositories/expense_repository.dart';
import '../core/enums/period_type.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _categoryFilter;

  // Getters
  List<Expense> get expenses => _expenses;
  List<Expense> get filteredExpenses => _filteredExpenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;

  // Initialize and load expenses
  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = ExpenseRepository.instance.getAll();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add expense
  Future<bool> addExpense(Expense expense) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ExpenseRepository.instance.add(expense);
      await loadExpenses();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update expense
  Future<bool> updateExpense(Expense expense) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ExpenseRepository.instance.update(expense);
      await loadExpenses();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ExpenseRepository.instance.delete(id);
      await loadExpenses();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get expenses by period
  List<Expense> getExpensesByPeriod(PeriodType period, [DateTime? baseDate]) {
    return ExpenseRepository.instance.getByPeriod(period, baseDate);
  }

  // Get total spent by period
  double getTotalSpent(PeriodType period, [DateTime? baseDate]) {
    return ExpenseRepository.instance.getTotalSpent(period, baseDate);
  }

  // Get recent expenses
  List<Expense> getRecentExpenses({int limit = 5}) {
    return ExpenseRepository.instance.getRecent(limit: limit);
  }

  // Get expenses grouped by date
  Map<DateTime, List<Expense>> getGroupedExpenses() {
    return ExpenseRepository.instance.getGroupedByDate(_filteredExpenses);
  }

  // Search expenses
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredExpenses = _expenses;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _filteredExpenses = _filteredExpenses.where((e) {
        return e.merchant.toLowerCase().contains(query) ||
            e.categoryDisplayName.toLowerCase().contains(query) ||
            (e.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      _filteredExpenses = _filteredExpenses.where((e) {
        // Use categoryDisplayName since that's what we show in the UI
        return e.categoryDisplayName.toLowerCase() == _categoryFilter!.toLowerCase();
      }).toList();
    }
  }

  // Get category breakdown for current expenses
  Map<String, double> getCategoryBreakdown() {
    return ExpenseRepository.instance.getCategoryBreakdown(_expenses);
  }

  // Clear all expenses
  Future<void> clearAllExpenses() async {
    await ExpenseRepository.instance.clearAll();
    await loadExpenses();
  }

  // Export expenses
  List<Map<String, dynamic>> exportExpenses() {
    return ExpenseRepository.instance.exportToJson();
  }
}

import 'package:flutter/foundation.dart';
import '../data/models/insight_result.dart';
import '../services/insight_service.dart';
import '../core/utils/date_formatter.dart';

class InsightProvider extends ChangeNotifier {
  InsightResult? _insightResult;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // Getters
  InsightResult? get insightResult => _insightResult;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with current bi-weekly period
  void initializeDates() {
    final now = DateTime.now();
    final biWeekly = DateFormatter.getBiWeeklyPeriod(now);
    _startDate = biWeekly['start']!;
    _endDate = biWeekly['end']!;
    notifyListeners();
  }

  // Set date range
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  // Set to today
  void setToday() {
    final now = DateTime.now();
    _startDate = DateFormatter.startOfDay(now);
    _endDate = DateFormatter.endOfDay(now);
    notifyListeners();
  }

  // Set to current week
  void setCurrentWeek() {
    final now = DateTime.now();
    _startDate = DateFormatter.startOfWeek(now);
    _endDate = DateFormatter.endOfWeek(now);
    notifyListeners();
  }

  // Set to current bi-weekly
  void setCurrentBiWeekly() {
    final now = DateTime.now();
    final biWeekly = DateFormatter.getBiWeeklyPeriod(now);
    _startDate = biWeekly['start']!;
    _endDate = biWeekly['end']!;
    notifyListeners();
  }

  // Set to current month
  void setCurrentMonth() {
    final now = DateTime.now();
    _startDate = DateFormatter.startOfMonth(now);
    _endDate = DateFormatter.endOfMonth(now);
    notifyListeners();
  }

  // Generate insight
  Future<void> generateInsight() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _insightResult = await InsightService.instance.generateInsight(
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear insight
  void clearInsight() {
    _insightResult = null;
    _error = null;
    notifyListeners();
  }

  // Get formatted date range
  String get formattedDateRange {
    return DateFormatter.formatDateRange(_startDate, _endDate);
  }
}

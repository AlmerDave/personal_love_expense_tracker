import 'package:flutter/material.dart';
import 'route_names.dart';
import '../features/main/screens/main_screen.dart';
import '../features/expense_entry/screens/manual_entry_screen.dart';
import '../features/receipt_upload/screens/upload_screen.dart';
import '../features/receipt_upload/screens/processing_screen.dart';
import '../features/receipt_upload/screens/review_screen.dart';
import '../features/ai_insights/screens/period_selection_screen.dart';
import '../features/ai_insights/screens/insight_result_screen.dart';
import '../features/goals/screens/set_goal_screen.dart';
import '../features/transactions/screens/transaction_detail_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Main navigation - now using MainScreen
      case RouteNames.dashboard:
      case RouteNames.transactions:
      case RouteNames.goals:
        return _buildRoute(const MainScreen(), settings);

      // Expense entry
      case RouteNames.manualEntry:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ManualEntryScreen(
            initialAmount: args?['initialAmount'] as double?,
            isFromReceipt: args?['isFromReceipt'] as bool? ?? false,
          ),
          settings,
        );

      case RouteNames.receiptUpload:
        return _buildRoute(const UploadScreen(), settings);

      case RouteNames.receiptProcessing:
        final imagePath = settings.arguments as String;
        return _buildRoute(ProcessingScreen(imagePath: imagePath), settings);

      case RouteNames.receiptReview:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          ReviewScreen(
            extractedAmount: args['extractedAmount'] as double?,
            imagePath: args['imagePath'] as String?,
          ),
          settings,
        );

      // Insights
      case RouteNames.insightsPeriodSelection:
        return _buildRoute(const PeriodSelectionScreen(), settings);

      case RouteNames.insightsResult:
        return _buildRoute(const InsightResultScreen(), settings);

      // Goals
      case RouteNames.setGoal:
        return _buildRoute(const SetGoalScreen(), settings);

      case RouteNames.goalAmount:
        final periodType = settings.arguments as String;
        return _buildRoute(SetGoalScreen(initialPeriod: periodType), settings);

      // Transaction detail
      case RouteNames.transactionDetail:
        final expenseId = settings.arguments as String;
        return _buildRoute(
          TransactionDetailScreen(expenseId: expenseId),
          settings,
        );

      default:
        return _buildRoute(const MainScreen(), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
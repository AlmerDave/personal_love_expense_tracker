import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/local/hive_database.dart';
import 'providers/expense_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/insight_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for Flutter
  await Hive.initFlutter();
  
  // Initialize database and register adapters
  await HiveDatabase.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => InsightProvider()),
      ],
      child: const PesoPalApp(),
    ),
  );
}

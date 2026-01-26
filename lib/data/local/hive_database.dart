import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/goal.dart';
import '../models/category.dart';

class HiveDatabase {
  HiveDatabase._();

  static const String expenseBoxName = 'expenses';
  static const String goalBoxName = 'goals';
  static const String categoryBoxName = 'categories';
  static const String settingsBoxName = 'settings';

  static late Box<Expense> expenseBox;
  static late Box<Goal> goalBox;
  static late Box<Category> categoryBox;
  static late Box<dynamic> settingsBox;

  static Future<void> initialize() async {
    // Register adapters
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(CategoryAdapter());

    // Open boxes
    expenseBox = await Hive.openBox<Expense>(expenseBoxName);
    goalBox = await Hive.openBox<Goal>(goalBoxName);
    categoryBox = await Hive.openBox<Category>(categoryBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
  }

  static Future<void> clearAll() async {
    await expenseBox.clear();
    await goalBox.clear();
    await categoryBox.clear();
    await settingsBox.clear();
  }

  static Future<void> close() async {
    await expenseBox.close();
    await goalBox.close();
    await categoryBox.close();
    await settingsBox.close();
  }
}

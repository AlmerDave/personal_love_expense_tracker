import '../local/hive_database.dart';
import '../models/category.dart';
import '../../core/enums/category_type.dart';

class CategoryRepository {
  CategoryRepository._();

  static final CategoryRepository instance = CategoryRepository._();

  /// Get all custom categories
  List<Category> getCustomCategories() {
    return HiveDatabase.categoryBox.values.where((c) => c.isCustom).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get all categories (preset + custom)
  List<Map<String, dynamic>> getAllCategories() {
    final categories = <Map<String, dynamic>>[];

    // Add preset categories
    for (final type in CategoryType.values) {
      if (type != CategoryType.custom) {
        categories.add({
          'id': type.name,
          'name': type.label,
          'emoji': type.emoji,
          'isCustom': false,
          'backgroundColor': type.backgroundColor,
        });
      }
    }

    // Add custom categories
    for (final custom in getCustomCategories()) {
      categories.add({
        'id': custom.id,
        'name': custom.name,
        'emoji': custom.emoji,
        'isCustom': true,
        'backgroundColor': CategoryType.custom.backgroundColor,
      });
    }

    return categories;
  }

  /// Add custom category
  Future<void> addCustom(Category category) async {
    await HiveDatabase.categoryBox.put(category.id, category);
  }

  /// Delete custom category
  Future<void> deleteCustom(String id) async {
    await HiveDatabase.categoryBox.delete(id);
  }

  /// Check if category name exists
  bool categoryExists(String name) {
    // Check preset categories
    for (final type in CategoryType.values) {
      if (type.label.toLowerCase() == name.toLowerCase()) {
        return true;
      }
    }

    // Check custom categories
    return HiveDatabase.categoryBox.values
        .any((c) => c.name.toLowerCase() == name.toLowerCase());
  }

  /// Get category by ID
  Map<String, dynamic>? getCategoryById(String id) {
    // Check preset categories
    try {
      final type = CategoryType.values.firstWhere((t) => t.name == id);
      return {
        'id': type.name,
        'name': type.label,
        'emoji': type.emoji,
        'isCustom': false,
        'backgroundColor': type.backgroundColor,
      };
    } catch (_) {}

    // Check custom categories
    try {
      final custom =
          HiveDatabase.categoryBox.values.firstWhere((c) => c.id == id);
      return {
        'id': custom.id,
        'name': custom.name,
        'emoji': custom.emoji,
        'isCustom': true,
        'backgroundColor': CategoryType.custom.backgroundColor,
      };
    } catch (_) {
      return null;
    }
  }

  /// Clear all custom categories
  Future<void> clearAll() async {
    await HiveDatabase.categoryBox.clear();
  }
}

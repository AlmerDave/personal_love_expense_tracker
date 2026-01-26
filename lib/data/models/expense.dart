import 'package:hive/hive.dart';
import '../../core/enums/category_type.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String merchant;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String? customCategoryName;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final bool isFromReceipt;

  Expense({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.category,
    this.customCategoryName,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isFromReceipt = false,
  });

  /// Get CategoryType enum from string
  CategoryType get categoryType {
    if (category == 'custom' && customCategoryName != null) {
      return CategoryType.custom;
    }
    return CategoryTypeExtension.fromString(category);
  }

  /// Get display name for category
  String get categoryDisplayName {
    if (category == 'custom' && customCategoryName != null) {
      return customCategoryName!;
    }
    return categoryType.label;
  }

  /// Get emoji for category
  String get categoryEmoji {
    return categoryType.emoji;
  }

  /// Create a copy with updated fields
  Expense copyWith({
    String? id,
    double? amount,
    String? merchant,
    String? category,
    String? customCategoryName,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFromReceipt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      customCategoryName: customCategoryName ?? this.customCategoryName,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isFromReceipt: isFromReceipt ?? this.isFromReceipt,
    );
  }

  /// Create new expense
  factory Expense.create({
    required double amount,
    required String merchant,
    required String category,
    String? customCategoryName,
    required DateTime date,
    String? notes,
    bool isFromReceipt = false,
  }) {
    final now = DateTime.now();
    return Expense(
      id: '${now.millisecondsSinceEpoch}',
      amount: amount,
      merchant: merchant,
      category: category,
      customCategoryName: customCategoryName,
      date: date,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isFromReceipt: isFromReceipt,
    );
  }

  /// Convert to Map for JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'merchant': merchant,
      'category': category,
      'customCategoryName': customCategoryName,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFromReceipt': isFromReceipt,
    };
  }

  /// Create from Map
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      merchant: json['merchant'] as String,
      category: json['category'] as String,
      customCategoryName: json['customCategoryName'] as String?,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFromReceipt: json['isFromReceipt'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, amount: $amount, merchant: $merchant, category: $category, date: $date)';
  }
}

import 'package:hive/hive.dart';
import '../../core/enums/period_type.dart';

part 'goal.g.dart';

@HiveType(typeId: 1)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String periodType; // daily, weekly, biWeekly, monthly

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final bool isActive;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.periodType,
    required this.amount,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get PeriodType enum
  PeriodType get period {
    return PeriodTypeExtension.fromString(periodType);
  }

  /// Create a copy with updated fields
  Goal copyWith({
    String? id,
    String? periodType,
    double? amount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      periodType: periodType ?? this.periodType,
      amount: amount ?? this.amount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Create new goal
  factory Goal.create({
    required PeriodType period,
    required double amount,
  }) {
    final now = DateTime.now();
    return Goal(
      id: '${now.millisecondsSinceEpoch}',
      periodType: period.name,
      amount: amount,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Convert to Map for JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodType': periodType,
      'amount': amount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from Map
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      periodType: json['periodType'] as String,
      amount: (json['amount'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Goal(id: $id, periodType: $periodType, amount: $amount, isActive: $isActive)';
  }
}

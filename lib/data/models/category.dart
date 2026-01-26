import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String emoji;

  @HiveField(3)
  final bool isCustom;

  @HiveField(4)
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.emoji,
    this.isCustom = false,
    required this.createdAt,
  });

  /// Create a custom category
  factory Category.custom({
    required String name,
    String emoji = '📁',
  }) {
    final now = DateTime.now();
    return Category(
      id: 'custom_${now.millisecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      isCustom: true,
      createdAt: now,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from Map
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, emoji: $emoji, isCustom: $isCustom)';
  }
}

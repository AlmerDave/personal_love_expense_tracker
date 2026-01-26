import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CategoryType {
  foodAndDining,
  transportation,
  shopping,
  billsAndUtilities,
  entertainment,
  healthcare,
  personalCare,
  others,
  custom,
}

extension CategoryTypeExtension on CategoryType {
  String get label {
    switch (this) {
      case CategoryType.foodAndDining:
        return 'Food & Dining';
      case CategoryType.transportation:
        return 'Transportation';
      case CategoryType.shopping:
        return 'Shopping';
      case CategoryType.billsAndUtilities:
        return 'Bills & Utilities';
      case CategoryType.entertainment:
        return 'Entertainment';
      case CategoryType.healthcare:
        return 'Healthcare';
      case CategoryType.personalCare:
        return 'Personal Care';
      case CategoryType.others:
        return 'Others';
      case CategoryType.custom:
        return 'Custom';
    }
  }

  String get emoji {
    switch (this) {
      case CategoryType.foodAndDining:
        return '🍔';
      case CategoryType.transportation:
        return '🚗';
      case CategoryType.shopping:
        return '🛍️';
      case CategoryType.billsAndUtilities:
        return '⚡';
      case CategoryType.entertainment:
        return '🎬';
      case CategoryType.healthcare:
        return '💊';
      case CategoryType.personalCare:
        return '💄';
      case CategoryType.others:
        return '📦';
      case CategoryType.custom:
        return '➕';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case CategoryType.foodAndDining:
        return AppColors.categoryFood;
      case CategoryType.transportation:
        return AppColors.categoryTransport;
      case CategoryType.shopping:
        return AppColors.categoryShopping;
      case CategoryType.billsAndUtilities:
        return AppColors.categoryBills;
      case CategoryType.entertainment:
        return AppColors.categoryEntertainment;
      case CategoryType.healthcare:
        return AppColors.categoryHealthcare;
      case CategoryType.personalCare:
        return AppColors.categoryPersonalCare;
      case CategoryType.others:
        return AppColors.categoryOthers;
      case CategoryType.custom:
        return AppColors.primarySoft;
    }
  }

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => CategoryType.others,
    );
  }
}

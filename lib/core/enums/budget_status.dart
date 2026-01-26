import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum BudgetStatus {
  onTrack,
  caution,
  overBudget,
  noGoal,
}

extension BudgetStatusExtension on BudgetStatus {
  String get label {
    switch (this) {
      case BudgetStatus.onTrack:
        return 'On Track';
      case BudgetStatus.caution:
        return 'Approaching Limit';
      case BudgetStatus.overBudget:
        return 'Over Budget';
      case BudgetStatus.noGoal:
        return 'No Goal Set';
    }
  }

  Color get color {
    switch (this) {
      case BudgetStatus.onTrack:
        return AppColors.success;
      case BudgetStatus.caution:
        return AppColors.warning;
      case BudgetStatus.overBudget:
        return AppColors.danger;
      case BudgetStatus.noGoal:
        return AppColors.textMuted;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case BudgetStatus.onTrack:
        return AppColors.successLight;
      case BudgetStatus.caution:
        return AppColors.warningLight;
      case BudgetStatus.overBudget:
        return AppColors.dangerLight;
      case BudgetStatus.noGoal:
        return AppColors.bgSoft;
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case BudgetStatus.onTrack:
        return AppColors.successGradient;
      case BudgetStatus.caution:
        return AppColors.warningGradient;
      case BudgetStatus.overBudget:
        return AppColors.dangerGradient;
      case BudgetStatus.noGoal:
        return const LinearGradient(
          colors: [AppColors.textMuted, AppColors.textMuted],
        );
    }
  }

  String get emoji {
    switch (this) {
      case BudgetStatus.onTrack:
        return '🎉';
      case BudgetStatus.caution:
        return '⚠️';
      case BudgetStatus.overBudget:
        return '🚨';
      case BudgetStatus.noGoal:
        return '🎯';
    }
  }

  static BudgetStatus fromPercentage(double percentage) {
    if (percentage < 70) {
      return BudgetStatus.onTrack;
    } else if (percentage < 100) {
      return BudgetStatus.caution;
    } else {
      return BudgetStatus.overBudget;
    }
  }
}

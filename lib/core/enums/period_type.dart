enum PeriodType {
  daily,
  weekly,
  biWeekly,
  monthly,
}

extension PeriodTypeExtension on PeriodType {
  String get label {
    switch (this) {
      case PeriodType.daily:
        return 'Daily';
      case PeriodType.weekly:
        return 'Weekly';
      case PeriodType.biWeekly:
        return 'Bi-Weekly';
      case PeriodType.monthly:
        return 'Monthly';
    }
  }

  String get description {
    switch (this) {
      case PeriodType.daily:
        return 'Daily spending cap';
      case PeriodType.weekly:
        return '7-day spending budget';
      case PeriodType.biWeekly:
        return 'Based on your salary cutoff (1-15 or 16-31)';
      case PeriodType.monthly:
        return 'Full month budget';
    }
  }

  String get emoji {
    switch (this) {
      case PeriodType.daily:
        return '📅';
      case PeriodType.weekly:
        return '📆';
      case PeriodType.biWeekly:
        return '💰';
      case PeriodType.monthly:
        return '🗓️';
    }
  }

  static PeriodType fromString(String value) {
    return PeriodType.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => PeriodType.biWeekly,
    );
  }
}

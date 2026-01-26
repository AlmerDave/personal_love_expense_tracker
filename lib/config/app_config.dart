class AppConfig {
  AppConfig._();

  // App Information
  static const String appName = 'PesoPal';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your friendly peso tracker';

  // Currency
  static const String currencySymbol = '₱';
  static const String currencyCode = 'PHP';
  static const String currencyName = 'Philippine Peso';

  // Default Settings
  static const String defaultPeriodType = 'biWeekly';
  static const int recentTransactionsLimit = 5;

  // Goal Suggestions (in PHP)
  static const List<double> goalSuggestions = [
    10000,
    15000,
    20000,
    25000,
    30000,
    40000,
  ];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Success dialog auto-dismiss
  static const Duration successDialogDuration = Duration(seconds: 2);

  // Date Format
  static const String dateFormat = 'MMMM dd, yyyy';
  static const String shortDateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'h:mm a';
}

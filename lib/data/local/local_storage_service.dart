import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Keys
  static const String keyDefaultPeriod = 'default_period';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyLastSyncDate = 'last_sync_date';

  // Default Period
  static Future<void> setDefaultPeriod(String period) async {
    await prefs.setString(keyDefaultPeriod, period);
  }

  static String getDefaultPeriod() {
    return prefs.getString(keyDefaultPeriod) ?? 'biWeekly';
  }

  // First Launch
  static Future<void> setFirstLaunch(bool value) async {
    await prefs.setBool(keyFirstLaunch, value);
  }

  static bool isFirstLaunch() {
    return prefs.getBool(keyFirstLaunch) ?? true;
  }

  // Last Sync Date
  static Future<void> setLastSyncDate(DateTime date) async {
    await prefs.setString(keyLastSyncDate, date.toIso8601String());
  }

  static DateTime? getLastSyncDate() {
    final dateStr = prefs.getString(keyLastSyncDate);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  // Clear all
  static Future<void> clearAll() async {
    await prefs.clear();
  }
}

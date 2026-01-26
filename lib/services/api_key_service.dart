import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static const String _apiKeyKey = 'gemini_api_key';
  static ApiKeyService? _instance;
  static SharedPreferences? _prefs;

  ApiKeyService._();

  static Future<ApiKeyService> getInstance() async {
    _instance ??= ApiKeyService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Save API key to local storage
  Future<bool> saveApiKey(String apiKey) async {
    try {
      return await _prefs!.setString(_apiKeyKey, apiKey);
    } catch (e) {
      return false;
    }
  }

  // Get API key from local storage
  Future<String?> getApiKey() async {
    try {
      return _prefs!.getString(_apiKeyKey);
    } catch (e) {
      return null;
    }
  }

  // Remove API key from local storage
  Future<bool> removeApiKey() async {
    try {
      return await _prefs!.remove(_apiKeyKey);
    } catch (e) {
      return false;
    }
  }

  // Check if API key exists
  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  // Validate API key format (basic validation)
  bool isValidApiKey(String apiKey) {
    // Basic validation - Gemini API keys typically start with 'AIza' and are 39 characters
    return apiKey.length >= 20 && 
           apiKey.startsWith('AIza') && 
           RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(apiKey);
  }
}
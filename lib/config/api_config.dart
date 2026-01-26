import '../services/api_key_service.dart';

class ApiConfig {
  ApiConfig._();

  // Gemini API Configuration
  static String? _cachedApiKey;
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-2.5-flash-lite';

  // Get API key from storage
  static Future<String?> get geminiApiKey async {
    if (_cachedApiKey != null) return _cachedApiKey;
    
    final apiKeyService = await ApiKeyService.getInstance();
    _cachedApiKey = await apiKeyService.getApiKey();
    return _cachedApiKey;
  }

  // Update cached API key when changed
  static void updateCachedApiKey(String apiKey) {
    _cachedApiKey = apiKey;
  }

  // Clear cached API key
  static void clearCachedApiKey() {
    _cachedApiKey = null;
  }

  // API Endpoints - now async
  static Future<String?> get geminiGenerateContent async {
    final apiKey = await geminiApiKey;
    if (apiKey == null) return null;
    return '$geminiBaseUrl/models/$geminiModel:generateContent?key=$apiKey';
  }

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Receipt scanning settings
  static const int maxReceiptImageSize = 4 * 1024 * 1024; // 4MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
}
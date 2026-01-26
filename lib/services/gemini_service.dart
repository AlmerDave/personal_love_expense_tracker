import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'dart:developer' as developer;

class GeminiService {
  GeminiService._();

  static final GeminiService instance = GeminiService._();

  /// Generate content from Gemini API
  Future<String> generateContent(String prompt) async {
    try {
      final url = await ApiConfig.geminiGenerateContent;
      if (url == null) {
        throw Exception('API key not configured');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log('🔍 Full API Response: ${response.body}');

        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? 'Unable to generate response';
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Gemini API: $e');
    }
  }

  /// Extract total amount from receipt image
  Future<double?> extractReceiptTotal(String base64Image) async {
    try {
      final url = await ApiConfig.geminiGenerateContent;
      if (url == null) {
        throw Exception('API key not configured');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Analyze this receipt image and extract the total amount due.

Instructions:
- Look for these exact phrases: "TOTAL DUE", "TOTAL", "GRAND TOTAL", "AMOUNT DUE", "SUBTOTAL", or "BALANCE DUE"
- The total amount is usually the final amount the customer needs to pay (before payment method)
- Check both the middle and bottom sections of the receipt
- Ignore payment details like "CASH", "CHANGE", "CREDIT CARD" - focus on the amount owed
- Look for the number that appears after the total label (may be on same line or next line)
- Include decimal values (e.g., if you see "165.71", return "165.71")

Format requirements:
- Return ONLY the numeric value with decimal point if present
- Do NOT include currency symbols (₱, etc.)
- Do NOT include commas or other formatting
- If no clear total is found, respond with "NOT_FOUND"

Examples:
- If receipt shows "TOTAL DUE 165.71" → return: 165.71
- If receipt shows "AMOUNT DUE ₱1,234.50" → return: 1234.50

Response: Just the number, nothing else.'''
                },
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 50,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (text == null || text.trim() == 'NOT_FOUND') {
          return null;
        }

        // Parse the extracted amount
        final cleanedText = text.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleanedText);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to extract receipt total: $e');
    }
  }

  /// Generate spending insights
  Future<String> generateSpendingInsight({
    required double totalSpent,
    required Map<String, double> categoryBreakdown,
    required int daysInPeriod,
    required int daysRemaining,
    double? goalAmount,
    double? previousPeriodTotal,
  }) async {
    final categoryList = categoryBreakdown.entries
        .map((e) => '- ${e.key}: ₱${e.value.toStringAsFixed(2)}')
        .join('\n');

    final goalInfo = goalAmount != null
        ? 'Budget Goal: ₱${goalAmount.toStringAsFixed(2)}'
        : 'No budget goal set';

    final comparisonInfo = previousPeriodTotal != null
        ? 'Previous period total: ₱${previousPeriodTotal.toStringAsFixed(2)}'
        : '';

    final percentUsed = goalAmount != null && goalAmount > 0
        ? ((totalSpent / goalAmount) * 100).toStringAsFixed(1)
        : 'N/A';

    final prompt = '''You are PesoPal, a friendly and encouraging Filipino personal finance buddy. Analyze this spending data and provide a helpful, conversational insight.

SPENDING DATA:
- Total Spent: ₱${totalSpent.toStringAsFixed(2)}
- $goalInfo
- Budget Used: $percentUsed%
- Days in Period: $daysInPeriod
- Days Remaining: $daysRemaining
$comparisonInfo

CATEGORY BREAKDOWN:
$categoryList

INSTRUCTIONS:
1. Write in a friendly, supportive tone like a caring friend
2. Use Filipino-English mix naturally (Taglish is okay but keep it professional)
3. Start with an observation about their spending
4. Highlight the top spending category and provide gentle advice
5. If they're over budget, be encouraging not judgmental
6. If they're under budget, celebrate their progress
7. End with one actionable tip
8. Keep response under 150 words
9. Use 1-2 relevant emojis naturally

Write as a single flowing narrative paragraph, not bullet points.''';

    return generateContent(prompt);
  }
}
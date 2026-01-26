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
                  'text': '''Extract the final amount the customer needs to pay from this receipt image.

WHAT TO LOOK FOR:
- The amount that appears with labels like: "TOTAL DUE", "TOTAL", "AMOUNT DUE", "GRAND TOTAL", "BALANCE DUE", "SUBTOTAL"
- In Filipino receipts, look for: "KABUUAN", "BAYAD", "TOTAL"
- The final payable amount (usually the largest prominent number before payment details)
- Numbers that appear in the bottom half of the receipt near payment information

SCANNING STRATEGY:
1. First, look for any text containing "TOTAL" or "DUE" 
2. Then look for the largest monetary amount in the lower portion
3. Check for numbers near payment sections (before CASH, CHANGE, CREDIT details)
4. Consider amounts that appear emphasized or in larger text

WHAT TO IGNORE:
- Individual item prices in the itemized list
- Change amounts
- Cash tendered amounts  
- Tax components (unless it's the final total including tax)
- Discount amounts

FORMAT RULES:
- Return only the numeric value with decimal point
- Remove currency symbols (₱, etc.)
- Remove commas and spaces from numbers
- If multiple candidates exist, choose the one closest to payment section
- If genuinely unclear, return "UNCLEAR"

Be flexible and use context clues. The goal is to find what a human would naturally identify as "the amount to pay".

Return only the number (e.g., 165.71 or 184.00).'''
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
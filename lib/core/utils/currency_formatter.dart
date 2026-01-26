import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _pesoFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  static final NumberFormat _pesoFormatNoDecimal = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'en_PH');

  /// Format amount with peso symbol (₱12,450.00)
  static String format(double amount) {
    return _pesoFormat.format(amount);
  }

  /// Format amount with peso symbol, no decimals (₱12,450)
  static String formatNoDecimal(double amount) {
    return _pesoFormatNoDecimal.format(amount);
  }

  /// Format amount without peso symbol (12,450.00)
  static String formatNumber(double amount) {
    return _numberFormat.format(amount);
  }

  /// Parse string to double (handles comma and peso symbol)
  static double parse(String value) {
    String cleaned = value
        .replaceAll('₱', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Format for input display (without peso symbol for editing)
  static String formatForInput(double amount) {
    if (amount == 0) return '';
    return _numberFormat.format(amount);
  }

  /// Get peso symbol
  static String get pesoSymbol => '₱';

  /// Format compact (₱12.4K)
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '₱${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₱${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}

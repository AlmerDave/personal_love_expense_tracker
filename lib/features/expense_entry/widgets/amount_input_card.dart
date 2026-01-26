import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/utils/currency_formatter.dart';

class AmountInputCard extends StatefulWidget {
  final double initialAmount;
  final Function(double) onAmountChanged;

  const AmountInputCard({
    super.key,
    this.initialAmount = 0,
    required this.onAmountChanged,
  });

  @override
  State<AmountInputCard> createState() => _AmountInputCardState();
}

class _AmountInputCardState extends State<AmountInputCard> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialAmount > 0
          ? widget.initialAmount.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    final cleanValue = value.replaceAll(',', '');
    final amount = double.tryParse(cleanValue) ?? 0;
    widget.onAmountChanged(amount);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: AppRadius.largeRadius,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.logoGradient,
                borderRadius: AppRadius.mediumRadius,
              ),
              child: const Center(
                child: Text('💰', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 16),

            // Amount input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₱',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 4),
                IntrinsicWidth(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: AppTypography.display,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: AppTypography.display.copyWith(
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      _DecimalTextInputFormatter(),
                    ],
                    onChanged: _onAmountChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Hint text
            Text(
              'Tap to enter amount',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only allow one decimal point
    if (newValue.text.split('.').length > 2) {
      return oldValue;
    }

    // Limit to 2 decimal places
    if (newValue.text.contains('.')) {
      final parts = newValue.text.split('.');
      if (parts[1].length > 2) {
        return oldValue;
      }
    }

    // Limit total length
    if (newValue.text.replaceAll('.', '').length > 9) {
      return oldValue;
    }

    return newValue;
  }
}

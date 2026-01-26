import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/enums/period_type.dart';

class PeriodTabSelector extends StatelessWidget {
  final PeriodType selectedPeriod;
  final Function(PeriodType) onPeriodChanged;
  final bool isLight;

  const PeriodTabSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PeriodType.values.map((period) {
          final isSelected = selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onPeriodChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isLight ? Colors.white : AppColors.primary)
                      : (isLight
                          ? Colors.white.withOpacity(0.15)
                          : AppColors.bgSoft),
                  borderRadius: AppRadius.fullRadius,
                  border: !isLight && !isSelected
                      ? Border.all(color: AppColors.border)
                      : null,
                ),
                child: Text(
                  period.label,
                  style: AppTypography.caption.copyWith(
                    color: isSelected
                        ? (isLight ? AppColors.primary : Colors.white)
                        : (isLight ? Colors.white : AppColors.textSecondary),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

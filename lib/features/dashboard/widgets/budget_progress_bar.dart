import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/enums/budget_status.dart';

class BudgetProgressBar extends StatelessWidget {
  final double percentage;
  final double height;
  final bool isWhiteBackground;

  const BudgetProgressBar({
    super.key,
    required this.percentage,
    this.height = 8,
    this.isWhiteBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = percentage.clamp(0.0, 100.0);
    final status = BudgetStatusExtension.fromPercentage(percentage);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isWhiteBackground
            ? Colors.white.withOpacity(0.2)
            : AppColors.bgSoft,
        borderRadius: AppRadius.fullRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * (clampedPercentage / 100),
                height: height,
                decoration: BoxDecoration(
                  gradient: status.gradient,
                  borderRadius: AppRadius.fullRadius,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

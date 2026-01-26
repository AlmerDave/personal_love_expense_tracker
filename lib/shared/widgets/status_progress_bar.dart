import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/enums/budget_status.dart';

class StatusProgressBar extends StatelessWidget {
  final double percentage;
  final double height;
  final bool showGradient;
  final Color? backgroundColor;

  const StatusProgressBar({
    super.key,
    required this.percentage,
    this.height = 8,
    this.showGradient = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = percentage.clamp(0.0, 100.0);
    final status = BudgetStatusExtension.fromPercentage(percentage);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.2),
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
                  gradient: showGradient ? status.gradient : null,
                  color: showGradient ? null : status.color,
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

class StatusProgressBarLight extends StatelessWidget {
  final double percentage;
  final double height;

  const StatusProgressBarLight({
    super.key,
    required this.percentage,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = percentage.clamp(0.0, 100.0);
    final status = BudgetStatusExtension.fromPercentage(percentage);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
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
                  color: status.color,
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

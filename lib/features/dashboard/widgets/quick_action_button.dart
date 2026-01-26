import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_shadows.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String label;
  final String sublabel;
  final bool isPrimary;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : AppColors.bgCard,
          borderRadius: AppRadius.largeRadius,
          border: isPrimary ? null : Border.all(color: AppColors.border, width: 2),
          boxShadow: isPrimary ? AppShadows.medium : AppShadows.soft,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primarySoft,
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Label
            Text(
              label,
              style: AppTypography.bodyBold.copyWith(
                color: isPrimary ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // Sublabel
            Text(
              sublabel,
              style: AppTypography.small.copyWith(
                color: isPrimary
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import 'primary_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji with background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              title,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              description,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            // Button
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: buttonLabel!,
                onPressed: onButtonPressed,
                isFullWidth: false,
                icon: Icons.add_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

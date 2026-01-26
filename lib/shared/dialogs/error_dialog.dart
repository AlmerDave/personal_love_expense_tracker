import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../widgets/primary_button.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onPressed;

  const ErrorDialog({
    super.key,
    this.title = 'Oops!',
    required this.message,
    this.buttonLabel = 'Got it',
    this.onPressed,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Oops!',
    required String message,
    String buttonLabel = 'Got it',
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        buttonLabel: buttonLabel,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Button
            PrimaryButton(
              label: buttonLabel,
              height: 48,
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

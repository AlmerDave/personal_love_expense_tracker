import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Delete',
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: () => Navigator.of(context).pop(true),
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
            // Warning icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
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

            // Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    height: 48,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SecondaryButton(
                    label: confirmLabel,
                    height: 48,
                    isDanger: true,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

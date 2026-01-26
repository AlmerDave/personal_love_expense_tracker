import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_shadows.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed != null && !isLoading
            ? AppColors.primaryGradient
            : null,
        color: onPressed == null || isLoading
            ? AppColors.primary.withOpacity(0.5)
            : null,
        borderRadius: AppRadius.mediumRadius,
        boxShadow: onPressed != null && !isLoading ? AppShadows.medium : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.mediumRadius,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTypography.button,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

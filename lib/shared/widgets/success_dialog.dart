import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../config/app_config.dart';

class SuccessDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onDismiss;
  final bool autoDismiss;

  const SuccessDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.onDismiss,
    this.autoDismiss = true,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    VoidCallback? onDismiss,
    bool autoDismiss = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => SuccessDialog(
        title: title,
        subtitle: subtitle,
        onDismiss: onDismiss,
        autoDismiss: autoDismiss,
      ),
    );
  }

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    if (widget.autoDismiss) {
      Future.delayed(AppConfig.successDialogDuration, () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onDismiss?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated checkmark
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.successGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: _checkAnimation.value,
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    widget.title,
                    style: AppTypography.h2,
                    textAlign: TextAlign.center,
                  ),

                  // Subtitle
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle!,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

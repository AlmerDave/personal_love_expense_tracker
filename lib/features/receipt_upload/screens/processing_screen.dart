import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/receipt_scanner_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/dialogs/error_dialog.dart';
import '../../../navigation/route_names.dart';
import 'package:image_picker/image_picker.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;

  const ProcessingScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  String _statusText = 'Preparing image...';
  int _currentStep = 0;

  final List<String> _steps = [
    'Preparing image...',
    'Uploading to AI...',
    'Analyzing receipt...',
    'Extracting total...',
    'Almost done...',
  ];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 0.9).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _progressController.addListener(() {
      final progress = _progressAnimation.value;
      final step = (progress * _steps.length).floor().clamp(0, _steps.length - 1);
      if (step != _currentStep) {
        setState(() {
          _currentStep = step;
          _statusText = _steps[step];
        });
      }
    });

    _progressController.forward();
    _processReceipt();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _processReceipt() async {
    try {
      final result = await ReceiptScannerService.instance.processReceipt(
        XFile(widget.imagePath),
      );

      if (!mounted) return;

      // Complete the progress
      _progressController.animateTo(1.0, duration: const Duration(milliseconds: 300));
      await Future.delayed(const Duration(milliseconds: 400));

      if (result.success) {
        Navigator.pushReplacementNamed(
          context,
          RouteNames.receiptReview,
          arguments: {
            'extractedAmount': result.extractedAmount,
            'imagePath': widget.imagePath,
          },
        );
      } else {
        // Show error and go to manual entry with image
        await ErrorDialog.show(
          context,
          title: 'Could not extract amount',
          message: result.errorMessage ?? 'Please enter the amount manually.',
        );

        Navigator.pushReplacementNamed(
          context,
          RouteNames.receiptReview,
          arguments: {
            'extractedAmount': null,
            'imagePath': widget.imagePath,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;

      await ErrorDialog.show(
        context,
        message: 'Failed to process receipt. Please try again.',
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: CustomAppBar(
        title: 'Processing...',
        showBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon placeholder (for future Lottie)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating circle
                      Transform.rotate(
                        angle: _progressController.value * 6.28,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Icon
                      const Text('🔍', style: TextStyle(fontSize: 40)),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 40),

            // Progress bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    // Progress percentage
                    Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: AppTypography.h1.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Progress bar
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.bgSoft,
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppRadius.fullRadius,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Status text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _statusText,
                key: ValueKey(_statusText),
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // Sub text
            Text(
              '✨ Our AI is finding the total amount for you!',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

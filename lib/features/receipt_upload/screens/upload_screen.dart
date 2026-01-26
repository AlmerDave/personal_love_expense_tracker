import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/receipt_scanner_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/dialogs/error_dialog.dart';
import '../../../navigation/route_names.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isCheckingConnection = false;

  Future<void> _pickFromGallery() async {
    setState(() => _isCheckingConnection = true);

    final hasConnection =
        await ConnectivityService.instance.hasInternetConnection();

    setState(() => _isCheckingConnection = false);

    if (!hasConnection) {
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'No Connection',
          message:
              'Internet connection is required to scan receipts. Please connect and try again.',
        );
      }
      return;
    }

    try {
      final image = await ReceiptScannerService.instance.pickFromGallery();

      if (image != null && mounted) {
        Navigator.pushNamed(
          context,
          RouteNames.receiptProcessing,
          arguments: image.path,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(
          context,
          message: 'Failed to select image. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: const CustomAppBar(title: 'Scan Receipt'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            const Spacer(),

            // Illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: AppRadius.extraLargeRadius,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📷', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 8,
                          width: 60,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withOpacity(0.3),
                            borderRadius: AppRadius.smallRadius,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 8,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withOpacity(0.3),
                            borderRadius: AppRadius.smallRadius,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₱',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              height: 8,
                              width: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.3),
                                borderRadius: AppRadius.smallRadius,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Description
            Text(
              'Upload a photo of your receipt',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "and we'll extract the total for you automatically!",
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Button
            PrimaryButton(
              label: '📷  Choose from Gallery',
              onPressed: _isCheckingConnection ? null : _pickFromGallery,
              isLoading: _isCheckingConnection,
            ),
            const SizedBox(height: 24),

            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: AppRadius.smallRadius,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_rounded,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Requires internet connection',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
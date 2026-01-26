import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../navigation/route_names.dart';

class QuickInsightCard extends StatelessWidget {
  const QuickInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, RouteNames.insightsPeriodSelection),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: AppRadius.largeRadius,
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primarySoft,
                        AppColors.bgSoft,
                      ],
                    ),
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/financial-coach.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to emoji if image fails to load
                        return const Text('🤖', style: TextStyle(fontSize: 24));
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Today's Insight",
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('✨', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Insight text or loading
                      if (provider.isLoadingInsight)
                        _buildLoadingState()
                      else
                        Text(
                          provider.quickInsight.isEmpty
                              ? 'Tap to get AI-powered insights! ✨'
                              : provider.quickInsight,
                          style: AppTypography.body,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 8),

                      // Tap for more
                      Row(
                        children: [
                          Text(
                            'Tap for more',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Analyzing your spending...',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

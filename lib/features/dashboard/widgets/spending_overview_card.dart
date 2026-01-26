import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/enums/period_type.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../shared/widgets/status_progress_bar.dart';

class SpendingOverviewCard extends StatelessWidget {
  const SpendingOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.largeRadius,
            boxShadow: AppShadows.large,
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    'Total Spent',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Amount
                  Text(
                    CurrencyFormatter.format(provider.totalSpent),
                    style: AppTypography.displayWhite,
                  ),
                  const SizedBox(height: 4),

                  // Period label
                  Text(
                    provider.periodLabel,
                    style: AppTypography.small.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Period tabs
                  _buildPeriodTabs(context, provider),
                  const SizedBox(height: 20),

                  // Budget progress
                  if (provider.goalAmount != null) ...[
                    _buildBudgetProgress(provider),
                  ] else ...[
                    _buildNoGoalPrompt(),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodTabs(BuildContext context, DashboardProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PeriodType.values.map((period) {
          final isSelected = provider.selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _PeriodTab(
              label: period.label,
              isSelected: isSelected,
              onTap: () => provider.setPeriod(period),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetProgress(DashboardProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${CurrencyFormatter.formatNoDecimal(provider.totalSpent)} of ${CurrencyFormatter.formatNoDecimal(provider.goalAmount!)}',
              style: AppTypography.small.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              '${provider.percentageUsed.toStringAsFixed(0)}%',
              style: AppTypography.small.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StatusProgressBar(
          percentage: provider.percentageUsed,
          height: 8,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${provider.daysRemaining} days left',
              style: AppTypography.small.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              provider.amountRemaining.contains('-')
                  ? 'Over by ${provider.amountRemaining.replaceAll('-', '')}'
                  : '${provider.amountRemaining} remaining',
              style: AppTypography.small.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoGoalPrompt() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Set a budget goal to track your progress!',
              style: AppTypography.small.copyWith(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: AppRadius.fullRadius,
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

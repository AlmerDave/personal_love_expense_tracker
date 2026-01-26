import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/insight_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/status_progress_bar.dart';

class InsightResultScreen extends StatefulWidget {
  const InsightResultScreen({super.key});

  @override
  State<InsightResultScreen> createState() => _InsightResultScreenState();
}

class _InsightResultScreenState extends State<InsightResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightProvider>().generateInsight();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: const CustomAppBar(title: 'AI Insights'),
      body: Consumer<InsightProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!, provider);
          }

          final result = provider.insightResult;
          if (result == null) {
            return _buildLoadingState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodHeader(provider),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildNarrativePanel(result.narrative, result.totalSpent),
                const SizedBox(height: AppSpacing.sectionGap),
                if (result.categoryBreakdown.isNotEmpty) ...[
                  _buildCategoryBreakdown(result),
                  const SizedBox(height: AppSpacing.sectionGap),
                ],
                if (result.dailyBudgetRemaining != null &&
                    result.daysRemaining > 0) ...[
                  _buildDailyBudgetCard(result),
                  const SizedBox(height: AppSpacing.sectionGap),
                ],
                SecondaryButton(
                  label: '🔄  Analyze Again',
                  onPressed: () => provider.generateInsight(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/financial-coach.png',
                width: 70,
                height: 70,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to emoji if image fails to load
                  return const Text('🤖', style: TextStyle(fontSize: 40));
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing your spending...',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, InsightProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Unable to generate insights', style: AppTypography.h2),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Try Again',
              onPressed: () => provider.generateInsight(),
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodHeader(InsightProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analysis Period', style: AppTypography.caption),
              Text(provider.formattedDateRange, style: AppTypography.bodyBold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNarrativePanel(String narrative, double totalSpent) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Center(
                    child: Image.asset(
                      'assets/images/financial-coach.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to emoji if image fails to load
                        return const Text('🤖', style: TextStyle(fontSize: 20));
                      },
                    )
                  ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Financial AI', style: AppTypography.bodyBold.copyWith(color: AppColors.primary)),
                  Text('✨ Your spending analysis', style: AppTypography.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Row(
              children: [
                const Text('💰', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Spent', style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.9))),
                    Text(CurrencyFormatter.format(totalSpent), style: AppTypography.h1.copyWith(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(narrative, style: AppTypography.body.copyWith(height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(result) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('Category Breakdown', style: AppTypography.h3),
            ],
          ),
          const SizedBox(height: 16),
          ...result.categoryBreakdown.take(5).map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryItem(cat.emoji, cat.category, cat.amount, cat.percentage),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String emoji, String name, double amount, double percentage) {
    return Column(
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: AppTypography.body)),
            Text(CurrencyFormatter.format(amount), style: AppTypography.bodyBold),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: StatusProgressBarLight(percentage: percentage, height: 6)),
            const SizedBox(width: 8),
            Text('${percentage.toStringAsFixed(0)}%', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyBudgetCard(result) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Budget Suggestion', style: AppTypography.caption.copyWith(color: AppColors.success)),
                const SizedBox(height: 4),
                Text(
                  '${CurrencyFormatter.format(result.dailyBudgetRemaining!)}/day for ${result.daysRemaining} days',
                  style: AppTypography.bodyBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

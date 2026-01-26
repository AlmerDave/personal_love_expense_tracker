import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/enums/period_type.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/goal.dart';
import '../../../providers/goal_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/status_progress_bar.dart';
import '../../../navigation/route_names.dart';

class GoalListScreen extends StatefulWidget {
  const GoalListScreen({super.key});

  @override
  State<GoalListScreen> createState() => _GoalListScreenState();
}

class _GoalListScreenState extends State<GoalListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GoalProvider>().loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: CustomAppBar(
        title: 'Goals',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => Navigator.pushNamed(context, RouteNames.setGoal),
          ),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeGoals = provider.activeGoals;

          if (activeGoals.isEmpty) {
            return EmptyStateWidget(
              emoji: '🎯',
              title: 'Set your first goal!',
              description: 'Goals help you stay on track and save more each month',
              buttonLabel: 'Set a Goal',
              onButtonPressed: () => Navigator.pushNamed(context, RouteNames.setGoal),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBanner(),
                const SizedBox(height: AppSpacing.sectionGap),
                Text('Active Goals', style: AppTypography.h3),
                const SizedBox(height: 12),
                ...activeGoals.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalCard(goal: goal),
                    )),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildAddGoalButton(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, RouteNames.dashboard);
          if (index == 1) Navigator.pushReplacementNamed(context, RouteNames.transactions);
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Setting goals helps you stay on track and save more!',
              style: AppTypography.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddGoalButton() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteNames.setGoal),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Add Another Goal',
              style: AppTypography.bodyBold.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.read<ExpenseProvider>();
    final spent = expenseProvider.getTotalSpent(goal.period);
    final percentage = goal.amount > 0 ? (spent / goal.amount) * 100 : 0.0;
    final remaining = goal.amount - spent;

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
              Text(goal.period.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.period.label, style: AppTypography.bodyBold),
                    Text(goal.period.description, style: AppTypography.caption),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20, color: AppColors.textMuted),
                onPressed: () => Navigator.pushNamed(
                  context,
                  RouteNames.goalAmount,
                  arguments: goal.periodType,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(spent),
                style: AppTypography.amountMedium,
              ),
              Text(
                'of ${CurrencyFormatter.format(goal.amount)}',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatusProgressBarLight(percentage: percentage, height: 8),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}% used',
                style: AppTypography.caption,
              ),
              Text(
                remaining >= 0
                    ? '${CurrencyFormatter.format(remaining)} left'
                    : 'Over by ${CurrencyFormatter.format(-remaining)}',
                style: AppTypography.caption.copyWith(
                  color: remaining >= 0 ? AppColors.success : AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

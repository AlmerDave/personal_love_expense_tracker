import 'package:flutter/material.dart';
import 'package:personal_love_expense_tracker/core/enums/category_type.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/expense.dart';
import '../../../providers/expense_provider.dart';
import '../../../navigation/route_names.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final recentExpenses = provider.getRecentExpenses(limit: 5);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: AppTypography.h3,
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, RouteNames.transactions),
                  child: Text(
                    'View All',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List
            if (recentExpenses.isEmpty)
              _buildEmptyState(context)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentExpenses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _TransactionItem(expense: recentExpenses[index]);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text('📝', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            'No expenses yet',
            style: AppTypography.bodyBold,
          ),
          const SizedBox(height: 4),
          Text(
            'Start tracking your spending!',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Expense expense;

  const _TransactionItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        RouteNames.transactionDetail,
        arguments: expense.id,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: AppRadius.mediumRadius,
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: expense.categoryType.backgroundColor,
                borderRadius: AppRadius.smallRadius,
              ),
              child: Center(
                child: Text(
                  expense.categoryEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.merchant,
                    style: AppTypography.bodyBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${expense.categoryDisplayName} • ${DateFormatter.formatRelative(expense.date)}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '-${CurrencyFormatter.format(expense.amount)}',
              style: AppTypography.amountSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

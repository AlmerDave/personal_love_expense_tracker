import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/enums/category_type.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/expense.dart';
import '../../../providers/expense_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/dialogs/confirm_delete_dialog.dart';
import '../../../navigation/route_names.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseProvider>().loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: CustomAppBar(
        title: 'Transactions',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allExpenses = provider.expenses; 
          final grouped = provider.getGroupedExpenses(); 

          return Column(
            children: [
              // ALWAYS show the filter bar - KEY FIX
              _buildCategoryFilter(provider),
              Expanded(
                child: grouped.isEmpty ? 
                  _buildEmptyState(allExpenses.isEmpty) : 
                  _buildExpensesList(grouped, provider)
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, RouteNames.dashboard);
          if (index == 2) Navigator.pushReplacementNamed(context, RouteNames.goals);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool hasNoExpensesAtAll) {
  if (hasNoExpensesAtAll) {
    return EmptyStateWidget(
      emoji: '📝',
      title: 'No expenses yet',
      description: 'Start tracking your spending to see your history here',
      buttonLabel: 'Add Expense',
      onButtonPressed: () => Navigator.pushNamed(context, RouteNames.manualEntry),
    );
  } else {
    return EmptyStateWidget(
      emoji: '🔍', 
      title: 'No $_selectedCategory expenses',
      description: 'Try a different category or clear the filter',
      buttonLabel: 'Show All',
      onButtonPressed: () {
        setState(() => _selectedCategory = null);
        context.read<ExpenseProvider>().setCategoryFilter(null);
      },
    );
  }
}

  Widget _buildExpensesList(Map<DateTime, List<Expense>> grouped, ExpenseProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped.keys.elementAt(index);
        final expenses = grouped[date]!;
        return _buildDateSection(date, expenses, provider);
      },
    );
  }

  Widget _buildCategoryFilter(ExpenseProvider provider) {
    final categories = ['All', ...CategoryType.values.where((c) => c != CategoryType.custom).map((c) => c.label)];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = (_selectedCategory == null && category == 'All') ||
              _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category == 'All' ? null : category;
              });
              provider.setCategoryFilter(_selectedCategory);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.bgCard,
                borderRadius: AppRadius.fullRadius,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: AppTypography.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSection(DateTime date, List<Expense> expenses, ExpenseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            DateFormatter.formatListHeader(date),
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ...expenses.map((expense) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TransactionItem(
                expense: expense,
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteNames.transactionDetail,
                  arguments: expense.id,
                ),
                onDelete: () => _confirmDelete(expense, provider),
              ),
            )),
      ],
    );
  }

  Future<void> _confirmDelete(Expense expense, ExpenseProvider provider) async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'Delete Expense?',
      message: 'Are you sure you want to delete this expense? This action cannot be undone.',
    );

    if (confirmed == true) {
      await provider.deleteExpense(expense.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted')),
        );
      }
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(
        onSearch: (query) {
          context.read<ExpenseProvider>().setSearchQuery(query);
        },
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TransactionItem({
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: AppRadius.mediumRadius,
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        onDelete();
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: AppRadius.mediumRadius,
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: expense.categoryType.backgroundColor,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Center(
                  child: Text(expense.categoryEmoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.merchant, style: AppTypography.bodyBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      '${expense.categoryDisplayName} • ${DateFormatter.formatTime(expense.date)}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Text('-${CurrencyFormatter.format(expense.amount)}', style: AppTypography.amountSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchDialog extends StatefulWidget {
  final Function(String) onSearch;

  const _SearchDialog({required this.onSearch});

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
      title: Text('Search Transactions', style: AppTypography.h2),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search by merchant or category...',
          prefixIcon: Icon(Icons.search_rounded),
        ),
        onSubmitted: (value) {
          widget.onSearch(value);
          Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onSearch('');
            Navigator.pop(context);
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () {
            widget.onSearch(_controller.text);
            Navigator.pop(context);
          },
          child: const Text('Search'),
        ),
      ],
    );
  }
}

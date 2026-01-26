import 'package:flutter/material.dart';
import 'package:personal_love_expense_tracker/core/enums/category_type.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/expense.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/input_field.dart';
import '../../../shared/widgets/category_bottom_sheet.dart';
import '../../../shared/widgets/success_dialog.dart';
import '../../../shared/dialogs/confirm_delete_dialog.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String expenseId;

  const TransactionDetailScreen({super.key, required this.expenseId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();

  Expense? _expense;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  void _loadExpense() {
    final provider = context.read<ExpenseProvider>();
    final expenses = provider.expenses;
    try {
      _expense = expenses.firstWhere((e) => e.id == widget.expenseId);
      _merchantController.text = _expense!.merchant;
      _notesController.text = _expense!.notes ?? '';
      _amountController.text = _expense!.amount.toStringAsFixed(2);
      _selectedCategoryId = _expense!.category;
      _selectedCategoryName = _expense!.categoryDisplayName;
      _selectedDate = _expense!.date;
    } catch (_) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _hasChanges = true;
      });
    }
  }

  void _selectCategory() {
    CategoryBottomSheet.show(
      context,
      selectedCategory: _selectedCategoryId,
      onSelect: (id, name) {
        setState(() {
          _selectedCategoryId = id;
          _selectedCategoryName = name;
          _hasChanges = true;
        });
      },
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expense == null) return;

    final amount = double.tryParse(_amountController.text) ?? _expense!.amount;

    setState(() => _isLoading = true);

    final updatedExpense = _expense!.copyWith(
      amount: amount,
      merchant: _merchantController.text.trim(),
      category: _selectedCategoryId,
      customCategoryName: _selectedCategoryId == 'custom' ? _selectedCategoryName : null,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final success = await context.read<ExpenseProvider>().updateExpense(updatedExpense);

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.read<DashboardProvider>().refresh();

      await SuccessDialog.show(
        context,
        title: 'Changes Saved! ✓',
      );

      Navigator.pop(context);
    }
  }

  Future<void> _deleteExpense() async {
    if (_expense == null) return;

    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'Delete Expense?',
      message: 'Are you sure you want to delete this expense? This action cannot be undone.',
    );

    if (confirmed == true) {
      final success = await context.read<ExpenseProvider>().deleteExpense(_expense!.id);

      if (success && mounted) {
        context.read<DashboardProvider>().refresh();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_expense == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: const CustomAppBar(title: 'Transaction Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() => _hasChanges = true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              _buildHeaderCard(),
              const SizedBox(height: AppSpacing.sectionGap),

              Text('Details', style: AppTypography.h3),
              const SizedBox(height: 12),

              // Category
              _buildCategorySelector(),
              const SizedBox(height: AppSpacing.md),

              // Amount
              InputField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                prefixIcon: Icons.payments_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: AppSpacing.md),

              // Merchant
              InputField(
                controller: _merchantController,
                label: 'Merchant / Store',
                hint: 'Where did you spend?',
                prefixIcon: Icons.store_rounded,
                validator: Validators.validateMerchant,
              ),
              const SizedBox(height: AppSpacing.md),

              // Date
              _buildDatePicker(),
              const SizedBox(height: AppSpacing.md),

              // Notes
              InputField(
                controller: _notesController,
                label: 'Notes',
                hint: 'Add a note...',
                prefixIcon: Icons.edit_note_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save button
              PrimaryButton(
                label: '💾  Save Changes',
                onPressed: _hasChanges ? _saveChanges : null,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),

              // Delete button
              SecondaryButton(
                label: '🗑️  Delete Transaction',
                onPressed: _deleteExpense,
                isDanger: true,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _expense!.categoryType.backgroundColor,
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Center(
              child: Text(_expense!.categoryEmoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 16),
          Text(_expense!.merchant, style: AppTypography.h2),
          const SizedBox(height: 8),
          Text(
            '-${CurrencyFormatter.format(_expense!.amount)}',
            style: AppTypography.display.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormatter.formatFull(_expense!.date)} • ${DateFormatter.formatTime(_expense!.date)}',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectCategory,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text(_expense!.categoryEmoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCategoryName ?? _expense!.categoryDisplayName,
                    style: AppTypography.input,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(DateFormatter.formatFull(_selectedDate), style: AppTypography.input),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

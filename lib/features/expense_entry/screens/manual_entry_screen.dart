import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../shared/widgets/input_field.dart';
import '../../../shared/widgets/category_bottom_sheet.dart';
import '../../../shared/widgets/success_dialog.dart';
import '../widgets/amount_input_card.dart';

class ManualEntryScreen extends StatefulWidget {
  final double? initialAmount;
  final bool isFromReceipt;

  const ManualEntryScreen({
    super.key,
    this.initialAmount,
    this.isFromReceipt = false,
  });

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();

  double _amount = 0;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amount = widget.initialAmount!;
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _notesController.dispose();
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
      setState(() => _selectedDate = picked);
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
        });
      },
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final expense = Expense.create(
      amount: _amount,
      merchant: _merchantController.text.trim(),
      category: _selectedCategoryId!,
      customCategoryName:
          _selectedCategoryId == 'custom' ? _selectedCategoryName : null,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isFromReceipt: widget.isFromReceipt,
    );

    final success = await context.read<ExpenseProvider>().addExpense(expense);

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Refresh dashboard
      context.read<DashboardProvider>().refresh();

      // Show success dialog
      await SuccessDialog.show(
        context,
        title: 'Expense Saved! 🎉',
        subtitle:
            '${CurrencyFormatter.format(_amount)} at ${_merchantController.text}',
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: const CustomAppBar(title: 'Add Expense'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount input card
              AmountInputCard(
                initialAmount: _amount,
                onAmountChanged: (value) => setState(() => _amount = value),
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // Merchant field
              InputField(
                controller: _merchantController,
                label: 'Merchant / Store',
                hint: 'Where did you spend?',
                prefixIcon: Icons.store_rounded,
                validator: Validators.validateMerchant,
              ),
              const SizedBox(height: AppSpacing.md),

              // Category selector
              _buildCategorySelector(),
              const SizedBox(height: AppSpacing.md),

              // Date picker
              _buildDatePicker(),
              const SizedBox(height: AppSpacing.md),

              // Notes field
              InputField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Add a note...',
                prefixIcon: Icons.edit_note_rounded,
                maxLines: 3,
                maxLength: 500,
                validator: Validators.validateNotes,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save button
              PrimaryButton(
                label: '💾  Save Expense',
                onPressed: _saveExpense,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
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
                Icon(
                  Icons.category_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCategoryName ?? 'Select category',
                    style: _selectedCategoryName != null
                        ? AppTypography.input
                        : AppTypography.inputHint,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
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
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormatter.formatFull(_selectedDate),
                  style: AppTypography.input,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

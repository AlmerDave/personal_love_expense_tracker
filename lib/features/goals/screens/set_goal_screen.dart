import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/enums/period_type.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../config/app_config.dart';
import '../../../providers/goal_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/success_dialog.dart';

class SetGoalScreen extends StatefulWidget {
  final String? initialPeriod;

  const SetGoalScreen({super.key, this.initialPeriod});

  @override
  State<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends State<SetGoalScreen> {
  PeriodType? _selectedPeriod;
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPeriod != null) {
      _selectedPeriod = PeriodTypeExtension.fromString(widget.initialPeriod!);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (_selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a goal type')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal must be at least ₱100')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<GoalProvider>().createGoal(
          period: _selectedPeriod!,
          amount: amount,
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.read<DashboardProvider>().refresh();

      await SuccessDialog.show(
        context,
        title: 'Goal Set! 🎯',
        subtitle: '${_selectedPeriod!.label} budget: ${CurrencyFormatter.format(amount)}',
      );

      Navigator.pop(context);
    }
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final showAmountSection = _selectedPeriod != null || widget.initialPeriod != null;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: CustomAppBar(
        title: widget.initialPeriod != null ? '${_selectedPeriod?.label ?? ''} Budget' : 'Set Goals',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.initialPeriod == null) ...[
              _buildInfoBanner(),
              const SizedBox(height: AppSpacing.sectionGap),
              Text('Choose a goal type', style: AppTypography.h3),
              const SizedBox(height: 12),
              _buildGoalTypeList(),
              const SizedBox(height: AppSpacing.sectionGap),
            ],
            if (showAmountSection) ...[
              _buildAmountSection(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildPeriodPreview(),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: '✓  Save Goal',
                onPressed: _saveGoal,
                isLoading: _isLoading,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
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

  Widget _buildGoalTypeList() {
    return Column(
      children: PeriodType.values.map((period) {
        final isSelected = _selectedPeriod == period;
        final isRecommended = period == PeriodType.biWeekly;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primarySoft : AppColors.bgCard,
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(period.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(period.label, style: AppTypography.bodyBold),
                            if (isRecommended) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: AppRadius.smallRadius,
                                ),
                                child: Text(
                                  '⭐ RECOMMENDED',
                                  style: AppTypography.small.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(period.description, style: AppTypography.caption),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set your spending limit', style: AppTypography.h3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: AppRadius.largeRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₱', style: AppTypography.h1.copyWith(color: AppColors.textMuted)),
                  const SizedBox(width: 4),
                  IntrinsicWidth(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTypography.display,
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: AppTypography.display.copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '💡 Quick suggestions based on typical Filipino salaries:',
          style: AppTypography.caption,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConfig.goalSuggestions.map((amount) {
            return GestureDetector(
              onTap: () => _setAmount(amount),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgSoft,
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  CurrencyFormatter.formatNoDecimal(amount),
                  style: AppTypography.bodyBold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPeriodPreview() {
    if (_selectedPeriod == null) return const SizedBox.shrink();

    final now = DateTime.now();
    String periodInfo;

    switch (_selectedPeriod!) {
      case PeriodType.daily:
        periodInfo = 'Resets every day at midnight';
        break;
      case PeriodType.weekly:
        periodInfo = 'Monday to Sunday each week';
        break;
      case PeriodType.biWeekly:
        final biWeekly = DateFormatter.getBiWeeklyPeriod(now);
        final isFirstHalf = now.day <= 15;
        periodInfo =
            'Period 1: 1st - 15th\nPeriod 2: 16th - end of month\n\nCurrent: Period ${isFirstHalf ? 1 : 2} (${DateFormatter.formatDateRange(biWeekly['start']!, biWeekly['end']!)})';
        break;
      case PeriodType.monthly:
        periodInfo = '${DateFormatter.formatMonthYear(now)}';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Period Preview', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(periodInfo, style: AppTypography.body),
        ],
      ),
    );
  }
}

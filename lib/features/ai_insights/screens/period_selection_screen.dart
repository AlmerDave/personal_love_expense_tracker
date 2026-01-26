import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/insight_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../navigation/route_names.dart';

class PeriodSelectionScreen extends StatefulWidget {
  const PeriodSelectionScreen({super.key});

  @override
  State<PeriodSelectionScreen> createState() => _PeriodSelectionScreenState();
}

class _PeriodSelectionScreenState extends State<PeriodSelectionScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  @override
  void initState() {
    super.initState();
    // Initialize with current bi-weekly period
    final biWeekly = DateFormatter.getBiWeeklyPeriod(DateTime.now());
    _rangeStart = biWeekly['start'];
    _rangeEnd = biWeekly['end'];
  }

  void _setQuickSelection(String type) {
    final now = DateTime.now();
    DateTime start, end;

    switch (type) {
      case 'today':
        start = DateFormatter.startOfDay(now);
        end = DateFormatter.endOfDay(now);
        break;
      case 'week':
        start = DateFormatter.startOfWeek(now);
        end = DateFormatter.endOfWeek(now);
        break;
      case 'biweekly':
        final biWeekly = DateFormatter.getBiWeeklyPeriod(now);
        start = biWeekly['start']!;
        end = biWeekly['end']!;
        break;
      case 'month':
        start = DateFormatter.startOfMonth(now);
        end = DateFormatter.endOfMonth(now);
        break;
      default:
        return;
    }

    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _focusedDay = start;
    });
  }

  void _analyzeSpending() {
    if (_rangeStart == null) return;

    final provider = context.read<InsightProvider>();

    final endDate = _rangeEnd ?? _rangeStart!;

    provider.setDateRange(_rangeStart!, endDate);

    Navigator.pushNamed(context, RouteNames.insightsResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: const CustomAppBar(title: 'AI Insights'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Avatar and intro
            _buildIntroCard(),
            const SizedBox(height: AppSpacing.sectionGap),

            // Quick selection buttons
            Text(
              'Quick Select',
              style: AppTypography.h3,
            ),
            const SizedBox(height: 12),
            _buildQuickSelections(),
            const SizedBox(height: AppSpacing.sectionGap),

            // Calendar
            Text(
              'Or choose custom range',
              style: AppTypography.h3,
            ),
            const SizedBox(height: 12),
            _buildCalendar(),
            const SizedBox(height: AppSpacing.sectionGap),

            // Selected range display
            if (_rangeStart != null && _rangeEnd != null) ...[
              _buildSelectedRange(),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Analyze button
            PrimaryButton(
              label: '✨  Analyze My Spending',
              onPressed: (_rangeStart != null)
                  ? _analyzeSpending
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.largeRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/financial-coach.png',
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to emoji if image fails to load
                  return const Text('🤖', style: TextStyle(fontSize: 28));
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi! I'm ready to analyze your spending!",
                  style: AppTypography.bodyBold,
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a date range to get started.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelections() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuickSelectChip(
          label: 'Today',
          emoji: '📅',
          isSelected: _isSelectedRange('today'),
          onTap: () => _setQuickSelection('today'),
        ),
        _QuickSelectChip(
          label: 'This Week',
          emoji: '📆',
          isSelected: _isSelectedRange('week'),
          onTap: () => _setQuickSelection('week'),
        ),
        _QuickSelectChip(
          label: 'Bi-Weekly',
          emoji: '💰',
          isSelected: _isSelectedRange('biweekly'),
          isRecommended: true,
          onTap: () => _setQuickSelection('biweekly'),
        ),
        _QuickSelectChip(
          label: 'This Month',
          emoji: '🗓️',
          isSelected: _isSelectedRange('month'),
          onTap: () => _setQuickSelection('month'),
        ),
      ],
    );
  }

  bool _isSelectedRange(String type) {
    if (_rangeStart == null || _rangeEnd == null) return false;

    final now = DateTime.now();
    DateTime expectedStart, expectedEnd;

    switch (type) {
      case 'today':
        expectedStart = DateFormatter.startOfDay(now);
        expectedEnd = DateFormatter.endOfDay(now);
        break;
      case 'week':
        expectedStart = DateFormatter.startOfWeek(now);
        expectedEnd = DateFormatter.endOfWeek(now);
        break;
      case 'biweekly':
        final biWeekly = DateFormatter.getBiWeeklyPeriod(now);
        expectedStart = biWeekly['start']!;
        expectedEnd = biWeekly['end']!;
        break;
      case 'month':
        expectedStart = DateFormatter.startOfMonth(now);
        expectedEnd = DateFormatter.endOfMonth(now);
        break;
      default:
        return false;
    }

    return isSameDay(_rangeStart, expectedStart) &&
        isSameDay(_rangeEnd, expectedEnd);
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: TableCalendar(
        firstDay: DateTime(2020),
        lastDay: DateTime.now(),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        rangeSelectionMode: _rangeSelectionMode,
        onRangeSelected: (start, end, focusedDay) {
          setState(() {
            _rangeStart = start;
            _rangeEnd = end;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          rangeHighlightColor: AppColors.primarySoft,
          rangeStartDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          rangeEndDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          outsideDaysVisible: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTypography.bodyBold,
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.primary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTypography.caption,
          weekendStyle: AppTypography.caption.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedRange() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.date_range_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Selected: ${DateFormatter.formatDateRange(_rangeStart!, _rangeEnd!)}',
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSelectChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  const _QuickSelectChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.bgCard,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isRecommended && !isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodyBold.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (isRecommended && !isSelected) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Text(
                  '⭐',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../services/api_key_service.dart';
import '../../../config/api_config.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/goal_provider.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../navigation/route_names.dart';
import '../widgets/spending_overview_card.dart';
import '../widgets/quick_insight_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/api_key_setup_modal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;
  late ApiKeyService _apiKeyService;
  bool _isInitialized = false;
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _apiKeyService = await ApiKeyService.getInstance();
    
    // Check if API key exists
    _hasApiKey = await _apiKeyService.hasApiKey();
    
    if (!_hasApiKey && mounted) {
      // Show API key setup modal
      _showApiKeySetupModal();
    } else {
      // Load data normally
      await _loadData();
    }
    
    setState(() {
      _isInitialized = true;
    });
  }

  void _showApiKeySetupModal() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => ApiKeySetupModal(
        onApiKeySaved: (apiKey) {
          // Update cached API key in config
          ApiConfig.updateCachedApiKey(apiKey);
          // Update the local state
          _hasApiKey = true;
          // Load data after API key is saved
          _loadData();
        },
      ),
    );
  }

  Future<void> _loadData() async {
    // Update API key status when refreshing
    _hasApiKey = await _apiKeyService.hasApiKey();

    final dashboardProvider = context.read<DashboardProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final goalProvider = context.read<GoalProvider>();

    await Future.wait([
      dashboardProvider.loadDashboard(),
      expenseProvider.loadExpenses(),
      goalProvider.loadGoals(),
    ]);

    // Load quick insight after initial data (only if API key exists)
    if (_hasApiKey) {
      dashboardProvider.loadQuickInsight();
    }

    // Add setState to refresh the UI
    if (mounted) {
      setState(() {});
    }
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.pushNamed(context, RouteNames.transactions);
        break;
      case 2:
        Navigator.pushNamed(context, RouteNames.goals);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // API Key Status Banner (shows when no API key)
                if (!_hasApiKey) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_rounded, color: Colors.orange, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'AI features disabled. Please Tap to add API key.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showApiKeySetupModal,
                          child: Text(
                            'Setup',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Spending Overview Card
                const SpendingOverviewCard(),
                const SizedBox(height: AppSpacing.sectionGap),

                // Quick Insight Card
                const QuickInsightCard(),
                const SizedBox(height: AppSpacing.sectionGap),

                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: AppSpacing.md),

                // Secondary Actions
                _buildSecondaryActions(),
                const SizedBox(height: AppSpacing.sectionGap),

                // Recent Transactions
                const RecentTransactionsList(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: QuickActionButton(
            icon: Icons.edit_rounded,
            emoji: '💰',
            label: 'Manual Entry',
            sublabel: 'Type amount',
            isPrimary: true,
            onTap: () => Navigator.pushNamed(context, RouteNames.manualEntry),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: QuickActionButton(
            icon: Icons.camera_alt_rounded,
            emoji: '📷',
            label: 'Scan Receipt',
            sublabel: 'Auto-extract',
            isPrimary: false,
            onTap: () => Navigator.pushNamed(context, RouteNames.receiptUpload),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions() {
    return Row(
      children: [
        Expanded(
          child: _SecondaryActionButton(
            icon: Icons.auto_awesome_rounded,
            label: 'Ask AI',
            onTap: () async {
              if (!_hasApiKey && mounted) {
                _showApiKeySetupModal();
              } else {
                Navigator.pushNamed(context, RouteNames.insightsPeriodSelection);
              }
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SecondaryActionButton(
            icon: Icons.flag_rounded,
            label: 'Set Goals',
            onTap: () => Navigator.pushNamed(context, RouteNames.goals),
          ),
        ),
      ],
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
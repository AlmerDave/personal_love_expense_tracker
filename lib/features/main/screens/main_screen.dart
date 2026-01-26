import 'package:flutter/material.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../transactions/screens/transaction_history_screen.dart';
import '../../goals/screens/goal_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentTabIndex = 0;

  // List of all tab screens
  final List<Widget> _tabScreens = const [
    DashboardScreen(),
    TransactionHistoryScreen(),
    GoalListScreen(),
  ];

  void _onTabTap(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: _tabScreens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentTabIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
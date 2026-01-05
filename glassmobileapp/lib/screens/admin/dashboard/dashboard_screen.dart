import 'package:flutter/material.dart';

import '../../../config/app_router.dart';
import '../../../constants/colors.dart';
import '../../../constants/routes.dart';
import '../../../widgets/common/commission_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Keep same bottom navigation behavior/design as HomeScreen
  int _currentBottomNavIndex = 0;

  // Commission dialog state (same pattern as HomeScreen)
  final bool _isFirstRowOccupied = false;

  // Keep the import available for future admin actions.
  // ignore: unused_element
  void _showCommissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CommissionDialog(
          onCommissionSelected: (tier) {
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 100), () {
              AppRouter.pushNamed(
                context,
                AppRoutes.productRegister,
                arguments: {'commissionTier': tier, 'isFirstRowOccupied': _isFirstRowOccupied},
              );
            });
          },
          isFirstRowOccupied: _isFirstRowOccupied,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => AppRouter.pushNamed(context, AppRoutes.profile),
              child: CircleAvatar(
                radius: isTablet ? 20.0 : 18.0,
                backgroundColor: AppColors.white,
                child: CircleAvatar(
                  radius: isTablet ? 18.0 : 16.0,
                  backgroundImage: const AssetImage('asset/images/n.jpeg'),
                  onBackgroundImageError: (_, __) {},
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 16.0 : 14.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Good morning,',
                    style: TextStyle(
                      fontSize: isTablet ? 14.0 : 12.0,
                      color: AppColors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: isTablet ? 18.0 : 16.0,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Admin notifications coming soon'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: isTablet ? 24.0 : 22.0,
                      color: AppColors.white,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: isTablet ? 18.0 : 16.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: isTablet ? 12.0 : 10.0),
            _AdminStatRow(isTablet: isTablet),
            SizedBox(height: isTablet ? 16.0 : 12.0),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: isTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: isTablet ? 12.0 : 10.0),
            _AdminActionsGrid(isTablet: isTablet),
          ],
        ),
      ),
      bottomNavigationBar: _AdminBottomNav(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });

          switch (index) {
            case 0:
              // Keep user on admin dashboard
              break;
            case 1:
              AppRouter.pushNamed(context, AppRoutes.adminProducts);
              break;
            case 2:
              AppRouter.pushNamed(context, AppRoutes.adminAnalytics);
              break;
            case 3:
              AppRouter.pushNamed(context, AppRoutes.adminUsers);
              break;
            case 4:
              AppRouter.pushNamed(context, AppRoutes.profile);
              break;
          }
        },
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8AC1ED),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF8AC1ED),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isTablet ? 12.0 : 10.0,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: isTablet ? 10.0 : 9.0,
        ),
        selectedFontSize: isTablet ? 12.0 : 10.0,
        unselectedFontSize: isTablet ? 10.0 : 9.0,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 0 ? Icons.home : Icons.home_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              // Use an eyewear-like icon for Products
              currentIndex == 1 ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 2 ? Icons.query_stats : Icons.query_stats_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 3 ? Icons.people : Icons.people_outline,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 4 ? Icons.settings : Icons.settings_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _AdminStatRow extends StatelessWidget {
  const _AdminStatRow({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AdminStatCard(
            title: 'Users',
            value: '128',
            icon: Icons.people_outline,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AdminStatCard(
            title: 'Products',
            value: '54',
            icon: Icons.inventory_2_outlined,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isTablet,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16.0 : 14.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 44 : 40,
            height: isTablet ? 44 : 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 13.0 : 12.0,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 20.0 : 18.0,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionsGrid extends StatelessWidget {
  const _AdminActionsGrid({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    Widget tile({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) {
      return Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 14.0 : 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: isTablet ? 22 : 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 14.0 : 13.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        tile(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Manage Users',
          onTap: () => AppRouter.pushNamed(context, AppRoutes.adminUsers),
        ),
        const SizedBox(height: 12),
        tile(
          icon: Icons.inventory_2_outlined,
          title: 'Manage Products',
          onTap: () => AppRouter.pushNamed(context, AppRoutes.adminProducts),
        ),
        const SizedBox(height: 12),
        tile(
          icon: Icons.receipt_long_outlined,
          title: 'Manage Orders',
          onTap: () => AppRouter.pushNamed(context, AppRoutes.adminOrders),
        ),
      ],
    );
  }
}







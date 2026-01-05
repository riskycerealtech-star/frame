import 'package:flutter/material.dart';
import '../../config/app_router.dart';
import '../../constants/routes.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final int cartBadgeCount;

  const BottomNavigationBarWidget({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.cartBadgeCount = 0,
  });

  @override
  State<BottomNavigationBarWidget> createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(BottomNavigationBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      setState(() {
        _currentIndex = widget.currentIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : const Color(0xFF8AC1ED);
    final fg = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: const Border(
          top: BorderSide(color: Colors.white, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Call custom onTap if provided, otherwise use default navigation
          if (widget.onTap != null) {
            widget.onTap!(index);
          } else {
            _handleDefaultNavigation(index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: bg,
        selectedItemColor: fg,
        unselectedItemColor: fg,
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
              _currentIndex == 0 ? Icons.home : Icons.home_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1 ? Icons.storefront : Icons.storefront_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  _currentIndex == 2 ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                  size: isTablet ? 24.0 : 22.0,
                ),
                if (widget.cartBadgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.cartBadgeCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 10.0 : 9.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 3 ? Icons.add : Icons.add_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 4 ? Icons.person : Icons.person_outline,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _handleDefaultNavigation(int index) {
    switch (index) {
      case 0:
        // Home
        AppRouter.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        // Market
        AppRouter.pushNamed(context, AppRoutes.myMarket);
        break;
      case 2:
        // Cart
        AppRouter.pushNamed(context, AppRoutes.cart);
        break;
      case 3:
        // Sell
        AppRouter.pushNamed(context, AppRoutes.productRegister);
        break;
      case 4:
        // Profile
        AppRouter.pushNamed(context, AppRoutes.profile);
        break;
    }
  }
}

// Static helper class for easy access
class BottomNavHelper {
  static Widget build({
    int currentIndex = 0,
    Function(int)? onTap,
    int cartBadgeCount = 0,
  }) {
    return BottomNavigationBarWidget(
      currentIndex: currentIndex,
      onTap: onTap,
      cartBadgeCount: cartBadgeCount,
    );
  }
}

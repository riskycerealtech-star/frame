import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class AppBarActionIcons extends StatelessWidget {
  const AppBarActionIcons({
    super.key,
    required this.notificationCount,
    required this.cartCount,
    required this.isTablet,
    required this.iconColor,
    required this.onNotificationTap,
    required this.onCartTap,
    this.showCart = true,
  });

  final int notificationCount;
  final int cartCount;
  final bool isTablet;
  final Color iconColor;
  final VoidCallback onNotificationTap;
  final VoidCallback onCartTap;
  final bool showCart;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onNotificationTap,
          icon: _BadgeIcon(
            icon: Icons.notifications_outlined,
            count: notificationCount,
            isTablet: isTablet,
            iconColor: iconColor,
          ),
          tooltip: 'Notifications',
        ),
        if (showCart)
          IconButton(
            onPressed: onCartTap,
            icon: _BadgeIcon(
              icon: Icons.shopping_cart_outlined,
              count: cartCount,
              isTablet: isTablet,
              iconColor: iconColor,
            ),
            tooltip: 'Cart',
          ),
        const SizedBox(width: 6),
      ],
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({
    required this.icon,
    required this.count,
    required this.isTablet,
    required this.iconColor,
  });

  final IconData icon;
  final int count;
  final bool isTablet;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: isTablet ? 24.0 : 22.0,
        ),
        if (count > 0)
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
                '$count',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: isTablet ? 10.0 : 9.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}









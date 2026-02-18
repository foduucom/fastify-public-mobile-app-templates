import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class ResponsiveBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color borderColor;
  final double heightFactor;
  final double height;

  const ResponsiveBottomNav({
    super.key,
    required this.height,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.backgroundColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.borderColor,
    this.heightFactor = 0.09,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height * heightFactor,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -10),
            blurRadius: 60,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3) // Dark mode shadow
                : DefaultThemeColors.lightOnSecondary
                    .withOpacity(0.1), // Light mode shadow
          ),
        ],
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          items.length,
          (index) => _NavItem(
            item: items[index],
            isActive: currentIndex == index,
            onTap: () => onTap(index),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const BottomNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? item.activeIcon : item.inactiveIcon,
            size: height * 0.03,
            color: isActive ? activeColor : inactiveColor,
          ),
          SizedBox(height: height * 0.005),
          Text(
            item.label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.013,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

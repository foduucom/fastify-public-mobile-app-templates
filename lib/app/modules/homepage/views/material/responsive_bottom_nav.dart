import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ResponsiveBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color borderColor;
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
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final barHeight = 65.0 + bottomPadding;
    final itemWidth = MediaQuery.of(context).size.width / items.length;

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: borderColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Sliding Indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: currentIndex * itemWidth + (itemWidth * 0.1),
            top: 0,
            child: Container(
              width: itemWidth * 0.8,
              height: 3,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(3),
                ),
                gradient: LinearGradient(
                  colors: [
                    activeColor,
                    activeColor.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          // Nav Items
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                items.length,
                (index) => Expanded(
                  child: _NavItem(
                    item: items[index],
                    isActive: currentIndex == index,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTap(index);
                    },
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final int? badgeCount;

  const BottomNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    this.badgeCount,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isActive ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    isActive ? item.activeIcon : item.inactiveIcon,
                    size: 24,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          item.badgeCount! > 9 ? '9+' : item.badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: isActive ? 0.2 : 0,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

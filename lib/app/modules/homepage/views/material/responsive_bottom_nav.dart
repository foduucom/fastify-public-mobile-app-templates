import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final barHeight = 66.0 + bottomPadding;

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: borderColor.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding, top: 6),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isActive ? 16 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isActive ? item.activeIcon : item.inactiveIcon,
                  size: 23,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
              if (item.badgeCount != null && item.badgeCount! > 0)
                Positioned(
                  right: isActive ? 6 : -2,
                  top: -3,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        item.badgeCount! > 99
                            ? '99+'
                            : item.badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : inactiveColor,
              letterSpacing: isActive ? 0.2 : 0,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

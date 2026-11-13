import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';

class ResponsiveCircleIcon extends StatelessWidget {
  final IconData icon;
  final double width;
  final double height;

  final double? diameter; // optional override
  final Color? borderColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final int? badgeCount;
  final bool showDot;

  const ResponsiveCircleIcon({
    Key? key,
    required this.icon,
    required this.width,
    required this.height,
    this.diameter,
    this.borderColor,
    this.iconColor,
    this.backgroundColor,
    this.borderWidth = 1,
    this.onTap,
    this.badgeCount,
    this.showDot = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double size = diameter ?? (height * 0.052).clamp(42.0, 48.0);
    final Color border = borderColor ?? colorScheme.outline.withOpacity(0.18);
    final Color iconC = iconColor ?? colorScheme.onSurface;
    final Color bg = backgroundColor ?? colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: border,
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: (size * 0.48).clamp(18.0, 22.0),
                color: iconC,
              ),
            ),
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.error.withOpacity(0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    badgeCount! > 99 ? '99+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            )
          else if (showDot)
            Positioned(
              right: 1,
              top: 1,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

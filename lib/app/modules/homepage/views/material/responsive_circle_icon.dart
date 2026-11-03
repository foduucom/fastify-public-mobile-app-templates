import 'package:flutter/material.dart';

class ResponsiveCircleIcon extends StatelessWidget {
  final IconData icon;
  final double height;
  final double width;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final int badgeCount;

  const ResponsiveCircleIcon({
    super.key,
    required this.icon,
    required this.height,
    required this.width,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circleSize = size ?? (width * 0.1).clamp(36.0, 48.0);
    final iconSize = (circleSize * 0.52).clamp(18.0, 24.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(circleSize / 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor ?? theme.colorScheme.surface,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? theme.colorScheme.onSurface,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


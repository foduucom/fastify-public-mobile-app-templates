import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';

class ResponsiveCircleIcon extends StatelessWidget {
  final IconData icon;
  final double width;
  final double height;

  final double? diameter; // optional override
  final Color? borderColor;
  final Color? iconColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const ResponsiveCircleIcon({
    Key? key,
    required this.icon,
    required this.width,
    required this.height,
    this.diameter,
    this.borderColor,
    this.iconColor,
    this.borderWidth = 1,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double size = diameter ?? height * 0.055;
    final Color border = borderColor ?? colorScheme.outline.withOpacity(0.3);
    final Color iconC = iconColor ?? colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: border,
            width: borderWidth,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: height * 0.025,
            color: iconC,
          ),
        ),
      ),
    );
  }
}

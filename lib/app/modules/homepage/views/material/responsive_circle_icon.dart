import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';

class ResponsiveCircleIcon extends StatelessWidget {
  final IconData icon;
  final double width;
  final double height;

  final double? diameter; // optional override
  final Color borderColor;
  final Color iconColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const ResponsiveCircleIcon({
    Key? key,
    required this.icon,
    required this.width,
    required this.height,
    this.diameter,
    this.borderColor = DefaultThemeColors.darklight,
    this.iconColor = DefaultThemeColors.darklighter,
    this.borderWidth = 1,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double size = diameter ?? height * 0.055;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: height * 0.025,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

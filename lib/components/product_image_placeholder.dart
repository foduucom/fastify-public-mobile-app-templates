import 'package:flutter/material.dart';
import 'package:zouhi/constants/theme_ext.dart';

/// Shown in place of a product photo when there is none or when it fails to load:
/// the VIC logo watermarked on a theme-aware tile.
class ProductImagePlaceholder extends StatelessWidget {
  const ProductImagePlaceholder({
    super.key,
    this.radius = 8.0,
    this.padding = const EdgeInsets.all(16.0),
    this.opacity = 0.4,
    this.backgroundColor,
    this.fit = BoxFit.contain,
  });

  final double radius;
  final EdgeInsetsGeometry padding;
  final double opacity;
  final Color? backgroundColor;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (context.isDark
            ? context.themegreyColor.withValues(alpha: 0.35)
            : context.themegreyColor);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: padding,
            child: Image.asset(
              'assets/images/VIC-Logo-Final-500.png',
              fit: fit,
            ),
          ),
        ),
      ),
    );
  }
}

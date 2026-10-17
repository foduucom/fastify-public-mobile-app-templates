import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shown in place of a photo when there is none or when it fails to load:
/// the app launcher icon watermarked on a theme-aware tile.
class AppImagePlaceholder extends StatelessWidget {
  const AppImagePlaceholder({
    super.key,
    this.radius = 8.0,
    this.shape = BoxShape.rectangle,
    this.padding,
    this.opacity = 0.38,
    this.backgroundColor,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.colorFilter,
  });

  /// Specialized constructor for circular avatars (e.g. round category chips)
  const AppImagePlaceholder.circular({
    super.key,
    double? size,
    this.padding,
    this.opacity = 0.38,
    this.backgroundColor,
    this.fit = BoxFit.contain,
    double? width,
    double? height,
    this.colorFilter,
  })  : radius = 0,
        shape = BoxShape.circle,
        width = size ?? width,
        height = size ?? height;

  final double radius;
  final BoxShape shape;
  final EdgeInsetsGeometry? padding;
  final double opacity;
  final Color? backgroundColor;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final Color defaultBg = isDark
        ? colorScheme.surfaceVariant.withOpacity(0.35)
        : colorScheme.surfaceVariant;
    final Color tileColor = backgroundColor ?? defaultBg;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tileColor,
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(radius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double minDimension =
              (constraints.hasBoundedWidth && constraints.hasBoundedHeight)
                  ? math.min(constraints.maxWidth, constraints.maxHeight)
                  : (width ?? height ?? 100);

          final EdgeInsetsGeometry effectivePadding = padding ??
              (minDimension < 50
                  ? const EdgeInsets.all(4.0)
                  : minDimension < 75
                      ? const EdgeInsets.all(8.0)
                      : minDimension < 120
                          ? const EdgeInsets.all(12.0)
                          : const EdgeInsets.all(16.0));

          return Center(
            child: Opacity(
              opacity: opacity,
              child: Padding(
                padding: effectivePadding,
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: fit,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Alias for Visioninfra compatibility
typedef ProductImagePlaceholder = AppImagePlaceholder;

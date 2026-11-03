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
        ? const Color(0xFF1E1E22)
        : const Color(0xFFF6F5F2);
    final Color tileColor = backgroundColor ?? defaultBg;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tileColor,
        shape: shape,
        gradient: shape == BoxShape.circle
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF242429), const Color(0xFF1A1A1D)]
                    : [const Color(0xFFF9F9F8), const Color(0xFFEFECE6)],
              ),
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(radius),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
          width: 0.8,
        ),
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
            child: Padding(
              padding: effectivePadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: math.min(minDimension * 0.35, 34),
                    color: const Color(0xFFD4AF37).withOpacity(0.65),
                  ),
                  if (minDimension >= 90) ...[
                    const SizedBox(height: 6),
                    Text(
                      'BOUTIQUE',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: (isDark ? Colors.white70 : Colors.black45),
                      ),
                    ),
                  ],
                ],
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

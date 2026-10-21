import 'package:flutter/material.dart';
import '/constants/constants.dart';

class SpacerComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const SpacerComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = double.tryParse(contentJson['height'].toString()) ?? 10.0;
    return SizedBox(height: height);
  }
}

class DividerComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const DividerComponent({Key? key, required this.contentJson})
      : super(key: key);

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse('0x$hexColor'));
  }

  @override
  Widget build(BuildContext context) {
    String hexColor = contentJson['color'] ?? '#000000';
    double thickness =
        double.tryParse(contentJson['thickness'].toString()) ?? 1.0;
    double indent = double.tryParse(contentJson['indent'].toString()) ?? 0.0;

    return Divider(
      color: _parseColor(hexColor),
      thickness: thickness,
      indent: indent,
      endIndent: indent,
    );
  }
}

class TextBlockComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;
  const TextBlockComponent({Key? key, required this.contentJson})
      : super(key: key);

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse('0x$hexColor'));
  }

  @override
  Widget build(BuildContext context) {
    String text = (contentJson['text'] ?? '').toString().trim();
    if (text.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final String? eyebrow = contentJson['eyebrow']?.toString();
    final bool hasEyebrow = eyebrow != null && eyebrow.trim().isNotEmpty;
    final bool isPhilosophy =
        text.toLowerCase().contains('philosophy') || hasEyebrow;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (isPhilosophy) {
      final Color dotColor = isDark
          ? colorScheme.primary
          : (colorScheme.primary.computeLuminance() > 0.6
              ? Colors.black
              : colorScheme.primary);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF161616)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasEyebrow) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    eyebrow.trim().toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 15.0,
                height: 1.55,
                color: isDark ? const Color(0xFFE5E5E5) : colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );
    }

    double size = double.tryParse(contentJson['size'].toString()) ?? 14.0;
    String weightStr = contentJson['weight'] ?? 'normal';
    String alignStr = contentJson['alignment'] ?? 'left';
    String colorStr = contentJson['color'] ?? '#000000';
    Color textColor = _parseColor(colorStr);
    bool isNearWhite = (textColor.r * 255.0).round().clamp(0, 255) > 240 &&
        (textColor.g * 255.0).round().clamp(0, 255) > 240 &&
        (textColor.b * 255.0).round().clamp(0, 255) > 240;
    if (isNearWhite) textColor = Colors.black;

    FontWeight weight =
        weightStr == 'bold' ? FontWeight.bold : FontWeight.normal;
    TextAlign align = TextAlign.left;
    if (alignStr == 'center') align = TextAlign.center;
    if (alignStr == 'right') align = TextAlign.right;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontSize: size,
            fontWeight: weight,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class StudioSectionHeader extends StatelessWidget {
  final String? eyebrow;
  final String? title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const StudioSectionHeader({
    Key? key,
    this.eyebrow,
    this.title,
    this.subtitle,
    this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasEyebrow = eyebrow != null && eyebrow!.trim().isNotEmpty;
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    if (hasEyebrow || hasTitle || hasSubtitle) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final Color dotColor = isDark
          ? colorScheme.primary
          : (colorScheme.primary.computeLuminance() > 0.6
              ? Colors.black
              : colorScheme.primary);

      return Padding(
        padding: pageSurroundingPadding.copyWith(top: 26, bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasEyebrow) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          eyebrow!.trim().toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (hasTitle)
                    Text(
                      title!,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                        letterSpacing: -0.3,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2, left: 8),
                  child: Text(
                    'See all',
                    style: textTheme.labelMedium?.copyWith(
                      color: isDark
                          ? colorScheme.onSurface
                          : (colorScheme.primary.computeLuminance() > 0.6
                              ? colorScheme.onSurface
                              : colorScheme.primary),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

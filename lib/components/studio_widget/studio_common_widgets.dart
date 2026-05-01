import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '../../app/modules/bottomar/controllers/bottombar_controller.dart';

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
    String text = contentJson['text'] ?? '';
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
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
  final String? title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const StudioSectionHeader({
    Key? key,
    this.title,
    this.subtitle,
    this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show if EITHER title or subtitle is non-empty (more flexible than strict BOTH)
    if ((title != null && title!.isNotEmpty) ||
        (subtitle != null && subtitle!.isNotEmpty)) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      return Padding(
        padding: pageSurroundingPadding.copyWith(top: 24, bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null && title!.isNotEmpty)
                    Text(title!, style: textTheme.titleLarge),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(subtitle!,
                        style: textTheme.titleSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
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

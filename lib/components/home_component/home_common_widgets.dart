import 'package:flutter/material.dart';
import 'package:foddu/app/modules/shop/shop_navigation.dart';

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
    String text = (contentJson['text'] ?? '').toString();
    // Normalize and clean multiline text
    final cleanLines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (cleanLines.isEmpty) return const SizedBox.shrink();

    // Check if this text block is a deal showcase (e.g. from parent web map section)
    final isDealBlock = cleanLines.any((l) =>
        l.toLowerCase().contains('up to') && l.toLowerCase().contains('% off'));

    if (isDealBlock) {
      return _buildDealShowcase(context, cleanLines);
    }

    double size = double.tryParse(contentJson['size'].toString()) ?? 14.0;
    String weightStr = contentJson['weight'] ?? 'normal';
    String alignStr = contentJson['alignment'] ?? 'left';
    String colorStr = contentJson['color'] ?? '#000000';

    FontWeight weight =
        weightStr == 'bold' ? FontWeight.bold : FontWeight.normal;
    TextAlign align = TextAlign.left;
    if (alignStr == 'center') align = TextAlign.center;
    if (alignStr == 'right') align = TextAlign.right;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        cleanLines.join('\n\n'),
        textAlign: align,
        style: TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: _parseColor(colorStr),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildDealShowcase(BuildContext context, List<String> lines) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Pair up: title line followed by "up to X% off" line
    final deals = <({String title, String discount})>[];
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.toLowerCase().contains('up to') &&
          line.toLowerCase().contains('% off')) {
        final title = i > 0 ? lines[i - 1] : 'Special Deal';
        deals.add((title: title, discount: line));
      }
    }

    if (deals.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECE6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFE53935),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOP DEALS & OFFERS',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            fontSize: 12.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Limited-time curated discounts',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'HOT PICKS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Column(
              children: deals.map((deal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        openShop({'name': deal.title, 'source': 'deals_widget'});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF232328)
                              : const Color(0xFFF9F9FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                deal.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                deal.discount.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class StudioSectionHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final EdgeInsetsGeometry padding;

  const StudioSectionHeader({
    Key? key,
    this.title,
    this.subtitle,
    this.onSeeAll,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = title?.trim() ?? '';
    final rawSubtitle = subtitle?.trim() ?? '';

    // Only show if title is non-empty and not just a single placeholder character
    if (t.isEmpty || t == '_' || t.toLowerCase() == 'null') {
      return const SizedBox.shrink();
    }

    // Filter out ugly junk CMS subtitles
    final isJunkSubtitle = rawSubtitle.isEmpty ||
        rawSubtitle == '_' ||
        rawSubtitle.toLowerCase() == 'null' ||
        rawSubtitle.toLowerCase().contains('all products -');
    final s = isJunkSubtitle ? '' : rawSubtitle;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (s.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    s,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See all',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

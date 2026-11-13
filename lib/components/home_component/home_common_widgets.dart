import 'package:flutter/material.dart';

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

class TextBlockComponent extends StatefulWidget {
  final Map<String, dynamic> contentJson;

  const TextBlockComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  State<TextBlockComponent> createState() => _TextBlockComponentState();
}

class _TextBlockComponentState extends State<TextBlockComponent> {
  bool _isExpanded = false;

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    try {
      return Color(int.parse('0x$hexColor'));
    } catch (_) {
      return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String text = widget.contentJson['text']?.toString() ?? '';
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final cardBg = isDark ? colorScheme.surface : const Color(0xFFF8FAFC);
    final borderColor = colorScheme.outline.withOpacity(0.12);

    final lower = text.toLowerCase();

    // Render the luxury Brand Story card for Foduu Store
    final isAboutStore = lower.contains('brands people already trust') ||
        lower.contains('foduu store brings the brands');
    if (isAboutStore) {
      return _buildAboutFoduuStoryCard(
        context,
        colorScheme,
        isDark,
        cardBg,
        borderColor,
      );
    }

    // Suppress redundant split title box for About Foduu Store
    // which is unified into the luxury Brand Story card above.
    if (lower.contains('about foduu store') ||
        lower.contains('smarter way to shop') ||
        (lower.contains('about') && lower.contains('foduu'))) {
      return const SizedBox.shrink();
    }

    final title = widget.contentJson['title']?.toString() ?? '';
    final subtitle = widget.contentJson['subtitle']?.toString() ?? '';
    final bool isLongContent = text.length > 220;

    if (!isLongContent && title.isEmpty && subtitle.isEmpty) {
      double size =
          double.tryParse(widget.contentJson['size']?.toString() ?? '') ?? 14.0;
      String weightStr = widget.contentJson['weight'] ?? 'normal';
      String alignStr = widget.contentJson['alignment'] ?? 'left';
      String colorStr = widget.contentJson['color'] ?? '#000000';

      FontWeight weight =
          weightStr == 'bold' ? FontWeight.bold : FontWeight.normal;
      TextAlign align = TextAlign.left;
      if (alignStr == 'center') align = TextAlign.center;
      if (alignStr == 'right') align = TextAlign.right;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontSize: size,
            fontWeight: weight,
            color: _parseColor(colorStr),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty || subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 17,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              letterSpacing: 0.2,
                            ),
                          ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: (!isLongContent || _isExpanded)
                        ? double.infinity
                        : 140,
                  ),
                  child: ClipRect(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLongContent && !_isExpanded)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            cardBg.withOpacity(0.0),
                            cardBg.withOpacity(0.95),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isLongContent)
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: borderColor.withOpacity(0.7)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpanded ? 'Show Less' : 'Read More',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutFoduuStoryCard(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
    Color cardBg,
    Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Eyebrow Tag
          const Text(
            'ABOUT FODUU STORE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2563EB),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Main Headline
          Text(
            'A Smarter Way to Shop Everyday Electronics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),

          // Paragraph 1 (Always Visible)
          Text(
            'Foduu Store brings the brands people already trust — Apple, Samsung, Sony, LG and Philips — into one catalogue built for shoppers who read the spec sheet before the price tag. Every listing carries the detail that actually decides a purchase: panel type, battery figures, port layout, and what is genuinely in the box.',
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          // Collapsible Additional Details matching web
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Stock is checked across our warehouses every morning, so what reads as available really is, and the price on the product page is the price at checkout.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.55,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Support That Continues After Checkout',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Orders ship within 24 hours with full manufacturer warranty and tracking at every stage. Returns stay open for 30 days with no restocking fee, and our product specialists are reachable seven days a week — for setup help long after the box is opened, not only on the day it arrives.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.55,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Outlined Pill Button matching parent website
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? colorScheme.outline.withOpacity(0.3)
                      : const Color(0xFFD1D5DB),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? 'Show less ‹' : 'Read more ›',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    final s = subtitle?.trim() ?? '';

    // Only show if title is non-empty
    if (t.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  t,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onSeeAll != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSeeAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      'See all',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (s.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              s,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

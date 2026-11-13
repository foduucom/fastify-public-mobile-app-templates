import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class RichTextComponent extends StatefulWidget {
  final Map<String, dynamic> contentJson;

  const RichTextComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  State<RichTextComponent> createState() => _RichTextComponentState();
}

class _RichTextComponentState extends State<RichTextComponent> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String htmlContent =
        widget.contentJson['html_content']?.toString() ??
        widget.contentJson['content']?.toString() ??
        widget.contentJson['text']?.toString() ??
        '';

    if (htmlContent.trim().isEmpty) return const SizedBox.shrink();

    final title = widget.contentJson['title']?.toString() ?? '';
    final subtitle = widget.contentJson['subtitle']?.toString() ?? '';

    // Check if content is long enough to warrant an expand/collapse toggle
    final bool isLongContent = htmlContent.length > 220;

    final cardBg = isDark
        ? colorScheme.surface
        : const Color(0xFFF8FAFC);
    final borderColor = colorScheme.outline.withOpacity(0.12);

    final lower = htmlContent.toLowerCase();
    final isAboutStore = lower.contains('brands people already trust') ||
        lower.contains('about foduu store') ||
        lower.contains('smarter way to shop') ||
        title.toLowerCase().contains('about foduu store');

    if (isAboutStore) {
      // Suppress redundant heading/description from rich_text since TextBlockComponent
      // renders the single unified luxury Brand Story card below.
      return const SizedBox.shrink();
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
          // Header Row if title or subtitle exists
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

          // HTML Content Area
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: (!isLongContent || _isExpanded) ? double.infinity : 140,
                  ),
                  child: ClipRect(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Html(
                        data: htmlContent,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(12.5),
                            lineHeight: LineHeight(1.5),
                            color: colorScheme.onSurfaceVariant,
                          ),
                          "h1": Style(
                            fontSize: FontSize(16),
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            margin: Margins.only(bottom: 6),
                          ),
                          "h2": Style(
                            fontSize: FontSize(15),
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            margin: Margins.only(bottom: 6),
                          ),
                          "h3": Style(
                            fontSize: FontSize(14),
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            margin: Margins.only(bottom: 4),
                          ),
                          "h4": Style(
                            fontSize: FontSize(13),
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                            margin: Margins.only(bottom: 4),
                          ),
                          "p": Style(
                            margin: Margins.only(bottom: 8),
                            fontSize: FontSize(12.5),
                            lineHeight: LineHeight(1.5),
                            color: colorScheme.onSurfaceVariant,
                          ),
                          "span": Style(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        },
                      ),
                    ),
                  ),
                ),

                // Soft fade-out gradient overlay when collapsed
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

          // "Read More" / "Show Less" Action Bar
          if (isLongContent)
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
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
}

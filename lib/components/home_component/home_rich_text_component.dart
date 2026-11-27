import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class RichTextComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const RichTextComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final htmlContent = (contentJson['html_content'] ?? '').toString();
    final cleanText = htmlContent
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
    if (cleanText.isEmpty) return const SizedBox.shrink();

    // Editorial CMS pages use rich-text blocks for compact category tickers.
    if (cleanText.contains('✦')) {
      final segments = cleanText
          .split('✦')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      final colors = Theme.of(context).colorScheme;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withOpacity(0.45),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < segments.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('✦', style: TextStyle(color: Color(0xFFD4AF37))),
                    ),
                  Text(segments[i].toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          )),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Html(
        data: htmlContent,
      ),
    );
  }
}

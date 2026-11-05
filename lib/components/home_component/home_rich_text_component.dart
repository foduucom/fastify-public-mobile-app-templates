import 'package:flutter/material.dart';

class RichTextComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const RichTextComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    String raw = contentJson['html_content'] ?? '';
    final cleanText =
        raw.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();

    if (cleanText.isEmpty) return const SizedBox.shrink();

    // If it contains diamond/star tickers (e.g. Jeans ✦ Shirts ✦ Shorts)
    if (cleanText.contains('✦') || cleanText.contains('&nbsp;')) {
      final segments = cleanText
          .split('✦')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.35),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.18),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: segments.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.toUpperCase(),
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          fontSize: 11.5,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '✦',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Text(
        cleanText,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          height: 1.4,
        ),
      ),
    );
  }
}

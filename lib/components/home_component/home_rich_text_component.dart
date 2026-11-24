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

    // Check if the text contains a leading question or headline (e.g. "why Pixio ?...", "Questions ?...")
    if (cleanText.contains('?')) {
      final parts = cleanText.split('?');
      final question = '${parts.first.trim()}?';
      final remaining = parts.sublist(1).join('?').trim();

      // Check if it's an inquiry / question callout banner (e.g. Section 4: "Questions ? Our experts...")
      final isCallout = question.toLowerCase().contains('question');
      if (isCallout && remaining.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.contact_support_outlined,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        remaining,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.75),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Editorial question & story block (e.g. Section 2: "Why Pixio? It is a long established...")
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.isNotEmpty
                  ? '${question[0].toUpperCase()}${question.substring(1)}'
                  : question,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
            ),
            if (remaining.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                remaining,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Section header title (e.g. Section 5: "Meet our team of creators...")
    if (cleanText.length < 90 && !cleanText.contains('.')) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 6.0),
        child: Text(
          cleanText,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            height: 1.3,
            color: colorScheme.onSurface,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Text(
        cleanText,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          height: 1.45,
        ),
      ),
    );
  }
}

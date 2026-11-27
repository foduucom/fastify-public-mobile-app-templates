import 'package:flutter/material.dart';

/// Editorial header for the Blog page when CMS broadcasts a `rich_text`
/// section such as `"News & Insights"`.
class BlogPageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const BlogPageHeader({
    Key? key,
    required this.eyebrow,
    this.title = '',
    this.subtitle = '',
  }) : super(key: key);

  factory BlogPageHeader.fromMap(Map<String, dynamic>? json) {
    final raw = (json?['html_content'] ??
            json?['content'] ??
            json?['text'] ??
            'News & Insights')
        .toString()
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return BlogPageHeader(
      eyebrow: raw.isNotEmpty ? raw : 'News & Insights',
      title: (json?['title'] ?? '').toString().trim(),
      subtitle: (json?['subtitle'] ?? '').toString().trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_stories_outlined,
                  size: 13,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.3,
                color: colorScheme.onSurface,
              ),
            ),
          ],
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                height: 1.45,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

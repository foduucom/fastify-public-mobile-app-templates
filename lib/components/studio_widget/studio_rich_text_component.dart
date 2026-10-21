import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class RichTextComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const RichTextComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String htmlContent = (contentJson['html_content'] ?? '').toString().trim();
    if (htmlContent.isEmpty) return const SizedBox.shrink();

    final isPlainText =
        !htmlContent.contains('<') && !htmlContent.contains('>');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (isPlainText) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
        child: Text(
          htmlContent,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: colorScheme.onSurface,
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

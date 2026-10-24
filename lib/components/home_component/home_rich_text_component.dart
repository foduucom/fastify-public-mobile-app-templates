import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class RichTextComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const RichTextComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String htmlContent = contentJson['html_content'] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Html(
        data: htmlContent,
      ),
    );
  }
}

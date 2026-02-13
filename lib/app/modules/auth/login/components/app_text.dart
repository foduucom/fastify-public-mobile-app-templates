import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double height;
  final double letterSpacing;
  final Color? color;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  const AppText(
    this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.height = 1.2,
    this.letterSpacing = 0,
    this.color,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: fontWeight,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }
}

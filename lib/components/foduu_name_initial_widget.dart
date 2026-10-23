import 'package:flutter/material.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

/// Renders user initials (up to 2 characters) on a theme-styled background
/// as an avatar placeholder when no profile image is available.
class FoduuNameInitialWidget extends StatelessWidget {
  const FoduuNameInitialWidget({
    Key? key,
    required this.name,
    this.size = 70,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  final String? name;
  final double size;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;

  String _getInitials(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name ?? '');
    final effectiveBg =
        backgroundColor ?? context.themePrimaryColor.withOpacity(0.12);
    final effectiveText = textColor ?? context.themePrimaryColor;
    final calcFontSize =
        fontSize ?? (initials.length > 1 ? size * 0.35 : size * 0.42);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.themePrimaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: initials.isNotEmpty
          ? Text(
              initials,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: effectiveText,
                fontSize: calcFontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            )
          : Icon(
              Icons.person_outline,
              size: size * 0.5,
              color: effectiveText,
            ),
    );
  }
}

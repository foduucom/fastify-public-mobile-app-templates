import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final TextInputType keyboardType;
  final bool enabled;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final int? maxLines;
  final int? minLines;
  final double? fontSize;
  final Color? textColor;
  final Color? hintColor;
  final Color? labelColor;
  final Color? borderColor;
  final Color? focusColor;
  final Color? errorColor;
  final Color? disabledColor;
  final Color? fillColor;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final EdgeInsetsGeometry? contentPadding;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool enableInteractiveSelection; // ADD THIS

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.minLines,
    this.fontSize,
    this.textColor,
    this.hintColor,
    this.labelColor,
    this.borderColor,
    this.focusColor,
    this.errorColor,
    this.disabledColor,
    this.fillColor,
    this.prefixIconColor,
    this.suffixIconColor,
    this.contentPadding,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.enableInteractiveSelection = true, // ADD THIS WITH DEFAULT
  });

  OutlineInputBorder _border({
    required Color color,
    double width = 1.0,
    double radius = 12.0,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        width: width,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Smart default colors based on theme
    final defaultTextColor = textColor ?? theme.colorScheme.onSurface;
    final defaultHintColor =
        hintColor ?? theme.colorScheme.onSurfaceVariant.withOpacity(0.6);
    final defaultLabelColor = labelColor ?? theme.colorScheme.primary;
    final defaultBorderColor = borderColor ?? theme.colorScheme.outline;
    final defaultFocusColor = focusColor ?? theme.colorScheme.primary;
    final defaultErrorColor = errorColor ?? theme.colorScheme.error;
    final defaultDisabledColor =
        disabledColor ?? theme.colorScheme.onSurface.withOpacity(0.1);
    final defaultFillColor = fillColor ?? theme.colorScheme.surface;
    final defaultPrefixIconColor = theme.colorScheme.onSurfaceVariant;
    final defaultSuffixIconColor = theme.colorScheme.onSurfaceVariant;

    // Safety check for fontSize
    final double safeFontSize =
        (fontSize != null && fontSize! > 0) ? fontSize! : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              labelText!,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: defaultLabelColor,
              ),
            ),
          ),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          minLines: minLines,
          textInputAction: textInputAction,
          focusNode: focusNode,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          enableInteractiveSelection: enableInteractiveSelection,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: safeFontSize,
            fontWeight: FontWeight.w500,
            color: enabled ? defaultTextColor : defaultHintColor,
          ),
          decoration: InputDecoration(
            // Prefix Icon
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: defaultPrefixIconColor,
                  )
                : null,

            // Suffix Icon
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      size: 20,
                      color: defaultSuffixIconColor,
                    ),
                    onPressed: onSuffixIconPressed,
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,

            // Text Content
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: safeFontSize,
              fontWeight: FontWeight.w400,
              color: defaultHintColor,
            ),

            // Border Styling
            border: _border(color: defaultBorderColor),
            enabledBorder: _border(color: defaultBorderColor),
            focusedBorder: _border(
              color: defaultFocusColor,
              width: 2.0,
            ),
            errorBorder: _border(color: defaultErrorColor),
            focusedErrorBorder: _border(
              color: defaultErrorColor,
              width: 2.0,
            ),
            disabledBorder: _border(color: defaultDisabledColor),

            // Background & Padding
            filled: true,
            fillColor: enabled
                ? defaultFillColor
                : defaultDisabledColor.withOpacity(0.1),
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

            // Error Style
            errorStyle: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: defaultErrorColor,
              height: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

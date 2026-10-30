import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A password text field with a visibility toggle.
/// Used throughout the auth and profile change-password flows.
class AppPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final RxBool isVisible;
  final VoidCallback onToggle;
  final String? hintText;
  final double? fontSize;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AppPasswordField({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onToggle,
    this.hintText,
    this.fontSize,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() => TextFormField(
          controller: controller,
          obscureText: !isVisible.value,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: TextStyle(fontSize: fontSize),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: fontSize,
              color: scheme.onSurface.withValues(alpha: 0.45),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: scheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ));
  }
}


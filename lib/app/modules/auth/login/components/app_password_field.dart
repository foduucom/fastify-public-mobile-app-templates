import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class AppPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final RxBool isVisible;
  final VoidCallback onToggle;
  final String hintText;
  final double fontSize;
  final String? Function(String?)? validator;
  final bool enableInteractiveSelection; // ADD THIS

  const AppPasswordField({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onToggle,
    required this.fontSize,
    required this.hintText,
    this.validator,
    this.enableInteractiveSelection = true, // ADD THIS WITH DEFAULT
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(width: 1, color: color),
      );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // Safety check for fontSize
    final double safeFontSize = fontSize > 0 ? fontSize : 14.0;

    return Obx(
      () => SizedBox(
        height: height * 0.07,
        child: TextFormField(
          controller: controller,
          enableInteractiveSelection: enableInteractiveSelection,
          obscureText: !isVisible.value,
          validator: validator,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            fontSize: safeFontSize,
            height: 1.43,
            color: Theme.of(context).brightness == Brightness.dark
                ? DefaultThemeColors.darklighter
                : DefaultThemeColors.lightDarker,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Theme.of(context).brightness == Brightness.dark
                  ? DefaultThemeColors.darklighter
                  : context.onSurfaceVariantColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible.value ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).brightness == Brightness.dark
                    ? DefaultThemeColors.darklighter
                    : context.onSurfaceVariantColor,
              ),
              onPressed: onToggle,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w500,
              fontSize: fontSize,
              height: 1.43,
              color: Theme.of(context).brightness == Brightness.dark
                  ? DefaultThemeColors.darklighter
                  : DefaultThemeColors.lightDarker,
            ),
            border: _border(context.outlineColor),
            enabledBorder: _border(DefaultThemeColors.mainprimary!),
            focusedBorder: _border(DefaultThemeColors.mainprimary!),
            disabledBorder: _border(context.outlineColor),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: context.surfaceColor,
          ),
        ),
      ),
    );
  }
}

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

  const AppPasswordField({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onToggle,
    required this.fontSize,
    required this.hintText,
    this.validator,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(width: 1, color: color),
      );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Obx(
      () => SizedBox(
        height: height * 0.07,
        child: TextFormField(
          controller: controller,
          obscureText: !isVisible.value,
          validator: validator,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            fontSize: fontSize,
            height: 1.43,
            color: DefaultThemeColors.darklighter,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible.value ? Icons.visibility_off : Icons.visibility,
                color: DefaultThemeColors.darklighter,
              ),
              onPressed: onToggle,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w500,
              fontSize: fontSize,
              height: 1.43,
              color: DefaultThemeColors.darklighter,
            ),
            border: _border(DefaultThemeColors.lightOnPrimary),
            enabledBorder: _border(DefaultThemeColors.mainprimary!),
            focusedBorder: _border(DefaultThemeColors.mainprimary!),
            disabledBorder: _border(DefaultThemeColors.darklighter),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: DefaultThemeColors.lightOnPrimary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool enabled;
  final IconData? prefixIcon;
  final double fontSize;
  final Color textColor;
  final Color hintColor;
  final Color borderColor;
  final Color focusColor;
  final Color disabledColor;
  final Color fillColor;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.fontSize,
    required this.textColor,
    required this.hintColor,
    required this.borderColor,
    required this.focusColor,
    required this.disabledColor,
    required this.fillColor,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.prefixIcon,
    this.validator,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(width: 1, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.07,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        validator: validator,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          height: 1.43,
          color: textColor,
        ),
        decoration: InputDecoration(
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
            height: 1.43,
            color: hintColor,
          ),
          border: _border(borderColor),
          enabledBorder: _border(borderColor),
          focusedBorder: _border(focusColor),
          disabledBorder: _border(disabledColor),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: fillColor,
        ),
      ),
    );
  }
}

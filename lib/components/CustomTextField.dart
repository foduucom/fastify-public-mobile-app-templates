import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

class CartTextField extends StatelessWidget {
  const CartTextField({
    Key? key,
    required this.fieldHintText,
    required this.title,
    required this.validationmsg,
    required this.controller,
    this.validCheck,
    this.suffixIcon,
    this.fillcolor = Colors.white,
    this.keyType = TextInputType.text,
    this.obsecure = false,
    this.maxLine = 1,
    this.maxLength = 100,
    this.inputFormatters,
    this.readyOnly = false,
  }) : super(key: key);

  final String fieldHintText;
  final String title;
  final String validationmsg;
  final Color fillcolor;
  final TextEditingController controller;
  final String? Function(String?)? validCheck;
  final bool obsecure;
  final TextInputType keyType;
  final int maxLine;
  final int? maxLength;
  final bool readyOnly;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: TextFormField(
        maxLines: maxLine == 0 ? null : maxLine,
        readOnly: readyOnly == true ? true : readyOnly,
        inputFormatters: inputFormatters,
        controller: controller,
        keyboardType: keyType,
        obscureText: obsecure,
        maxLength: maxLength == 0 ? null : maxLength,
        decoration: InputDecoration(
            filled: false,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(themeButtonRadius),
                borderSide:
                    const BorderSide(color: themePrimaryColor, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(themeButtonRadius),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            label: Text(
              title,
              style: TextStyle(
                  color: context.themeSecondrytext,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
            hintText: fieldHintText,
            suffixIcon: suffixIcon ?? null),
        style: TextStyle(fontSize: 14),
        validator: validCheck,
      ),
    );
  }
}

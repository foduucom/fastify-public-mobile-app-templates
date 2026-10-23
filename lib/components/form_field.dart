import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/theme_ext.dart';

class AppFormTextField extends StatelessWidget {
  const AppFormTextField({
    Key? key,
    required this.fieldHintText,
    this.hintText = '',
    required this.controller,
    required this.validationmsg,
    required this.onsaved,
    this.validCheck,
    this.keyType = TextInputType.text,
    this.isTextInput = false,
    this.obsecure = false,
    this.maxLine = 1,
    this.textlength = 50,
    this.maxLength,
    this.inputFormatters,
    this.suffixIcon,
  }) : super(key: key);

  final String fieldHintText;
  final String hintText;
  final TextEditingController controller;
  final String validationmsg;
  final Function(String?)? onsaved;
  final String? Function(String?)? validCheck;
  final bool obsecure;
  final TextInputType keyType;
  final int maxLine;
  final int textlength;
  final bool isTextInput;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 17),
        TextFormField(
          maxLines: maxLine == 0 ? null : maxLine,
          onSaved: onsaved,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          cursorColor: context.themeSecondrytext,
          keyboardType: keyType,
          maxLength: maxLength,
          inputFormatters: inputFormatters ??
              (isTextInput
                  ? [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ]
                  : null),
          controller: controller,
          obscureText: obsecure,
          validator: validCheck,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
              suffixIcon: suffixIcon,
              hintText: hintText,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              labelText: fieldHintText,
              focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 253, 81, 81), width: 1)),
              errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 253, 81, 81), width: 1)),
              labelStyle: TextStyle(
                  color: context.themeSecondrytext, fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}

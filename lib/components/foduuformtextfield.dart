import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FoduuFormTextField extends StatelessWidget {
  const FoduuFormTextField({
    Key? key,
    required this.fieldHintText,
    required this.title,
    required this.validationmsg,
    required this.controller,
    this.validCheck,
    this.suffixIcon,
    this.readOnly = false,
    this.fillcolor = Colors.white,
    this.keyType = TextInputType.text,
    this.obsecure = false,
    this.maxLine = 1,
    this.inputFormatters,
  }) : super(key: key);

  final String fieldHintText;
  final String title;
  final bool readOnly;
  final String validationmsg;
  final Color fillcolor;
  final TextEditingController controller;
  final String? Function(String?)? validCheck;
  final bool obsecure;
  final TextInputType keyType;
  final int maxLine;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLine == 0 ? null : maxLine,
      inputFormatters: inputFormatters,
      controller: controller,

      // 👇 IMPORTANT: disable properly
      readOnly: readOnly,
      enabled: !readOnly,

      keyboardType: keyType,
      obscureText: obsecure,

      style: const TextStyle(color: Colors.black), // prevent fade

      decoration: InputDecoration(
        // 👇 fill color control
        filled: true,
        fillColor: readOnly
            ? Colors.grey.shade200   // disabled color
            : fillcolor,             // normal color

        // 👇 LABEL
        floatingLabelAlignment: FloatingLabelAlignment.start,
        floatingLabelBehavior: FloatingLabelBehavior.always,

        label: RichText(
          text: TextSpan(
            text: title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        // 👇 hint
        hintText: fieldHintText,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant
              .withOpacity(0.6),
        ),

        suffixIcon: suffixIcon,

        // 👇 borders (ALL states handled)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),

      validator: validCheck,
    );
  }
}
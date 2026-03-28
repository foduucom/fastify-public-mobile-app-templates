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
      readOnly: readOnly,
      keyboardType: keyType,
      obscureText: obsecure,
      decoration: InputDecoration(
        floatingLabelAlignment: FloatingLabelAlignment.start,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.6),
            ),
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
        hintText: fieldHintText,
        suffixIcon: suffixIcon,
      ),
      validator: validCheck,
    );
  }
}

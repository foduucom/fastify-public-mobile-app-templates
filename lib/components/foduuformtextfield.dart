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
    this.fillcolor,
    this.keyType = TextInputType.text,
    this.obsecure = false,
    this.maxLine = 1,
    this.inputFormatters,
    this.showAsterisk = true,
  }) : super(key: key);

  final String fieldHintText;
  final String title;
  final bool readOnly;
  final String validationmsg;
  final Color? fillcolor;
  final TextEditingController controller;
  final String? Function(String?)? validCheck;
  final bool obsecure;
  final TextInputType keyType;
  final int maxLine;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool showAsterisk;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color effectiveFillColor = fillcolor ?? colorScheme.surfaceVariant;
    final Color effectiveTextColor = colorScheme.onSurface;
    final Color effectiveHintColor = colorScheme.onSurfaceVariant;
    final Color effectiveBorderColor = colorScheme.outline;
    final Color effectiveLabelColor = colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Separate label widget for better control
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              text: title,
              style: TextStyle(
                color: effectiveLabelColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: showAsterisk
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: colorScheme.error, fontSize: 16),
                      ),
                    ]
                  : [],
            ),
          ),
        ),
        // TextField with proper background color
        Container(
          decoration: BoxDecoration(
            color: effectiveFillColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            maxLines: maxLine == 0 ? null : maxLine,
            inputFormatters: inputFormatters,
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyType,
            obscureText: obsecure,
            style: TextStyle(
              fontSize: 15,
              color: effectiveTextColor,
            ),
            decoration: InputDecoration(
              hintText: fieldHintText,
              hintStyle: TextStyle(
                fontSize: 15,
                color: effectiveHintColor,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: effectiveFillColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: effectiveBorderColor, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.error, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.error, width: 1.5),
              ),
            ),
            validator: validCheck,
          ),
        ),
      ],
    );
  }
}

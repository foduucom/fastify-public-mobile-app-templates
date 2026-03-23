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
    this.isRequired = true,       // ← NEW: toggle the red * star
    this.onTap,                   // ← NEW: for readOnly tap handling
    this.onChanged,               // ← NEW: listen to value changes
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
  final bool isRequired;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Field Label ──────────────────────────────────────────
        RichText(
          text: TextSpan(
            text: title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
            children: isRequired
                ? [
              // TextSpan(
              //   text: ' *',
              //   style: TextStyle(
              //     color: theme.colorScheme.error,
              //     fontSize: 16,
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
            ]
                : [],
          ),
        ),

        const SizedBox(height: 10),

        // ── Text Field ───────────────────────────────────────────
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyType,
          obscureText: obsecure,
          maxLines: obsecure ? 1 : (maxLine == 0 ? null : maxLine),
          inputFormatters: inputFormatters,
          onTap: onTap,
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: fieldHintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontSize: 14,
            ),
            suffixIcon: suffixIcon,

            // ── Fill ─────────────────────────────────────────────
            filled: true,
            fillColor: readOnly
                ? theme.colorScheme.surfaceVariant.withOpacity(0.4)
                : fillcolor,

            // ── Padding ───────────────────────────────────────────
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),

            // ── Borders ───────────────────────────────────────────
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),

            // ── No floating label (label is above via Column) ─────
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          validator: validCheck ??
                  (val) {
                if (isRequired && (val == null || val.trim().isEmpty)) {
                  return validationmsg;
                }
                return null;
              },
        ),
      ],
    );
  }
}

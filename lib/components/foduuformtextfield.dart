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
        hintStyle: const TextStyle(
          fontSize: 16,
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
        label: RichText(
          text: TextSpan(
            text: title,
            style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 18,
                fontWeight: FontWeight.w400),
            children: const [
              TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 22)),
            ],
          ),
        ),
        // label: Text(title,
        //     style: TextStyle(
        //         color: greyTextColor,
        //         fontSize: 18,
        //         fontWeight: FontWeight.w400)),
        hintText: fieldHintText,
        suffixIcon: suffixIcon ?? null,
        // prefixIcon: IconButton(
        //     icon: const Icon(
        //       Icons.search,
        //       color: Colors.grey,
        //     ),
        //     onPressed: () {}),
      ),
      validator: validCheck,
    );
  }
}

import 'package:flutter/material.dart';

Widget TextButtonCustom(String text, FontWeight? fontweight,
    Function()? onPressed, Color colour, double? fontsize) {
  return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
            fontWeight: fontweight, color: colour, fontSize: fontsize),
      ));
}

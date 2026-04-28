import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foduu_ecommerce/constants/constants.dart';

TextTheme txtTheme() {
  return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        // color: themeTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        // color: themeTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: 16,
        // color: themeTextColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 15.5,
      ),
      titleLarge: TextStyle(
        fontSize: 14,
      ),
      titleMedium: TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w400,
      ),
      titleSmall: TextStyle(
        fontSize: 10,
      ));
}

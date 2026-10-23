// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/constants.dart';
import '../../constants/theme_ext.dart';

class AppButton extends StatelessWidget {
  AppButton({
    Key? key,
    // required this.itemIcon,
    required this.itemText,
    required this.keypressEvent,
    this.width,
    this.fontSize,
  }) : super(key: key);

  // final String itemIcon;
  final String itemText;
  final VoidCallback keypressEvent;
  final double? width;
  final double? fontSize; // Allow custom font size
  double defaultFontSize = 16; // Adjust based on screen width

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? Get.width,
      height: themeButtonHeight,
      child: ElevatedButton(
        onPressed: keypressEvent,
        child: Text(itemText.toUpperCase(),
            style: TextStyle(
                color: Colors.white,
                // fontSize: 16,
                fontSize: fontSize ??
                    defaultFontSize, // Use custom font size if provided

                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins')),
        style: ElevatedButton.styleFrom(
          backgroundColor: themePrimaryColor,
          elevation: 0,
          // side: BorderSide(
          //     width: 1.0, color: Colors.black), // Border width and color
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(themeButtonRadius),
          ),
        ),
      ),
    );
  }
}

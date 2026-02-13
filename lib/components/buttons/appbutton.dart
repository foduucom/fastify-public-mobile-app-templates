// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/constants.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    Key? key,
    // required this.itemIcon,
    required this.itemText,
    required this.keypressEvent,
  }) : super(key: key);

  // final String itemIcon;
  final String itemText;
  final VoidCallback keypressEvent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: 42,
      child: ElevatedButton(
        onPressed: keypressEvent,
        child: Text(itemText.toUpperCase(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lato')),
        style: themeButton,
      ),
    );
  }
}

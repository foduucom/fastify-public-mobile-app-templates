import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';

class outLineButton extends StatelessWidget {
  outLineButton(
      {Key? key,
      required this.buttonText,
      required this.pressEvent,
      required this.backgroundColor})
      : super(key: key);
  String buttonText;
  VoidCallback pressEvent;
  Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: 40,
      child: OutlinedButton(
        onPressed: pressEvent,
        style: ButtonStyle(
            side: MaterialStateProperty.all(BorderSide(
          color: backgroundColor,
          width: 1.0,
          style: BorderStyle.solid,
        ))),
        child: Text(buttonText.toUpperCase(),
            style: txtTheme().titleLarge!.copyWith(
                color: backgroundColor,
                fontWeight: FontWeight.w600,
                fontSize: 16)),
      ),
    );
  }
}

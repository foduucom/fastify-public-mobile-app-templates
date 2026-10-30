import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../components/commonWidgets/success_dialog.dart';

class DialogHelper {
  static void showSuccessDialog({
    required String title,
    required String description,
    required String imagePath,
    String buttonText = "Continue",
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      SuccessDialog(
        title: title,
        description: description,
        imagePath: imagePath,
        buttonText: buttonText,
        onPressed: onPressed ?? Get.back,
      ),
      barrierDismissible: false,
    );
  }
}

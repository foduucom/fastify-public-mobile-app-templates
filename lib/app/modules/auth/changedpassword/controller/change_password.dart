// lib/app/modules/auth/resetpassword/controllers/resetpassword_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/basic_provider.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';

class ResetpasswordController extends GetxController {
  final formKey                   = GlobalKey<FormState>();
  final newPasswordController     = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading      = false.obs;
  var obscureNew     = true.obs;
  var obscureConfirm = true.obs;
  var email          = ''.obs;

  // ✅ Reactive password string — drives live rule indicators in the view
  var passwordText = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Read email from navigation arguments
    final args = Get.arguments;
    if (args != null) email.value = args['email'] ?? '';

    // ✅ Update passwordText on every keystroke → triggers Obx rebuild
    newPasswordController.addListener(() {
      passwordText.value = newPasswordController.text;
    });
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose(); // ✅ always call super.onClose()
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading(true);
    try {
      final body = {
        'email':    email.value,
        'password': newPasswordController.text.trim(),
      };

      final response = await BasicProvider('auth/reset-password')
          .postRequest(body);

      if (response != null) {
        HelperFunctions().showSnackBarSuccess('Password reset successfully!');
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (error) {
      HelperFunctions().showSnackBarError('Something went wrong. Try again.');
    } finally {
      isLoading(false);
    }
  }
}
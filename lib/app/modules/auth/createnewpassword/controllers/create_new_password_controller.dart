import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateNewPasswordController extends GetxController {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> updatePassword() async {
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();
    if (newPass.isEmpty || newPass != confirm) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }
    isLoading.value = true;
    // TODO: wire up to API service
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    Get.offAllNamed('/login');
  }
}

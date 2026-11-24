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
    if (newPass.length < 8) {
      Get.snackbar('Invalid password', 'Use at least 8 characters.');
      return;
    }
    if (newPass != confirm) {
      Get.snackbar('Error', 'Passwords do not match.');
      return;
    }

    // The backend currently exposes only authenticated password changes,
    // which require the current password. Never claim that an unauthenticated
    // reset succeeded without a reset endpoint/token contract.
    Get.snackbar(
      'Password reset unavailable',
      'This store has not configured password recovery. Please contact support.',
    );
  }
}

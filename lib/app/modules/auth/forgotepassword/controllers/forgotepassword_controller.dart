import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotepasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetLink() async {
    if (emailController.text.trim().isEmpty) return;
    isLoading.value = true;
    // TODO: wire up to API service
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    Get.back();
  }
}

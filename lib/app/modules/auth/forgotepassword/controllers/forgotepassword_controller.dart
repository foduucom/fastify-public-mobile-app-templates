import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/constants/app_exceptions.dart';

class ForgotepasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetLink() async {
    final email = emailController.text.trim();
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Invalid email', 'Enter a valid email address.');
      return;
    }

    isLoading.value = true;
    try {
      await BasicProvider('auth/resend-otp').postRequest({'email': email});
      Get.toNamed(Routes.OTP, arguments: {
        'email': email,
        'context': 'forgot_password',
      });
    } catch (error) {
      final message = error is AppException
          ? error.message ?? 'Unable to send a verification code.'
          : 'Unable to send a verification code. Please try again.';
      Get.snackbar('Could not send code', message);
    } finally {
      isLoading.value = false;
    }
  }
}

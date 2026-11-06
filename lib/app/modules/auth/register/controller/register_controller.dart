import 'package:flutter/material.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../provider/register_provider.dart';

class RegisterController extends GetxController {
  late TextEditingController emailController, nameController;
  var isLoading = false.obs;

  final RegisterProvider registerProvider = RegisterProvider();

  @override
  void onInit() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  String? validName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  String? validEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please provide a valid email!';
    }
    return null;
  }

  void reset() {
    nameController.clear();
    emailController.clear();
  }

  Future<void> onSubmit() async {
    debugPrint('RegisterController.onSubmit invoked');
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading(true);
    try {
      debugPrint('Calling RegisterProvider.sendOtp(...)');
      final result = await registerProvider.sendOtp(
        emailController.text.trim(),
        nameController.text.trim(),
      );
      debugPrint('sendOtp returned: $result');
      if (result != null) {
        Get.toNamed(Routes.OTP, arguments: {
          'email': emailController.text.trim(),
          'name': nameController.text.trim(),
          'context': 'register',
        });
      }
    } catch (e, st) {
      debugPrint('Registration error: $e\n$st');
    } finally {
      isLoading(false);
    }
  }
}

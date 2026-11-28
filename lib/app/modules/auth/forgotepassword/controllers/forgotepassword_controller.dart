import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:get/get.dart';

class ForgotepasswordController extends GetxController {
  TextEditingController emailController = TextEditingController();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  @override
  void onInit() {
    super.onInit();
  }

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Sign in method
  Future<void> forgot_password() async {
    if (isLoading.value || !formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email address.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await BasicProvider("auth/resend-otp").postRequest({
        'email': email,
      });

      final responseMap = response is Map ? response : null;
      final responseStatus = responseMap?['status']?.toString().toLowerCase();
      if (response == null ||
          responseMap?['success'] == false ||
          {'error', 'failed', 'failure'}.contains(responseStatus)) {
        final message = responseMap?['message']?.toString();
        throw Exception(message?.isNotEmpty == true
            ? message
            : 'We could not send a recovery code. Please try again.');
      }

      final message = responseMap?['message']?.toString();
      if (Get.context != null) {
        final colorScheme = Theme.of(Get.context!).colorScheme;
        Get.snackbar(
          'Recovery code sent',
          message?.isNotEmpty == true
              ? message!
              : 'Check your email for the verification code.',
          backgroundColor: colorScheme.primary,
          colorText: colorScheme.onPrimary,
        );
      }

      Get.toNamed(Routes.OTP, arguments: {
        'email': email,
        'context': 'forgot_password',
      });
    } catch (e) {
      errorMessage.value = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'We could not send a recovery code. Please try again.';
      if (Get.context != null) {
        final colorScheme = Theme.of(Get.context!).colorScheme;
        Get.snackbar(
          'Unable to send code',
          errorMessage.value,
          backgroundColor: colorScheme.error,
          colorText: colorScheme.onError,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}

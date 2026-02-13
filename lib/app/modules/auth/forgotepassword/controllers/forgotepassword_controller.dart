import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
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
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        errorMessage.value = '';

        final BasicProvider _provider = BasicProvider("auth/resend-otp");

        Map<String, dynamic> data = {
          'email': emailController.text.trim(),
        };

        // Make API call
        dynamic response = await _provider.postRequest(data);

        //Get.offAllNamed('/home');
        if (response is String) {
          // Show success message
          Get.snackbar(
            'Success',
            response,
            backgroundColor: Colors.green,
          );

          // Navigate to OTP screen or login screen
          // Navigate to OTP screen with email
          Get.toNamed(Routes.OTP, arguments: {
            'email': emailController.text.trim(), // Pass email here
            'context': 'forgot_password', // Add context if needed
          });
        } else {
          print(response['message']);
          // Handle error from API
          errorMessage.value = response['message'] ?? 'Something went wrong';
          Get.snackbar(
            'Error',
            errorMessage.value,
            backgroundColor: DefaultThemeColors.alertErrorLighter,
          );
        }
      } catch (e) {
        // Handle exceptions
        print(e.toString());
        errorMessage.value = e.toString();
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: DefaultThemeColors.alertErrorLighter,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}

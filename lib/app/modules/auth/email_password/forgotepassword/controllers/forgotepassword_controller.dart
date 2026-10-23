import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/app_exceptions.dart';
import 'package:zouhi/constants/helper_functions.dart';

class ForgotepasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  String? validEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return "Please enter email address";
    }
    if (!GetUtils.isEmail(trimmed)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (Get.context != null) {
      HelperFunctions().closeKeyboard(Get.context!);
    }
    isLoading.value = true;

    final email = emailController.text.trim();

    try {
      final response = await BasicProvider("auth/resend-otp").postRequest({
        "email": email,
      });

      isLoading.value = false;
      isOtpSent.value = true;

      String successMsg = "Verification code sent to $email. Please check your inbox.";
      if (response is Map) {
        if (response["message"] != null && response["message"].toString().isNotEmpty) {
          successMsg = response["message"].toString();
        } else if (response["data"] != null && response["data"].toString().isNotEmpty) {
          successMsg = response["data"].toString();
        }
      } else if (response is String && response.isNotEmpty) {
        successMsg = response;
      }

      HelperFunctions().showSnackBarSuccess(successMsg);
      Get.toNamed(Routes.FORGOT_PASSWORD_OTP, arguments: {'email': email});
    } catch (e) {
      isLoading.value = false;
      String errorMsg = "Failed to send verification code. Please try again.";

      if (e is AppException) {
        errorMsg = e.message ?? errorMsg;
      } else if (e is Map) {
        errorMsg = e["data"]?.toString() ??
            e["message"]?.toString() ??
            e["error"]?.toString() ??
            errorMsg;
      } else if (e is String && e.isNotEmpty) {
        errorMsg = e;
      }

      HelperFunctions().showSnackBarError(errorMsg);
    }
  }
}


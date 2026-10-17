import 'package:flutter/material.dart';
import '/app/data/basic_provider.dart';
import '/app/routes/app_pages.dart';
import '/app/modules/auth/auth_settings_helper.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var box = GetStorage();

  late TextEditingController nameController,
      mobileController,
      emailController,
      passwordController,
      confirmPasswordController;

  var isLoading = false.obs;
  var showPassword = false.obs;
  var isChecked = true.obs;

  // Auth settings
  var isOtpMode = false.obs;
  var isPasswordMode = true.obs;

  @override
  void onInit() {
    nameController = TextEditingController();
    mobileController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // Load auth settings
    loadAuthSettings();
    super.onInit();
  }

  void loadAuthSettings() {
    isOtpMode.value = AuthSettingsHelper.isEmailOtpEnabled();
    isPasswordMode.value = AuthSettingsHelper.isEmailPasswordEnabled();
    print(
        'Register Auth Mode - OTP: ${isOtpMode.value}, Password: ${isPasswordMode.value}');
  }

  void onChecked(val) {
    isChecked.value = val;
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Main submit handler - routes to OTP or password flow
  Future<void> onSubmit([GlobalKey<FormState>? key]) async {
    final targetForm = key ?? formKey;
    if (targetForm.currentState!.validate()) {
      isLoading(true);

      try {
        var body = {};

        if (isOtpMode.value) {
          body = {
            'email': emailController.text.trim(),
            'name': nameController.text.trim(),
            'mobile': mobileController.text.trim(),
            'device_details': await HelperFunctions.getDeviceDetails(),
          };
        } else {
          body = {
            'name': nameController.text.trim(),
            'mobile': mobileController.text.trim(),
            'email': emailController.text.trim(),
            'password': passwordController.text,
            'device_details': await HelperFunctions.getDeviceDetails(),
          };
        }

        print('register form submitted $body');

        var response = await BasicProvider('auth/register').postRequest(body);
        if (response != null) {
          String successMessage = 'Registration successful!';
          if (response is Map && response['message'] != null) {
            successMessage = response['message'].toString();
          } else if (response is String && response.isNotEmpty) {
            successMessage = response;
          }
          HelperFunctions().showSnackBarSuccess(successMessage);
          if (isOtpMode.value) {
            Get.toNamed(Routes.OTP, arguments: {
              'email': emailController.text.trim(),
              'mobile': mobileController.text.trim(),
              'name': nameController.text.trim(),
              'password': passwordController.text,
            });
          } else {
            Get.offAllNamed(Routes.LOGIN);
          }
        }
      } catch (e) {
        print('Registration error: $e');
      } finally {
        isLoading(false);
      }
    }
  }
}
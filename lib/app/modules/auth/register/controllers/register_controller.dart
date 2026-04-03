import 'package:flutter/material.dart';
import '/app/data/basic_provider.dart';
import '/app/routes/app_pages.dart';
import '/app/modules/auth/auth_settings_helper.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final box = GetStorage();

  // ✅ No more `late` — initialized directly as fields
  final nameController            = TextEditingController();
  final mobileController          = TextEditingController();
  final emailController           = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading     = false.obs;
  var showPassword  = false.obs;
  var isChecked     = true.obs;
  var isOtpMode     = false.obs;
  var isPasswordMode = true.obs;

  @override
  void onInit() {
    super.onInit(); // ✅ super.onInit() FIRST
    loadAuthSettings();
  }

  void loadAuthSettings() {
    isOtpMode.value     = AuthSettingsHelper.isEmailOtpEnabled();
    isPasswordMode.value = AuthSettingsHelper.isEmailPasswordEnabled();
    print('Register Auth Mode - OTP: ${isOtpMode.value}, Password: ${isPasswordMode.value}');
  }

  void onChecked(val) => isChecked.value = val;

  Future<void> onSubmit() async {
    if (formKey.currentState!.validate()) {
      isLoading(true);
      try {
        final deviceDetails = await HelperFunctions.getDeviceDetails();

        final body = isOtpMode.value
            ? {
          'email':          emailController.text,
          'name':           nameController.text,
          'mobile':         mobileController.text,
          'device_details': deviceDetails,
        }
            : {
          'name':              nameController.text,
          'mobile':            mobileController.text,
          'email':             emailController.text,
          'password':          passwordController.text,
          'confirem-password': confirmPasswordController.text,
          'device_details':    deviceDetails,
        };

        print('register form submitted $body');

        final response = await BasicProvider('auth/register').postRequest(body);

        if (response != null) {
          HelperFunctions().showSnackBarSuccess(response);
          if (isOtpMode.value) {
            Get.toNamed(Routes.OTP, arguments: {
              'email':             emailController.text,
              'mobile':            mobileController.text,
              'name':              nameController.text,
              'password':          passwordController.text,
              'confirem-password': confirmPasswordController.text,
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

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
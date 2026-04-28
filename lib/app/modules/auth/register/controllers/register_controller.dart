import 'package:flutter/widgets.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_settings_helper.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var box = GetStorage();
  late TextEditingController mobileController,
      emailController,
      nameController,
      passwordController;
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
    super.onClose();
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  /// Main submit handler - routes to OTP or password flow
  Future<void> onSubmit() async {
    if (formKey.currentState!.validate()) {
      isLoading(true);

      try {
        var body = {};

        if (isOtpMode.value) {
          body = {
            'email': emailController.text,
            'name': nameController.text,
            'mobile': mobileController.text,
            'device_details': await HelperFunctions.getDeviceDetails(),
          };
        } else {
          body = {
            'name': nameController.text,
            'mobile': mobileController.text,
            'email': emailController.text,
            'password': passwordController.text,
            'device_details': await HelperFunctions.getDeviceDetails(),
          };
        }

        print('register form submitted ${body}');

        var response = await BasicProvider('auth/register').postRequest(body);
        // print('Register Response ${response}');
        if (response != null) {
          HelperFunctions().showSnackBarSuccess(response);
          if (isOtpMode.value) {
            Get.toNamed(Routes.OTP, arguments: {
              'email': emailController.text,
              'mobile': mobileController.text,
              'name': nameController.text,
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

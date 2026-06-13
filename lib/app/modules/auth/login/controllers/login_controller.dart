import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_settings_helper.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController with BaseController {
  var obsecuretext = true.obs;
  var isLoading = false.obs;
  late TextEditingController emailController, passwordController;
  var email = "";
  var password = "";

  final box = GetStorage();
  // Auth type from settings
  var isOtpMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Load auth settings
    loadAuthSettings();
  }

  void loadAuthSettings() {
    isOtpMode.value = AuthSettingsHelper.isEmailOtpEnabled();
    print('Login Auth Mode - OTP: ${isOtpMode.value}');
  }

  // Validate email format
  String? validEmail(String value) {
    if (!GetUtils.isEmail(value)) {
      return "Please provide a valid email!";
    }
    return null;
  }

  // Validate password
  String? validPassword(String value) {
    if (value.isEmpty || value.length < 6) {
      return "Password must be at least 6 characters long.";
    }
    return null;
  }

  /// Main submit handler - routes based on auth type
  Future<void> onSubmit(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    isLoading(true);

    try {
      var form = {
        'email': emailController.text,
        'device_details': await HelperFunctions.getDeviceDetails(),
      };

      if (!isOtpMode.value) {
        form['password'] = passwordController.text;
      }

      var response = await BasicProvider('auth/login')
          .postRequest(form)
          .catchError(handleError);

      if (response != null) {
        if (!isOtpMode.value) {
          HelperFunctions().showSnackBarSuccess(response);
          Get.toNamed(Routes.OTP, arguments: {'email': emailController.text});
        } else {
          // Get.toNamed(Routes.BOTTOMBAR);
          HelperFunctions().showSnackBarSuccess(response);
          Get.toNamed(Routes.OTP, arguments: {'email': emailController.text});
        }
      }

      // if (response != null) {
      //   box.write('isLogin', true);
      //   Get.offAllNamed(Routes.BOTTOMBAR);
      // }
    } catch (e, stackTrace) {
      print('Login error: $e');
      print('Login stackTrace: $stackTrace');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }
}

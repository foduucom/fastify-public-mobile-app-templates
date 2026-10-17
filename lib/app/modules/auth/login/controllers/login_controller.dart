import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';
import '/app/modules/auth/auth_settings_helper.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController with BaseController {
  var obsecuretext = true.obs;
  var isLoading = false.obs;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController emailController, passwordController;
  var email = "";
  var password = "";

  final box = GetStorage();
  // Auth type from settings
  var isOtpMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
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
  Future<void> onSubmit([GlobalKey<FormState>? key]) async {
    final targetForm = key ?? formKey;
    if (targetForm.currentState == null || !targetForm.currentState!.validate()) return;

    isLoading(true);

    try {
      var form = {
        'email': emailController.text.trim(),
        'device_details': await HelperFunctions.getDeviceDetails(),
      };

      if (!isOtpMode.value) {
        form['password'] = passwordController.text;
      }

      var response = await BasicProvider('auth/login')
          .postRequest(form)
          .catchError(handleError);

      if (response != null) {
        String successMessage = 'OTP sent successfully!';
        if (response is Map && response['message'] != null) {
          successMessage = response['message'].toString();
        } else if (response is String && response.isNotEmpty) {
          successMessage = response;
        }
        HelperFunctions().showSnackBarSuccess(successMessage);
        Get.toNamed(Routes.OTP, arguments: {'email': emailController.text.trim()});
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

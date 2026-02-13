import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_settings_helper.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/provider/provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  var obsecuretext = true.obs;
  var isLoading = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController emailController, passwordController;
  var email = "";
  var password = "";

  final box = GetStorage();
  final AuthProvider authProvider = AuthProvider();

  // Auth type from settings
  var isOtpMode = false.obs;

  // Toggle password visibility
  void togglePasswordVisibility() {
    obsecuretext.value = !obsecuretext.value;
  }

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
  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading(true);

    try {
      var form = {
        'email': emailController.text,
        // 'device_details': await HelperFunctions.getDeviceDetails(),
      };

      if (isOtpMode.value) {
        // form['otp'] = passwordController.text;
      } else {
        form['password'] = passwordController.text;
      }
      print('form form form ${form.toString()}');

      var response = await authProvider.sendLoginRequest(form);

      if (response != null) {
        // _handleLoginSuccess(response);
        // AuthDetails().
        box.write('isLogin', true);
        Get.offAllNamed(Routes.BOTTOMBAR);
      }
    } catch (e) {
      print('Login error: $e');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

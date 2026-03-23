import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
          // ✅ added
import '/app/modules/auth/auth_settings_helper.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';

class CreateAccountController extends GetxController with BaseController {

  // ── State ────────────────────────────────────────────────────
  final obscureText = true.obs;
  final isLoading   = false.obs;
  final isOtpMode   = false.obs;

  // ── Form ─────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    emailController    = TextEditingController();
    passwordController = TextEditingController();
    _loadAuthSettings();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ── Auth Settings ─────────────────────────────────────────────
  void _loadAuthSettings() {
    isOtpMode.value = AuthSettingsHelper.isEmailOtpEnabled();
  }

  void togglePassword() => obscureText.toggle();

  // ── Skip (guest) ──────────────────────────────────────────────
  void skipLogin() {
    // Guest skips login — no token, no socket connection needed
    Get.offAllNamed('/bottombar');
  }

  // ── Validators ────────────────────────────────────────────────
  String? validEmail(String? value) {
    if (value == null || !GetUtils.isEmail(value)) {
      return 'Please provide a valid email!';
    }
    return null;
  }

  String? validPassword(String? value) {
    if (!isOtpMode.value && (value == null || value.length < 6)) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────
  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading(true);

    try {
      final form = <String, dynamic>{
        'email':          emailController.text.trim(),
        'device_details': await HelperFunctions.getDeviceDetails(),
      };

      if (!isOtpMode.value) {
        form['password'] = passwordController.text;
      }

      final response = await BasicProvider('auth/login')
          .postRequest(form)
          .catchError(handleError);

      if (response != null) {
        HelperFunctions().showSnackBarSuccess(response);

        // ✅ Go to OTP — socket connects AFTER OTP success in OTP controller
        Get.toNamed(
          Routes.OTP,
          arguments: {'email': emailController.text.trim()},
        );
      }
    } catch (e, stack) {
      debugPrint('Login error: $e\n$stack');
    } finally {
      isLoading(false);
    }
  }
}

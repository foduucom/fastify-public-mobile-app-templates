import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';

class OtpController extends GetxController with BaseController {

  final isLoading   = false.obs;
  final isResending = false.obs;
  final otpCode     = ''.obs;
  late String email;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
    debugPrint('OTP screen — email: $email');
  }

  void onOtpChanged(String value) => otpCode.value = value;

  // ── Verify OTP ─────────────────────────────────────────────────
  Future<void> verifyOtp() async {
    if (otpCode.value.length < 4) {
      HelperFunctions().showSnackBarError('Please enter the complete OTP');
      return;
    }

    isLoading(true);

    try {
      final response = await BasicProvider('auth/verify-otp')
          .postRequest({
        'email':          email,
        'otp':            otpCode.value,
        'device_details': await HelperFunctions.getDeviceDetails(),
      })
          .catchError(handleError);

      if (response != null) {
        // ── BasicProvider already returns response.body["data"] ──
        // So `response` IS the user object directly.
        // Structure: { id, name, email, mobile, token: { value, expiry }, ... }
        final data = Map<String, dynamic>.from(response as Map); // ✅ no ['data'] unwrap

        // ── Extract token ──────────────────────────────────────
        final tokenObj = data['token'];
        final token    = tokenObj is Map
            ? tokenObj['value']?.toString() ?? ''
            : '';

        debugPrint('🔍 data keys: ${data.keys.toList()}');
        debugPrint('🔍 tokenObj: $tokenObj');
        debugPrint('🔍 token: $token');

        if (token.isNotEmpty) {
          // ✅ Save JWT token
          AuthDetails.saveToken(token);
          box.write('isLogin',    true);
          box.write('auth_token', token);

          // ✅ Save basic user info for immediate ProfileController use
          box.write('user_name',  data['name']?.toString()  ?? '');
          box.write('user_email', data['email']?.toString() ?? '');
          box.write('user_id',    data['id']?.toString()    ?? '');

          // ✅ Verify storage actually worked
          final verify = box.read<String>('auth_token') ?? 'EMPTY';
          debugPrint('🔐 Token read-back: ${verify.length > 20 ? verify.substring(0, 20) : verify}...');
        } else {
          debugPrint('⚠️ Token missing — full response: $response');
        }

        HelperFunctions().showSnackBarSuccess('Login successful!');
        Get.offAllNamed(Routes.BOTTOMBAR);
      }
    } catch (e) {
      debugPrint('OTP verify error: $e');
    } finally {
      isLoading(false);
    }
  }

  // ── Resend OTP ─────────────────────────────────────────────────
  Future<void> resendOtp() async {
    isResending(true);
    try {
      final response = await BasicProvider('auth/login')
          .postRequest({
        'email':          email,
        'device_details': await HelperFunctions.getDeviceDetails(),
      })
          .catchError(handleError);

      if (response != null) {
        HelperFunctions().showSnackBarSuccess('OTP resent to $email');
      }
    } catch (e) {
      debugPrint('Resend OTP error: $e');
    } finally {
      isResending(false);
    }
  }
}

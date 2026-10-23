import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/auth/token_manager.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/app_exceptions.dart';
import 'package:zouhi/constants/helper_functions.dart';

class EmailOtpController extends GetxController {
  final box = GetStorage();

  final email = ''.obs;
  final isLoading = false.obs;
  final isResending = false.obs;
  final resendSeconds = 60.obs;
  Timer? _timer;

  // 6 Individual digit controllers & focus nodes
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  final List<FocusNode> keyboardFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool get canResend => resendSeconds.value == 0 && !isResending.value;

  String get currentOtp =>
      otpControllers.map((controller) => controller.text).join();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map && args['email'] != null) {
      email.value = args['email'].toString().trim();
    }
    _startCountdown();
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    for (final k in keyboardFocusNodes) {
      k.dispose();
    }
    super.onClose();
  }

  void _startCountdown() {
    _timer?.cancel();
    resendSeconds.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  /// Handles input change for each OTP box (handles auto-advance, backspace, paste)
  void onDigitChanged(int index, String value) {
    // Check if pasted multiple digits
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        for (int i = 0; i < 6; i++) {
          if (i < digits.length) {
            otpControllers[i].text = digits[i];
          }
        }
        final targetIndex = (digits.length >= 6) ? 5 : digits.length;
        focusNodes[targetIndex].requestFocus();

        if (currentOtp.length == 6) {
          verifyOtp();
        }
        return;
      }
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
      if (currentOtp.length == 6) {
        verifyOtp();
      }
    }
  }

  /// Handles backspace press to navigate to previous box
  void onBackspacePressed(int index) {
    if (otpControllers[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
      otpControllers[index - 1].text = '';
    }
  }

  /// Resends the OTP using api/auth/resend-otp
  Future<void> resendOtp() async {
    if (!canResend) return;

    if (email.value.isEmpty) {
      HelperFunctions().showSnackBarError("Email address is missing.");
      return;
    }

    isResending.value = true;
    try {
      final response = await BasicProvider("auth/resend-otp").postRequest({
        "email": email.value,
      });

      isResending.value = false;
      _startCountdown();

      // Clear current boxes
      for (final c in otpControllers) {
        c.clear();
      }
      focusNodes[0].requestFocus();

      String successMsg =
          "Verification code resent to ${email.value}. Please check your inbox.";
      if (response is Map) {
        if (response["message"] != null &&
            response["message"].toString().isNotEmpty) {
          successMsg = response["message"].toString();
        } else if (response["data"] != null &&
            response["data"].toString().isNotEmpty) {
          successMsg = response["data"].toString();
        }
      } else if (response is String && response.isNotEmpty) {
        successMsg = response;
      }

      HelperFunctions().showSnackBarSuccess(successMsg);
    } catch (e) {
      isResending.value = false;
      String errorMsg = "Failed to resend verification code. Please try again.";
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

  /// Verifies OTP using api/auth/verify-otp and logs user into session
  Future<void> verifyOtp() async {
    final otp = currentOtp.trim();
    if (otp.length < 6) {
      HelperFunctions()
          .showSnackBarError("Please enter the complete 6-digit OTP");
      return;
    }

    if (email.value.isEmpty) {
      HelperFunctions()
          .showSnackBarError("Email is missing. Please go back and retry.");
      return;
    }

    if (Get.context != null) {
      HelperFunctions().closeKeyboard(Get.context!);
    }
    isLoading.value = true;

    try {
      // Optional device details and FCM token
      String? fcmToken;
      try {
        fcmToken = await NotificationService.getFcmToken();
      } catch (_) {}

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo? androidInfo;
      IosDeviceInfo? iosInfo;
      try {
        if (Platform.isAndroid) {
          androidInfo = await deviceInfo.androidInfo;
        } else if (Platform.isIOS) {
          iosInfo = await deviceInfo.iosInfo;
        }
      } catch (_) {}

      final Map<String, dynamic> requestBody = {
        "email": email.value,
        "otp": otp,
        if (fcmToken != null) "fcm_token": fcmToken,
        if (androidInfo != null || iosInfo != null)
          "device_details": {
            "type": Platform.operatingSystem,
            "mobile_name": Platform.isAndroid
                ? androidInfo!.model
                : (iosInfo?.utsname.machine ?? 'iOS'),
            "brand": Platform.isAndroid
                ? androidInfo!.manufacturer
                : (iosInfo?.model ?? 'Apple'),
            "version": Platform.isAndroid
                ? androidInfo!.version.release
                : (iosInfo?.systemVersion ?? ''),
            "device_identifier": Platform.isAndroid
                ? androidInfo!.id.toString()
                : (iosInfo?.identifierForVendor ?? ''),
          }
      };

      final response =
          await BasicProvider("auth/verify-otp").postRequest(requestBody);
      isLoading.value = false;

      if (response != null) {
        // Extract token
        String? tokenValue;
        if (response is Map) {
          if (response['token'] is Map && response['token']['value'] != null) {
            tokenValue = response['token']['value'].toString();
          } else if (response['token'] is String &&
              response['token'].toString().isNotEmpty) {
            tokenValue = response['token'].toString();
          } else if (response['access_token'] != null) {
            tokenValue = response['access_token'].toString();
          } else if (response['data'] is Map &&
              response['data']['token'] is Map) {
            tokenValue = response['data']['token']['value']?.toString();
          }
        }

        if (tokenValue != null && tokenValue.isNotEmpty) {
          await TokenManager.setAccessToken(tokenValue);
        }

        // Extract user data
        dynamic userData;
        if (response is Map) {
          if (response['user'] != null && response['user'] is Map) {
            userData = response['user'];
          } else if (response['customer'] != null &&
              response['customer'] is Map) {
            userData = response['customer'];
          } else if (response['data'] != null && response['data'] is Map) {
            userData = response['data'];
          } else if (response.containsKey('id') ||
              response.containsKey('email')) {
            final userMap = Map<String, dynamic>.from(response);
            userMap.remove('token');
            userData = userMap;
          }
        }

        if (userData != null) {
          box.write('userData', userData);
        }

        box.write('isLogin', true);

        try {
          await AuthDetails().updateUserDetailsFromServer();
        } catch (_) {}

        if (Get.isRegistered<ProfileController>()) {
          final pc = Get.find<ProfileController>();
          pc.getBoxData();
          pc.fetchDataFromServer(forceRefresh: true);
        }

        HelperFunctions()
            .showSnackBarSuccess("Verification successful! Welcome back.");
        Get.offAllNamed(Routes.BOTTOMBAR);
      } else {
        HelperFunctions()
            .showSnackBarError("Invalid verification code. Please try again.");
      }
    } catch (e) {
      isLoading.value = false;
      String errorMsg =
          "Verification failed. Please check the code and try again.";
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

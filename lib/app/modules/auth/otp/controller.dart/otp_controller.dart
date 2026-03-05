import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/provider/otp_provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/app_exceptions.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

//enum OtpContext { login, register }
enum OtpContext {
  login,
  register,
  forgotPassword, // Add this
}

class OtpController extends GetxController with BaseController {
  var isLoading = false.obs;
  var isResendVisible = false.obs;
  final box = GetStorage();
  var otpCode = "".obs;
  var activeIndex = 0.obs;
  var countdown = 30.obs; // Countdown in seconds
  Timer? _countdownTimer;

  // Context-specific variables
  var email = "".obs;
  var otpContext = OtpContext.login.obs;

  //final AuthProvider authProvider = AuthProvider();
  //final RegisterProvider registerProvider = RegisterProvider();

  final OtpProvider otpProvider = OtpProvider();

  @override
  Future<void> onInit() async {
    super.onInit();

    final args = Get.arguments;
    if (args != null) {
      email.value = args['email'] ?? '';
      //String contextStr = args['context'] ?? 'login';
      //otpContext.value =
      //  contextStr == 'register' ? OtpContext.register : OtpContext.login;
      String contextStr =
          args['context'] ?? 'forgot_password'; // Default to forgot_password
      otpContext.value = _getOtpContext(contextStr);
      print('OTP Screen - Email: ${email.value}, Context: ${otpContext.value}');
    } else {
      // Fallback - try to get from storage or previous screen
      email.value = box.read('userEmail') ?? '';
      print('OTP Screen - No args, using stored email: ${email.value}');
    }

    startCountdown();
  }

// Helper method to convert string to OtpContext enum
  OtpContext _getOtpContext(String contextStr) {
    switch (contextStr) {
      case 'register':
        return OtpContext.register;
      case 'login':
        return OtpContext.login;
      case 'forgot_password':
      default:
        return OtpContext.forgotPassword; // Add this to your enum
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  void setActive(int index) {
    activeIndex.value = index;
  }

  void clearOtp() {
    otpCode.value = "";
    activeIndex.value = 0;
  }

  void updateOtp(String otp) {
    otpCode.value = otp;
    if (otp.length < 4) {
      activeIndex.value = otp.length;
    } else {
      activeIndex.value = 3;
    }
  }

  Future<void> verifyOtp({required String otp}) async {
    if (otp.isEmpty || otp.length < 4) {
      HelperFunctions().showSnackBarError("Please enter 4-digit OTP");
      return;
    }

    if (email.value.isEmpty) {
      HelperFunctions().showSnackBarError("Email is required");
      return;
    }

    isLoading(true);

    try {
      // Different endpoints based on context
      if (otpContext.value == OtpContext.forgotPassword) {
        await _verifyForgotPasswordOtp(otp);
      } else {
        await _verifyAuthOtp(otp);
      }
    } catch (error) {
      isLoading(false);
      print('OTP verification error: $error');
      HelperFunctions()
          .showSnackBarError("OTP verification failed. Please try again.");
    }
  }

// For forgot password verification
  Future<void> _verifyForgotPasswordOtp(String otp) async {
    try {
      final response = await otpProvider.verifyOtp(email.value, otp);

      if (response != null && response['statusCode'] == 200) {
        await _handleSuccessResponse(response);
      } else {
        // FIX: Handle null or invalid response
        final errorMessage = response?['body']?['message']?.toString() ??
            'Invalid response from server';
        throw Exception("Invalid response from server");
      }
    } catch (error) {
      print('OTP verification error type: ${error.runtimeType}');
      print('OTP verification error: $error');

      // FIX: Handle different error types
      String errorMessage = "OTP verification failed. Please try again.";

      if (error is FormatException) {
        errorMessage = error.message ?? 'Invalid OTP format';
      } else if (error is UnAuthorizedException) {
        errorMessage = error.toString();
      } else if (error is Exception) {
        errorMessage = error.toString();
      } else if (error is String) {
        errorMessage = error;
      }

      HelperFunctions().showSnackBarError(errorMessage);
    }
  }

// For login/register verification
  Future<void> _verifyAuthOtp(String otp) async {
    try {
      final response = await otpProvider.verifyOtp(email.value, otp);

      if (response != null && response['statusCode'] == 200) {
        await _handleSuccessResponse(response);
      } else {
        throw Exception("Invalid response from server");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Handle successful OTP verification with cookie-based auth
  Future<void> _handleSuccessResponse(Map<String, dynamic> response) async {
    try {
      final responseBody = response['body'];
      final headers = response['headers'];
      AuthDetails.saveLoginResponse(responseBody);

      print('Full Response Body: ${jsonEncode(responseBody)}');
      print('User Data Type: ${responseBody['data'].runtimeType}');

      // Check if data exists and is Map
      if (responseBody['data'] == null) {
        print('ERROR: userData is null!');
        throw Exception('User data not found in response');
      }

      final userData = responseBody['data'];

      // Check if userData is actually a Map
      if (userData is! Map<String, dynamic>) {
        print('ERROR: userData is not a Map! Type: ${userData.runtimeType}');
        print('userData value: $userData');

        // Try to handle if it's a string or other type
        if (userData is String) {
          // If data is just a string message
          box.write('isLogin', true);
          box.write('userEmail', email.value);
          box.write('userName', 'User');

          HelperFunctions().showSnackBarSuccess('OTP verified successfully');
          isLoading(false);
          Get.offAllNamed(Routes.BOTTOMBAR);
          return;
        }
        throw Exception('Invalid user data format');
      }

      // Now safely extract data with null checks
      final Map<String, dynamic> safeUserData = userData;

      // Debug each field
      print('Checking user data fields:');
      print(
          'id: ${safeUserData['id']} (type: ${safeUserData['id']?.runtimeType})');
      print(
          'email: ${safeUserData['email']} (type: ${safeUserData['email']?.runtimeType})');
      print(
          'name: ${safeUserData['name']} (type: ${safeUserData['name']?.runtimeType})');

      // Extract with null coalescing
      final userId = safeUserData['id']?.toString() ?? 'unknown_id';
      final userEmail = safeUserData['email']?.toString() ?? email.value;
      final userName = safeUserData['name']?.toString() ?? 'User';

      // Store data
      box.write('isLogin', true);
      box.write('userData', safeUserData);
      box.write('userEmail', userEmail);
      box.write('userName', userName);
      box.write('userId', userId);

      // Navigate
      isLoading(false);
      HelperFunctions().showSnackBarSuccess('Welcome to Foduu Cart!');
      //Get.toNamed(Routes.CREATENEWPASSWORD);
      Get.offAllNamed(Routes.BOTTOMBAR);
    } catch (e, stackTrace) {
      print('Error in _handleSuccessResponse: $e');
      print('Stack trace: $stackTrace');
      isLoading(false);
      rethrow;
    }
  }

  // Future<void> verifyOtp({required String otp}) async {
  //   if (otp.isEmpty || otp.length < 4) {
  //     HelperFunctions().showSnackBarError("Please enter 4-digit OTP");
  //     return;
  //   }

  //   isLoading(true);

  //   try {
  //     if (otpContext.value == OtpContext.login) {
  //       await _loginWithOtp(otp);
  //     } else {
  //       await _registerWithOtp(otp);
  //     }
  //   } catch (error) {
  //     isLoading(false);
  //     print('OTP verification error: $error');
  //     HelperFunctions()
  //         .showSnackBarError("OTP verification failed. Please try again.");
  //   }
  // }

  /// Login with OTP - uses same API as password login but with otp key instead
  // Future<void> _loginWithOtp(String otp) async {
  //   try {
  //     // Build form with otp key only (no password key)
  //     var form = {
  //       'email': email.value,
  //       'otp': otp,
  //       'device_details': await _getDeviceDetails(),
  //     };

  //     var response = await authProvider.sendLoginRequest(form);

  //     if (response != null && response['access_token'] != null) {
  //       isLoading(false);

  //       TokenManager.setAccessToken(response['access_token']);
  //       TokenManager.setRefreshToken(response['refresh_token']);

  //       await AuthDetails().updateUserDetailsFromServer();

  //       box.write('isLogin', true);
  //       box.write('userDetails', {
  //         'token': response['access_token'],
  //         'userData': response['data'],
  //       });

  //       HelperFunctions().showSnackBarSuccess('Welcome to Foduu Cart');
  //       Get.offAllNamed(Routes.BOTTOMBAR);
  //     }
  //   } catch (error) {
  //     isLoading(false);
  //     print('Login OTP error: $error');
  //   }
  // }

  // /// Register with OTP - uses same API as password registration but with otp key instead
  // Future<void> _registerWithOtp(String otp) async {
  //   try {
  //     var response = await registerProvider.otpRegister(email.value, otp);

  //     if (response != null && response['access_token'] != null) {
  //       isLoading(false);

  //       TokenManager.setAccessToken(response['access_token']);
  //       TokenManager.setRefreshToken(response['refresh_token']);

  //       await AuthDetails().updateUserDetailsFromServer();

  //       box.write('isLogin', true);
  //       box.write('userDetails', {
  //         'token': response['access_token'],
  //         'userData': response['data'],
  //       });

  //       HelperFunctions().showSnackBarSuccess(
  //           'Registration successful! Welcome to Foduu Cart');
  //       Get.offAllNamed(Routes.BOTTOMBAR);
  //     }
  //   } catch (error) {
  //     isLoading(false);
  //     print('Register OTP error: $error');
  //   }
  // }

  /// Resend OTP
  // Future<void> resendOtp() async {
  //   if (isResendVisible.value) {
  //     isResendVisible(false);
  //     countdown.value = 30;
  //     startCountdown();

  //     isLoading(true);

  //     try {
  //       if (otpContext.value == OtpContext.login) {
  //         await authProvider.resendOtp(email.value);
  //         HelperFunctions().showSnackBarSuccess('OTP resent successfully');
  //       } else {
  //         await registerProvider.sendOtp(email.value);
  //         HelperFunctions().showSnackBarSuccess('OTP resent successfully');
  //       }
  //       isLoading(false);
  //     } catch (error) {
  //       isLoading(false);
  //       HelperFunctions().showSnackBarError('Failed to resend OTP');
  //       print('Error resending OTP: $error');
  //     }
  //   }
  // }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (isResendVisible.value) {
      isResendVisible(false);
      countdown.value = 30;
      startCountdown();

      isLoading(true);

      try {
        await otpProvider.resendOtp(email.value);
        HelperFunctions().showSnackBarSuccess('OTP resent successfully');
        isLoading(false);
      } catch (error) {
        isLoading(false);
        HelperFunctions().showSnackBarError('Failed to resend OTP');
        print('Error resending OTP: $error');
      }
    }
  }

  /// Start countdown timer for resend
  void startCountdown() {
    _countdownTimer?.cancel();
    countdown.value = 30;
    isResendVisible.value = false;

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        isResendVisible.value = true;
      }
    });
  }

  /// Get device details for API request
  Future<Map<String, dynamic>> _getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      return {
        'type': Platform.operatingSystem,
        'mobile_name': androidInfo.model,
        'brand': androidInfo.manufacturer,
        'version': androidInfo.version.release,
        'device_identifier': androidInfo.id.toString(),
      };
    } else {
      var iosInfo = await deviceInfo.iosInfo;
      return {
        'type': Platform.operatingSystem,
        'mobile_name': iosInfo.utsname.machine,
        'brand': iosInfo.model,
        'version': iosInfo.systemVersion,
        'device_identifier': iosInfo.identifierForVendor,
      };
    }
  }
}

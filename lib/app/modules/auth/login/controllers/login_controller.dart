import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_settings_helper.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:foduu_ecommerce/app/modules/auth/login/provider/login_provider.dart';

class LoginController extends GetxController with BaseController {
  var obsecuretext = true.obs;
  var isLoading = false.obs;

  // Use a unique key to prevent Duplicate GlobalKey errors during navigation/rebuilds
  // Use a unique key to prevent Duplicate GlobalKey errors during navigation/rebuilds
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController mobileController;
  var email = "";
  var countryCode = "91".obs;

  final box = GetStorage();
  final LoginProvider loginProvider = LoginProvider();

  // Auth types from settings
  var isOtpMode = true.obs; // Default to OTP mode
  var isPasswordMode = false.obs;
  var isMobileOtpMode = false.obs;

  // Toggle password visibility (kept for compatibility)
  void togglePasswordVisibility() {
    obsecuretext.value = !obsecuretext.value;
  }

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    mobileController = TextEditingController();

    // Load auth settings
    loadAuthSettings();
  }

  void loadAuthSettings() {
    isOtpMode.value = AuthSettingsHelper.isEmailOtpEnabled();
    isPasswordMode.value = AuthSettingsHelper.isEmailPasswordEnabled();
    isMobileOtpMode.value = AuthSettingsHelper.isMobileOtpEnabled();

    // Prioritize mobile OTP if requested by user logic
    if (isMobileOtpMode.value) {
      isOtpMode.value = false;
      isPasswordMode.value = false;
    }

    print(
        'Login Auth Mode - OTP: ${isOtpMode.value}, Password: ${isPasswordMode.value}, Mobile OTP: ${isMobileOtpMode.value}');
  }

  // Validate email format
  String? validEmail(String value) {
    if (value.isEmpty) {
      return "Please enter your email";
    }
    if (!GetUtils.isEmail(value)) {
      return "Please provide a valid email!";
    }
    return null;
  }

  /// Main submit handler - routes to OTP or password flow
  Future<void> onSubmit() async {
    // Validate form
    if (!loginFormKey.currentState!.validate()) return;

    // Show loading state
    isLoading(true);

    try {
      if (isPasswordMode.value) {
        // Password-based login
        await _loginWithPassword();
      } else if (isMobileOtpMode.value) {
        // Mobile OTP based login
        await _requestOtp(isMobile: true);
      } else {
        // OTP-based login (current flow)
        await _requestOtp(isMobile: false);
      }
    } catch (e) {
      print('Submit error: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Request OTP (current flow)
  Future<void> _requestOtp({bool isMobile = false}) async {
    try {
      // Prepare login form data
      Map<String, dynamic> form = {};

      if (isMobile) {
        var mobile = mobileController.text.trim();
        // Remove non-digits
        mobile = mobile.replaceAll(RegExp(r'[^0-9]'), '');
        if (mobile.length > 10) mobile = mobile.substring(mobile.length - 10);

        if (mobile.length != 10) {
          HelperFunctions()
              .showSnackBarError('Please enter a valid 10-digit phone number');
          return;
        }

        form['mobile'] = mobile;
        form['country_code'] = countryCode.value.replaceAll('+', '');
      } else {
        form['email'] = emailController.text.trim();
        if (form['email'].isEmpty || !GetUtils.isEmail(form['email'])) {
          HelperFunctions().showSnackBarError('Please enter a valid email');
          return;
        }
      }

      // Add device details with error handling
      try {
        form['device_details'] = await HelperFunctions.getDeviceDetails();
      } catch (e) {
        print('Could not get device details: $e');
        form['device_details'] = {
          'device_type': 'unknown',
          'device_model': 'unknown',
          'os_version': 'unknown',
        };
      }

      print('OTP Login request data: ${form.toString()}');

      // Make API call for OTP request
      var response = await BasicProvider('auth/login')
          .postRequest(form)
          .catchError(handleError);

      // Handle response safely
      if (response != null) {
        // Extract message safely
        String successMessage = '';
        if (response is Map<String, dynamic>) {
          successMessage = response['message'] ??
              response['msg'] ??
              'OTP sent successfully!';
        } else if (response is String) {
          successMessage = response;
        } else {
          successMessage = 'OTP sent successfully!';
        }

        HelperFunctions().showSnackBarSuccess(successMessage);

        // Navigate to OTP verification screen
        Get.toNamed(Routes.OTP, arguments: {
          'email': isMobile ? '' : emailController.text.trim(),
          'mobile': isMobile ? mobileController.text.trim() : '',
          'country_code': isMobile ? countryCode.value.replaceAll('+', '') : '',
          'from_login': true,
          'context': 'login' // Explicitly set context
        });
      }
    } catch (e, stackTrace) {
      String errorMessage = e.toString();
      // Clean up error message
      errorMessage = errorMessage.replaceAll('Exception:', '').trim();
      if (errorMessage.isEmpty) {
        errorMessage = 'Failed to send OTP. Please try again.';
      }

      HelperFunctions().showSnackBarError(errorMessage);
      print('OTP Login error: $e');
      print('OTP Login stackTrace: $stackTrace');
    } finally {
      isLoading(false);
    }
  }

  // Social login handlers
  void handleGoogleSignIn() {
    print('Google sign in initiated');
    //HelperFunctions().showSnackBarInfo('Google sign in coming soon');
  }

  void handleAppleSignIn() {
    print('Apple sign in initiated');
    //HelperFunctions().showSnackBarInfo('Apple sign in coming soon');
  }

  void handleFacebookSignIn() {
    print('Facebook sign in initiated');
    //HelperFunctions().showSnackBarInfo('Facebook sign in coming soon');
  }

  @override
  void onClose() {
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }

  /// Login with email and password
  Future<void> _loginWithPassword() async {
    try {
      Map<String, dynamic> form = {
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      };

      // Add device details
      try {
        form['device_details'] = await HelperFunctions.getDeviceDetails();
      } catch (e) {
        form['device_details'] = {
          'device_type': 'unknown',
          'device_model': 'unknown',
          'os_version': 'unknown',
        };
      }

      print('Password Login request data: ${form.toString()}');

      // Make API call using LoginProvider
      final response = await loginProvider.sendLoginRequest(form);
      final responseBody = response['body'];
      final statusCode = response['statusCode'];

      print('Login Response Body Type: ${responseBody.runtimeType}');

      if (statusCode == 200 || statusCode == 201) {
        // Use AuthDetails to save the response properly
        AuthDetails.saveLoginResponse(responseBody);

        // Extract message for snackbar
        String successMessage = 'Login successful!';
        if (responseBody is Map && responseBody['data'] is String) {
          successMessage = responseBody['data'];
        } else if (responseBody is Map && responseBody['message'] is String) {
          successMessage = responseBody['message'];
        }

        HelperFunctions().showSnackBarSuccess(successMessage);

        // Fetch profile data from server since login body might be empty
        // Create an instance of AuthDetails first
        await AuthDetails().updateUserDetailsFromServer();       

        // Clear password for security
        passwordController.clear();

        // Navigate to main screen
        Get.offAllNamed(Routes.BOTTOMBAR);
      } else {
        // Handle error responses
        String errorMsg = 'Login failed. Please check your credentials.';
        if (responseBody is Map) {
          errorMsg = responseBody['message'] ??
              responseBody['data'] ??
              responseBody['msg'] ??
              errorMsg;
        } else if (responseBody is String) {
          errorMsg = responseBody;
        }

        HelperFunctions().showSnackBarError(errorMsg);
      }
    } catch (e, stackTrace) {
      print('Password Login error: $e');
      print('Stack trace: $stackTrace');
      HelperFunctions().showSnackBarError('An error occurred during login: $e');
    }
  }
}

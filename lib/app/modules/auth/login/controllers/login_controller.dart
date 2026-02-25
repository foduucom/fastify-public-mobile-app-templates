import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_settings_helper.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController with BaseController {
  var obsecuretext = true.obs;
  var isLoading = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  var email = "";

  final box = GetStorage();

  // Auth type from settings
  var isOtpMode = true.obs; // Default to OTP mode

  // Toggle password visibility (kept for compatibility)
  void togglePasswordVisibility() {
    obsecuretext.value = !obsecuretext.value;
  }

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();

    // Load auth settings
    loadAuthSettings();
  }

  void loadAuthSettings() {
    isOtpMode.value = AuthSettingsHelper.isEmailOtpEnabled();
    print('Login Auth Mode - OTP: ${isOtpMode.value}');
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

  /// Main submit handler for OTP-based login
  Future<void> onSubmit() async {
    // Validate form
    if (!formKey.currentState!.validate()) return;

    isLoading(true);

    try {
      // Prepare login form data (OTP mode - no password)
      Map<String, dynamic> form = {
        'email': emailController.text.trim(),
      };

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
          'email': emailController.text.trim(),
          'from_login': true
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
    emailController.dispose();
    super.onClose();
  }
}

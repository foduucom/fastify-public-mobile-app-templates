import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

import '../provider/register_provider.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var box = GetStorage();
  late TextEditingController mobileController,
      emailController,
      nameController,
      passwordController;
  var isLoading = false.obs;
  var showPassword = false.obs;
  var isChecked = false.obs;

  // Auth settings
  var isOtpMode = false.obs;
  var isPasswordMode = true.obs;

  // Toggle password visibility
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  final RegisterProvider registerProvider = RegisterProvider();

  @override
  void onInit() {
    nameController = TextEditingController();
    mobileController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    // Initialize as unchecked by default
    isChecked.value = false;
    // Load auth settings
    //  loadAuthSettings();
    super.onInit();
  }

  // void loadAuthSettings() {
  //   isOtpMode.value = AuthSettingsHelper.isEmailOtpEnabled();
  //   isPasswordMode.value = AuthSettingsHelper.isEmailPasswordEnabled();
  //   print(
  //       'Register Auth Mode - OTP: ${isOtpMode.value}, Password: ${isPasswordMode.value}');
  // }
  // FIXED: Toggle the checkbox value instead of setting it directly
  void toggleCheckbox() {
    isChecked.value = !isChecked.value;
    print('Checkbox toggled to: ${isChecked.value}');
  }

  void reset() {
    isChecked.value = false;
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    passwordController.clear();
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
    // Validate form
    if (!formKey.currentState!.validate()) {
      HelperFunctions()
          .showSnackBarError('Please fill all required fields correctly');
      return;
    }
    // Validate terms checkbox
    if (!isChecked.value) {
      HelperFunctions().showSnackBarError('Please accept terms & conditions');
      return;
    }

    print('Form submitted with checkbox: ${isChecked.value}');
    isLoading(true);

    try {
      //if (isOtpMode.value) {
      // OTP-based registration: register and send OTP
      //await _registerWithOtp();
      //} else {
      // Password-based registration
      //   await _registerWithPassword();
      // }
      await _registerWithPassword();
    } catch (e) {
      print('Registration error: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Register with OTP - uses register API with only email (no password key)
  // Future<void> _registerWithOtp() async {
  //   try {
  //     // First send OTP to the email
  //     var result = await registerProvider.sendOtp(emailController.text);

  //     if (result != null) {
  //       HelperFunctions()
  //           .showSnackBarSuccess('OTP sent to ${emailController.text}');

  //       // Navigate to OTP screen with register context
  //       Get.toNamed(
  //         Routes.OTP,
  //         arguments: {
  //           'email': emailController.text,
  //           'context': 'register',
  //         },
  //       );
  //     }
  //   } catch (e) {
  //     print('OTP Registration error: $e');
  //   }
  // }

  /// Register with Password - uses register API with password key (no otp key)
  /// Register with Password
  Future<void> _registerWithPassword() async {
    try {
      var name = nameController.text.trim();
      var mobile = mobileController.text.trim();
      var email = emailController.text.trim();
      var password = passwordController.text;

      // Validate name
      if (name.isEmpty) {
        HelperFunctions().showSnackBarError('Please enter your full name');
        return;
      }

      // Process mobile number
      if (mobile.isEmpty) {
        HelperFunctions().showSnackBarError('Please enter your mobile number');
        return;
      }

      // Remove any non-digit characters
      mobile = mobile.replaceAll(RegExp(r'[^0-9]'), '');

      // Check if mobile is valid (10 digits for India)
      if (mobile.length > 10) {
        mobile = mobile.substring(mobile.length - 10);
      }

      if (mobile.length != 10) {
        HelperFunctions()
            .showSnackBarError('Please enter a valid 10-digit mobile number');
        return;
      }

      // Validate email
      if (email.isEmpty || !email.contains('@')) {
        HelperFunctions()
            .showSnackBarError('Please enter a valid email address');
        return;
      }

      // Validate password
      if (password.isEmpty || password.length < 8) {
        HelperFunctions()
            .showSnackBarError('Password must be at least 8 characters');
        return;
      }

      print('Attempting registration with:');
      print('Name: $name');
      print('Mobile: $mobile');
      print('Email: $email');
      print('Password Length: ${password.length}');

      // FIX: Handle the Map response properly
      final Map<String, dynamic> response = await registerProvider
          .passwordRegister(name, mobile, email, password);

      // Check if response is successful
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final responseBody = response['body'] as Map<String, dynamic>;

        // Handle successful registration
        await _handleRegistrationSuccess(responseBody, email);
      } else {
        throw Exception(
            'Registration failed with status: ${response['statusCode']}');
      }
    } catch (e) {
      print('Password Registration error: $e');
      // The error message should already be shown by the provider
    }
  }

  /// Handle successful registration response
  Future<void> _handleRegistrationSuccess(
      Map<String, dynamic> responseBody, String email) async {
    print('Registration Success Response: $responseBody');

    // Check response structure
    if (responseBody['status'] == 'success') {
      final message = responseBody['data'] is String
          ? responseBody['data']
          : 'Registration Successful!';

      HelperFunctions().showSnackBarSuccess(message.toString());

      // Directly navigate to add profile
      print('Registration successful, navigating to add profile');
      Get.toNamed(Routes.ADDPROFILE);
    } else if (responseBody['status'] == 'error') {
      // Handle error from API
      final errorMessage = responseBody['data'] ?? 'Registration failed';
      HelperFunctions().showSnackBarError(errorMessage.toString());
    } else {
      // Handle unexpected success structure
      HelperFunctions().showSnackBarSuccess('Registration Successful!');
      Get.toNamed(Routes.ADDPROFILE);
    }
  }
}

// class RegisterController extends GetxController {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   var box = GetStorage();
//   late TextEditingController mobileController,
//       emailController,
//       nameController,
//       passwordController;
//   var isLoading = false.obs;
//   var showPassword = false.obs;
//   var isChecked = true.obs;

//   @override
//   void onInit() {
//     nameController = TextEditingController();
//     mobileController = TextEditingController();
//     emailController = TextEditingController();
//     passwordController = TextEditingController();
//     super.onInit();
//   }

//   void onChecked(val) {
//     isChecked.value = val;
//   }

//   @override
//   void onReady() {
//     super.onReady();
//   }

//   @override
//   void onClose() {
//     super.onClose();
//     nameController.dispose();
//     mobileController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//   }

//   Future<void> onSubmit() async {
//     if (formKey.currentState!.validate()) {
//       isLoading(true);
//       mobileController.text =
//           mobileController.text.substring(mobileController.text.length - 10);
//       var form = {
//         'name': nameController.text,
//         'mobile': mobileController.text,
//         'email': emailController.text,
//         'password': passwordController.text,
//       };

//       print('before api call function ${form.toString()}');

//       RegisterProvider().sendRegisterCustomerRequest(form).then((value) {
//         if (value['status'] != null && value["status"] == "success") {
//           isLoading(false);
//           HelperFunctions().showSnackBarSuccess(
//               "Your account has been registered successfully!");

//           // FIX: Pass the email as arguments
//           Get.offNamed(Routes.EMAIL_OTP,
//               arguments: {'email': emailController.text.trim()});
//         }
//         // }
//       }, onError: (err) {
//         isLoading(false);

//         if (err["data"] != null) {
//           HelperFunctions().showSnackBarError(err["data"]);
//         } else {
//           HelperFunctions()
//               .showSnackBarError("Something is wrong with registration!");
//         }
//         // }
//       });
//     }
//   }
// }

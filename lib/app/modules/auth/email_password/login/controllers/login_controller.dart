import 'package:zouhi/constants/app_exceptions.dart';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/auth/email_password/login/provider/provider.dart';
import 'package:zouhi/app/modules/auth/token_manager.dart';
import 'package:zouhi/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  var obsecuretext = true.obs;
  final isRegistered = false.obs;
  var isLoading = false.obs;
  var rememberMe = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController emailController, passwordController;
  var email = "";
  var password = "";
  final box = GetStorage();
  List list = [];

  @override
  void onInit() {
    super.onInit();

    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Restore remembered email if previously stored
    if (box.hasData('remember_email')) {
      final savedEmail = box.read('remember_email')?.toString() ?? '';
      if (savedEmail.isNotEmpty) {
        emailController.text = savedEmail;
        rememberMe.value = true;
      }
    }

    applyRouteArguments();
  }

  @override
  void onReady() {
    super.onReady();
    applyRouteArguments();
  }

  void applyRouteArguments() {
    final args = Get.arguments;
    if (args != null && args is Map && args['email'] != null) {
      final passedEmail = args['email'].toString().trim();
      if (passedEmail.isNotEmpty) {
        emailController.text = passedEmail;
      }
    }
  }

  String? validEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return "Please enter email address";
    }
    if (!GetUtils.isEmail(trimmed)) {
      return "Please provide valid email!";
    }
    return null;
  }

  String? validPassword(String value) {
    if (value.isEmpty) {
      return "Please enter your password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  Future<void> onSubmit(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    HelperFunctions().closeKeyboard(Get.context!);
    isLoading.value = true;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo? androidInfo;
    IosDeviceInfo? iosInfo;
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    } else {
      iosInfo = await deviceInfo.iosInfo;
    }

    final fcmToken = await NotificationService.getFcmToken();
    print("Fcm Token value for login $fcmToken");
    var form = {
      'email': emailController.text.trim(),
      'password': passwordController.text,
      if (fcmToken != null) 'fcm_token': fcmToken,
      'device_details': {
        'type': Platform.operatingSystem,
        'mobile_name':
            Platform.isAndroid ? androidInfo!.model : iosInfo!.utsname.machine,
        'brand':
            Platform.isAndroid ? androidInfo!.manufacturer : iosInfo!.model,
        'version': Platform.isAndroid
            ? androidInfo!.version.release
            : iosInfo!.systemVersion,
        'device_identifier': Platform.isAndroid
            ? androidInfo!.id.toString()
            : iosInfo!.identifierForVendor,
      }
    };
    print("Full Request in login Controller: $form");
    await LoginProvider().sendLoginRequest(form).then((value) async {
      isLoading(false);
      if (value != null) {
        print('Login success response: $value');

        // Handle Remember Me persistence
        if (rememberMe.value) {
          box.write('remember_email', emailController.text.trim());
        } else {
          box.remove('remember_email');
        }

        // Check if response is token payload or OTP redirection
        final bool hasOtp = value is Map &&
            value['otp'] != null &&
            value['access_token'] == null &&
            value['token'] == null;
        if (hasOtp) {
          Get.toNamed(Routes.MOBILELOGINOTP,
              arguments: {'email': emailController.text.trim()});
          return;
        }

        // Standard token & user persistence
        if (value is Map) {
          String? token;
          if (value['token'] is Map && value['token']['value'] != null) {
            token = value['token']['value'].toString();
          } else if (value['token'] is String &&
              value['token'].toString().isNotEmpty) {
            token = value['token'].toString();
          } else if (value['access_token'] != null) {
            token = value['access_token'].toString();
          } else if (value['token'] is Map &&
              value['token']['access_token'] != null) {
            token = value['token']['access_token'].toString();
          }

          if (token != null && token.isNotEmpty) {
            await TokenManager.setAccessToken(token);
          }

          String? refreshToken;
          if (value['refresh_token'] != null) {
            refreshToken = value['refresh_token'].toString();
          } else if (value['token'] is Map &&
              value['token']['refresh_token'] != null) {
            refreshToken = value['token']['refresh_token'].toString();
          }

          if (refreshToken != null && refreshToken.isNotEmpty) {
            await TokenManager.setRefreshToken(refreshToken);
          }

          dynamic userData;
          if (value['user'] != null && value['user'] is Map) {
            userData = value['user'];
          } else if (value['customer'] != null && value['customer'] is Map) {
            userData = value['customer'];
          } else if (value['data'] != null &&
              value['data'] is Map &&
              (value['data']['id'] != null || value['data']['email'] != null)) {
            userData = value['data'];
          } else if (value.containsKey('id') || value.containsKey('email')) {
            final userMap = Map<String, dynamic>.from(value);
            userMap.remove('token');
            userData = userMap;
          }

          if (userData != null) {
            box.write('userData', userData);
          }
        }

        box.write('isLogin', true);

        try {
          await AuthDetails().updateUserDetailsFromServer();
        } catch (e) {
          print('Error updating user profile: $e');
        }

        if (Get.isRegistered<ProfileController>()) {
          final pc = Get.find<ProfileController>();
          pc.getBoxData();
          pc.fetchDataFromServer(forceRefresh: true);
        }

        Get.offAllNamed(Routes.BOTTOMBAR);
      }
    }, onError: (err) {
      isLoading(false);
      final msg = errorMessageOf(err, fallback: "Login failed. Please try again.");
      HelperFunctions().showSnackBarError(msg);
    });
  }

  void saveTokenDetails(data) {
    Map<String, dynamic> userDetails = {
      'token': data,
      'userData': null,
    };
    try {
      box.write('userDetails', userDetails);
    } catch (e) {
      print('login controller $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

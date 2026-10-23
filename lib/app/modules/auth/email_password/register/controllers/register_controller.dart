import 'package:zouhi/constants/app_exceptions.dart';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../provider/register_provider.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var box = GetStorage();
  late TextEditingController mobileController,
      emailController,
      nameController,
      saap_code,
      passwordController,
      confirmPasswordController;
  var isLoading = false.obs;
  var showPassword = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var isChecked = true.obs;

  @override
  void onInit() {
    nameController = TextEditingController();
    mobileController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    saap_code = TextEditingController();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void onChecked(val) {
    isChecked.value = val;
  }

  @override
  void onClose() {
    super.onClose();
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    saap_code.dispose();
  }

  Future<void> onSubmit(GlobalKey<FormState> formKey) async {
    if (!isChecked.value) {
      HelperFunctions().showSnackBarError(
          "Please accept the Terms & Conditions to continue.");
      return;
    }

    if (formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        HelperFunctions().showSnackBarError("Passwords do not match!");
        return;
      }

      isLoading(true);

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo? androidInfo;
      IosDeviceInfo? iosInfo;
      if (Platform.isAndroid) {
        androidInfo = await deviceInfo.androidInfo;
      } else {
        iosInfo = await deviceInfo.iosInfo;
      }

      final fcmToken = await NotificationService.getFcmToken();
      print("Fcm Token from Registration value $fcmToken");
      var form = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        if (mobileController.text.trim().isNotEmpty)
          'mobile': mobileController.text.trim(),
        if (saap_code.text.trim().isNotEmpty)
          'saap_code': saap_code.text.trim(),
        if (fcmToken != null) 'fcm_token': fcmToken,
        'device_details': {
          'type': Platform.operatingSystem,
          'mobile_name': Platform.isAndroid
              ? androidInfo!.model
              : iosInfo!.utsname.machine,
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

      print("Full Request in register: $form");

      RegisterProvider().sendRegisterCustomerRequest(form).then((value) {
        isLoading(false);

        bool isSuccess = false;
        String successMsg = "Welcome! Your account has been created successfully.";

        if (value is String) {
          isSuccess = true;
          if (value.trim().isNotEmpty) {
            successMsg = value.trim();
          }
        } else if (value is Map) {
          if (value['status'] == "success" ||
              value['status'] == 200 ||
              value['status'] == 201 ||
              value['token'] != null ||
              value['data'] != null) {
            isSuccess = true;
            if (value['data'] is String &&
                (value['data'] as String).trim().isNotEmpty) {
              successMsg = (value['data'] as String).trim();
            } else if (value['message'] is String &&
                (value['message'] as String).trim().isNotEmpty) {
              successMsg = (value['message'] as String).trim();
            }
          }
        }

        if (isSuccess) {
          final registeredEmail = emailController.text.trim();
          HelperFunctions().showSnackBarSuccess(successMsg);
          Get.offNamed(Routes.LOGIN, arguments: {
            'email': registeredEmail,
            'registered': true,
          });
        } else {
          String errorMsg = "Registration failed. Please try again.";
          if (value is Map) {
            errorMsg = errorMessageOf(value, fallback: errorMsg);
          } else if (value != null) {
            errorMsg = value.toString();
          }
          HelperFunctions().showSnackBarError(errorMsg);
        }
      }, onError: (err) {
        isLoading(false);
        final errorMsg = errorMessageOf(err,
            fallback: "Registration failed. Please try again.");
        HelperFunctions().showSnackBarError(errorMsg);
      });
    }
  }
}

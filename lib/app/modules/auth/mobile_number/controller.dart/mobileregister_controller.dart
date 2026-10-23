import 'package:zouhi/constants/app_exceptions.dart';

import 'package:flutter/material.dart';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/app/modules/auth/email_password/register/provider/register_provider.dart';
import 'package:zouhi/app/modules/auth/mobile_number/controller.dart/mobileLogin_contgroller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var box = GetStorage();
  late TextEditingController mobileController, emailController, nameController;
  var isLoading = false.obs;
  var loader = false.obs;

  var showPassword = false.obs;

  @override
  void onInit() {
    nameController = TextEditingController();
    //mobileController = TextEditingController();
    emailController = TextEditingController();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    nameController.dispose();
    //mobileController.dispose();
    emailController.dispose();
  }

  Future<void> onSubmit() async {
    if (formKey.currentState!.validate()) {
      isLoading(true);
      mobileController.text =
          mobileController.text.substring(mobileController.text.length - 10);
      final fcmToken = await NotificationService.getFcmToken();
      var form = FormData({
        'name': nameController.text,
        //'mobile': mobileController.text,
        'email': emailController.text,
        "type": "customer",
        if (fcmToken != null) 'fcm_token': fcmToken,
      });

      RegisterProvider().sendRegisterCustomerRequest(form).then((value) {
        isLoading(false);

        bool isSuccess = false;
        String successMsg = "Your account has been registered successfully!";

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
          if (Get.isRegistered<MobileNoLoginController>()) {
            var loginController = Get.find<MobileNoLoginController>();
            loginController.moibileNocontroller.text = mobileController.text;
          }
          HelperFunctions().showSnackBarSuccess(successMsg);
          Get.toNamed(Routes.MOBILELOGINOTP);
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

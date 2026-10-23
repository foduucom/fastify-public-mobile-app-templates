import 'package:zouhi/constants/app_exceptions.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/app/modules/auth/mobile_number/provider.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MobileNoLoginController extends GetxController with BaseController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController moibileNocontroller;
  final box = GetStorage();
  final isLoading = false.obs;
  var loader = false.obs;

  var showPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    moibileNocontroller = TextEditingController();
  }

  @override
  void onClose() {
    super.onClose();
    moibileNocontroller.dispose();
  }

  Future<void> onSubmit(
      {required int mobileNo, required GlobalKey<FormState> formKey}) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    isLoading.value = true;

    final fcmToken = await NotificationService.getFcmToken();
    var form = jsonEncode({
      'mobile': mobileNo.toString(),
      if (fcmToken != null) 'fcm_token': fcmToken,
    });

    await OTPLoginProvider().sendLoginRequest(form).then((value) async {
      if (value != null) {
        isLoading.value = false;
        Get.toNamed(Routes.MOBILELOGINOTP);
      }
    }, onError: (err) {
      HelperFunctions().showSnackBarError(errorMessageOf(err));
      isLoading(false);
    });
  }

  void saveTokenDetails(data) {
    box.write('token', data);
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:zouhi/app/modules/auth/mobile_number/controller.dart/mobileLogin_contgroller.dart';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/app/modules/auth/token_manager.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MobieNoLoginOtpController extends GetxController with BaseController {
  var isLoading = false.obs;
  var isResendVisible = false.obs;
  final box = GetStorage();
  var otpCode = "".obs;
  var email = "".obs;

  get value => null;

  @override
  Future<void> onInit() async {
    super.onInit();
    email.value = Get.arguments['email'];
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  Future<void> attemptLogin({required String otp}) async {
    otpCode.value = otp;
    if (otpCode == "" || otpCode.value.length < 6) {
      HelperFunctions().showSnackBarError("Please enter OTP");
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
    print("Fcm Token value for login Otp ${fcmToken}");

    var form = jsonEncode({
      'email': email.value,
      'otp': otp,
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
    });

    try {
      print('Full Request in attemptLogin: $form');
      var response = await BasicProvider("auth/verify-otp")
          .postRequest(form)
          .catchError(handleError);
      print('Full Response in attemptLogin: $response');

      var tokenData = response != null ? (response['token'] ?? response) : null;

      if (tokenData != null && tokenData["value"] != null) {
        //isLoading(false);
        print('Extracted Token Data: $tokenData');
        TokenManager.setAccessToken(tokenData['value']);
        // TokenManager.setRefreshToken(tokenData['refresh_token']);

        await AuthDetails().updateUserDetailsFromServer();

        box.write('isLogin', true);
        if (Get.isRegistered<ProfileController>()) {
          final pc = Get.find<ProfileController>();
          pc.getBoxData();
          pc.fetchDataFromServer(forceRefresh: true);
        }
        Get.offAllNamed(Routes.BOTTOMBAR);
      } else if (response != null) {
        HelperFunctions()
            .showSnackBarError(response['message'] ?? "Verification failed");
      }
    } catch (error) {
      isLoading(false);
      // print(error);
    } finally {
      isLoading(false);
    }
  }

  Future<void> resendOtp() async {
    isResendVisible(false);
    isLoading(true);
    var form = FormData({
      "mobile": Get.find<MobileNoLoginController>().moibileNocontroller.text,
    });
    print("resend otp form : $form");
    var response = await BasicProvider("auth/resendotp")
        .postRequest(form)
        .catchError(handleError);
    if (response == null) return;
    isLoading(false);
  }
}

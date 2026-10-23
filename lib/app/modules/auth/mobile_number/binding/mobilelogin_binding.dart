import 'package:zouhi/app/modules/auth/mobile_number/controller.dart/mobileLoginOtp_controller.dart';
import 'package:zouhi/app/modules/auth/mobile_number/controller.dart/mobileLogin_contgroller.dart';
import 'package:get/get.dart';

class MobileNoLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MobileNoLoginController>(
      () => MobileNoLoginController(),
    );

    Get.lazyPut<MobieNoLoginOtpController>(
      () => MobieNoLoginOtpController(),
    );
  }
}

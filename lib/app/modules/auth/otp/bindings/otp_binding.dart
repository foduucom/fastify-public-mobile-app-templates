// lib/app/modules/auth/otp/bindings/otp_binding.dart
import 'package:get/get.dart';

import '../controller/otp_controller.dart';


class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<OtpController>(OtpController());
  }
}

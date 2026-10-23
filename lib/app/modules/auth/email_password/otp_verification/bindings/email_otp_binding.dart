import 'package:get/get.dart';
import '../controllers/email_otp_controller.dart';

class EmailOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailOtpController>(
      () => EmailOtpController(),
    );
  }
}

import 'package:get/get.dart';
import '../controller/security_controller.dart';

class SecurityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecurityController>(
          () => SecurityController(),
      fenix: true,
    );
  }
}
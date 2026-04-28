import 'package:get/get.dart';

import 'package:foduu_ecommerce/app/modules/auth/login/controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}

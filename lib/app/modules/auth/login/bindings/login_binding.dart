import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../views/widgets/controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
    Get.lazyPut<CreateAccountController>(() => CreateAccountController());
  }
}

// Stub binding for the Register flow.
// Currently registration is handled inside CreateAccountView / LoginController.
import 'package:get/get.dart';
import '../../login/controllers/login_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}


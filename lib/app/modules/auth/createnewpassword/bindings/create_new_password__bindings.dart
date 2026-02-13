import 'package:get/get.dart';
import 'package:foduu_ecommerce/app/modules/auth/createnewpassword/controllers/create_new_password_controllers.dart';

class CreateNewPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNewPasswordController>(
      () => CreateNewPasswordController(),
    );
  }
}

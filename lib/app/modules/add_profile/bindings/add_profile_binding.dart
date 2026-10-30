import 'package:get/get.dart';
import '../controllers/add_profile_controllers.dart';

class AddProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProfileController>(
      () => AddProfileController(),
    );
  }
}

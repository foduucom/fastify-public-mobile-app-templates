import 'package:get/get.dart';

import '../controllers/forgotepassword_controller.dart';

class ForgotepasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotepasswordController>(
      () => ForgotepasswordController(),
    );
  }
}

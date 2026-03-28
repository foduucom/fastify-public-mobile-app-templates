import 'package:get/get.dart';

import '../controllers/custompage_controller.dart';

class CustomPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomPageController>(
      () => CustomPageController(),
    );
  }
}

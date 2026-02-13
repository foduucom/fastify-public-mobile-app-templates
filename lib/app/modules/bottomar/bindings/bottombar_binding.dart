import 'package:foduu_ecommerce/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:get/get.dart';

import '../controllers/bottombar_controller.dart';

class BottombarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottombarController>(
      () => BottombarController(),
    );
    Get.lazyPut<HomepageController>(() => HomepageController());
  }
}

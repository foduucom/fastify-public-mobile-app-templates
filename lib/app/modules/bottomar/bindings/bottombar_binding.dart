import 'package:get/get.dart';

import '../controllers/bottombar_controller.dart';
import '../../shop/controllers/shop_controller.dart';

class BottombarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottombarController>(
      () => BottombarController(),
    );
    Get.lazyPut<ShopController>(
      () => ShopController(),
    );
  }
}

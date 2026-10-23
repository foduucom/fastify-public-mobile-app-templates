import 'package:get/get.dart';

import '../controllers/shop_controller.dart';

class ShopBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<ProductvariantController>(
    //   () => ProductvariantController(),
    // );
    // Get.lazyPut<ProductdetialController>(
    //   () => ProductdetialController(),
    // );
    Get.lazyPut<ShopController>(
      () => ShopController(),
    );
  }
}

import 'package:get/get.dart';

import '../../cart/controllers/cart_controller.dart';
import '../../category/controllers/category_search_filter_controller.dart';
import '../../notification/controller/notification_controller.dart';
import '../../shop/controllers/shop_controller.dart';
import '../controllers/bottombar_controller.dart';

class BottombarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottombarController>(
      () => BottombarController(),
      fenix: true,
    );
    Get.lazyPut<CartController>(
      () => CartController(),
      fenix: true,
    );
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(),
      fenix: true,
    );
    Get.lazyPut<CategorySearchFilterController>(
      () => CategorySearchFilterController(),
      fenix: true,
    );
    Get.lazyPut<ShopController>(
      () => ShopController(),
      fenix: true,
    );
  }
}

import 'package:foduu_ecommerce/app/modules/home_wishlist/controllers/home_wishlist_controllers.dart';
import 'package:get/get.dart';

import '../controllers/homepage_controller.dart';

class HomepageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomepageController>(
      () => HomepageController(),
    );
    Get.lazyPut<HomeWishlistControllers>(
      () => HomeWishlistControllers(),
    );
  }
}

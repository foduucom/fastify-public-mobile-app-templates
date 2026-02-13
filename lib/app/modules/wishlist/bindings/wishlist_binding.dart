import 'package:foduu_ecommerce/app/modules/home_wishlist/controllers/home_wishlist_controllers.dart';
import 'package:get/get.dart';

import '../controllers/wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WishlistController>(
      () => WishlistController(),
    );
    Get.lazyPut<HomeWishlistControllers>(
      () => HomeWishlistControllers(),
    );
  }
}

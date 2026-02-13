import 'package:foduu_ecommerce/app/modules/home_wishlist/controllers/home_wishlist_controllers.dart';
import 'package:get/get.dart';

class HomeWishlistBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeWishlistControllers>(() => HomeWishlistControllers());
  }
}

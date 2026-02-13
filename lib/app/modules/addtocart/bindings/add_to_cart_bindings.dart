import 'package:foduu_ecommerce/app/modules/addtocart/controllers/add_to_cart_controllers.dart';
import 'package:get/get.dart';

class AddToCartBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<AddToCartControllers>(() => AddToCartControllers());
  }
}

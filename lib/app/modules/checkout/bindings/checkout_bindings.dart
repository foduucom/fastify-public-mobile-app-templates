import 'package:foduu_ecommerce/app/modules/checkout/controllers/checkout_controllers.dart';
import 'package:get/get.dart';

class CheckoutBindings with Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutControllers>(() => CheckoutControllers());
  }
}

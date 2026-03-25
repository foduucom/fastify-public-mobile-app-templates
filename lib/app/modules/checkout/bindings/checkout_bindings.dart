import 'package:foduu_ecommerce/app/modules/checkout/controllers/checkout_controllers.dart';
import 'package:get/get.dart';

class CheckOutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckOutController>(
      () => CheckOutController(),
    );
  }
}

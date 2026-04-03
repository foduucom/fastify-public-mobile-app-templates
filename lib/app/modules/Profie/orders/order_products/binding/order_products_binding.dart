import 'package:get/get.dart';
import '../controller/order_products_controller.dart';

class OrderProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderProductsController>(
      () => OrderProductsController(),
    );
  }
}

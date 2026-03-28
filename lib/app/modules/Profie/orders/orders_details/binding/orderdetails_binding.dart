import '/app/modules/Profie/orders/orders_details/controller/orderdetails_controller.dart';
import 'package:get/get.dart';

class OrderdetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderdetailController>(
      () => OrderdetailController(),
    );
  }
}

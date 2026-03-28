import 'package:get/get.dart';

import '../controllers/ordersucess_controller.dart';

class OrderResponseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderSuccessController>(
      () => OrderSuccessController(),
    );
  }
}

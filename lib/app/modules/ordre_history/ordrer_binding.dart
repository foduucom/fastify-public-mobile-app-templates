import 'package:get/get.dart';

import 'controller/order_controller.dart';
import 'model/model.dart';


class OrderHistoryBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Use put not lazyPut — guarantees controller exists immediately
    Get.put<OrderHistoryController>(OrderHistoryController());
  }
}

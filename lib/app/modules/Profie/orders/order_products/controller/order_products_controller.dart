import 'package:get/get.dart';

class OrderProductsController extends GetxController {
  final products = <dynamic>[].obs;
  final orderNo = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      products.value = Get.arguments['products'] ?? [];
      orderNo.value = (Get.arguments['order_no'] ?? '').toString();
    }
  }
}

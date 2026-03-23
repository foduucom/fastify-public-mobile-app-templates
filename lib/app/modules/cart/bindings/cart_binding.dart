// lib/app/modules/cart/bindings/cart_binding.dart

import 'package:get/get.dart';

import '../controller/cart_controller.dart';


class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
  }
}

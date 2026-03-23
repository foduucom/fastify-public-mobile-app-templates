import 'package:get/get.dart';

import '../controller/products_details_controller.dart';


class ProductDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductDetailsController>(
          () => ProductDetailsController(),
    );
  }
}
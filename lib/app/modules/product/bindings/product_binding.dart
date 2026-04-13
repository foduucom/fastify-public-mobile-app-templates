import 'package:foduu_ecommerce/app/modules/product/controllers/product_controller.dart';
import 'package:get/get.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(
      () => ProductController(),
      fenix: true,
    );
  }
}

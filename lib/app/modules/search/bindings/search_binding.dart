import 'package:foduu_ecommerce/app/modules/product/controllers/product_controller.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchsController>(
      () => SearchsController(),
    );
    Get.lazyPut<ProductController>(
      () => ProductController(),
    );
  }
}

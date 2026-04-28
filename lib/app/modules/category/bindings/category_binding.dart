import 'package:foduu_ecommerce/app/modules/category/controllers/categorydetial_controller.dart';
import 'package:get/get.dart';

import '../controllers/category_controller.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryController>(
      () => CategoryController(),
    );

    Get.lazyPut<CategeorydetaiController>(
      () => CategeorydetaiController(),
    );
  }
}

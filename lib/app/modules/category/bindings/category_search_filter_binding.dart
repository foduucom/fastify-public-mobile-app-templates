import 'package:foduu_ecommerce/app/modules/category/controllers/category_search_filter_controller.dart';
import 'package:get/get.dart';

class CategorySearchFilterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategorySearchFilterController>(
      () => CategorySearchFilterController(),
    );
  }
}

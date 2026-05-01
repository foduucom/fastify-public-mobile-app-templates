import 'package:get/get.dart';
import '../controllers/category_search_controller.dart';

class CategorySearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategorySearchController>(() => CategorySearchController());
  }
}

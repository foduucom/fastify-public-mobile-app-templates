import 'package:get/get.dart';
import '../controllers/choose_category_controllers.dart';

class ChooseCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChooseCategoryController>(
      () => ChooseCategoryController(),
    );
  }
}

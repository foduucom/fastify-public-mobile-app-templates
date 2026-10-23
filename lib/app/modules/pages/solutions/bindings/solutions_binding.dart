import 'package:get/get.dart';
import '../controllers/solutions_controller.dart';

class SolutionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SolutionsController>(
      () => SolutionsController(),
    );
  }
}

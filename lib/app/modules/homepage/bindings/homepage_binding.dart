import 'package:get/get.dart';
import '../controllers/homepage_controller.dart';

class HomepageBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Use Put not lazyPut — guarantees controller exists immediately
    Get.put<HomeController>(HomeController());
  }
}

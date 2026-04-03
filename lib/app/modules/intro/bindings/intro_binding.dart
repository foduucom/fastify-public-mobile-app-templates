import 'package:get/get.dart';
import '../controllers/intro_controller.dart';

class IntroBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ put() — creates immediately so onInit() fires
    Get.put<IntroController>(IntroController());
  }
}
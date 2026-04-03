import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ fenix: true — recreates controller fresh if it was disposed
    Get.lazyPut<RegisterController>(
          () => RegisterController(),
      fenix: true,  // ← THIS is the fix
    );
  }
}
import 'package:foduu_ecommerce/app/modules/splashscreen/controller/splash_screen_controller.dart';
import 'package:get/get.dart';

class SplashscreenBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<SplashScreenController>(() => SplashScreenController());
  }
}

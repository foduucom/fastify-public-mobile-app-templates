import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {

  @override
  void onReady() {           // ← FIXED: onReady not onInit
    super.onReady();
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offAllNamed(Routes.ONBOARDING);
  }
}

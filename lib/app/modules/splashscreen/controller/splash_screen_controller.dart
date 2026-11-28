import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/data/services/session_service.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/core/config/app_config.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashScreenController extends GetxController with BaseController {
  // Make these reactive using Rx
  var isLoading = true.obs;
  var progressValue = 0.0.obs; // Observable progress value
  List list = [];
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();

    _initializeAndRoute();
  }

  Future<void> _initializeAndRoute() async {
    try {
      progressValue.value = 0.1;
      await Get.find<ThemeController>().initThemeManager();
      progressValue.value = 0.3;
      final refresh = _refreshPublicSettings();
      // On a fresh install, allow auth preferences to load before selecting
      // the login route. Returning users continue with their saved config.
      if (box.read('auth_preference') == null) {
        await refresh.timeout(const Duration(seconds: 10), onTimeout: () {});
      }
      progressValue.value = 0.6;

      var isLoggedIn = box.read('isLogin') == true ||
          box.read('isLogin')?.toString() == 'true';
      if (isLoggedIn) {
        isLoggedIn = await SessionService.validateAtLaunch();
      }

      progressValue.value = 1.0;
      final route = isLoggedIn
          ? Routes.BOTTOMBAR
          : (isOtpLogin ? Routes.MOBILELOGIN : Routes.LOGIN);
      Get.offAllNamed(route);

      if (SessionService.pendingNotice != null) {
        Future.delayed(
          const Duration(milliseconds: 900),
          SessionService.showPendingNotice,
        );
      }
    } catch (e) {
      debugPrint('Startup routing failed: $e');
      final isLoggedIn = box.read('isLogin') == true ||
          box.read('isLogin')?.toString() == 'true';
      final route = isLoggedIn
          ? Routes.BOTTOMBAR
          : (isOtpLogin ? Routes.MOBILELOGIN : Routes.LOGIN);
      Get.offAllNamed(route);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshPublicSettings() async {
    try {
      final response = await BasicProvider('public-settings').getRequest();
      final settings = AppConfig.instance.applyPublicSettings(response);
      if (settings == null) return;

      final palette = AppConfig.instance.extractThemePalette(settings);
      if (palette != null && DynamicThemeManager().updateFromApi(palette)) {
        Get.find<ThemeController>().refreshTheme();
      }
    } catch (error) {
      // A settings service outage should not prevent opening the app.
      debugPrint('Public settings refresh failed during startup: $error');
    }
  }
}

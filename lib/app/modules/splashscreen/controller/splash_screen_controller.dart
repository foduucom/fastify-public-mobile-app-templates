import 'package:foddu/app/controllers/api_exception_handle_controller.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/app/data/services/session_service.dart';
import 'package:foddu/constants/dynamic_theme.dart';
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

    // 1. Initialize the Theme Manager (delayed from main.dart)
    Get.find<ThemeController>().initThemeManager().then((_) {
      // 2. Then proceed to fetch the latest settings and route
      fetchSettings();
    });
  }

  Future<void> fetchSettings() async {
    try {
      // Start progress
      progressValue.value = 0.1;
      await Future.delayed(
          Duration(milliseconds: 100)); // Small delay for visual feedback

      progressValue.value = 0.3;
      var response = await BasicProvider('public-settings').getRequest();

      progressValue.value = 0.6;

      if (response != null) {
        progressValue.value = 0.8;

        var authPreference = response['storeSettings']?['auth_preference'];

        // Save auth preference for use throughout the app
        box.write('auth_preference', authPreference);
        print('Auth Preference saved: $authPreference');
        print('swapnil splash screen response ${response}');

        if (response['storeSettings']['app_theme_color'] != null) {
          print(
              'App Theme Color: ${response['storeSettings']['app_theme_color']}');
          DynamicThemeManager()
              .updateFromApi(response['storeSettings']['app_theme_color']);

          // Trigger app-wide theme rebuild
          Get.find<ThemeController>().refreshTheme();
        }

        progressValue.value = 0.9;

        await _routeAfterSettings();

        progressValue.value = 1.0; // Complete
      } else {
        throw Exception('Failed to load settings');
      }
    } catch (e) {
      print('Error fetching settings: $e');
      // A settings outage must not bypass validation of a stored session.
      await _routeAfterSettings();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _routeAfterSettings() async {
    final rawLogin = box.read('isLogin');
    final hasStoredLogin = rawLogin == true || rawLogin == 'true';
    final sessionIsValid =
        hasStoredLogin ? await SessionService.validateAtLaunch() : false;

    if (sessionIsValid) {
      Get.offAllNamed(Routes.BOTTOMBAR);
      return;
    }

    if (SessionService.pendingNotice != null) {
      Get.offAllNamed(Routes.LOGIN);
      Future.delayed(
          const Duration(milliseconds: 900), SessionService.showPendingNotice);
      return;
    }

    Get.offAllNamed(Routes.ONBOARDING);
  }
}

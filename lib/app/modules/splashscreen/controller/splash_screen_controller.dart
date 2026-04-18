import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
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

        var authPreference = response['storeSettings']['auth_preference'];

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

        // Check if user is already logged in
        bool isLogin = box.read('isLogin') ?? false;

        if (isLogin) {
          // User is logged in, go to bottom bar
          Get.offAllNamed(Routes.BOTTOMBAR);
        } else {
          // User not logged in, go to onboarding/login
          Get.offAllNamed(Routes.ONBOARDING);
        }

        progressValue.value = 1.0; // Complete
      } else {
        throw Exception('Failed to load settings');
      }
    } catch (e) {
      print('Error fetching settings: $e');
      // Default to login screen on error
      //Get.offAllNamed(Routes.LOGIN);
      Get.offAllNamed(Routes.ONBOARDING);
    } finally {
      isLoading.value = false;
    }
  }
}

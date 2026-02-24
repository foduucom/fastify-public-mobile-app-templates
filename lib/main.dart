// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/internet_controller.dart';
import 'package:foduu_ecommerce/core/foduuStudio/register_default_widgets.dart';
import 'package:foduu_ecommerce/core/studio_socket_routing.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await GetStorage.init();

  if (kIsWeb) {
    var accessKey = Uri.base.queryParameters['api_key'];
    var domain = Uri.base.queryParameters['domain_name'];
    String? slug = Uri.base.queryParameters['slug'] ?? 'home';
    if (accessKey == null && Uri.base.fragment.isNotEmpty) {
      try {
        final fragmentUri = Uri.parse(Uri.base.fragment);
        accessKey = fragmentUri.queryParameters['api_key'];
        domain = fragmentUri.queryParameters['domain_name'];
        slug = fragmentUri.queryParameters['slug'];
        print('Access Key: $accessKey');
        print('Domain: $domain');
        print('Slug: $slug');
      } catch (e) {
        print("Error parsing URI fragment: $e");
      }
    }

    if (accessKey != null && accessKey.isNotEmpty) {
      ACCESS_KEY = accessKey;
    }

    if (domain != null && domain.isNotEmpty) {
      websiteDomain = domain;
    }

    print('swapnil Initial slug: $slug');
    Get.put(StudioSocketRouting(initialSlug: slug));
  }

  // Initialize dynamic theme from storage
  await DynamicThemeManager().init();

  Get.put(InternetController(), permanent: true);
  // Register ThemeController globally
  Get.put(ThemeController());

  // Register all dynamic layout widgets
  registerDefaultWidgets();

  // Initialize App and get initial route
  late String initialRoute;
  initialRoute = await _initApp();

  runApp(MyApp(initialRoute: initialRoute));

  // Remove splash screen after app is ready
  FlutterNativeSplash.remove();
}

Future<String> _initApp() async {
  final box = GetStorage();
  try {
    var response = await BasicProvider('public-settings').getRequest();

    if (response != null) {
      var authPreference = response['storeSettings']['auth_preference'];
      box.write('auth_preference', authPreference);

      if (response['storeSettings']['app_theme_color'] != null) {
        DynamicThemeManager().updateFromApi(
          response['storeSettings']['app_theme_color'],
        );
        Get.find<ThemeController>().refreshTheme();
      }

      bool isLogin = box.read('isLogin') ?? false;
      return isLogin ? Routes.BOTTOMBAR : Routes.LOGIN;
    }
  } catch (e) {
    print('Error during initApp: $e');
  }
  return Routes.LOGIN;
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final systemBrightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;

        final effectiveBrightness =
            themeController.themeMode == ThemeMode.system
                ? systemBrightness
                : (themeController.themeMode == ThemeMode.dark
                    ? Brightness.dark
                    : Brightness.light);

        debugPrint('────────────────────────────');
        debugPrint('ThemeMode = ${themeController.themeMode}');
        debugPrint('SystemBrightness = $systemBrightness');
        debugPrint('EffectiveBrightness = $effectiveBrightness');
        debugPrint(
          effectiveBrightness == Brightness.dark
              ? '🌙 APP USING DARK THEME'
              : '☀️ APP USING LIGHT THEME',
        );
        debugPrint('────────────────────────────');
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Application",
          initialRoute: initialRoute,
          getPages: AppPages.routes,
          theme: themeController.lightTheme,
          darkTheme: themeController.darkTheme,
          themeMode: themeController.themeMode,
        );
      },
    );
  }
}

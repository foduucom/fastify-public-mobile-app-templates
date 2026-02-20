// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/internet_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  // Initialize dynamic theme from storage
  await DynamicThemeManager().init();

  Get.put(InternetController(), permanent: true);
  // Register ThemeController globally
  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          theme: themeController.lightTheme,
          darkTheme: themeController.darkTheme,
          themeMode: themeController.themeMode,
        );
      },
    );
  }
}

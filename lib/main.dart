import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
      // ✅ theme controller
import 'constants/dynamic_theme.dart';
import 'helpers/socket_helper.dart';               // ✅ socket

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();                           // ✅ storage first

  // ✅ Init theme manager — loads cached colors
  await DynamicThemeManager().init();

  // ✅ Register ThemeController once — available everywhere
  Get.put(ThemeController(), permanent: true);

  // Lock to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>(); // ✅ finds registered controller

    return GetMaterialApp(
      title: 'Your App',
      debugShowCheckedModeBanner: false,

      // ── Dynamic Themes ─────────────────────────────────────────
      themeMode:  themeCtrl.themeMode,           // ✅ reactive
      theme:      themeCtrl.lightTheme,          // ✅ dynamic light
      darkTheme:  themeCtrl.darkTheme,           // ✅ dynamic dark

      // ── Routing ────────────────────────────────────────────────
      initialRoute: Routes.SPLASH,
      getPages: AppPages.pages,

      // ── Transitions ────────────────────────────────────────────
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),

      // ── Locale ─────────────────────────────────────────────────
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

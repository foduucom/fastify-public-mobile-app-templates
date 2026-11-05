import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'constants/constants.dart';
import 'constants/dynamic_theme.dart';
import 'core/foduuStudio/register_default_widgets.dart';
import 'core/services/cartServcie.dart';
import 'core/services/wishlistService.dart';
import 'core/studio_socket_routing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init(); // ✅ storage first

  // Dynamic CMS sections must be registered before the homepage fetches its
  // layout, otherwise the API data arrives but no section widgets are built.
  registerDefaultWidgets();

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
      url = "https://$websiteDomain/";
      assetURL = "${url}images/";
      apiURL = "${url}api/";
    }

    Get.put(StudioSocketRouting(initialSlug: slug));
  }

  // ✅ Init theme manager — loads cached colors
  await DynamicThemeManager().init();

  // ✅ Register ThemeController once — available everywhere
  Get.put(ThemeController(), permanent: true);

  // Lock to portrait mode
  if (!kIsWeb) {
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
  }

  // Determine initial route
  final initialRoute = await _initApp();

  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> _initApp() async {
  final box = GetStorage();
  bool isLogin = box.read('isLogin') == true || box.read('isLogin') == 'true';

  // In Web / Studio mode, bypass Splash and Onboarding directly to BOTTOMBAR.
  // StudioSocketRouting will immediately navigate to the requested slug.
  if (kIsWeb) {
    return Routes.BOTTOMBAR;
  }

  if (isLogin) {
    return Routes.BOTTOMBAR;
  }
  return Routes.SPLASH;
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeCtrl =
        Get.find<ThemeController>(); // ✅ finds registered controller

    return GetMaterialApp(
      title: 'Your App',
      debugShowCheckedModeBanner: false,

      // ── Dynamic Themes ─────────────────────────────────────────
      themeMode: themeCtrl.themeMode, // ✅ reactive
      theme: themeCtrl.lightTheme, // ✅ dynamic light
      darkTheme: themeCtrl.darkTheme, // ✅ dynamic dark

      // ── Routing ────────────────────────────────────────────────
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      // Register services before the initial route (and its controllers) are
      // constructed. Route widget fields can resolve these during creation.
      initialBinding: BindingsBuilder(() {
        Get.put(CartService(), permanent: true);
        Get.put(WishListService(), permanent: true);
      }),

      // ── Transitions ────────────────────────────────────────────
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),

      // ── Locale ─────────────────────────────────────────────────
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

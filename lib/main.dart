import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/app/controllers/internetconnection_controller.dart';
import 'package:zouhi/core/services/wishlistService.dart';
import 'package:zouhi/core/services/cartServcie.dart';
import 'package:zouhi/constants/dynamic_theme.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/core/foduuStudio/register_default_widgets.dart';
import 'app/routes/app_pages.dart';

import 'package:flutter/foundation.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/core/studio_socket_routing.dart';

Future<void> _refreshPublicSettings() async {
  try {
    final response =
        await BasicProvider('public-settings', showSnackBar: false).getRequest();
    if (response != null && response is Map) {
      if (response.containsKey('storeSettings')) {
        final storeSettings = response['storeSettings'];
        if (storeSettings is Map &&
            storeSettings.containsKey('app_theme_color')) {
          final themeColor = storeSettings['app_theme_color'];
          if (themeColor is Map) {
            if (Get.isRegistered<ThemeController>()) {
              Get.find<ThemeController>().updateThemeFromApi(
                  Map<String, dynamic>.from(themeColor));
            } else {
              DynamicThemeManager().updateFromApi(
                  Map<String, dynamic>.from(themeColor));
            }
          }
        }
      }
    }
  } catch (e) {
    debugPrint('⚠️ Error fetching public-settings for dynamic theme: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize dynamic theme manager from local cache
  await DynamicThemeManager().init();
  Get.put(ThemeController(), permanent: true);

  // Refresh public settings in background to keep theme up-to-date with backend CMS
  _refreshPublicSettings();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  registerDefaultWidgets();
  Get.put(WishListService(), permanent: true);
  Get.put(CartService(), permanent: true);
  Get.put(InternetconnectionController(), permanent: true);
  Get.put(CurrencyController(), permanent: true);

  if (kIsWeb) {
    var accessKey = Uri.base.queryParameters['api_key'];
    var domain = Uri.base.queryParameters['domain_name'];
    String? slug = Uri.base.queryParameters['slug'] ?? 'home';
    if (accessKey == null && Uri.base.fragment.isNotEmpty) {
      try {
        final fragmentUri = Uri.parse(Uri.base.fragment);
        accessKey = fragmentUri.queryParameters['api_key'];
        domain = fragmentUri.queryParameters['domain_name'];
        slug = fragmentUri.queryParameters['slug'] ?? slug;
      } catch (e) {
        print("Error parsing URI fragment: $e");
      }
    }

    if (accessKey != null && accessKey.isNotEmpty) {
      ACCESS_KEY = accessKey;
      accessToken = accessKey;
    }

    if (domain != null && domain.isNotEmpty) {
      websiteDomain = domain;
    }

    Get.put(StudioSocketRouting(initialSlug: slug));
  }

  runApp(const AppRoot());

  // Notification channel/permission/token work is not needed to paint the first
  // frame; running it before runApp kept the main thread busy at launch.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.init();
  });
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Vision Infrastructure",
          theme: themeController.lightTheme,
          darkTheme: themeController.lightTheme,
          themeMode: ThemeMode.light,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        );
      },
    );
  }
}


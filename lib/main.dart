import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/app/controllers/internetconnection_controller.dart';
import 'package:zouhi/constants/theme.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  Get.put(InternetconnectionController(), permanent: true);
  Get.put(CurrencyController(), permanent: true);

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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Vision Infrastructure",
      theme: lightThemeData(),
      themeMode: ThemeMode.light,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

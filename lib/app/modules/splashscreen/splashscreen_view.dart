// // ignore_for_file: prefer_const_constructors, sort_child_properties_last

// import 'dart:async';
// import 'dart:isolate';

// import 'package:flutter/material.dart';
// import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
// import 'package:foduu_ecommerce/app/data/basic_provider.dart';
// import 'package:foduu_ecommerce/app/routes/app_pages.dart';
// import 'package:foduu_ecommerce/constants/constants.dart';
// import 'package:foduu_ecommerce/constants/dynamic_theme.dart';

// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// class SplashscreenView extends StatefulWidget with BaseController {
//   SplashscreenView({super.key});

//   @override
//   State<SplashscreenView> createState() => _SplashscreenViewState();
// }

// class _SplashscreenViewState extends State<SplashscreenView> {
//   bool isLoading = true;
//   List list = [];
//   final box = GetStorage();

//   @override
//   void initState() {
//     super.initState();
//     fetchSettings();
//   }

//   Future<void> fetchSettings() async {
//     try {
//       var response = await BasicProvider('public-settings').getRequest();

//       if (response != null) {
//         var authPreference = response['storeSettings']['auth_preference'];

//         // Save auth preference for use throughout the app
//         box.write('auth_preference', authPreference);

//         print('Auth Preference saved: $authPreference');

//         print('swapnil splash screen response ${response}');

//         if (response['storeSettings']['app_theme_color'] != null) {
//           print(
//               'App Theme Color: ${response['storeSettings']['app_theme_color']}');
//           DynamicThemeManager()
//               .updateFromApi(response['storeSettings']['app_theme_color']);

//           // Trigger app-wide theme rebuild
//           Get.find<ThemeController>().refreshTheme();
//         }

//         // // Check if user is already logged in
//         // bool isLogin = box.read('isLogin') ?? false;

//         // if (isLogin) {
//         //   // User is logged in, go to bottom bar
//         //   Get.offAllNamed(Routes.BOTTOMBAR);
//         // } else {
//         //   // User not logged in, go to login screen
//         //   Get.offAllNamed(Routes.LOGIN);
//         // }
//       } else {
//         throw Exception('Failed to load settings');
//       }
//     } catch (e) {
//       print('Error fetching settings: $e');
//       // Default to login screen on error
//       Get.offAllNamed(Routes.LOGIN);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           SizedBox(
//             height: Get.height * 0.85,
//             child: ClipPath(
//               child: Container(
//                 // color: themeRedColor,
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           // color: themeWhiteColor,
//                           borderRadius: BorderRadius.circular(80),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.black38,
//                               blurRadius: 6,
//                               spreadRadius: -1,
//                               offset: Offset(3, 6),
//                             ),
//                           ],
//                         ),
//                         height: 150,
//                         width: 150,
//                         child: Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: Image.asset('assets/images/app_logo.png'),
//                         ),
//                       ),
//                       SizedBox(height: 100),
//                       Text('Welcome to FoduuCart',
//                           style: TextStyle(
//                             fontFamily: 'Lato',
//                             fontSize: 20,
//                             fontWeight: FontWeight.w600,
//                           )),
//                       SizedBox(height: 40),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 50),
//                         child: Text(
//                           'Please let us know of your taste so show always bring you the most relevant looks & inspirations to shop from',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               fontFamily: 'Lato',
//                               // color: themeWhiteColor,
//                               fontSize: 16),
//                         ),
//                       ),
//                       SizedBox(height: 30),
//                     ],
//                   ),
//                 ),
//               ),
//               clipper: _CustomClipper(),
//             ),
//           ),
//           Positioned(
//             bottom: 15,
//             child: CircularProgressIndicator(
//               // backgroundColor: themeRedColor,
//               color: Colors.grey[300],
//               strokeWidth: 3.5,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class _CustomClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height - 150);
//     path.quadraticBezierTo(
//         size.width / 2, size.height - 40, size.width, size.height - 150);
//     path.lineTo(size.width, 0);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => true;
// }

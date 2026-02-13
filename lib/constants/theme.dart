import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foduu_ecommerce/constants/constants.dart';

// // Global theme structure
// ThemeData themeData() {
//   return ThemeData(
//     appBarTheme: const AppBarTheme(
//       systemOverlayStyle: SystemUiOverlayStyle.light,
//       toolbarTextStyle: TextStyle(
//         color: Colors.black,
//         fontWeight: FontWeight.w500,
//       ),
//       titleTextStyle: TextStyle(
//         color: Colors.black,
//         fontWeight: FontWeight.w500,
//         fontSize: 16.0,
//       ),
//       iconTheme: IconThemeData(
//         color: themeTextColor,
//       ),
//       backgroundColor: themeWhiteColor,
//     ),
//     fontFamily: 'Lato',
//     scaffoldBackgroundColor: Colors.white,
//     colorScheme: const ColorScheme.light(
//       primary: themePrimaryColor,
//       secondary: themeSecondryColor,
//       surface: themeSecondryColor,
//       background: Colors.white,
//       error: Colors.red,
//       onBackground: Colors.white,
//     ),
//     textTheme: txtTheme(),
//   );
// }

// TextTheme txtTheme() {
//   return const TextTheme(
//       displayLarge: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.w600,
//         color: themeTextColor,
//       ),
//       displayMedium: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: themeTextColor,
//       ),
//       displaySmall: TextStyle(
//         fontSize: 16,
//         color: themeTextColor,
//       ),
//       headlineSmall: TextStyle(fontSize: 15.5, color: themeTextColor),
//       titleLarge: TextStyle(fontSize: 14, color: themeTextColor),
//       titleMedium: TextStyle(
//           fontSize: 15.5, fontWeight: FontWeight.w400, color: themeTextColor),
//       titleSmall: TextStyle(fontSize: 10, color: themeTextColor));
// }

TextTheme txtTheme() {
  return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        // color: themeTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        // color: themeTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: 16,
        // color: themeTextColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 15.5,
      ),
      titleLarge: TextStyle(
        fontSize: 14,
      ),
      titleMedium: TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w400,
      ),
      titleSmall: TextStyle(
        fontSize: 10,
      ));
}

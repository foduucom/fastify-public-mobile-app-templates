// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/splashscreen/controller/splash_screen_controller.dart';
import 'package:foduu_ecommerce/app/modules/splashscreen/view/circular_loading_indicator.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashscreenView extends GetView<SplashScreenController> {
  SplashscreenView({super.key});

  @override
  Widget build(BuildContext context) {
    var height = Get.height;
    var width = Get.width;

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: height * 0.04,
            right: 0,
            left: 0,
            bottom: height * 0.18,
            child: Image.asset(
              'assets/images/splash.png',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: height * 0.80,
            right: 0,
            left: 0,
            bottom: height * 0.03,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularLoadingIndicator(
                  progress: controller.progressValue.value,
                  size: height * 0.10,
                ),
                Text(
                  '©2023 OCTAGON - All Right Reserved ',
                  style: TextStyle(
                    // Using ThemeColorExtension explicitly to avoid ambiguity
                    color: Theme.of(context).brightness == Brightness.dark
                        ? DefaultThemeColors.lightDarker // For dark mode
                        : DefaultThemeColors.darklighter, // For light mode
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

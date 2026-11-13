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
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: SizedBox(
              width: width * 0.55,
              height: width * 0.55,
              child: Image.asset(
                'assets/images/app_launcher_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: height * 0.04,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularLoadingIndicator(
                  progress: controller.progressValue.value,
                  size: height * 0.08,
                ),
                const SizedBox(height: 16),
                Text(
                  '©2023 OCTAGON - All Right Reserved ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
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

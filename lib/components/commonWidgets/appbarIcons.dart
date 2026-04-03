//Heart Icon
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

Widget HeartIcon(Function()? onTap) {
  return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icon/appbarlike.svg',
        colorFilter: ColorFilter.mode(
          Theme.of(Get.context!).colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ));
}

Widget NotificationIcon(Function()? onTap) {
  return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icon/appbarnotification.svg',
        colorFilter: ColorFilter.mode(
          Theme.of(Get.context!).colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ));
}

Widget SearchIcon(Function()? onTap) {
  return IconButton(
      onPressed: onTap,
      icon: SvgPicture.asset(
        'assets/icon/appbarsearch.svg',
        colorFilter: ColorFilter.mode(
          Theme.of(Get.context!).colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ));
}

//Cart Icon
Widget CartIcon(Function()? onTap) {
  return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icon/appbarshop.svg',
        colorFilter: ColorFilter.mode(
          Theme.of(Get.context!).colorScheme.onSurface,
          BlendMode.srcIn,
        ),
        // height: 22,
        // width: 22,
      ));
}

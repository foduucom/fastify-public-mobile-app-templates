//Heart Icon
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zouhi/constants/theme_ext.dart';

Widget HeartIcon(Function()? onTap) {
  return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icon/appbarlike.svg',
        colorFilter: ColorFilter.mode(Get.context!.themeTextColor, BlendMode.srcIn),
      ));
}

Widget NotificationIcon(Function()? onTap) {
  return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icon/appbarnotification.svg',
        colorFilter: ColorFilter.mode(Get.context!.themeTextColor, BlendMode.srcIn),
      ));
}

Widget SearchIcon(Function()? onTap) {
  return IconButton(
      onPressed: onTap,
      icon: SvgPicture.asset(
        'assets/icon/appbarsearch.svg',
        colorFilter: ColorFilter.mode(Get.context!.themeTextColor, BlendMode.srcIn),
      ));
}

//Cart Icon
Widget CartIcon(Function()? onTap) {
  return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icon/appbarshop.svg',
        colorFilter: ColorFilter.mode(Get.context!.themeTextColor, BlendMode.srcIn),
      ));
}

//Shop Icon
Widget ShopIcon(Function()? onTap) {
  return IconButton(
      onPressed: onTap,
      icon: SvgPicture.asset(
        'assets/icon/shop.svg',
        width: 20,
        height: 25,
        colorFilter: ColorFilter.mode(Get.context!.themeTextColor, BlendMode.srcIn),
      ));
}

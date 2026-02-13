//Heart Icon
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget HeartIcon(Function()? onTap) {
  return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icon/appbarlike.svg',
      ));
}

Widget NotificationIcon(Function()? onTap) {
  return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icon/appbarnotification.svg',
      ));
}

Widget SearchIcon(Function()? onTap) {
  return IconButton(
      onPressed: onTap,
      icon: SvgPicture.asset(
        'assets/icon/appbarsearch.svg',
      ));
}

//Cart Icon
Widget CartIcon(Function()? onTap) {
  return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icon/appbarshop.svg',
        // height: 22,
        // width: 22,
      ));
}

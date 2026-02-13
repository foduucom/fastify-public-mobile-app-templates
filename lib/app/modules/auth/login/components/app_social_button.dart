import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class AppSocialButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;
  final double? size;
  final double? iconSize;
  final Color backgroundColor;
  final Color borderColor;

  const AppSocialButton({
    super.key,
    required this.imagePath,
    this.onTap,
    this.size,
    this.iconSize,
    this.backgroundColor = DefaultThemeColors.lightOnPrimary,
    this.borderColor = DefaultThemeColors.darklighter,
  });

  @override
  Widget build(BuildContext context) {
    final width = size ?? Get.width * 0.14;
    final imgSize = iconSize ?? Get.width * 0.055;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: width,
        padding: EdgeInsets.all(width * 0.25),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: imgSize,
            height: imgSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

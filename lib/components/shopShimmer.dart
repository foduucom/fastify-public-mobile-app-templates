import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/constants/theme_ext.dart';

class ShopShimmer extends StatelessWidget {
  const ShopShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: context.isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  height: Get.height * 0.28,
                  width: 180,
                  decoration: BoxDecoration(
                      color: context.themeWhiteColor,
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 10),
              Container(
                  height: 10,
                  decoration: BoxDecoration(
                      color: context.themeWhiteColor,
                      borderRadius: BorderRadius.circular(10)),
                  width: 80),
              const SizedBox(height: 5),
              Container(
                  height: 10,
                  decoration: BoxDecoration(
                      color: context.themeWhiteColor,
                      borderRadius: BorderRadius.circular(10)),
                  width: 80),
              const SizedBox(height: 5),
              Container(
                  height: 10,
                  decoration: BoxDecoration(
                      color: context.themeWhiteColor,
                      borderRadius: BorderRadius.circular(10)),
                  width: 80),
            ]),
      ),
    );
  }
}


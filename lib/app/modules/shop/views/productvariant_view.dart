// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zouhi/app/modules/shop/controllers/productvariant_controller.dart';
import 'package:zouhi/components/colorextenstion.dart';
import 'package:zouhi/components/shimmer_effects.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:get/get.dart';

class ProductvariantView extends GetView<ProductvariantController> {
  ProductvariantView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() {
            if (controller.productDetials['name'] == null) {
              return ShimmerEffect(height: 10, width: 100);
            } else {
              return Text(
                controller.productDetials['name'].toString(),
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: context.themeTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              );
            }
          }),
          titleSpacing: 0.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      if (controller.productDetials['image'] == null) {
                        return ShimmerEffect(
                            height: Get.height * 0.6, width: Get.width);
                      } else {
                        final img = controller.productDetials['image']?.toString() ?? '';
                        final hasValidImg = img.isNotEmpty &&
                            img != HelperFunctions.getNoImage() &&
                            (Uri.tryParse(img)?.hasAuthority ?? false);
                        return ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: SizedBox(
                                height: Get.height * 0.6,
                                width: Get.width,
                                child: hasValidImg
                                    ? CachedNetworkImage(
                                        height: Get.height * 0.6,
                                        width: Get.width,
                                        fit: BoxFit.contain,
                                        imageUrl: img,
                                        errorWidget: (context, url, error) =>
                                            const ProductImagePlaceholder(radius: 3),
                                        progressIndicatorBuilder:
                                            (context, url, progress) => Container(
                                          decoration: BoxDecoration(
                                              color: context.themegreyColor),
                                          height: 165,
                                          child: Center(
                                            child: SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: HelperFunctions()
                                                  .loadingIndicator(),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const ProductImagePlaceholder(radius: 3)));
                      }
                    }),
                    SizedBox(height: 8.0),
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            controller.productDetials['name'] == null
                                ? ShimmerEffect(height: 10, width: 100)
                                : Text(
                                    controller.productDetials['name']
                                        .toString(),
                                    style: txtTheme().headlineMedium!.copyWith(
                                        color: context.themeTextColor)),
                            SizedBox(height: 10),
                            Html(
                              data: controller.productDetials['content'] ?? "",
                              style: {
                                "body": Style(
                                    color: context.themeTextColor,
                                    fontFamily: 'Poppins')
                              },
                            ),
                            SizedBox(height: 10),
                            Html(
                              data: controller.productDetials['long_content'] ??
                                  "",
                              style: {
                                "body": Style(
                                    color: context.themeTextColor,
                                    fontFamily: 'Poppins')
                              },
                            ),
                            SizedBox(height: 10),
                            Text("Product Price: ",
                                style: txtTheme()
                                    .headlineMedium!
                                    .copyWith(color: context.themeTextColor)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(currency,
                                    style: txtTheme().headlineSmall!.copyWith(
                                        fontSize: 20,
                                        color: context.themeTextColor)),
                                Text(
                                  controller.productDetials['sale_price'] ??
                                      '0'.toString(),
                                  style: txtTheme().headlineSmall!.copyWith(
                                      fontSize: 20,
                                      color: context.themeTextColor),
                                ),
                                SizedBox(width: 04),
                                Text(
                                  controller.productDetials['price'].toString(),
                                  style: txtTheme().headlineSmall!.copyWith(
                                      color: context.themeSecondrytext,
                                      decoration: TextDecoration.lineThrough),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Text("Select Color: ",
                                style: txtTheme()
                                    .headlineMedium!
                                    .copyWith(color: context.themeTextColor)),
                            SizedBox(height: 10),
                            Row(
                              children: List.generate(
                                  controller.colorList.length,
                                  (index) => Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Container(
                                          width: 35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color:
                                                  '${controller.colorList[index]['value']}'
                                                      .toColor()),
                                        ),
                                      )),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Select Size:",
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        color: context.themeTextColor)),
                                GestureDetector(
                                  onTap: () => sizeModel(context),
                                  child: Text("Size Chart",
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: themeRedColor,
                                          fontSize: 14)),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFDD4B39),
                                  borderRadius: BorderRadius.circular(50)),
                              child: Center(
                                child: Obx(() {
                                  return Text(
                                    controller.getYourSize.value.toString(),
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 16),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(height: 100)
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                child: Material(
                  elevation: 10,
                  color: context.themeWhiteColor,
                  child: Container(
                      width: Get.width,
                      height: 50,
                      color: context.themeWhiteColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                  'assets/icon/appbarlike.svg',
                                  colorFilter: ColorFilter.mode(
                                      context.themeTextColor, BlendMode.srcIn)),
                              label: Text("WISHLIST",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: context.themeTextColor)),
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent)),
                          ElevatedButton.icon(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                  'assets/icon/appbarshop.svg',
                                  colorFilter: ColorFilter.mode(
                                      context.themeTextColor, BlendMode.srcIn)),
                              label: Text("ADD TO BAG",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: context.themeTextColor)),
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent))
                        ],
                      )),
                ))
          ],
        ),
      ),
    );
  }

  sizeModel(BuildContext context) {
    return Get.defaultDialog(
        backgroundColor: context.themeWhiteColor,
        title: "",
        titleStyle: TextStyle(height: 0.0),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0.0),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 80,
          height: Get.height * 0.20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Your Size',
                style: txtTheme()
                    .headlineMedium!
                    .copyWith(color: context.themeTextColor),
              ),
              SizedBox(
                height: 30,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.sizeList.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      return GestureDetector(
                        onTap: () {
                          controller.getSelectedSize.value = index;
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Container(
                            width: 40,
                            decoration: BoxDecoration(
                                color: controller.getSelectedSize.value == index
                                    ? themeRedColor
                                    : context.themegreyColor,
                                borderRadius: BorderRadius.circular(3)),
                            child: Center(
                              child: Text(
                                controller.sizeList[index]['value'].toString(),
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: controller.getSelectedSize.value ==
                                            index
                                        ? Colors.white
                                        : context.themeTextColor,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              SizedBox(
                height: 45,
                width: Get.width,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.sizeOnSubmit();
                  },
                  child: Text('Submit'.toUpperCase(),
                      style: txtTheme()
                          .headlineSmall!
                          .copyWith(color: Colors.white)),
                  style: themeButton,
                ),
              ),
            ],
          ),
        ),
        radius: 0.0);
  }
}

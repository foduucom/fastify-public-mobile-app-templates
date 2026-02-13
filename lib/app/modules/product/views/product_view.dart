import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/product/controllers/product_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/ImagePreviewMultipleView.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/components/commonWidgets/appbarIcons.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:foduu_ecommerce/components/commonWidgets/simple_price_text.dart';
import 'package:foduu_ecommerce/components/commonWidgets/variable_price_text.dart';
import 'package:foduu_ecommerce/components/gridviewproductcard.dart';
import 'package:foduu_ecommerce/components/review.dart';
import 'package:foduu_ecommerce/components/shimmer_effects.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProductView extends GetView<ProductController> {
  ProductView({Key? key}) : super(key: key);

  WishlistController wishListController = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;
    Get.create(() => ProductController(), permanent: false);
    final controller = Get.find<ProductController>();

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: height * 0.02),
                    SecondaryAppHeader(
                      title: "Product Detail",
                      rightIcon: Icons.favorite_outline,
                    ),
                    SizedBox(height: height * 0.02),
                    Obx(
                      () {
                        return ProductGallery(
                          controller: controller,
                          productGallery: controller.productDetials['type'] ==
                                  'variable' // Your API says "type":"variable"
                              ? controller.productDetials['variants']
                                      [controller.selectedVariantIndex.value][
                                  'images'] // Change from 'gallery' to 'images'
                              : controller.productGallery,
                        );
                      },
                    ),
                    const SizedBox(height: 8.0),
                    Obx(() {
                      return controller.productGallery.length == 1
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(
                                controller.productDetials['type'] == 'variant'
                                    ? controller
                                        .productDetials['variant_ids'][
                                            controller.selectedVariantIndex
                                                .value]['gallery']
                                        .length
                                    : controller.productGallery.length,
                                (index) => Obx(() {
                                  return Container(
                                    width: controller.selectedPageIndex.value ==
                                            index
                                        ? 30
                                        : 9,
                                    height: 9,
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  );
                                }),
                              ));
                    }),
                    Column(
                      children: [
                        Padding(
                          padding: pageSurroundingPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              // In your ProductView build method, after the gallery and before color selector:
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Product Name (Left side)
                                  Expanded(
                                    child: Obx(
                                      () => controller.productDetials['name'] ==
                                              null
                                          ? const ShimmerEffect(
                                              height: 20, width: 150)
                                          : Text(
                                              controller.productDetials['name']
                                                  .toString(),
                                              style: txtTheme()
                                                  .displayMedium!
                                                  .copyWith(
                                                    fontSize: height * 0.020,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                    ),
                                  ),

                                  // Price (Right side)
                                  Obx(
                                    () {
                                      if (controller.productDetials.isEmpty) {
                                        return const ShimmerEffect(
                                            height: 20, width: 80);
                                      }

                                      final productType =
                                          controller.productDetials['type'] ??
                                              'simple';

                                      if (productType == 'variable') {
                                        final variants = controller
                                                .productDetials['variants']
                                            as List?;
                                        if (variants != null &&
                                            variants.isNotEmpty) {
                                          final selectedVariant = variants[
                                              controller
                                                  .selectedVariantIndex.value];
                                          final price =
                                              selectedVariant['price'] ?? 0;
                                          final discountedPrice =
                                              selectedVariant[
                                                      'discounted_price'] ??
                                                  0;

                                          String discountRate = '';
                                          if (discountedPrice > 0 &&
                                              price > discountedPrice) {
                                            final discount =
                                                ((price - discountedPrice) /
                                                        price *
                                                        100)
                                                    .round();
                                            discountRate = '$discount% off';
                                          }

                                          return SimplePriceText(
                                            price: discountedPrice > 0
                                                ? discountedPrice
                                                : price,
                                            originalPrice: discountedPrice > 0
                                                ? price
                                                : null,
                                            discountLabel: discountedPrice > 0
                                                ? discountRate
                                                : null,
                                            priceStyle: txtTheme()
                                                .displayMedium!
                                                .copyWith(
                                                  fontSize: height * 0.020,
                                                  fontWeight: FontWeight.w700,
                                                  color: DefaultThemeColors
                                                      .mainprimary,
                                                ),
                                          );
                                        }
                                      }

                                      // Fallback
                                      final priceInfo =
                                          ProductHelper.calculatePriceInfo(
                                              controller.productDetials
                                                  .toJson());

                                      if (productType == 'variable') {
                                        return VariablePriceText(
                                          lowestPrice: priceInfo['lowestPrice'],
                                          highestPrice:
                                              priceInfo['highestPrice'],
                                          style: txtTheme()
                                              .displayMedium!
                                              .copyWith(
                                                fontSize: height * 0.020,
                                                fontWeight: FontWeight.w700,
                                                color: DefaultThemeColors
                                                    .mainprimary,
                                              ),
                                        );
                                      } else {
                                        return SimplePriceText(
                                          price: priceInfo['productPrice'],
                                          originalPrice:
                                              priceInfo['discountPrice'],
                                          discountLabel:
                                              priceInfo['discountRate'],
                                          priceStyle: txtTheme()
                                              .displayMedium!
                                              .copyWith(
                                                fontSize: height * 0.020,
                                                fontWeight: FontWeight.w700,
                                                color: DefaultThemeColors
                                                    .mainprimary,
                                              ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.001),
                              Padding(
                                padding: EdgeInsets.zero,
                                //width: width * 0.80,
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: height * 0.018, // ≈ 16
                                          color: DefaultThemeColors.darklight,
                                        ),
                                        Text('1.0',
                                            style:
                                                txtTheme().titleSmall!.copyWith(
                                                      fontSize: height * 0.018,
                                                      height: 1.4,
                                                      fontFamily:
                                                          'Plus Jakarta Sans',
                                                    )),
                                      ],
                                    ),
                                    SizedBox(width: width * 0.012),
                                    Text(
                                      "•",
                                      style: TextStyle(
                                        fontSize: height * 0.02,
                                        color: DefaultThemeColors.lightDarker,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.012),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.storefront,
                                          size: height * 0.02, // ≈ 16
                                          color: DefaultThemeColors.darkdark,
                                        ),
                                        SizedBox(width: width * 0.015),
                                        Text(
                                          'Near Store',
                                          style: txtTheme()
                                              .titleSmall!
                                              .copyWith(
                                                fontFamily: 'Plus Jakarta Sans',
                                                color:
                                                    DefaultThemeColors.darkdark,
                                                fontSize: height * 0.018,
                                                height: 1.4,
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: width * 0.012),
                                    Text(
                                      "•",
                                      style: TextStyle(
                                        fontSize: height * 0.02,
                                        color: DefaultThemeColors.lightDarker,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.012),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: height * 0.02, // ≈ 16
                                          color: DefaultThemeColors.darkdark,
                                        ),
                                        SizedBox(width: width * 0.015),
                                        Obx(
                                          () {
                                            return Text(
                                              '${controller.productReview.length} Reviews',
                                              style: txtTheme()
                                                  .titleSmall!
                                                  .copyWith(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    fontSize: height * 0.018,
                                                    height: 1.4,
                                                  ),
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              // Obx(
                              //   () => Row(
                              //     children: [
                              //       RatingBarIndicator(
                              //         rating: controller.productDetials[
                              //                     'average_rating'] ==
                              //                 null
                              //             ? 0.0
                              //             : double.parse(controller
                              //                 .productDetials['average_rating']
                              //                 .toString()),
                              //         itemBuilder: (context, index) => const Icon(
                              //           Icons.star,
                              //           color: Colors.amber,
                              //         ),
                              //         itemCount: 5,
                              //         itemSize: 18.0,
                              //         direction: Axis.horizontal,
                              //       ),
                              //       const SizedBox(width: 10),
                              //       Text(
                              //         controller.productDetials['rating_count'] ==
                              //                 null
                              //             ? '0'
                              //             : controller
                              //                 .productDetials['rating_count']
                              //                 .toString(),
                              //         style: txtTheme().titleLarge!.copyWith(

                              //         ),
                              //       )
                              //     ],
                              //   ),
                              // ),
                              // const SizedBox(height: 10),
                              // Obx(() {
                              //   if (controller.productDetials['variant_ids'] ==
                              //       null) {
                              //     return const ShimmerEffect(
                              //         height: 10, width: 50);
                              //   } else {
                              //     var productPrice = controller
                              //                     .productDetials['variant_ids'][
                              //                 controller.selectedVariantIndex
                              //                     .value]['sale_price'] ==
                              //             null
                              //         ? controller.productDetials['variant_ids']
                              //                 [controller.selectedVariantIndex.value]
                              //                 ['price']
                              //             .toString()
                              //         : controller.productDetials['variant_ids']
                              //                 [controller.selectedVariantIndex.value]
                              //                 ['sale_price']
                              //             .toString();
                              //     var sale_price = controller
                              //                     .productDetials['variant_ids'][
                              //                 controller.selectedVariantIndex
                              //                     .value]['sale_price'] ==
                              //             null
                              //         ? null
                              //         : controller.productDetials['variant_ids'][
                              //                 controller.selectedVariantIndex
                              //                     .value]['price']
                              //             .toString();
                              //     return Row(
                              //       crossAxisAlignment: CrossAxisAlignment.end,
                              //       children: [
                              //         Text(
                              //           "₹${productPrice}",
                              //           style: txtTheme().titleLarge,
                              //         ),
                              //         const SizedBox(width: 04),
                              //         sale_price == null
                              //             ? Container()
                              //             : Text(
                              //                 "₹${sale_price}",
                              //                 style: txtTheme()
                              //                     .titleLarge!
                              //                     .copyWith(
                              //                         decoration: TextDecoration
                              //                             .lineThrough),
                              //               ),
                              //         Text(
                              //           controller.productDetials['variant_ids'][
                              //                       controller
                              //                           .selectedVariantIndex
                              //                           .value]['sale_price'] ==
                              //                   null
                              //               ? ''
                              //               // : " ${(100 - controller.productDetials['variant_ids'][controller.selectedVariantIndex.value]['sale_price'] * 100 / controller.productDetials['variant_ids'][controller.selectedVariantIndex.value]['price']).round()}" +
                              //               //     "%off",
                              //               : ' (${(((controller.productDetials['variant_ids'][controller.selectedVariantIndex.value]['price'] - controller.productDetials['variant_ids'][controller.selectedVariantIndex.value]['sale_price']) / controller.productDetials['variant_ids'][controller.selectedVariantIndex.value]['price']) * 100).toStringAsFixed(2)}% off)',
                              //           style: txtTheme().titleLarge!.copyWith(),
                              //         )
                              //       ],
                              //     );
                              //   }
                              // }),
                              // Text("Inclusive of all taxes",
                              //     style: txtTheme().titleLarge!.copyWith()),
                            ],
                          ),
                        ),

                        // COLOR SELECTOR - Make it reactive
                        Obx(
                          () => controller.colors.isEmpty
                              ? SizedBox.shrink() // Hide if no colors
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Color',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: height * 0.018,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.01),
                                    Container(
                                      width: width * 0.90,
                                      height: height * 0.045,
                                      child: Row(
                                        children: List.generate(
                                            controller.colors.length, (index) {
                                          final bool isActive = index ==
                                              controller
                                                  .selectedColorIndex.value;
                                          print(
                                              "Selected Color Index: ${controller.selectedColorIndex.value}");
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right: index !=
                                                      controller.colors.length -
                                                          1
                                                  ? width * 0.02
                                                  : 0,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                controller.selectedColorIndex
                                                    .value = index;
                                                print(
                                                    "Pressed Color Index: ${controller.selectedColorIndex.value}");
                                                controller
                                                    .updateSelectedVariant();
                                              },
                                              child: Container(
                                                width: width * 0.162,
                                                height: height * 0.045,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.032,
                                                  vertical: height * 0.0075,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? DefaultThemeColors
                                                          .lightOnSecondary
                                                      : DefaultThemeColors
                                                          .darklight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          height * 2),
                                                  border: Border.all(
                                                    color: isActive
                                                        ? DefaultThemeColors
                                                            .darklight
                                                        : DefaultThemeColors
                                                            .lightOnSecondary,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    controller.colors[index],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Plus Jakarta Sans',
                                                      fontSize: height * 0.015,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isActive
                                                          ? DefaultThemeColors
                                                              .lightOnPrimary
                                                          : DefaultThemeColors
                                                              .lightOnSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                        ),

                        SizedBox(height: height * 0.02),

                        // SIZE SELECTOR - Make it reactive
                        Obx(
                          () => controller.sizes.isEmpty
                              ? SizedBox.shrink() // Hide if no sizes
                              : Container(
                                  width: width * 0.90,
                                  height: height * 0.045,
                                  child: Row(
                                    children: List.generate(
                                        controller.sizes.length, (index) {
                                      // ✅ FIXED: Change from activeIndex to selectedSizeIndex
                                      final bool isActive = index ==
                                          controller.selectedSizeIndex.value;
                                      print(
                                          "Selected Size Index: ${controller.selectedSizeIndex.value}");
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          right: index !=
                                                  controller.sizes.length - 1
                                              ? width * 0.02
                                              : 0,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            // ✅ FIXED: Change from activeIndex to selectedSizeIndex
                                            controller.selectedSizeIndex.value =
                                                index;
                                            print(
                                                "Pressed Size Index: ${controller.selectedSizeIndex.value}");
                                            controller.updateSelectedVariant();
                                          },
                                          child: Container(
                                            width: width * 0.162,
                                            height: height * 0.045,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: width * 0.032,
                                              vertical: height * 0.0075,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? DefaultThemeColors
                                                      .lightOnBackground
                                                  : DefaultThemeColors
                                                      .darklight,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      height * 2),
                                              border: Border.all(
                                                color: isActive
                                                    ? DefaultThemeColors
                                                        .darklight
                                                    : DefaultThemeColors
                                                        .lightOnBackground,
                                                width: 1,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                controller.sizes[index],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontSize: height * 0.015,
                                                  fontWeight: FontWeight.w500,
                                                  color: isActive
                                                      ? DefaultThemeColors
                                                          .lightOnPrimary
                                                      : DefaultThemeColors
                                                          .lightOnSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                        ),

                        SizedBox(height: height * 0.01),

                        Padding(
                          padding: pageSurroundingPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Obx(
                              //   () {
                              //     return Column(
                              //       children: [
                              //         ListView.separated(
                              //             physics:
                              //                 const NeverScrollableScrollPhysics(),
                              //             shrinkWrap: true,
                              //             itemBuilder: (context, parentIndex) {
                              //               return Column(
                              //                 crossAxisAlignment:
                              //                     CrossAxisAlignment.start,
                              //                 children: [
                              //                   Text(
                              //                       'Select ${controller.labels[parentIndex]}',
                              //                       style: txtTheme()
                              //                           .titleLarge!
                              //                           .copyWith(
                              //                               fontWeight:
                              //                                   FontWeight.bold)),
                              //                   Padding(
                              //                     padding: const EdgeInsets.only(
                              //                         top: 8.0),
                              //                     child: SizedBox(
                              //                       height: 40,
                              //                       child: ListView.builder(
                              //                         shrinkWrap: true,
                              //                         scrollDirection:
                              //                             Axis.horizontal,
                              //                         itemCount: controller
                              //                             .labelVariant[
                              //                                 parentIndex]
                              //                             .length,
                              //                         itemBuilder:
                              //                             (context, index) {
                              //                           return GestureDetector(
                              //                             onTap: () {
                              //                               controller.onSelectVariant(
                              //                                   controller.labels[
                              //                                       parentIndex],
                              //                                   controller.labelVariant[
                              //                                           parentIndex]
                              //                                       [index]);
                              //                               print(
                              //                                   controller.labels[
                              //                                       parentIndex]);
                              //                               print(
                              //                                   'label variant ${controller.labelVariant}');
                              //                               print(
                              //                                   'parent index index  ${controller.labelVariant[parentIndex][index]}');
                              //                             },
                              //                             child: Obx(
                              //                               () {
                              //                                 print(
                              //                                     '${controller.labelVariant[parentIndex][index]} = ${controller.joinedVariants.contains(controller.labelVariant[parentIndex][index])}');
                              //                                 return Container(
                              //                                   margin:
                              //                                       const EdgeInsets
                              //                                           .only(
                              //                                           right:
                              //                                               10),
                              //                                   padding:
                              //                                       const EdgeInsets
                              //                                           .symmetric(
                              //                                           horizontal:
                              //                                               15,
                              //                                           vertical:
                              //                                               2),
                              //                                   decoration:
                              //                                       BoxDecoration(
                              //                                     border: Border.all(
                              //                                         width: 1.5,
                              //                                         // color: controller
                              //                                         //         .joinedVariants
                              //                                         //         .contains(controller.labelVariant[parentIndex][
                              //                                         //             index])
                              //                                         //     ? Colors
                              //                                         //         .red
                              //                                         //         .shade300
                              //                                         //     : themegreyColor),
                              //                                         color: controller.containsExactSize(controller.joinedVariants.value, controller.labelVariant[parentIndex][index]) ? Colors.red.shade300 : Colors.red),
                              //                                     borderRadius:
                              //                                         BorderRadius
                              //                                             .circular(
                              //                                                 08),
                              //                                   ),
                              //                                   child: Center(
                              //                                     child: Text(
                              //                                       controller.labelVariant[
                              //                                               parentIndex]
                              //                                           [index],
                              //                                       style: const TextStyle(
                              //                                           color: Colors
                              //                                               .black),
                              //                                     ),
                              //                                   ),
                              //                                 );
                              //                               },
                              //                             ),
                              //                           );
                              //                         },
                              //                       ),
                              //                     ),
                              //                   )
                              //                 ],
                              //               );
                              //             },
                              //             separatorBuilder: (context, index) {
                              //               return const SizedBox(
                              //                 height: 10,
                              //               );
                              //             },
                              //             itemCount: controller.labels.length)
                              //       ],
                              //     );
                              //   },
                              // ),
                              //const SizedBox(height: 10),

                              Padding(
                                  padding: EdgeInsets
                                      .zero, // Add your desired padding here
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: width * 0.535, // ≈ 200.15
                                            child: Text(
                                              "Description",
                                              style: TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: height * 0.02, // ≈ 16
                                                fontWeight:
                                                    FontWeight.w700, // Bold
                                                height: 1.75, // ≈ 28
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                side: const BorderSide(
                                                    color: Color.fromARGB(
                                                        255, 216, 216, 216)),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                elevation: 0,
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                              onPressed: () {
                                                reviewModal(controller);
                                              },
                                              child: Text('Add Review',
                                                  style: txtTheme()
                                                      .titleLarge!
                                                      .copyWith(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                        ],
                                      ),

                                      SizedBox(
                                          height:
                                              height * 0.004), // ≈ gap 10.46

                                      // Remove the Expanded widget
                                      Container(
                                        width: width * 0.92,
                                        child: Obx(() {
                                          final description =
                                              controller.productDetials[
                                                      'long_content'] ??
                                                  "";
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize:
                                                MainAxisSize.min, // Add this
                                            children: [
                                              Html(
                                                data: description,
                                                style: {
                                                  "body": Style(
                                                    fontWeight: FontWeight.w700,
                                                    color: DefaultThemeColors
                                                        .darklighter,
                                                    maxLines: controller
                                                            .isDescriptionExpanded
                                                            .value
                                                        ? 3
                                                        : 10,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                },
                                              ),
                                              if (description.length > 150)
                                                GestureDetector(
                                                  onTap: () => controller
                                                      .toggleDescription(),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: height * 0.01),
                                                    child: Text(
                                                      controller
                                                              .isDescriptionExpanded
                                                              .value
                                                          ? 'Read less'
                                                          : 'Read more',
                                                      style: TextStyle(
                                                        fontSize:
                                                            height * 0.016,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            DefaultThemeColors
                                                                .mainprimary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        // const Divider(
                        //   thickness: 10,
                        // ),
                        // Padding(
                        //   padding: pageSurroundingPadding,
                        //   child: Column(
                        //     children: [
                        // Row(
                        //   mainAxisAlignment:
                        //       MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Obx(
                        //       () => Text(
                        //           "Customer Reviews  ${controller.productReview.length}",
                        //           style: txtTheme().titleLarge!.copyWith(
                        //               fontWeight: FontWeight.bold)),
                        //     ),
                        //     InkWell(
                        //       onTap: () {},
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(8.0),
                        //         child: Text("All Reviews",
                        //             style: txtTheme()
                        //                 .titleLarge!
                        //                 .copyWith(
                        //                     fontWeight: FontWeight.bold)),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 10),
                        //       Obx(
                        //         () => ListView.separated(
                        //             shrinkWrap: true,
                        //             physics:
                        //                 const NeverScrollableScrollPhysics(),
                        //             separatorBuilder: (context, index) =>
                        //                 const Divider(
                        //                   thickness: 0.9,
                        //                 ),
                        //             itemCount: controller
                        //                         .productReview.value.length >
                        //                     2
                        //                 ? 2
                        //                 : controller.productReview.value.length,
                        //             itemBuilder: (context, index) {
                        //               return customerReview(
                        //                 profileimage: controller.productReview[
                        //                                 index]['customer']
                        //                             ['featured_image'] ==
                        //                         null
                        //                     ? HelperFunctions.getNoImage()
                        //                     : url +
                        //                         controller.productReview[index]
                        //                                     ['customer']
                        //                                 ['featured_image']
                        //                             ['filepath'],
                        //                 name:
                        //                     "${controller.productReview[index]['customer']['name'].toString()} | ${controller.getDate(controller.productReview[index]['updated_at'])}",
                        //                 review: controller.productReview[index]
                        //                     ['summary'],
                        //                 rating: controller.productReview[index]
                        //                     ['rating'],
                        //               );
                        //             }),
                        //       ),
                        //       const SizedBox(
                        //         height: 10,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const Divider(
                        //   thickness: 10,
                        // ),
                        // Obx(() => controller.similarProduct.isNotEmpty
                        //     ? Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Padding(
                        //             padding: pageSurroundingPadding,
                        //             child: Text("Similar Products",
                        //                 style: txtTheme().titleLarge!.copyWith(
                        //                     fontWeight: FontWeight.bold)),
                        //           ),
                        //           Obx(
                        //             () {
                        // print(
                        // 'djdjdj ${shopController.allProductList.length}');
                        // return SizedBox(
                        //   height: 240,
                        //   child: ListView.separated(
                        //       separatorBuilder:
                        //           (context, index) =>
                        //               const SizedBox(width: 10),
                        //       scrollDirection: Axis.horizontal,
                        //       itemCount: controller
                        //           .similarProduct.length,
                        //       itemBuilder: (context, index) {
                        //         var lowest;
                        //         var highest;
                        //         if (controller
                        //                     .similarProduct[index]
                        //                 ['type'] ==
                        //             'variant') {
                        //           // for (var item in trendingList) {
                        //           lowest = HelperFunctions
                        //               .lowestPrice(controller
                        //                       .similarProduct[
                        //                   index]['variant_ids']);
                        //           highest = HelperFunctions
                        //               .highestPrice(controller
                        //                       .similarProduct[
                        //                   index]['variant_ids']);

                        // }
                        //                   }
                        //                   return Padding(
                        //                     padding: const EdgeInsets.only(
                        //                         left: 05),
                        //                     child: gridProductCart(
                        //                       animationController:
                        //                           controller.controller,
                        //                       scaoleAnimation:
                        //                           controller.scaleAnimation,
                        //                       highestPrice:
                        //                           highest.toString(),
                        //                       lowestPrice:
                        //                           lowest.toString(),
                        //                       productType: controller
                        //                               .similarProduct[index]
                        //                           ['type'],
                        //                       liked: GetBuilder<
                        //                           WishlistController>(
                        //                         builder:
                        //                             (wishlistcontroller) {
                        //                           return wishlistcontroller
                        //                                   .wishlistProductIds
                        //                                   .contains(controller
                        //                                           .similarProduct[
                        //                                       index]['_id'])
                        //                               ? SvgPicture.asset(
                        //                                   'assets/icon/like.svg')
                        //                               : SvgPicture.asset(
                        //                                   'assets/icon/unlike.svg');
                        //                         },
                        //                       ),

                        //                       onLiked: () async {
                        //                         print('object');
                        //                         await wishListController
                        //                             .addProductToWishlist(
                        //                                 productid: controller
                        //                                         .similarProduct[
                        //                                     index]['_id']);
                        //                         await wishListController
                        //                             .getwishlist();
                        //                       },
                        //                       rating: double.parse(
                        //                         controller.similarProduct[
                        //                                         index][
                        //                                     'average_rating'] ==
                        //                                 null
                        //                             ? '0'
                        //                             : controller
                        //                                 .similarProduct[
                        //                                     index][
                        //                                     'average_rating']
                        //                                 .toString(),
                        //                       ),
                        //                       // rating: 3.3,
                        //                       quantity: controller.similarProduct[
                        //                                           index][
                        //                                       'variant_ids']
                        //                                   [0]['quantity'] ==
                        //                               null
                        //                           ? "Out of stock"
                        //                           : controller
                        //                               .similarProduct[index]
                        //                                   ['variant_ids'][0]
                        //                                   ['quantity']
                        //                               .toString(),
                        //                       keypressEvent: () {
                        //                         Get.toNamed(
                        //                             Routes.PRODUCTDETAILS,
                        //                             preventDuplicates:
                        //                                 false,
                        //                             arguments: {
                        //                               'productId': controller
                        //                                       .similarProduct[
                        //                                   index]['_id']
                        //                             });
                        //                       },
                        //                       assetimage: controller
                        //                                       .similarProduct[index]
                        //                                   [
                        //                                   'featured_image'] ==
                        //                               null
                        //                           ? ''
                        //                           : url +
                        //                               controller.similarProduct[
                        //                                           index][
                        //                                       'featured_image']
                        //                                   ['filepath'],
                        //                       // 'https://www.babycouture.in/blog/wp-content/uploads/2016/04/elegant-summers-yellow-blue-kids-dress.jpg',
                        //                       productname: controller
                        //                           .similarProduct[index]
                        //                               ['name']
                        //                           .toString(),
                        //                       productprice: controller.similarProduct[
                        //                                           index]
                        //                                       ['variant_ids'][0]
                        //                                   ['sale_price'] ==
                        //                               null
                        //                           ? controller
                        //                               .similarProduct[index]
                        //                                   ['variant_ids'][0]
                        //                                   ['price']
                        //                               .toString()
                        //                           : controller
                        //                               .similarProduct[index]
                        //                                   ['variant_ids'][0]
                        //                                   ['sale_price']
                        //                               .toString(),
                        //                       discountprice:
                        //                           controller.similarProduct[
                        //                                               index]
                        //                                           [
                        //                                           'variant_ids'][0]
                        //                                       [
                        //                                       'sale_price'] ==
                        //                                   null
                        //                               ? ''
                        //                               : controller
                        //                                   .similarProduct[
                        //                                       index][
                        //                                       'variant_ids']
                        //                                       [0]['price']
                        //                                   .toString(),
                        //                       discountrate: controller.similarProduct[
                        //                                           index][
                        //                                       'variant_ids'][0]
                        //                                   ['sale_price'] ==
                        //                               null
                        //                           ? ''
                        //                           : " ${(100 - controller.similarProduct[index]['variant_ids'][0]['sale_price'] * 100 / controller.similarProduct[index]['variant_ids'][0]['price']).round()}" +
                        //                               "%off",
                        //                       height: Get.width * 0.41,
                        //                       width: Get.width * 0.40,
                        //                     ),
                        //                   );
                        //                 }),
                        //           );
                        //         },
                        //       ),
                        //     ],
                        //   )
                        // : Container()),
                        const SizedBox(height: 50)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Positioned(
            //     bottom: 0,
            //     child: Obx(
            //       () => OrderButton(
            //         btntext: controller.isAlreadyInCart.value
            //             ? 'Already in cart'
            //             : 'Add to Bag',
            //         controller: controller,
            //         wishListTap: () async {
            //           await wishListController.addProductToWishlist(
            //               productid: controller.productId);
            //           await wishListController.getwishlist();
            //         },
            //         addToCartTap: () async {
            //           if (controller.isAlreadyInCart.value) {
            //             HelperFunctions.defaultdialogbox(
            //                 'Product Already Added In Cart');
            //             Future.delayed(const Duration(seconds: 2))
            //                 .then((value) => Get.back());
            //           } else {
            //             HelperFunctions().showOverlayLoader();
            //             if (wishListController.wishlistProductIds
            //                 .contains(controller.productId)) {
            //               await wishListController.addProductToWishlist(
            //                   productid: controller.productId);
            //             }
            //             await controller.addToCart().then((value) {
            //               Get.until((route) => !Get.isDialogOpen!);
            //               return Get.toNamed(Routes.CART);
            //             });
            //           }
            //         },
            //       ),
            //     )),
          ],
        ),
        bottomNavigationBar: _addToCartFooter(width: width, height: height),
      ),
    );
  }

  Widget _addToCartFooter({
    required final width,
    required final height,
  }) {
    return Container(
      width: width, // ≈ 393
      height: height * 0.10, // ≈ 80
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.06, // ≈ 24
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width * 0.30, // ≈ 118
            height: height * 0.06, // ≈ 48
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: height * 0.05, // ≈ 40
                  height: height * 0.05, // ≈ 40
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DefaultThemeColors.darklight,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.remove,
                      size: height * 0.025, // ≈ 20
                    ),
                    onPressed: () {
                      controller.decrement();
                    },
                  ),
                ),
                SizedBox(
                  width: width * 0.075, // ≈ 30
                  height: height * 0.06, // ≈ 48
                  child: Center(
                    child: Obx(() {
                      return Text(
                        controller.count.toString(),
                        style: txtTheme().displayMedium!.copyWith(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: height * 0.02, // ≈ 16
                              height: 1.75,
                            ),
                      );
                    }),
                  ),
                ),
                Container(
                  width: height * 0.05, // ≈ 40
                  height: height * 0.05, // ≈ 40
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DefaultThemeColors.darklight,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.increment();
                    },
                    icon: Icon(
                      Icons.add,
                      size: height * 0.025, // ≈ 20
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: height * 0.06, // ≈ 48
            width: width * 0.45,
            child: PrimaryActionButton(
              text: "Add Cart",
              onPressed: () {
                // add to cart logic later
                print("Clicked on Add to Cart Functionality");
                Get.toNamed(Routes.ADDTOCART);
              },
            ),
          ),
        ],
      ),
    );
  }
}

reviewModal(ProductController controller) {
  TextEditingController reviewController = TextEditingController();
  int rating = 3;
  return Get.dialog(AlertDialog(
      content: SizedBox(
        // width: MediaQuery.of(context).size.width * 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Write Review',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.zero,
                  itemBuilder: (context, _) => Transform.scale(
                    scale: 0.6,
                    child: const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  onRatingUpdate: (value) {
                    rating = value.toInt();
                  },
                ),
                const SizedBox(height: 10),
                const Text("Review:",
                    style: TextStyle(
                        // fontFamily: 'Lato',
                        fontSize: 14)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: reviewController,
                  maxLength: 300,
                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  onChanged: (value) {
                    // .text = value;
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFDDDDDD), width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFDDDDDD), width: 1)),
                  ),
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: SizedBox(
                    height: 45,
                    child: Center(
                      child: Text('Back'.toUpperCase(),
                          style: txtTheme().titleLarge),
                    )),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    if (reviewController.text.isNotEmpty) {
                      // print('23234554');
                      controller.postReview(
                          summary: reviewController.text, rating: rating);
                      Get.back();
                    } else {
                      // Get.showSnackbar(const GetSnackBar(
                      //   message: 'Enter review',
                      // ));
                      HelperFunctions().showSnackBarError('Enter review');
                    }
                  },
                  style: themeButton,
                  child: Text('Submit'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        // fontFamily: 'Lato'
                      )),
                ),
              ),
            ),
          ],
        ),
      ]));
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.wishListTap,
    required this.addToCartTap,
    required this.controller,
    required this.btntext,
  }) : super(key: key);

  final VoidCallback wishListTap;
  final String btntext;
  final Function() addToCartTap;
  final ProductController controller;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(96, 168, 164, 164),
                spreadRadius: 0,
                blurRadius: 02),
          ],
        ),
        width: Get.width,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  widget.wishListTap();
                  _controller
                      .forward(
                        from: 0.0,
                      )
                      .then((value) => _controller.reverse());
                },
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: GetBuilder<WishlistController>(
                            builder: (wishListController) {
                              return wishListController.wishlistProductIds
                                      .contains(widget.controller.productId)
                                  ? SvgPicture.asset('assets/icon/like.svg')
                                  : SvgPicture.asset('assets/icon/unlike.svg');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text("WISHLIST",
                            style: txtTheme()
                                .headlineSmall!
                                .copyWith(fontSize: 16))
                      ],
                    );
                  },
                ),
              ),
            ),
            const VerticalDivider(
              width: 20,
              thickness: 1.5,
              indent: 10,
              endIndent: 10,
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.addToCartTap,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icon/addtobag.svg',
                      width: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(widget.btntext,
                        style:
                            txtTheme().headlineSmall!.copyWith(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class ProductGallery extends StatelessWidget {
  final ProductController controller;
  final List productGallery;

  ProductGallery(
      {super.key, required this.controller, required this.productGallery});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      if (productGallery.isEmpty) {
        return _buildShimmerLoading(height, width);
      } else {
        return _buildGalleryWithThumbnails(context, height, width);
      }
    });
  }

  Widget _buildShimmerLoading(double height, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Shimmer.fromColors(
        enabled: true,
        direction: ShimmerDirection.ltr,
        loop: 0,
        period: const Duration(seconds: 1),
        baseColor: Colors.grey.shade300,
        highlightColor: const Color.fromARGB(255, 197, 197, 197),
        child: SizedBox(
          height: height * 0.47,
          width: width * 0.92,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.028),
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryWithThumbnails(
      BuildContext context, double height, double width) {
    // Extract image paths safely
    List<String> imagePaths = productGallery.map<String>((item) {
      return url + "images/" + (item['filepath'] ?? '');
    }).toList();

    return Container(
      width: width * 0.92,
      height: height * 0.47,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.028),
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            imagePaths[controller.selectedImageIndex.value],
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: width * 0.037,
            bottom: height * 0.02,
            child: Container(
              width: width * 0.845,
              height: height * 0.085,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.02,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.02),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: imagePaths.length,
                separatorBuilder: (_, __) => SizedBox(width: width * 0.02),
                itemBuilder: (context, index) {
                  final isActive = controller.selectedImageIndex.value == index;

                  return GestureDetector(
                    onTap: () {
                      controller.selectedImageIndex.value = index;
                    },
                    child: Container(
                      width: height * 0.085,
                      height: height * 0.085,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height * 0.02),
                        border: isActive
                            ? Border.all(
                                color: DefaultThemeColors.mainprimary,
                                width: 2,
                              )
                            : null,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            imagePaths[index],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Optional: Add tap to view full screen
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.to(
                    () => ImageSlider(),
                    arguments: {"images": productGallery},
                  );
                },
                borderRadius: BorderRadius.circular(height * 0.028),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class dileveryOption extends StatelessWidget {
  dileveryOption({Key? key, required this.icon, required this.services})
      : super(key: key);
  String icon;
  String services;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon),
        const SizedBox(width: 10),
        Text(services,
            style: const TextStyle(
              fontSize: 14,
            ))
      ],
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/productdetial_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/ImagePreviewMultipleView.dart';
import 'package:foduu_ecommerce/components/commonWidgets/appbarIcons.dart';
import 'package:foduu_ecommerce/components/gridviewproductcard.dart';
import 'package:foduu_ecommerce/components/review.dart';
import 'package:foduu_ecommerce/components/shimmer_effects.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProductdetailView extends GetView<ProductdetialController> {
  ProductdetailView({Key? key}) : super(key: key);

  // ProductdetialController controller =
  //     Get.put(ProductdetialController(), permanent: false);
  // ShopController shopController = Get.find<ShopController>();

  WishlistController wishListController = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    Get.create(() => ProductdetialController(), permanent: false);
    final controller = Get.find<ProductdetialController>();

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (controller.productDetials['name'] == null) {
            return const ShimmerEffect(height: 10, width: 100);
          } else {
            return Text(
              controller.productDetials['name'].toString(),
              style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            );
          }
        }),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset('assets/icon/appbarshare.svg')),
              // IconButton(
              //     onPressed: () {},
              //     icon: SvgPicture.asset('assets/icon/appbarlike.svg')),
              Obx(
                () => Get.find<BottombarController>().cartbadge(
                    child: CartIcon(() {
                      Get.toNamed(Routes.CART);
                    }),
                    badgeNumber:
                        Get.find<CartController>().productDetails.length),
              ),
              const SizedBox(
                width: 14,
              )
            ],
          )
          // InkWell(
          //   onTap: () {},
          //   child: SvgPicture.asset('assets/icon/appbarshare.svg'),
          // ),
          // const SizedBox(width: 10),
          // InkWell(
          //   onTap: () {},
          //   child: SvgPicture.asset('assets/icon/appbarlike.svg'),
          // ),
          // const SizedBox(width: 10),
          // InkWell(
          //   onTap: () {
          //     Get.find<BottombarController>().goToCart();
          //   },
          //   child: Obx(() {
          //     return Badge(
          //       showBadge: Get.find<BottombarController>().cart.isNotEmpty
          //           ? true
          //           : false,
          //       position: const BadgePosition(top: 0, start: 15),
          //       badgeContent: Text(
          //         Get.find<BottombarController>().cart.length.toString(),
          //         style: txtTheme()
          //             .titleLarge!
          //             .copyWith(color: themeWhiteColor),
          //       ),
          //       child: SvgPicture.asset('assets/icon/appbarshop.svg'),
          //     );
          //   }),
          // ),
        ],
        titleSpacing: 0.0,
        // backgroundColor: Colors.transparent,
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
                children: [
                  Obx(
                    () {
                      return ProductGallery(
                          controller: controller,
                          productGallery: controller.productDetials['type'] ==
                                  'variant'
                              ? controller.productDetials['variant_ids']
                                      [controller.selectedVariantIndex.value]
                                  ['gallery']
                              : controller.productGallery);
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
                                      .productDetials['variant_ids'][controller
                                          .selectedVariantIndex
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
                            Obx(() => controller.productDetials['name'] == null
                                ? const ShimmerEffect(height: 10, width: 100)
                                : Text(
                                    controller.productDetials['name']
                                        .toString(),
                                    style: txtTheme()
                                        .displayMedium!
                                        .copyWith(fontSize: 16),
                                  )),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Obx(() {
                                return controller.productDetials['content'] !=
                                        null
                                    ? HtmlWidget(controller
                                        .productDetials['content']
                                        .toString())
                                    : Container();
                              }),
                            ),
                            Obx(
                              () => Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: controller.productDetials[
                                                'average_rating'] ==
                                            null
                                        ? 0.0
                                        : double.parse(controller
                                            .productDetials['average_rating']
                                            .toString()),
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 18.0,
                                    direction: Axis.horizontal,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    controller.productDetials['rating_count'] ==
                                            null
                                        ? '0'
                                        : controller
                                            .productDetials['rating_count']
                                            .toString(),
                                    style: txtTheme().titleLarge!.copyWith(),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Obx(() {
                              if (controller.productDetials['variant_ids'] ==
                                  null) {
                                return const ShimmerEffect(
                                    height: 10, width: 50);
                              } else {
                                var productPrice = controller
                                                .productDetials['variant_ids'][
                                            controller.selectedVariantIndex
                                                .value]['sale_price'] ==
                                        null
                                    ? controller.productDetials['variant_ids']
                                            [controller.selectedVariantIndex.value]
                                            ['price']
                                        .toString()
                                    : controller.productDetials['variant_ids']
                                            [controller.selectedVariantIndex.value]
                                            ['sale_price']
                                        .toString();
                                var sale_price = controller
                                                .productDetials['variant_ids'][
                                            controller.selectedVariantIndex
                                                .value]['sale_price'] ==
                                        null
                                    ? null
                                    : controller.productDetials['variant_ids'][
                                            controller.selectedVariantIndex
                                                .value]['price']
                                        .toString();
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₹${productPrice}",
                                      style: txtTheme().titleLarge,
                                    ),
                                    const SizedBox(width: 04),
                                    sale_price == null
                                        ? Container()
                                        : Text(
                                            "₹${sale_price}",
                                            style: txtTheme()
                                                .titleLarge!
                                                .copyWith(
                                                    decoration: TextDecoration
                                                        .lineThrough),
                                          ),
                                    Text(
                                      controller.productDetials['variant_ids'][
                                                  controller
                                                      .selectedVariantIndex
                                                      .value]['sale_price'] ==
                                              null
                                          ? ''
                                          // : " ${(100 - controller.productDetials['variant_ids'][controller.selectedVariantIndex.value]['sale_price'] * 100 / controller.productDetials['variant_ids'][controller.selectedVariantIndex.value]['price']).round()}" +
                                          //     "%off",
                                          : ' (${(((controller.productDetials['variant_ids'][controller.selectedVariantIndex.value]['price'] - controller.productDetials['variant_ids'][controller.selectedVariantIndex.value]['sale_price']) / controller.productDetials['variant_ids'][controller.selectedVariantIndex.value]['price']) * 100).toStringAsFixed(2)}% off)',
                                      style: txtTheme().titleLarge!.copyWith(),
                                    )
                                  ],
                                );
                              }
                            }),
                            Text("Inclusive of all taxes",
                                style: txtTheme().titleLarge!.copyWith()),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 10,
                      ),
                      Padding(
                        padding: pageSurroundingPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () {
                                return Column(
                                  children: [
                                    ListView.separated(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, parentIndex) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Select ${controller.labels[parentIndex]}',
                                                  style: txtTheme()
                                                      .titleLarge!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: SizedBox(
                                                  height: 40,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: controller
                                                        .labelVariant[
                                                            parentIndex]
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          controller.onSelectVariant(
                                                              controller.labels[
                                                                  parentIndex],
                                                              controller.labelVariant[
                                                                      parentIndex]
                                                                  [index]);
                                                          print(
                                                              controller.labels[
                                                                  parentIndex]);
                                                          print(
                                                              'label variant ${controller.labelVariant}');
                                                          print(
                                                              'parent index index  ${controller.labelVariant[parentIndex][index]}');
                                                        },
                                                        child: Obx(
                                                          () {
                                                            print(
                                                                '${controller.labelVariant[parentIndex][index]} = ${controller.joinedVariants.contains(controller.labelVariant[parentIndex][index])}');
                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          10),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          2),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    width: 1.5,
                                                                    // color: controller
                                                                    //         .joinedVariants
                                                                    //         .contains(controller.labelVariant[parentIndex][
                                                                    //             index])
                                                                    //     ? Colors
                                                                    //         .red
                                                                    //         .shade300
                                                                    //     : themegreyColor),
                                                                    color: controller.containsExactSize(controller.joinedVariants.value, controller.labelVariant[parentIndex][index]) ? Colors.red.shade300 : Colors.red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            08),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  controller.labelVariant[
                                                                          parentIndex]
                                                                      [index],
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(
                                            height: 10,
                                          );
                                        },
                                        itemCount: controller.labels.length)
                                  ],
                                );
                              },
                            ),

                            // controller.productDetials['type'] == 'variant'
                            //     ? VariantSize(controller: controller)
                            //     : Container(),
                            const SizedBox(height: 10),
                            Text("Quantity:",
                                style: txtTheme()
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Container(
                              width: Get.width * 0.32,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        controller.decrement();
                                      },
                                      icon: Container(
                                        padding: const EdgeInsets.all(0.01),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(02),
                                            border: Border.all(width: 1.2)),
                                        child:
                                            const Icon(Icons.remove, size: 14),
                                      )),
                                  Obx(() {
                                    return Text(controller.count.toString());
                                  }),
                                  IconButton(
                                      onPressed: () {
                                        controller.increment();
                                      },
                                      icon: Container(
                                          padding: const EdgeInsets.all(0.01),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(02),
                                              border: Border.all(width: 1.2)),
                                          child:
                                              const Icon(Icons.add, size: 14))),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets
                                  .zero, // Add your desired padding here
                              child: Obx(() {
                                return Html(
                                  data: controller
                                          .productDetials['long_content'] ??
                                      "",
                                  style: {
                                    "body": Style(
                                      fontFamily: "Lato",
                                    ),
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 10,
                      ),
                      // Padding(
                      //   padding: pageSurroundingPadding,
                      //   child: Column(
                      //       crossAxisAlignment:
                      //           CrossAxisAlignment.start,
                      //       children: [
                      //         Text("Offers for You",
                      //             style: txtTheme()
                      //                 .titleLarge!
                      //                 .copyWith(
                      //                     fontWeight:
                      //                         FontWeight.bold)),
                      //         const SizedBox(height: 10),
                      //         Text(
                      //             "Use code FODUUKART10 to get flat 10%",
                      //             style: txtTheme()
                      //                 .titleLarge!
                      //                 .copyWith(fontSize: 13)),
                      //         const SizedBox(height: 10),
                      //         Text(
                      //             "Use code FODUUKART10 to get flat 10% off on minimum order of 200.00. Offer valid for first time users only",
                      //             style: txtTheme()
                      //                 .titleLarge!
                      //                 .copyWith(
                      //                     color: themeSecondrytext,
                      //                     fontSize: 12)),
                      //         const SizedBox(height: 10),
                      //         Row(
                      //           children: [
                      //             GestureDetector(
                      //               onTap: () {
                      //                 FlutterClipboard.copy(controller
                      //                     .offerCode
                      //                     .toUpperCase());
                      //                 controller.isCopied.toggle();
                      //               },
                      //               child: DottedBorder(
                      //                 dashPattern: [5, 5],
                      //                 borderType: BorderType.RRect,
                      //                 color: themeRedColor,
                      //                 radius:
                      //                     const Radius.circular(03),
                      //                 child: Container(
                      //                   decoration: BoxDecoration(
                      //                       color: themeRedColor
                      //                           .withOpacity(0.05),
                      //                       borderRadius:
                      //                           BorderRadius.circular(
                      //                               3)),
                      //                   padding:
                      //                       const EdgeInsets.all(08),
                      //                   child: Center(
                      //                     child: Row(
                      //                       children: [
                      //                         Text(
                      //                           controller.offerCode
                      //                               .toUpperCase(),
                      //                           style: txtTheme()
                      //                               .titleLarge!
                      //                               .copyWith(
                      //                                   fontSize: 12),
                      //                         ),
                      //                         const SizedBox(
                      //                           width: 5,
                      //                         ),
                      //                         const Icon(
                      //                           Icons.copy_outlined,
                      //                           size: 18,
                      //                         )
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             const SizedBox(width: 10),
                      //             Obx(
                      //               () => controller.isCopied == true
                      //                   ? Icon(Icons.check)
                      //                   : Text(
                      //                       'Tap to copy',
                      //                       style: txtTheme()
                      //                           .titleLarge!
                      //                           .copyWith(
                      //                               color:
                      //                                   themeSecondrytext,
                      //                                 fontSize: 12),
                      //                     ),
                      //             )
                      //           ],
                      //         )
                      //       ]),
                      // ),
                      // const Divider(
                      //   thickness: 10,
                      //   color: themegreyColor,
                      // ),
                      // Padding(
                      //   padding: pageSurroundingPadding,
                      //   child: Column(
                      //       crossAxisAlignment:
                      //           CrossAxisAlignment.start,
                      //       children: [
                      //         Text("Return & Exchange Policy",
                      //             style: txtTheme()
                      //                 .titleLarge!
                      //                 .copyWith(
                      //                     fontWeight:
                      //                         FontWeight.bold)),
                      //         const SizedBox(height: 10),
                      //         Text(
                      //             "This product is eligible for returns and size replacements. Please initiate returns/replacements from the 'My Orders' section in the App within 7 days of delivery. Please ensure the product is in its original condition with all tags attached.",
                      //             style: txtTheme()
                      //                 .titleLarge!
                      //                 .copyWith(
                      //                     color: themeSecondrytext)),
                      //       ]),
                      // ),
                      // const Divider(
                      //   thickness: 10,
                      //   color: themegreyColor,
                      // ),
                      // Padding(
                      //   padding: pageSurroundingPadding,
                      //   child: Column(
                      //     crossAxisAlignment:
                      //         CrossAxisAlignment.start,
                      //     children: [
                      //       Text("Product Details",
                      //           style: txtTheme().titleLarge!.copyWith(
                      //               fontWeight: FontWeight.bold)),
                      //       const SizedBox(height: 10),
                      //       Text(
                      //           "Blue solid denim jacket, has a spread collar, 2 pockets ,has a button closure, long sleeves, straight hemline, cotton lining.",
                      //           style: txtTheme().titleLarge!.copyWith(
                      //               color: themeSecondrytext)),
                      //       const SizedBox(height: 25),
                      //       Text("Model Size & Fit",
                      //           style: txtTheme().titleLarge!.copyWith(
                      //               fontWeight: FontWeight.bold)),
                      //       const SizedBox(height: 10),
                      //       Text(
                      //           "The model (height 5'8) is wearing a size S",
                      //           style: txtTheme().titleLarge!.copyWith(
                      //               color: themeSecondrytext)),
                      //       const SizedBox(height: 25),
                      //       Text("Material & Care",
                      //           style: txtTheme().titleLarge!.copyWith(
                      //               fontWeight: FontWeight.bold)),
                      //       const SizedBox(height: 10),
                      //       Text("100% polyester, Machine-wash",
                      //           style: txtTheme().titleLarge!.copyWith(
                      //               color: themeSecondrytext)),
                      //       const SizedBox(height: 25),
                      //       Text("Product Code",
                      //           style: txtTheme().titleLarge!.copyWith(
                      //               fontWeight: FontWeight.bold)),
                      //       const SizedBox(height: 10),
                      //       Text("460356366",
                      //           style: txtTheme().titleLarge!.copyWith(
                      //               color: themeSecondrytext)),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(
                      //   thickness: 10,
                      //   color: themegreyColor,
                      // ),
                      Padding(
                        padding: pageSurroundingPadding,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(
                                  () => Text(
                                      "Customer Reviews  ${controller.productReview.length}",
                                      style: txtTheme().titleLarge!.copyWith(
                                          fontWeight: FontWeight.bold)),
                                ),
                                InkWell(
                                  onTap: () {
                                    // Get.to(AllReview(
                                    //   reviewData: controller.productReview,
                                    //   controller: controller,
                                    //   name: controller.productDetials['name'],
                                    //   rating:
                                    //       // controller.productDetials[
                                    //       //         'average_rating'] ??
                                    //       0,
                                    // ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("All Reviews",
                                        style: txtTheme().titleLarge!.copyWith(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Obx(
                              () => ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        thickness: 0.9,
                                      ),
                                  itemCount:
                                      controller.productReview.value.length > 2
                                          ? 2
                                          : controller
                                              .productReview.value.length,
                                  itemBuilder: (context, index) {
                                    return customerReview(
                                      profileimage: controller
                                                          .productReview[index]
                                                      ['customer']
                                                  ['featured_image'] ==
                                              null
                                          ? HelperFunctions.getNoImage()
                                          : url +
                                              controller.productReview[index]
                                                          ['customer']
                                                      ['featured_image']
                                                  ['filepath'],
                                      name:
                                          "${controller.productReview[index]['customer']['name'].toString()} | ${controller.getDate(controller.productReview[index]['updated_at'])}",
                                      review: controller.productReview[index]
                                          ['summary'],
                                      rating: controller.productReview[index]
                                          ['rating'],
                                    );
                                  }),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    side: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 216, 216, 216)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    minimumSize:
                                        const Size(double.infinity, 40)),
                                onPressed: () {
                                  reviewModal(controller);

                                  // commentReviewButton(
                                  //     context: context,
                                  //     messageController:
                                  //         TextEditingController(),
                                  //     onPressed: () {},
                                  //     ratingController:
                                  //         TextEditingController());
                                },
                                child: Text('Add Review',
                                    style: txtTheme().titleLarge!.copyWith(
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 10,
                      ),
                      // controller.similarProduct.isEmpty
                      //     ? const SizedBox(height: 50)
                      //     : Container(),
                      // Padding(
                      //   padding: pageSurroundingPadding,
                      //   child: Column(
                      //     crossAxisAlignment:
                      //         CrossAxisAlignment.start,
                      //     children: [
                      //       SizedBox(height: 10),
                      //       Text("Check Delivery",
                      //           style: txtTheme().titleLarge!.copyWith(
                      //               fontWeight: FontWeight.bold)),
                      //       const SizedBox(height: 10),
                      //       Text(
                      //           "Enter Pincode to check delivery date / pickup option",
                      //           style: txtTheme().titleLarge!.copyWith(
                      //               color: themeSecondrytext)),
                      //       const SizedBox(height: 18),
                      //       CartTextField(
                      //           fieldHintText: '',
                      //           title: 'Enter PinCode',
                      //           validationmsg: '',
                      //           maxLength: 6,
                      //           suffixIcon: TextButton(
                      //             onPressed: () {},
                      //             child: const Text(
                      //               'Check',
                      //               style: TextStyle(
                      //                   color: themeRedColor),
                      //             ),
                      //           ),
                      //           keyType: TextInputType.number,
                      //           controller:
                      //               controller.pinCodeController),
                      //       const SizedBox(height: 10),
                      //       const SizedBox(
                      //         height: 40,
                      //         child: TextField(
                      //           cursorColor: themeSecondrytext,
                      //           decoration: InputDecoration(
                      //               filled: true,
                      //               fillColor: themegreyColor,
                      //               suffixIcon: Padding(
                      //                 padding: EdgeInsets.all(8.0),
                      //                 child: Text("Check",
                      //                     style: TextStyle(
                      //                         // fontFamily: 'lato',
                      //                         color: themeRedColor)),
                      //               ),
                      //               contentPadding:
                      //                   EdgeInsets.fromLTRB(
                      //                       15.0, 15.0, 15.0, 15.0),
                      //               focusedBorder: OutlineInputBorder(
                      //                   borderSide: BorderSide(
                      //                       color: themegreyColor,
                      //                       width: 1)),
                      //               enabledBorder: OutlineInputBorder(
                      //                   borderSide: BorderSide(
                      //                       color: themegreyColor,
                      //                       width: 1)),
                      //               hintText: "Pin code",
                      //               hintStyle: TextStyle(
                      //                   color: themeTextColor,
                      //                   // fontFamily: 'Lato',
                      //                   fontSize: 14,
                      //                   fontWeight: FontWeight.w400)),
                      //         ),
                      //       ),
                      //       const SizedBox(height: 20),
                      //       dileveryOption(
                      //         icon: "assets/icon/dilevery.svg",
                      //         services:
                      //             "Free Delivery on order above \$ 200.00",
                      //       ),
                      //       const SizedBox(height: 10),
                      //       dileveryOption(
                      //         icon:
                      //             "assets/icon/payment-method 1.svg",
                      //         services: "Cash On delivery Available",
                      //       ),
                      //       const SizedBox(height: 10),
                      //       dileveryOption(
                      //         icon: "assets/icon/refund 1.svg",
                      //         services:
                      //             "Easy 21 days returns and exchanges",
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(
                      //   thickness: 10,
                      //   color: themegreyColor,
                      // ),
                      Obx(() => controller.similarProduct.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: pageSurroundingPadding,
                                  child: Text("Similar Products",
                                      style: txtTheme().titleLarge!.copyWith(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Obx(
                                  () {
                                    // print(
                                    // 'djdjdj ${shopController.allProductList.length}');
                                    return SizedBox(
                                      height: 240,
                                      child: ListView.separated(
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(width: 10),
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              controller.similarProduct.length,
                                          itemBuilder: (context, index) {
                                            var lowest;
                                            var highest;
                                            if (controller.similarProduct[index]
                                                    ['type'] ==
                                                'variant') {
                                              // for (var item in trendingList) {
                                              lowest = HelperFunctions
                                                  .lowestPrice(controller
                                                          .similarProduct[index]
                                                      ['variant_ids']);
                                              highest = HelperFunctions
                                                  .highestPrice(controller
                                                          .similarProduct[index]
                                                      ['variant_ids']);

                                              // }
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 05),
                                              child: gridProductCart(
                                                animationController:
                                                    controller.controller,
                                                scaoleAnimation:
                                                    controller.scaleAnimation,
                                                highestPrice:
                                                    highest.toString(),
                                                lowestPrice: lowest.toString(),
                                                productType: controller
                                                        .similarProduct[index]
                                                    ['type'],
                                                liked: Obx(
                                                  () {
                                                    final wishlistService =
                                                        Get.find<
                                                            WishListService>();
                                                    return wishlistService
                                                            .isInWishlist(controller
                                                                    .similarProduct[
                                                                index]['_id'])
                                                        ? SvgPicture.asset(
                                                            'assets/icon/like.svg')
                                                        : SvgPicture.asset(
                                                            'assets/icon/unlike.svg');
                                                  },
                                                ),
                                                onLiked: () async {
                                                  print('object');
                                                  await WishListService()
                                                      .toggleWishlist(
                                                    productId: controller
                                                            .similarProduct[
                                                        index]['_id'],
                                                    variantSlug: controller
                                                                    .similarProduct[
                                                                index]
                                                            ['variant_slug'] ??
                                                        '', // Make sure to provide the variant slug
                                                  );
                                                  await WishListService()
                                                      .fetchWishList(); // This refreshes the wishlist
                                                },
                                                rating: double.parse(
                                                  controller.similarProduct[
                                                                  index][
                                                              'average_rating'] ==
                                                          null
                                                      ? '0'
                                                      : controller
                                                          .similarProduct[index]
                                                              ['average_rating']
                                                          .toString(),
                                                ),
                                                // rating: 3.3,
                                                quantity: controller.similarProduct[
                                                                    index]
                                                                ['variant_ids']
                                                            [0]['quantity'] ==
                                                        null
                                                    ? "Out of stock"
                                                    : controller
                                                        .similarProduct[index]
                                                            ['variant_ids'][0]
                                                            ['quantity']
                                                        .toString(),
                                                keypressEvent: () {
                                                  Get.toNamed(
                                                      Routes.PRODUCTDETAILS,
                                                      preventDuplicates: false,
                                                      arguments: {
                                                        'productId': controller
                                                                .similarProduct[
                                                            index]['_id']
                                                      });
                                                },
                                                assetimage: controller
                                                                .similarProduct[index]
                                                            [
                                                            'featured_image'] ==
                                                        null
                                                    ? ''
                                                    : url +
                                                        controller.similarProduct[
                                                                    index][
                                                                'featured_image']
                                                            ['filepath'],
                                                // 'https://www.babycouture.in/blog/wp-content/uploads/2016/04/elegant-summers-yellow-blue-kids-dress.jpg',
                                                productname: controller
                                                    .similarProduct[index]
                                                        ['name']
                                                    .toString(),
                                                productprice: controller.similarProduct[
                                                                    index]
                                                                ['variant_ids']
                                                            [0]['sale_price'] ==
                                                        null
                                                    ? controller
                                                        .similarProduct[index]
                                                            ['variant_ids'][0]
                                                            ['price']
                                                        .toString()
                                                    : controller
                                                        .similarProduct[index]
                                                            ['variant_ids'][0]
                                                            ['sale_price']
                                                        .toString(),
                                                discountprice:
                                                    controller.similarProduct[
                                                                        index]
                                                                    [
                                                                    'variant_ids'][0]
                                                                [
                                                                'sale_price'] ==
                                                            null
                                                        ? ''
                                                        : controller
                                                            .similarProduct[
                                                                index]
                                                                ['variant_ids']
                                                                [0]['price']
                                                            .toString(),
                                                discountrate: controller.similarProduct[
                                                                    index]
                                                                ['variant_ids']
                                                            [0]['sale_price'] ==
                                                        null
                                                    ? ''
                                                    : " ${(100 - controller.similarProduct[index]['variant_ids'][0]['sale_price'] * 100 / controller.similarProduct[index]['variant_ids'][0]['price']).round()}" +
                                                        "%off",
                                                height: Get.width * 0.41,
                                                width: Get.width * 0.40,
                                              ),
                                            );
                                          }),
                                    );
                                  },
                                ),
                              ],
                            )
                          : Container()),
                      const SizedBox(height: 50)
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Obx(
              () => OrderButton(
                btntext: controller.isAlreadyInCart.value
                    ? 'Already in cart'
                    : 'Add to Bag',
                controller: controller,
                wishListTap: () async {
                  final wishListService = Get.find<WishListService>();
                  // Get variant slug from your product data
                  String variantSlug =
                      controller.productDetials['variant_slug'] ??
                          ''; // Adjust based on your data structure

                  await wishListService.toggleWishlist(
                    productId: controller.productId,
                    variantSlug: variantSlug,
                  );
                  await wishListService.fetchWishList();
                },
                addToCartTap: () async {
                  if (controller.isAlreadyInCart.value) {
                    HelperFunctions.defaultdialogbox(
                        'Product Already Added In Cart');
                    Future.delayed(const Duration(seconds: 2))
                        .then((value) => Get.back());
                  } else {
                    HelperFunctions().showOverlayLoader();

                    final wishListService = Get.find<WishListService>();
                    // Get variant slug here too
                    String variantSlug =
                        controller.productDetials['variant_slug'] ?? '';

                    if (wishListService.isInWishlist(controller.productId)) {
                      await wishListService.toggleWishlist(
                        productId: controller.productId,
                        variantSlug: variantSlug,
                      );
                    }

                    await controller.addToCart().then((value) {
                      Get.until((route) => !Get.isDialogOpen!);
                      return Get.toNamed(Routes.CART);
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

reviewModal(ProductdetialController controller) {
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

// class VariantSize extends StatefulWidget {
//   ProductdetialController controller;
//   VariantSize({super.key, required this.controller});

//   @override
//   State<VariantSize> createState() => _VariantSizeState();
// }

// class _VariantSizeState extends State<VariantSize> {
//   @override
//   Widget build(BuildContext context) {
//     // widget.controller.getVariantDetails();
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         widget.controller.sizeList.isEmpty
//             ? Container()
//             : Text("Select Size:",
//                 style: txtTheme()
//                     .titleLarge!
//                     .copyWith(fontWeight: FontWeight.bold)),
//         widget.controller.sizeList.isEmpty
//             ? Container()
//             : const SizedBox(height: 10),
//         widget.controller.sizeList.isEmpty
//             ? Container()
//             : SizedBox(
//                 height: 35,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: widget.controller.sizeList.length,
//                   itemBuilder: (context, index) {
//                     return Obx(() {
//                       return GestureDetector(
//                         onTap: () {
//                           widget.controller.getSelectedSize.value = index;
//                           widget.controller.selectedSize.value =
//                               widget.controller.sizeList[index];
//                           // widget.controller.variantSelect();
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 15),
//                           child: Container(
//                             width: 35,
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                     width: 1.5,
//                                     color: widget.controller.getSelectedSize
//                                                 .value ==
//                                             index
//                                         ? themeRedColor
//                                         : themegreyColor),
//                                 color: themegreyColor,
//                                 borderRadius: BorderRadius.circular(08)),
//                             child: Center(
//                               child: Text(
//                                 widget.controller.sizeList[index],
//                                 style: txtTheme().bodyText1,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     });
//                   },
//                 ),
//               ),
//         const SizedBox(height: 15),
//         widget.controller.colorList.isEmpty
//             ? Container()
//             : Text("Select Color:",
//                 style: txtTheme()
//                     .titleLarge!
//                     .copyWith(fontWeight: FontWeight.bold)),
//         widget.controller.colorList.isEmpty
//             ? Container()
//             : const SizedBox(height: 10),
//         widget.controller.colorList.isEmpty
//             ? Container()
//             : SizedBox(
//                 height: 35,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: widget.controller.colorList.length,
//                   itemBuilder: (context, index) {
//                     return Obx(() {
//                       return GestureDetector(
//                         onTap: () {
//                           widget.controller.getSelectedColor.value = index;
//                           widget.controller.selectedColor.value =
//                               widget.controller.colorList[index];
//                           // widget.controller.variantSelect();
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 15),
//                           child: Container(
//                             width: 50,
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                     width: 1.5,
//                                     color: widget.controller.getSelectedColor
//                                                 .value ==
//                                             index
//                                         ? themeRedColor
//                                         : themegreyColor),
//                                 color: themegreyColor,
//                                 borderRadius: BorderRadius.circular(08)),
//                             child: Center(
//                               child: Text(
//                                 widget.controller.colorList[index],
//                                 style: txtTheme().bodyText1,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     });
//                   },
//                 ),
//               ),

//         // SizedBox(
//         //   height: 40,
//         //   child: GridView.builder(
//         //     physics: NeverScrollableScrollPhysics(),
//         //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         //       childAspectRatio: 1,
//         //       crossAxisCount: 7,
//         //       crossAxisSpacing: 20,
//         //     ),
//         //     itemCount: widget.controller.colorList.length,
//         //     itemBuilder: (context, index) {
//         //       return Obx(() {
//         //         print(widget.controller.colorList);
//         //         return GestureDetector(
//         //           onTap: () {
//         //             widget.controller.getSelectedColor.value = index;
//         //             widget.controller.selectedColor.value =
//         //                 widget.controller.colorList[index];
//         //             widget.controller.variantSelect();
//         //           },
//         //           child: Padding(
//         //             padding: const EdgeInsets.only(right: 0),
//         //             child: LayoutBuilder(
//         //               builder: (context, constraints) {
//         //                 return Container(
//         //                   decoration: BoxDecoration(
//         //                     border: Border.all(
//         //                       width: 1.5,
//         //                       color: widget.controller.getSelectedColor.value ==
//         //                               index
//         //                           ? themeRedColor
//         //                           : themegreyColor,
//         //                     ),
//         //                     color: themegreyColor,
//         //                     borderRadius: BorderRadius.circular(8),
//         //                   ),
//         //                   child: Center(
//         //                     child: FittedBox(
//         //                       fit: BoxFit.scaleDown,
//         //                       child: Text(
//         //                         widget.controller.colorList[index],
//         //                         style: txtTheme().bodyText1,
//         //                       ),
//         //                     ),
//         //                   ),
//         //                 );
//         //               },
//         //             ),
//         //           ),
//         //         );
//         //       });
//         //     },
//         //   ),
//         // ),
//         const SizedBox(
//           height: 10,
//         )
//       ],
//     );
//   }
// }

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
  final ProductdetialController controller;

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
                          child: Obx(
                            () {
                              final wishlistService =
                                  Get.find<WishListService>();
                              return wishlistService
                                      .isInWishlist(widget.controller.productId)
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
  final ProductdetialController controller;
  final List productGallery;
  ProductGallery(
      {super.key, required this.controller, required this.productGallery});

  Widget build(BuildContext context) {
    // var newlist = [];

    // for (int i = 0; i < productGallery.length; i++) {
    //   newlist.add(url + productGallery[i]['filepath']);
    // }

    // var ul = 'https://imgs.search.brave.com/';
    // var imagelist = [
    //   'Xw3NFxb1mDLhRHiFwZ6y4pqYJMU3dRW84i1nhdwXG8Q/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMuY3RmYXNzZXRz/Lm5ldC9ocmx0eDEy/cGw4aHEvNTU5Nnoy/QkNSOUttVDFLZVJC/ck9RYS80MDcwZmQ0/ZTJmMWExM2Y3MWMy/YzQ2YWZlYjE4ZTQx/Yy9zaHV0dGVyc3Rv/Y2tfNDUxMDc3MDQz/LWhlcm8xLmpwZz9m/aXQ9ZmlsbCZ3PTYw/MCZoPTEyMDA',
    //   'BMuYABP7oP4l8HymmSOQIH30nF_YQMtJm-y7Bz-vc6Q/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9idXJz/dC5zaG9waWZ5Y2Ru/LmNvbS9waG90b3Mv/dHdvLXRvbmUtaW5r/LWNsb3VkLmpwZz93/aWR0aD0xMDAwJmZv/cm1hdD1wanBnJmV4/aWY9MCZpcHRjPTA',
    //   'tm3m5yt4lwYHtnAxa6p8dyQHx079t6p86eW0uiL70NQ/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMuZnJlZWltYWdl/cy5jb20vaW1hZ2Vz/L2hvbWUvYmx1cmJz/L3Zpc3VhbHMud2Vi/cA'
    // ];

    return Obx(() {
      if (productGallery.isEmpty) {
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
              height: Get.height * 0.6,
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    width: 10,
                  );
                },
                shrinkWrap: false,
                itemCount: 3,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: Get.height * 0.6,
                      width: 300,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        // borderRadius: BorderRadius.circular(8)
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: SizedBox(
            // width: 300,
            height: MediaQuery.of(context).size.height * 0.6,
            child: productGallery.length == 1
                ? InkWell(
                    onTap: () {
                      Get.to(() => ImageSlider(),
                          arguments: {"images": productGallery});
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(08),
                        child: CachedNetworkImage(
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.cover,
                          width: Get.width,
                          imageUrl: url + productGallery[0]['filepath'],
                          errorWidget: (context, url, error) => Container(
                            decoration:
                                BoxDecoration(color: Colors.grey.shade300),
                            child: const Center(
                              child: Icon(Icons.error),
                            ),
                          ),
                          progressIndicatorBuilder: (context, url, progress) =>
                              Container(
                            decoration:
                                BoxDecoration(color: Colors.grey.shade300),
                            height: 165,
                            child: Center(
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: HelperFunctions().loadingIndicator(),
                              ),
                            ),
                          ),
                        )),
                  )
                : PageView.builder(
                    controller: controller.pageController,
                    padEnds: false,
                    onPageChanged: controller.selectedPageIndex,
                    itemCount: productGallery.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 08),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => ImageSlider(),
                                arguments: {"images": productGallery});
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(08),
                            child: CachedNetworkImage(
                              filterQuality: FilterQuality.low,
                              fit: BoxFit.cover,
                              imageUrl: url + productGallery[index]['filepath'],
                              errorWidget: (context, url, error) => Container(
                                decoration:
                                    BoxDecoration(color: Colors.grey.shade300),
                                child: const Center(
                                  child: Icon(Icons.error),
                                ),
                              ),
                              progressIndicatorBuilder:
                                  (context, url, progress) => Container(
                                decoration:
                                    BoxDecoration(color: Colors.grey.shade300),
                                height: 165,
                                child: Center(
                                  child: SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: HelperFunctions().loadingIndicator(),
                                  ),
                                ),
                              ),
                            ),
                            // child: Container(color: Colors.red,),
                          ),
                          // // child: FoduuCachedNetworkImage(
                          // //     fit: BoxFit.contain,
                          // //     height: Get.height * 0.38,
                          // //     width: Get.width,
                          // //     image: ul + imagelist[index]),
                          // // child: FoduuCachedNetworkImage(image: newlist[index]),
                          // // child:
                          // //     FoduuCachedNetworkImage(image: ul + imagelist[index]),
                          // child: FoduuCachedNetworkImage(
                          //     image: url +
                          //         productGallery[index]['filepath'].toString()),
                        ),
                      );
                    }),
          ),
        );
      }
    });
  }
}
// class ProductGallery extends StatelessWidget {
//   ProductGallery({
//     Key? key,
//     required this.productGallery,
//     required this.controller,
//   }) : super(key: key);

//   final ProductdetialController controller;
//   final List productGallery;

//   // var controller = Get.find<ProductdetialController>();

// var imagelist = [
//   'https://imgs.search.brave.com/Xw3NFxb1mDLhRHiFwZ6y4pqYJMU3dRW84i1nhdwXG8Q/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMuY3RmYXNzZXRz/Lm5ldC9ocmx0eDEy/cGw4aHEvNTU5Nnoy/QkNSOUttVDFLZVJC/ck9RYS80MDcwZmQ0/ZTJmMWExM2Y3MWMy/YzQ2YWZlYjE4ZTQx/Yy9zaHV0dGVyc3Rv/Y2tfNDUxMDc3MDQz/LWhlcm8xLmpwZz9m/aXQ9ZmlsbCZ3PTYw/MCZoPTEyMDA',
//   'https://imgs.search.brave.com/BMuYABP7oP4l8HymmSOQIH30nF_YQMtJm-y7Bz-vc6Q/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9idXJz/dC5zaG9waWZ5Y2Ru/LmNvbS9waG90b3Mv/dHdvLXRvbmUtaW5r/LWNsb3VkLmpwZz93/aWR0aD0xMDAwJmZv/cm1hdD1wanBnJmV4/aWY9MCZpcHRjPTA',
//   'https://imgs.search.brave.com/tm3m5yt4lwYHtnAxa6p8dyQHx079t6p86eW0uiL70NQ/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMuZnJlZWltYWdl/cy5jb20vaW1hZ2Vz/L2hvbWUvYmx1cmJz/L3Zpc3VhbHMud2Vi/cA'
// ];

//   }
// }

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

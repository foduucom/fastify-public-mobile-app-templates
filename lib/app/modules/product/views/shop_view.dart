// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_if_null_operators, prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/filterbutton.dart';
import 'package:foduu_ecommerce/components/commonWidgets/appbarIcons.dart';
import 'package:foduu_ecommerce/components/gridviewproductcard.dart';
import 'package:foduu_ecommerce/components/shopShimmer.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';

class ShopView extends GetView<ShopController> {
  final shopController = Get.lazyPut<ShopController>(() => ShopController());
  final wishlistController = Get.find<WishlistController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.collectionName.toString() + ' Collection',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'lato',
                    fontSize: 15),
              ),
              Obx(
                () => Text(
                  controller.allProductList.length.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'lato',
                      fontSize: 12,
                      color: Color.fromRGBO(119, 119, 119, 1)),
                ),
              ),
            ],
          ),
          titleSpacing: 0,
          elevation: 0,
          actions: [
            // SizedBox(width: 14),
            // Obx(() => Get.find<BottombarController>().cartbadge(
            //     child: NotificationIcon(() {}),
            //     badgeNumber: Get.find<NotificationsController>()
            //         .allnotificationList
            //         .length)),
            // SizedBox(width: 14),
            Obx(() => Get.find<BottombarController>().cartbadge(
                child: HeartIcon(() {
                  Get.toNamed(Routes.WISHLIST);
                }),
                badgeNumber: Get.find<WishlistController>().wishList.length)),
            SizedBox(width: 14),
            Obx(
              () => Get.find<BottombarController>().cartbadge(
                  child: CartIcon(() {
                    Get.toNamed(Routes.CART);
                  }),
                  badgeNumber:
                      Get.find<CartController>().productDetails.length),
            ),
            SizedBox(width: 15)
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            controller.onPullTorefresh();
          },
          child: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 50,
                floating: true,
                title: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: Get.height * 0.05,
                        child: TextFormField(
                          onTap: () {
                            Get.toNamed(Routes.SEARCH);
                          },
                          readOnly: true,
                          // cursorColor: themeSecondrytext,
                          decoration: InputDecoration(
                              filled: true,
                              // fillColor: themegreyColor,
                              prefixIcon: Icon(
                                Icons.search,
                                size: 20,
                                // color: themeSecondrytext,
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(
                                  30.0, 15.0, 30.0, 10.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(width: 1)),
                              hintText: "Search",
                              hintStyle: txtTheme().titleLarge!.copyWith()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FilterPage())),
                      child: SvgPicture.asset('assets/icon/filter.svg'),
                    )
                  ],
                ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Obx(() {
                    // if (controller.allProductList.isEmpty) {
                    //   return AlignedGridView.count(
                    //     // cacheExtent: 9999,
                    //     physics: NeverScrollableScrollPhysics(),
                    //     itemCount: 6,
                    //     crossAxisCount: 2,
                    //     mainAxisSpacing: 20,
                    //     crossAxisSpacing: 14,
                    //     shrinkWrap: true,
                    //     itemBuilder: (context, index) {
                    //       return ShopShimmer();
                    //     },
                    //   );
                    // }
                    //  else {
                    return controller.isLoading.value &&
                            controller.allProductList.isEmpty
                        ? AlignedGridView.count(
                            // cacheExtent: 9999,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 6,
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 14,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ShopShimmer();
                            },
                          )
                        : AlignedGridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: controller.allProductList.length,
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            cacheExtent: 9999,
                            crossAxisSpacing: 14,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Obx(() {
                                if (controller.allProductList.isEmpty) {
                                  return HelperFunctions().loadingIndicator();
                                }
                                var lowest;
                                var highest;
                                if (controller.allProductList[index]['type'] ==
                                    'variant') {
                                  if (controller
                                      .allProductList[index]['variant_ids']
                                      .isNotEmpty) {
                                    lowest = HelperFunctions.lowestPrice(
                                        controller.allProductList[index]
                                            ['variant_ids']);
                                    highest = HelperFunctions.highestPrice(
                                        controller.allProductList[index]
                                            ['variant_ids']);
                                  } else {
                                    return Container(
                                      color: Colors.grey,
                                    );
                                  }
                                }
                                return gridProductCart(
                                  animationController: controller.controller,
                                  scaoleAnimation: controller.scaleAnimation,
                                  highestPrice: highest.toString(),
                                  lowestPrice: lowest.toString(),
                                  productType: controller.allProductList[index]
                                      ['type'],
                                  liked: GetBuilder<WishlistController>(
                                    builder: (wishlistcontroller) {
                                      return wishlistcontroller
                                              .wishlistProductIds
                                              .contains(controller
                                                  .allProductList[index]['_id'])
                                          ? SvgPicture.asset(
                                              'assets/icon/like.svg')
                                          : SvgPicture.asset(
                                              'assets/icon/unlike.svg');
                                    },
                                  ),
                                  onLiked: () async {
                                    await wishlistController
                                        .addProductToWishlist(
                                            productid: controller
                                                .allProductList[index]['_id']);
                                    await wishlistController.getwishlist();
                                  },
                                  rating: double.parse(
                                    controller.allProductList[index]
                                                ['average_rating'] ==
                                            null
                                        ? '0'
                                        : controller.allProductList[index]
                                                ['average_rating']
                                            .toString(),
                                  ),
                                  quantity: controller.allProductList[index]
                                              ['variant_ids'][0]['quantity'] ==
                                          null
                                      ? "Out of stock"
                                      : controller.allProductList[index]
                                              ['variant_ids'][0]['quantity']
                                          .toString(),
                                  keypressEvent: () {
                                    controller.gotProductDetails(index);
                                  },
                                  assetimage: controller.allProductList[index]
                                              ['featured_image'] !=
                                          null
                                      ? url +
                                          controller.allProductList[index]
                                                  ['featured_image']['filepath']
                                              .toString()
                                      : HelperFunctions.getNoImage(),
                                  productname: controller.allProductList[index]
                                          ['name']
                                      .toString(),
                                  discountprice:
                                      controller.allProductList[index]
                                                      ['variant_ids'][0]
                                                  ['sale_price'] ==
                                              null
                                          ? ''
                                          : controller.allProductList[index]
                                                  ['variant_ids'][0]['price']
                                              .toString(),
                                  productprice: controller.allProductList[index]
                                                  ['variant_ids'][0]
                                              ['sale_price'] ==
                                          null
                                      ? controller.allProductList[index]
                                              ['variant_ids'][0]['price']
                                          .toString()
                                      : controller.allProductList[index]
                                              ['variant_ids'][0]['sale_price']
                                          .toString(),
                                  discountrate: controller.allProductList[index]
                                                  ['variant_ids'][0]
                                              ['sale_price'] ==
                                          null
                                      ? ''
                                      : " (${(100 - controller.allProductList[index]['variant_ids'][0]['sale_price'] * 100 / controller.allProductList[index]['variant_ids'][0]['price']).round()}" +
                                          " %off)",
                                  height: Get.height * 0.3,
                                  width: Get.width,
                                );
                              });
                            },
                          );
                    // }
                  }),
                ),
                const SizedBox(height: 20),
                Obx(() => controller.isLoading.isTrue &&
                        controller.allProductList.isNotEmpty
                    ? HelperFunctions().loadingIndicator()
                    : Container()),
                const SizedBox(height: 30)
              ]))
            ],
          ),
        ),
      ),
    );
  }
}

class FilterPage extends StatelessWidget {
  final controller = Get.find<ShopController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text("Filters",
              style: txtTheme()
                  .titleLarge!
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: pageSurroundingPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Brand: ",
                          style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 2 / 0.5,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 15),
                          itemCount: controller.brads.length,
                          itemBuilder: ((context, index) {
                            return Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  controller.selectBrand.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                      child: Text(
                                          controller.brads[index]['brandname']
                                              .toString(),
                                          style: TextStyle(
                                            fontFamily: 'lato',
                                            fontSize: 14,
                                          ))),
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      const Text("Size:",
                          style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 2 / 0.7,
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 15),
                          itemCount: controller.size.length,
                          itemBuilder: ((context, index) {
                            return Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  controller.selectSize.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                      child: Text(
                                          controller.size[index]['size']
                                              .toString(),
                                          style: TextStyle(
                                            fontFamily: 'lato',
                                            fontSize: 14,
                                          ))),
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      const Text("Price:",
                          style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                      Obx(() {
                        return RangeSlider(
                          values: controller.currentRangeValues.value,
                          max: double.parse(
                              controller.filterMaxPrice.toString()),
                          divisions: 5,
                          labels: RangeLabels(
                            controller.currentRangeValues.value.start
                                .round()
                                .toString(),
                            controller.currentRangeValues.value.end
                                .round()
                                .toString(),
                          ),
                          onChanged: (RangeValues values) {
                            controller.updateSlider(values);
                          },
                        );
                      }),
                      const Text("Colors:",
                          style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 1 / 1,
                                  crossAxisCount: 7,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 15),
                          itemCount: controller.colorList.length,
                          itemBuilder: ((context, index) {
                            return Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  controller.selectedColor.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: controller.colorList[index]
                                          ['color'],
                                      borderRadius: BorderRadius.circular(50)),
                                  child: controller.selectedColor.value == index
                                      ? Icon(Icons.check)
                                      : SizedBox(),
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      SizedBox(height: 60)
                    ],
                  ),
                ),
              ),
            ),
            filterButton(
              reset: 'reset',
              filter: 'apply filter',
              pressEvnetFilter: () {
                print(controller.currentRangeValues.value.start);
                controller.allProductList.clear();
                controller.currentPage.value = 0;
                controller.maxPage.value = 0;
                controller.filterProducts();
                Get.back();
              },
              pressEvnetReset: () {
                controller.isFilter.value = false;
                Get.back();
                controller.onPullTorefresh();
              },
            )
          ],
        ),
      ),
    );
  }
}

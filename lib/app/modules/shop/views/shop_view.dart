// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_if_null_operators, prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
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
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
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
                Obx(() => Text(
                      controller.collectionName.value.toString() +
                          ' Collection',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'lato',
                        fontSize: 15,
                        color: context.onSurfaceColor, // Theme-aware title
                      ),
                    )),
                Obx(
                  () => Text(
                    controller.allProductList.length.toString() + ' items',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'lato',
                      fontSize: 12,
                      color:
                          context.onSurfaceVariantColor, // Theme-aware subtitle
                    ),
                  ),
                ),
              ],
            ),
            titleSpacing: 0,
            elevation: 0,
            backgroundColor:
                context.surfaceColor, // Theme-aware app bar background
            actions: [
              Obx(() => Get.find<BottombarController>().cartbadge(
                    child: HeartIcon(() {
                      if (!AuthDetails.isUserLogin()) {
                        // Show login dialog for non-logged in users
                        Get.dialog(
                          AlertDialog(
                            backgroundColor:
                                context.surfaceColor, // Theme-aware dialog
                            title: Text(
                              'Login Required',
                              style: TextStyle(color: context.onSurfaceColor),
                            ),
                            content: Text(
                              'Please login to view your wishlist',
                              style: TextStyle(
                                  color: context.onSurfaceVariantColor),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: context.onSurfaceVariantColor),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  isOtpLogin
                                      ? Get.toNamed(Routes.MOBILELOGIN)
                                      : Get.toNamed(Routes.LOGIN);
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(color: context.primaryColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Navigate to BottomBar's WishlistView (index 2)
                        final bottomBarController =
                            Get.find<BottombarController>();
                        bottomBarController.pageController.jumpToPage(2);
                        bottomBarController.currentPageIndex.value = 2;
                      }
                    }),
                    badgeNumber: Get.find<WishlistController>().wishList.length,
                  )),
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
          body: FoduuStudioLayoutView(
            widgetList: controller.widgetList,
            isLoading: controller.isLayoutLoading,
            onRefresh: () async {
              return;
            },
          )),
    );
  }
}

class FilterPage extends StatelessWidget {
  final controller = Get.find<ShopController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: context.surfaceColor, // Theme-aware
          title: Text(
            "Filters",
            style: txtTheme().titleLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.onSurfaceColor, // Theme-aware
                ),
          ),
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
                      Text(
                        "Brand: ",
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: context.onSurfaceColor, // Theme-aware
                        ),
                      ),
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
                              final isSelected =
                                  controller.selectBrand.value == index;
                              return GestureDetector(
                                onTap: () {
                                  controller.selectBrand.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: isSelected
                                        ? context.primaryColor.withOpacity(0.1)
                                        : context.surfaceVariantColor,
                                    border: Border.all(
                                      color: isSelected
                                          ? context.primaryColor
                                          : context.outlineColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      controller.brads[index]['brandname']
                                          .toString(),
                                      style: TextStyle(
                                        fontFamily: 'lato',
                                        fontSize: 14,
                                        color: isSelected
                                            ? context.primaryColor
                                            : context.onSurfaceColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      Text(
                        "Size:",
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: context.onSurfaceColor, // Theme-aware
                        ),
                      ),
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
                              final isSelected =
                                  controller.selectSize.value == index;
                              return GestureDetector(
                                onTap: () {
                                  controller.selectSize.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: isSelected
                                        ? context.primaryColor.withOpacity(0.1)
                                        : context.surfaceVariantColor,
                                    border: Border.all(
                                      color: isSelected
                                          ? context.primaryColor
                                          : context.outlineColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      controller.size[index]['size'].toString(),
                                      style: TextStyle(
                                        fontFamily: 'lato',
                                        fontSize: 14,
                                        color: isSelected
                                            ? context.primaryColor
                                            : context.onSurfaceColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      Text(
                        "Price:",
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: context.onSurfaceColor, // Theme-aware
                        ),
                      ),
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
                          activeColor: context.primaryColor, // Theme-aware
                          inactiveColor: context.outlineColor, // Theme-aware
                        );
                      }),
                      Text(
                        "Colors:",
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: context.onSurfaceColor, // Theme-aware
                        ),
                      ),
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
                              final isSelected =
                                  controller.selectedColor.value == index;
                              return GestureDetector(
                                onTap: () {
                                  controller.selectedColor.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: controller.colorList[index]['color'],
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: isSelected
                                          ? context.primaryColor
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: context.onPrimaryColor,
                                          size: 16,
                                        )
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

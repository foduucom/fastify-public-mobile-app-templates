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
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
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
              // Obx(() => Get.find<BottombarController>().cartbadge(
              //     child: HeartIcon(() {
              //       Get.toNamed(Routes.WISHLIST);
              //     }),
              //     badgeNumber: Get.find<WishlistController>().wishList.length)),

              // In your shop_view.dart where you have the HeartIcon
              Obx(() {
                final wishlistService = Get.find<WishListService>();
                final bottomBarController = Get.find<BottombarController>();

                return bottomBarController.cartbadge(
                  child: HeartIcon(
                    () {
                      if (!AuthDetails.isUserLogin()) {
                        // Show login dialog for non-logged in users
                        Get.dialog(
                          AlertDialog(
                            title: Text('Login Required'),
                            content: Text('Please login to view your wishlist'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  isOtpLogin
                                      ? Get.toNamed(Routes.MOBILELOGIN)
                                      : Get.toNamed(Routes.LOGIN);
                                },
                                child: Text('Login'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Navigate to BottomBar's WishlistView (index 2)
                        bottomBarController.pageController.jumpToPage(2);
                        bottomBarController.currentPageIndex.value = 2;
                      }
                    },
                  ),
                  badgeNumber: wishlistService
                      .wishListItemCount, // Using wishListItemCount from service
                );
              }),

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

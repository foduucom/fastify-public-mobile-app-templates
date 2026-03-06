// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_if_null_operators, prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:get/get.dart';

class ShopView extends GetView<ShopController> {
  final shopController = Get.lazyPut<ShopController>(() => ShopController());
  final wishlistController = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // controller.
            },
          ),
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
                    controller.widgetList.length.toString(),
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
            // actions: [
            //   Obx(() => Get.find<BottombarController>().cartbadge(
            //       child: HeartIcon(() {
            //         Get.toNamed(Routes.WISHLIST);
            //       }),
            //       badgeNumber:
            //           Get.find<WishlistController>().wishlistItems.length)),
            //   SizedBox(width: 14),
            //   Get.find<BottombarController>().cartbadge(
            //       child: CartIcon(() {
            //         Get.toNamed(Routes.CART);
            //       }),
            //       badgeNumber: 0),
            //   SizedBox(width: 15)
            // ],
          ),
          body: FoduuStudioLayoutView(
            widgetList: controller.widgetList,
            isLoading: controller.isLayoutLoading,
            onRefresh: () async {
              return controller.fetchLayout('product-listing');
            },
          )),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CartView extends GetView<CartController> {
  CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          child: Column(
            children: [
              SizedBox(height: height * 0.01),
              SecondaryAppHeader(
                title: "My Cart",
              ),
              SizedBox(height: height * 0.001),
              Expanded(
                child: Obx(() {
                  if (controller.productDetails.isEmpty) {
                    return _buildEmptyCart(width, height);
                  }
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.productDetails.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: height * 0.025),
                    itemBuilder: (context, index) {
                      return _cartItemRow(index);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(() => controller.productDetails.isEmpty
            ? const SizedBox.shrink()
            : _bottombar(width: width, height: height)),
      ),
    );
  }

  Widget _buildEmptyCart(double width, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/lotti/emptyanimation.json', height: height * 0.3),
        const SizedBox(height: 20),
        const Text('Whoops !! Cart is Empty',
            style: TextStyle(
                fontFamily: 'lato', fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        const SizedBox(
            width: 320,
            child: Text(
                'Looks like you haven’t added anything to your cart yet. You will find a lot of interesting products on our “Shop” page',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'lato', fontSize: 16))),
        const SizedBox(height: 20),
        AppButton(
            itemText: 'START SHOPPING',
            keypressEvent: () {
              Get.back();
              Get.find<BottombarController>().currentPageIndex.value = 0;
              Get.find<BottombarController>().pageController.jumpToPage(0);
            })
      ],
    );
  }

  Widget _bottombar({required width, required height}) {
    return Container(
      width: width,
      height: height * 0.42,
      padding: EdgeInsets.all(width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.90,
            height: height * 0.06,
            padding: EdgeInsets.all(width * 0.025),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.01),
              border: Border.all(color: DefaultThemeColors.darklight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.couponController,
                    decoration: const InputDecoration(
                      hintText: "Enter Promo Code",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.018,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.couponController.text.isNotEmpty) {
                      controller.applyCoupon(
                          coupon: controller.couponController.text);
                    }
                  },
                  child: Text(
                    "Apply",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.018,
                      fontWeight: FontWeight.w600,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.015),
          SizedBox(
            width: width * 0.90,
            height: height * 0.18,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _priceRow("Subtotal", "₹${controller.viewprice.value}"),
                _priceRow("Delivery Fee", "Free"),
                _priceRow("Discount", "₹${controller.viewsavedPrice.value}"),
                _priceRow("Total", "₹${controller.viewTotalAmount.value}",
                    isBold: true),
              ],
            ),
          ),
          SizedBox(height: height * 0.015),
          PrimaryActionButton(
            text: "CheckOut",
            onPressed: () {
              Get.toNamed(Routes.CHECKOUT);
            },
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value, {bool isBold = false}) {
    final height = Get.height;
    final width = Get.width;

    return SizedBox(
      width: width * 0.90,
      height: height * 0.035,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.02,
              fontWeight: FontWeight.w500,
              color: DefaultThemeColors.darklighter,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.02,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItemRow(int index) {
    final width = Get.width;
    final height = Get.height;
    var product = controller.productDetails[index];
    var variantName = AuthDetails.isUserLogin()
        ? controller.cartProducts[index]['value']['variant_name'] ?? ''
        : controller.guestUserCartList[index]['variant_name'] ?? '';

    var imageUrl = product['featured_image'] == null
        ? HelperFunctions.getNoImage()
        : url + product['featured_image']['filepath'];

    var price = controller.getVariantPrice(index);
    var quantity = AuthDetails.isUserLogin()
        ? controller.cartProducts[index]['value']['quantity']
        : controller.guestUserCartList[index]['quantity'];

    return Container(
      width: width * 0.92,
      height: height * 0.11,
      padding: EdgeInsets.all(width * 0.026),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.015),
        border: Border.all(
          color: DefaultThemeColors.darklight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.PRODUCTDETAILS,
                  arguments: {'productId': product['_id']});
            },
            child: Container(
              width: height * 0.085,
              height: height * 0.085,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.012),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: width * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product['name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: height * 0.018,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (variantName.isNotEmpty && variantName != 'null')
                  Text(
                    variantName,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.014,
                      fontWeight: FontWeight.w400,
                      color: DefaultThemeColors.darklight,
                    ),
                  ),
                Text(
                  "₹$price",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: height * 0.016,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: width * 0.015),
          Container(
            width: height * 0.115,
            height: height * 0.035,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    controller.updateQuantity(index, quantity - 1);
                  },
                  child: Container(
                    width: height * 0.035,
                    height: height * 0.035,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DefaultThemeColors.darklight,
                      ),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: height * 0.018,
                    ),
                  ),
                ),
                Text(
                  "$quantity",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: height * 0.015,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    controller.updateQuantity(index, quantity + 1);
                  },
                  child: Container(
                    width: height * 0.035,
                    height: height * 0.035,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: DefaultThemeColors.darklight),
                    ),
                    child: Icon(
                      Icons.add,
                      size: height * 0.018,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              controller.removeCartProduct(
                  productId: product['_id'], index: index);
            },
            icon: Icon(Icons.delete_outline,
                size: height * 0.024, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

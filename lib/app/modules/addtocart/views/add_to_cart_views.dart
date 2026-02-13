import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class AddToCartViews extends GetView {
  const AddToCartViews({super.key});

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.02,
        ),
        child: Column(
          children: [
            SizedBox(height: height * 0.02),
            SecondaryAppHeader(
              title: "My Cart",
            ),
            SizedBox(height: height * 0.001),
            Container(
              width: width * 0.92, // ≈ 345
              height: height * 0.35, // ≈ 280
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: 3, // more in future
                separatorBuilder: (_, __) =>
                    SizedBox(height: height * 0.025), // ≈ gap 20
                itemBuilder: (context, index) {
                  return _cartItemRow();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottombar(width: width, height: height),
    );
  }

  Widget _bottombar({required width, required height}) {
    return Container(
      width: width, // ≈ 393
      height: height * 0.395, // ≈ 316
      padding: EdgeInsets.all(width * 0.05), // ≈ 20
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.90, // ≈ 353
            height: height * 0.06, // ≈ 48
            padding: EdgeInsets.all(width * 0.025), // ≈ 10
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.01), // ≈ 8
              border: Border.all(color: DefaultThemeColors.darklight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "ASR6744",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.02, // ≈ 16
                      fontWeight: FontWeight.w500,
                      height: 1.75, // ≈ 28
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: width * 0.01), // Add some spacing
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: height * 0.02, // ≈ 16
                      color: DefaultThemeColors.alertSuccessLight,
                    ),
                    SizedBox(width: width * 0.01), // gap 4
                    Text(
                      "Available",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: height * 0.018, // ≈ 14
                        fontWeight: FontWeight.w500,
                        height: 1.4, // ≈ 20
                        color: DefaultThemeColors.alertSuccessLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: height * 0.015), // gap 12
          SizedBox(
            width: width * 0.90, // ≈ 353
            height: height * 0.18, // ≈ 144
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _priceRow("Subtotal", "\$260,51"),
                _priceRow("Delivery Fee", "\$35"),
                _priceRow("Discount", "\$50,00"),
                _priceRow("Total", "\$245,51", isBold: true),
              ],
            ),
          ),

          SizedBox(height: height * 0.015), // gap 12

          PrimaryActionButton(
            text: "CheckOut",
            onPressed: () {
              Get.toNamed(Routes.CHECKOUT);
              // checkout logic
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
      width: width * 0.90, // ≈ 353
      height: height * 0.035, // ≈ 28
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.02, // ≈ 16
              fontWeight: FontWeight.w500,
              height: 1.75,
              color: DefaultThemeColors.darklighter,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.02, // ≈ 16
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w700,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItemRow() {
    final width = Get.width;
    final height = Get.height;

    return Container(
      width: width * 0.92,
      height: height * 0.10,
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
          Container(
            width: height * 0.075,
            height: height * 0.075,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.012),
              image: const DecorationImage(
                image: AssetImage("assets/images/shopping_image_1.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: width * 0.025),

          Expanded(
            child: Container(
              height: height * 0.075,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      "Oliver Blazer New Version",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    "Size : M",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.015,
                      fontWeight: FontWeight.w400,
                      color: DefaultThemeColors.darklight,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    "1 x \$85,23",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.015,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: width * 0.015), // Reduced spacing

          // QUANTITY SELECTOR - FIXED VERSION
          Container(
            width: height * 0.115, // Fixed width based on height, NOT width
            height: height * 0.035,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minus
                Container(
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

                // Quantity
                Container(
                  width: height * 0.035,
                  height: height * 0.035,
                  alignment: Alignment.center,
                  child: Text(
                    "1",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.015,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // Plus
                Container(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/payment/controllers/payment_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/buttons/bottombutton.dart';
import 'package:zouhi/components/oderdetail.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';

import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class PaymentView extends GetView<PaymentController> {
  PaymentView({Key? key}) : super(key: key);

  final cartController = Get.put(CartController());

  // Helper method to get payment method icon
  String getPaymentIcon(String paymentName) {
    switch (paymentName.toLowerCase()) {
      case 'stripe':
        return 'assets/icon/card.svg';
      case 'paypal':
        return 'assets/icon/wallet.svg';
      case 'razorpay':
        return 'assets/icon/banking.svg';
      case 'pesapal':
        return 'assets/icon/wallet.svg';
      case 'cod':
        return 'assets/icon/banking.svg';
      default:
        return 'assets/icon/banking.svg';
    }
  }

  // Helper method to get payment method display name
  String getPaymentDisplayName(String paymentName) {
    switch (paymentName.toLowerCase()) {
      case 'stripe':
        return 'Stripe';
      case 'paypal':
        return 'PayPal';
      case 'razorpay':
        return 'Razorpay';
      case 'pesapal':
        return 'Pesapal';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return paymentName.capitalizeFirst ?? paymentName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Details',
                  style: txtTheme().headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: context.themeTextColor)),
              Text('Step 3 of 3',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: context.themeSecondrytext))
            ],
          ),
          iconTheme: IconThemeData(
            color: context.themeTextColor,
          ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: context.themeTextColor,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => controller.paymentOptions.isEmpty
                                // () => true
                                ? PaymentMethodShimmer()
                                : ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 10),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: controller.paymentOptions.length,
                                    itemBuilder: ((context, index) {
                                      var paymentOption =
                                          controller.paymentOptions[index];
                                      var paymentName =
                                          paymentOption['name'] ?? '';

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: GestureDetector(
                                          onTap: (() {
                                            controller.selectedIndex.value =
                                                index;
                                            controller.deliveryOption.value =
                                                controller
                                                    .paymentOptions[index];
                                          }),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                color: context.themegreyColor),
                                            child: Obx(() {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 10),
                                                    SvgPicture.asset(
                                                        getPaymentIcon(
                                                            paymentName),
                                                        width: 20,
                                                        colorFilter: ColorFilter.mode(
                                                            context.themeTextColor,
                                                            BlendMode.srcIn)),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                        child: Text(
                                                            getPaymentDisplayName(
                                                                paymentName),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'lato',
                                                                fontSize: 16,
                                                                color:
                                                                    context.themeTextColor))),
                                                    Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              context.themeWhiteColor,
                                                          borderRadius:
                                                              BorderRadiusDirectional
                                                                  .circular(50),
                                                          border: Border.all(
                                                              width: 2,
                                                              color:
                                                                  context.themeBorderColor)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6.0),
                                                        child: Container(
                                                          height: 7.0,
                                                          width: 7.0,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: controller
                                                                          .selectedIndex
                                                                          .value ==
                                                                      index
                                                                  ? themeRedColor
                                                                  : context.themeWhiteColor),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      );
                                    })),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Order Note',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: context.themeTextColor,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: controller.noteController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add a note for this order...',
                              hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: context.themeSecondrytext),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: context.themeBorderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: context.themeBorderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: themeRedColor),
                              ),
                              fillColor: context.themegreyColor,
                              filled: true,
                            ),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: context.themeTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 10,
                      color: context.themegreyColor,
                    ),
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Order Details:",
                              style: txtTheme()
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.bold, color: context.themeTextColor)),
                          SizedBox(height: 10),

                          Obx(() {
                            var cartCtrl = cartController;
                            double exchangeRate =
                                (controller.selectedCurrency['exchange_rate']
                                            as num?)
                                        ?.toDouble() ??
                                    1.0;
                            String symbol = controller
                                    .selectedCurrency['symbol']
                                    ?.toString() ??
                                currency;

                            double originalBagTotal =
                                double.tryParse(cartCtrl.viewPrice.value) ??
                                    0.0;
                            double itemSavings = double.tryParse(
                                    cartCtrl.viewSavedPrice.value) ??
                                0.0;
                            double couponDiscountAmount = double.tryParse(
                                    cartCtrl.couponDiscountAmount.value) ??
                                0.0;
                            double subTotal = double.tryParse(
                                    cartCtrl.viewSubTotalAmount.value) ??
                                0.0;
                            double taxableValue =
                                subTotal - couponDiscountAmount;
                            double totalTaxAmount =
                                cartCtrl.tax.value * exchangeRate;
                            double finalTotal = double.tryParse(
                                    cartCtrl.viewTotalAmount.value) ??
                                0.0;

                            List<ItemTaxBreakdown> breakdown =
                                cartCtrl.taxBreakdownList.map((e) {
                              double itemTaxAmount = (double.tryParse(
                                          e['tax_amount']?.toString() ?? '0') ??
                                      0.0) *
                                  exchangeRate;
                              return ItemTaxBreakdown(
                                name: e['name']?.toString() ?? 'Product',
                                taxPercent: double.tryParse(
                                        e['tax_percent']?.toString() ?? '0') ??
                                    0.0,
                                taxAmount: itemTaxAmount,
                              );
                            }).toList();

                            return PriceBreakdownWidget(
                              originalBagTotal: originalBagTotal,
                              itemSavings: itemSavings,
                              couponCode: cartCtrl.viewCouponCode.value ==
                                      'Apply Coupon'
                                  ? ''
                                  : cartCtrl.viewCouponCode.value,
                              couponDiscountPrefix:
                                  cartCtrl.viewCouponPrefix.value,
                              couponDiscountAmount: couponDiscountAmount,
                              taxableValue: taxableValue,
                              totalTaxAmount: totalTaxAmount,
                              itemTaxBreakdown: breakdown,
                              finalTotal: finalTotal,
                              isLoading: controller.paymentOptions.isEmpty,
                              currencySymbol: symbol,
                            );
                          }),
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Obx(() {
              double exchangeRate =
                  (controller.selectedCurrency['exchange_rate'] as num?)
                          ?.toDouble() ??
                      1.0;
              String symbol =
                  controller.selectedCurrency['symbol']?.toString() ?? currency;
              double convertedTotal =
                  double.tryParse(cartController.viewTotalAmount.value) ?? 0.0;

              return bottomButton(
                totalAmount: cartController.viewTotalAmount.value,
                opacity: 1,
                buttonText: 'Pay Now',
                isLoading: controller.isOrderLoading.value,
                priceText: convertedTotal.toStringAsFixed(2),
                currencySymbol: symbol,
                exchangeRate: exchangeRate,
                keypressEvent: () async {
                  try {
                    controller.processOrder();
                  } catch (e) {
                    print('Error during payment process: $e');
                  }
                },
                otherText: 'View details',
              );
            })
          ],
        ),
      ),
    );
  }
}

class PaymentMethodShimmer extends StatelessWidget {
  const PaymentMethodShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        enabled: true,
        direction: ShimmerDirection.ltr,
        loop: 0,
        period: Duration(seconds: 1),
        baseColor: context.isDark ? Colors.grey[800]! : context.themegreyColor,
        highlightColor: context.isDark ? Colors.grey[700]! : const Color.fromARGB(255, 197, 197, 197),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: context.themegreyColor),
                borderRadius: BorderRadius.circular(3),
              ),
              width: Get.width,
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.horizontal,
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: context.themegreyColor,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                            color: context.themegreyColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ],
                  ),
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: context.themegreyColor,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: context.themegreyColor),
                borderRadius: BorderRadius.circular(3),
              ),
              width: Get.width,
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.horizontal,
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: context.themegreyColor,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                            color: context.themegreyColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ],
                  ),
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: context.themegreyColor,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}


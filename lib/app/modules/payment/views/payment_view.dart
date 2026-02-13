// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/payment/controllers/payment_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/bottombutton.dart';
import 'package:foduu_ecommerce/components/oderdetail.dart';
import 'package:foduu_ecommerce/components/shimmer_effects.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';

import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class PaymentView extends GetView<PaymentController> {
  PaymentView({Key? key}) : super(key: key);

  final cartController = Get.find<CartController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Details',
                  style: txtTheme().titleLarge!.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: 'Lato')),
              Text('Step 3 of 3',
                  style: TextStyle(
                    fontFamily: 'lato',
                    fontSize: 12,
                    // color: themeSecondrytext
                  ))
            ],
          ),
          iconTheme: const IconThemeData(
            color: Colors.black,
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
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 20),
                          Obx(
                            () => controller.isShippingLoading.value &&
                                    controller.paymentOptions.isEmpty
                                // () => true
                                ? PaymentMethodShimmer()
                                : ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 10),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: controller.paymentOptions.length,
                                    itemBuilder: ((context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: GestureDetector(
                                          onTap: (() {
                                            HelperFunctions()
                                                .showOverlayLoader();

                                            controller.selectedIndex.value =
                                                index;
                                            controller.deliveryOption.value =
                                                controller
                                                    .paymentOptions[index];
                                            controller
                                                .getShippingDetails()
                                                .then((value) =>
                                                    Get.until((route) {
                                                      return !Get.isDialogOpen!;
                                                    }));
                                          }),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              // color: themegreyColor
                                            ),
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
                                                        controller.paymentOptions[
                                                                        index]
                                                                    ['name'] ==
                                                                'paypal'
                                                            ? controller
                                                                    .paymentMethod[
                                                                0]['image']
                                                            : controller.paymentOptions[
                                                                            index]
                                                                        [
                                                                        'name'] ==
                                                                    'phonepay'
                                                                ? controller
                                                                        .paymentMethod[
                                                                    1]['image']
                                                                : controller
                                                                        .paymentMethod[
                                                                    2]['image'],
                                                        width: 20),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                        child: Text(
                                                            controller
                                                                .paymentOptions[
                                                                    index]
                                                                    ['name']
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'lato',
                                                              fontSize: 16,
                                                              // color:
                                                              //     themeTextColor
                                                            ))),
                                                    Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                          // color:
                                                          //     themeWhiteColor,
                                                          borderRadius:
                                                              BorderRadiusDirectional
                                                                  .circular(50),
                                                          border: Border.all(
                                                            width: 2,
                                                            // color:
                                                            //     themeBorderColor
                                                          )),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6.0),
                                                        child: Container(
                                                          height: 7.0,
                                                          width: 7.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            // color: controller
                                                            //             .selectedIndex
                                                            //             .value ==
                                                            //         index
                                                            //     ? themeRedColor
                                                            //     : themeWhiteColor
                                                          ),
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
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 10,
                      // color: themegreyColor,
                    ),
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Order Details:",
                              style: txtTheme()
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          // Obx(
                          //   () =>
                          // orderDetial(
                          // couponPrefix: cartController.couponDetails
                          //         .containsKey('coupon_type')
                          //     ? cartController.couponDetails['coupon_type'] ==
                          //             'fixAmount'
                          //         ? '(\u{20B9}${cartController.couponDetails['discount_value']})'
                          //         : '(%${cartController.couponDetails['discount_value'].toString()})'
                          //     : '',
                          //   price: AuthDetails.isUserLogin()
                          //       ? cartController.otherCartDetails['total']
                          //           .toString()
                          //       : cartController.bagpriceAmount.value
                          //           .toString(),
                          //   savedPrice: AuthDetails.isUserLogin()
                          //       ? (cartController.otherCartDetails['total'] -
                          //               cartController
                          //                   .otherCartDetails['subtotal'])
                          //           .toString()
                          //       : cartController.discountAmount.value
                          //           .toString(),
                          //   cuponValue: cartController
                          //               .couponDetails['message'] ==
                          //           'Applyed'
                          //       ? '-\u{20B9}${cartController.couponDetails['discount_amount']}'
                          //       : 'Apply Coupon',
                          //   deliveryStatus: controller
                          //               .shipping_details['shipping_charge'] ==
                          //           null
                          //       ? '0.00'
                          //       : controller.shipping_details['shipping_charge']
                          //           .toString(),
                          //   totalAmount: AuthDetails.isUserLogin()
                          //       ? (cartController.otherCartDetails['total'] -
                          //               (cartController
                          //                       .otherCartDetails['total'] -
                          //                   cartController
                          //                       .otherCartDetails['subtotal']) -
                          //               (cartController.couponDetails
                          //                       .containsKey('discount_amount')
                          //                   ? cartController.couponDetails[
                          //                       'discount_amount']
                          //                   : 0))
                          //           .toString()
                          //       : cartController.totalAmount.toString(),
                          // ),

                          Obx(
                            () => orderDetial(
                              isLoading: controller.isShippingLoading.value &&
                                  controller.paymentOptions.isEmpty,
                              couponPrefix: controller.couponPrefix.value,
                              price: controller.price.value,
                              savedPrice: controller.savedPrice.value,
                              cuponValue: controller.couponAmount.value ==
                                      '0.00'
                                  ? 'Apply Coupon'
                                  : '-\u{20B9}${controller.couponAmount.value}',
                              deliveryStatus:
                                  '\u{20B9}${controller.shipping_details['shipping_charge'].toString()}',
                              totalAmount: controller.totalAmount.value,
                            ),
                          ),
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Obx(
              () => bottomButton(
                totalAmount: controller.totalAmount.value,
                opacity: controller.isShippingLoading.value ? 0.5 : 1,
                deliveryAmount:
                    controller.shipping_details['shipping_charge'].toString(),
                buttonText: 'Pay Now',
                priceText: controller.totalAmount.value,
                keypressEvent: () async {
                  if (!controller.isShippingLoading.value) {
                    var selectedMethod = controller
                        .paymentOptions[controller.selectedIndex.value];
                    var paymentName = selectedMethod['name'];

                    if (paymentName == 'Cash On Delivery') {
                      HelperFunctions().showOverlayLoader();
                      await controller.createOrderCOd().then((id) {
                        if (id != null) {
                          Future.delayed(Duration(seconds: 2)).then((value) {
                            if (value != null) {
                              if (Get.isDialogOpen!) {
                                Get.back();
                              }
                            }
                            return Get.offNamedUntil(Routes.ORDERSUCCESS,
                                ModalRoute.withName(Routes.BOTTOMBAR),
                                arguments: {'id': id});
                          });
                        } else {
                          Get.until((route) => !Get.isDialogOpen!);
                          HelperFunctions()
                              .showSnackBarError('Something Went Wrong');
                        }
                      });
                    } else if (paymentName == 'phonepe') {
                      try {
                        controller.startPhonePay(
                            phonePayIndex: selectedMethod['value']
                                ['phonepe_index'],
                            phonePaySaltkey: selectedMethod['value']
                                ['phonepe_salt_key'],
                            phonepeMerchantId: selectedMethod['value']
                                ['phonepe_merchant_id']);
                      } catch (e) {
                        print('error phone pay ${e}');
                      }
                    } else if (paymentName == 'stripe') {
                      // controller.makeStripePayment();
                    } else {
                      var beforeOrderID = await controller.createOrder();
                    }
                  }
                  // print((double.parse(controller.totalAmount.value)
                  //     .toStringAsFixed(2)));
                  // controller.getShippingDetails();

                  // Get.to(PhonePayPaymentPage());
                  // Get.to(MerchantApp());
                },
                otherText: 'View details',
              ),
            )
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
    print('payment buidl EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');
    return Shimmer.fromColors(
        enabled: true,
        direction: ShimmerDirection.ltr,
        loop: 0,
        period: Duration(seconds: 1),
        baseColor: Theme.of(context).primaryColor,
        highlightColor: Color.fromARGB(255, 197, 197, 197),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(),
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
                            // color: themegreyColor,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                            // color: themegreyColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ],
                  ),
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        // color: themegreyColor,
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
                border: Border.all(),
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
                            // color: themegreyColor,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                            // color: themegreyColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ],
                  ),
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        // color: themegreyColor,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
